local isSpawned, isDead = false, false
local vehicles, customers = {}, {}
local inMenu = false

buddy = {}
buddyBlip = {}
jobBlip = {}

local vehData = {
    NetId = nil,
    Plate = nil,
    VehId = nil
}

-- SYNC + START [create peds, circlezones]
Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            TriggerServerEvent("job_post:sync")
        end
        for po, data in pairs(Config.Posts) do
            exports.target:AddCircleZone(
                "postMaster_" .. po,
                Config.Posts[po].Coords.xyz,
                1.0,
                {
                    actions = {
                        job = {
                            cb = function()
                                if not WarMenu.IsAnyMenuOpened() then
                                    if exports.license:hasLicense(Config.licenseNeeded, true) then
                                        openMenu(po)
                                    else 
                                        exports.notify:display(
                                            {
                                                type = "error",
                                                title = "Post OP | " .. po,
                                                text = "Nemáte řidičské oprávnění skupiny " .. Config.licenseNeeded,
                                                icon = "fas fa-envelope",
                                                length = 3000
                                            }
                                        )
                                    end
                                end
                            end,
                            icon = "fas fa-envelope",
                            label = "Oslovit chlapíka"
                        }
                    },
                    distance = 0.2
                }
            )
            checkMisc(po)
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")

            if not isSpawned then
                isSpawned = true
                for po, data in pairs(Config.Posts) do 
                    checkMisc(po)
                end
                TriggerServerEvent("job_post:sync")
            end
        end
    end
)

RegisterNetEvent("job_post:sync")
AddEventHandler(
    "job_post:sync",
    function(serverVehs, serverCust)
        vehicles = serverVehs
        customers = serverCust
    end
)

function openMenu(postoffice)
    Citizen.CreateThread(
        function()
            WarMenu.CreateMenu("post", "Post OP | " .. postoffice, "Zvolte akci")
            WarMenu.OpenMenu("post")

            if not vehData.VehId then
                while true do
                    if WarMenu.IsMenuOpened("post") then
                        if WarMenu.Button("Nové vozidlo") then
                            if isVehPlaceClean(postoffice) then
                                TriggerServerEvent("job_post:createNewVehicle", postoffice)
                                WarMenu.CloseMenu()
                            else
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Post OP | " .. postoffice,
                                        text = "Momentálně není nikde místo pro další vozidlo..",
                                        icon = "fas fa-envelope",
                                        length = 3000
                                    }
                                )
                            end
                        elseif WarMenu.Button("Zavřít") then
                            WarMenu.CloseMenu()
                        end
                        WarMenu.Display()
                    else
                        break
                    end

                    Citizen.Wait(0)
                end
            else
                while true do
                    if WarMenu.IsMenuOpened("post") then
                        if vehicles[vehData.VehId].Players[1] == GetPlayerServerId(PlayerId()) then
                            if WarMenu.Button("Nabrat kámoše") then
                                if tableLength(vehicles[vehData.VehId].Players) < 4 then
                                    WarMenu.CloseMenu()
                                    Citizen.Wait(10)
                                    TriggerEvent(
                                        "util:closestPlayer",
                                        {
                                            radius = 2.0
                                        },
                                        function(player)
                                            if player then
                                                TriggerServerEvent("job_post:addPlayerToVeh", vehData, player, postoffice)
                                            end
                                        end
                                    )
                                else
                                    exports.notify:display(
                                        {
                                            type = "error",
                                            title = "Post OP | " .. postoffice,
                                            text = "Už u sebe máš plno!",
                                            icon = "fas fa-envelope",
                                            length = 3000
                                        }
                                    )
                                end
                            end
                        end
                        if WarMenu.Button("Převléknout se") then
                            if not savedOutfit then
                                savedOutfit = exports.skinchooser:getPlayerOutfit()
                                local sex = exports.skinchooser:getPlayerSex() == 0 and "male" or "female"
                                exports.skinchooser:setPlayerOutfit(Config.Outfits[sex])
                            else
                                exports.skinchooser:setPlayerOutfit(savedOutfit)
                                savedOutfit = nil
                            end
                        elseif WarMenu.Button("Ukončit práci") then
                            TriggerServerEvent("job_post:endJob", vehData.VehId, postoffice)
                            WarMenu.CloseMenu()
                        elseif WarMenu.Button("Vzít dopisy") then
                            takePackages("letter")
                        elseif WarMenu.Button("Vzít malé balíky") then
                            takePackages("small")
                        elseif WarMenu.Button("Vzít střední balíky") then
                            takePackages("middle")
                        elseif WarMenu.Button("Vzít velké balíky") then
                            takePackages("big")
                        elseif WarMenu.Button("Zavřít") then
                            WarMenu.CloseMenu()
                        end
                        WarMenu.Display()
                    else
                        break
                    end

                    Citizen.Wait(0)
                end
            end
        end
    )
end

RegisterNetEvent("job_post:startWork")
AddEventHandler(
    "job_post:startWork",
    function(vehId, postoffice)
        if spawnVehicle(vehId, postoffice) == "done" then
            exports.notify:display(
                {
                    type = "success",
                    title = "Post OP | " .. postoffice,
                    text = "Dostal jsi vozidlo s SPZ " .. vehData.Plate .. ".",
                    icon = "fas fa-envelope",
                    length = 3000
                }
            )
            exports.target:AddTargetVehicleBone(
                {"seat_dside_r", "seat_pside_r"},
                {
                    actions = {
                        trunk = {
                            cb = function(vehicleDoorData)
                                exports.rp:openTrunk(vehicleDoorData.entity)
                            end,
                            icon = "fas fa-box",
                            label = "Použít kufr"
                        }
                    },
                    netId = vehData.NetId,
                    distance = 2.0
                }
            )
            startWork(vehId, postoffice)
        end
    end
)

function startWork(vehId, postoffice)
    exports.target:AddCircleZone(
        "post_delivery",
        customers[postoffice][vehicles[vehId].Current.Id].Coords.xyz,
        1.0,
        {
            actions = {
                deliver = {
                    cb = function(delivery)
                        TriggerServerEvent("job_post:deliveryPackage", delivery.Id, postoffice)
                    end,
                    cbData = {Id = vehId},
                    icon = "fas fa-envelope",
                    label = "Odevzdat zásilku"
                }
            },
            distance = 0.2
        }
    )
    jobBlip[postoffice] =
        createNewBlip(
        {
            coords = customers[postoffice][vehicles[vehId].Current.Id].Coords.xyz,
            sprite = 280,
            display = 4,
            scale = 0.7,
            colour = 24,
            isShortRange = true,
            text = "Zákazník - " .. exports.inventory:getItem(vehicles[vehId].Current.Type).label
        }
    )
    SetNewWaypoint(customers[postoffice][vehicles[vehId].Current.Id].Coords)
end

function takePackages(type)
    exports.input:openInput(
        "number",
        {title = "Zadejte počet, který chcete", placeholder = "0 - 100"},
        function(count)
            if not count or count == "" then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Post OP",
                        text = "Musíš zadat správný počet!",
                        icon = "fas fa-envelope",
                        length = 3500
                    }
                )
            else
                count = tonumber(count)
                TriggerServerEvent("job_post:getPackages", type, count)
            end
        end
    )
    WarMenu.CloseMenu()
end

RegisterNetEvent("job_post:nextDelivery")
AddEventHandler(
    "job_post:nextDelivery",
    function(vehId, postoffice)
        local item = string.lower(exports.inventory:getItem(vehicles[vehId].Current.Type).label)
        exports.notify:display(
            {
                type = "success",
                title = "Post OP | " .. postoffice,
                text = "Jeďte na další místo! Chtějí " .. item,
                icon = "fas fa-envelope",
                length = 4000
            }
        )

        exports.target:AddCircleZone(
            "post_delivery",
            customers[postoffice][vehicles[vehId].Current.Id].Coords.xyz,
            1.0,
            {
                actions = {
                    deliver = {
                        cb = function(delivery)
                            TriggerServerEvent("job_post:deliveryPackage", delivery.Id, postoffice)
                        end,
                        cbData = {Id = vehId},
                        icon = "fas fa-envelope",
                        label = "Odevzdat zásilku"
                    }
                },
                distance = 0.2
            }
        )
        SetBlipCoords(jobBlip[postoffice], customers[postoffice][vehicles[vehId].Current.Id].Coords.xyz)
        renameExistingBlip({blip = jobBlip[postoffice], text = "Zákazník - " .. item})
        SetNewWaypoint(customers[postoffice][vehicles[vehId].Current.Id].Coords)
    end
)

RegisterNetEvent("job_post:noMoreDelivery")
AddEventHandler(
    "job_post:noMoreDelivery",
    function(postoffice)
        exports.notify:display(
            {
                type = "error",
                title = "Post OP | " .. postoffice ,
                text = "Nemáme již žádné zakázky. Vrať se zpátky.",
                icon = "fas fa-envelope",
                length = 4000
            }
        )
        exports.target:RemoveZone("post_delivery")
        RemoveBlip(jobBlip[postoffice])
    end
)

RegisterNetEvent("job_post:AddPlayerToVeh")
AddEventHandler(
    "job_post:AddPlayerToVeh",
    function(newVehData, postoffice)
        if not vehData.VehId then
            vehData = newVehData
            startWork(vehData.VehId, postoffice)
            exports.notify:display(
                {
                    type = "success",
                    title = "Post OP | " .. postoffice,
                    text = "Kámoš tě přidal! Máš SPZ " .. vehData.Plate .. ".",
                    icon = "fas fa-envelope",
                    length = 3000
                }
            )
        end
    end
)

RegisterNetEvent("job_post:endJob")
AddEventHandler(
    "job_post:endJob",
    function(postoffice)
        if vehData.VehId then
            RemoveBlip(jobBlip[postoffice])
            exports.target:RemoveZone("post_delivery")
            vehData = {
                NetId = nil,
                Plate = nil,
                VehId = nil
            }
            if savedOutfit then
                exports.skinchooser:setPlayerOutfit(savedOutfit)
                savedOutfit = nil
            end
            exports.notify:display(
                {
                    type = "success",
                    title = "Post OP | " .. postoffice,
                    text = "Odešel jsi z práce..",
                    icon = "fas fa-envelope",
                    length = 3000
                }
            )
        end
    end
)

-- MISCS

function checkMisc(postoffice)
    if not DoesEntityExist(buddy[postoffice]) then
        createBuddy(postoffice)
    end
    if not DoesBlipExist(buddyBlip[postoffice]) then
        
        buddyBlip[postoffice] =
            createNewBlip(
            {
                coords = Config.Posts[postoffice].Coords.xyz,
                sprite = 478,
                display = 4,
                scale = 0.7,
                colour = 0,
                isShortRange = true,
                text = "Post OP | " .. postoffice
            }
        )
        SetBlipCategory(buddyBlip[postoffice], 10)
    end
end

function createBuddy(postoffice)
    while not HasModelLoaded(Config.Posts[postoffice].Ped) do
        RequestModel(Config.Posts[postoffice].Ped)
        Wait(5)
    end
    buddy[postoffice] = CreatePed(4, Config.Posts[postoffice].Ped, Config.Posts[postoffice].Coords.xyz, false, false)
    SetEntityHeading(buddy[postoffice], Config.Posts[postoffice].Coords.w)
    SetEntityAsMissionEntity(buddy[postoffice], true, true)
    SetPedHearingRange(buddy[postoffice], 0.0)
    SetPedSeeingRange(buddy[postoffice], 0.0)
    SetPedAlertness(buddy[postoffice], 0.0)
    SetPedFleeAttributes(buddy[postoffice], 0, 0)
    SetBlockingOfNonTemporaryEvents(buddy[postoffice], true)
    SetPedCombatAttributes(buddy[postoffice], 46, true)
    SetPedFleeAttributes(buddy[postoffice], 0, 0)
    SetEntityInvincible(buddy[postoffice], true)
    FreezeEntityPosition(buddy[postoffice], true)
    TaskStartScenarioInPlace(buddy[postoffice], "WORLD_HUMAN_CLIPBOARD", 0, false)
end

function isVehPlaceClean(postoffice)
    for _, spawn in each(Config.VehicleSpawns[postoffice]) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            return true
        end
    end
    return false
end


function spawnVehicle(vehId, postoffice)
    local model = GetHashKey("boxville4")

    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end

    local spawnpoint = nil
    for _, spawn in pairs(Config.VehicleSpawns[postoffice]) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            spawnpoint = _
            break
        end
    end

    if spawnpoint ~= nil then
        local truck = CreateVehicle(model, Config.VehicleSpawns[postoffice][spawnpoint], true, true)
        vehData = {
            NetId = VehToNet(truck),
            Plate = GetVehicleNumberPlateText(truck),
            VehId = vehId
        }
        TriggerServerEvent("job_post:updateVehicle", vehData)
        return "done"
    else
        return "nospace"
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

RegisterNetEvent("job_post:deleteVehicle")
AddEventHandler(
    "job_post:deleteVehicle",
    function(netId)
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local vehicle = NetToVeh(netId)
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
    end
)