local isSpawned, isDead = false, false
local centralBlips = {}
local onJob = {
    active = false,
    returning = false,
    truckData = nil,
    contract = {},
    blipData = {}
}
local inMenu = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end

        checkCentralBlipsExist()

        for depoId, central in pairs(Config.Central) do
            exports.target:AddCircleZone(
                "truckMaster_" .. depoId,
                central.Coords.xyz,
                3.2,
                {
                    actions = {
                        job = {
                            cb = function()
                                if not WarMenu.IsAnyMenuOpened() then
                                    if exports.license:hasLicense(Config.licenseNeeded, true) then
                                        if onJob.active then
                                            openActiveContractMenu()
                                        else
                                            TriggerServerEvent("job_trucker:open", depoId)
                                        end
                                    else
                                        exports.notify:display(
                                            {
                                                type = "error",
                                                title = "Kamióny",
                                                text = "Nemáte řidičské oprávnění skupiny " .. Config.licenseNeeded,
                                                icon = "fa fa-truck",
                                                length = 3000
                                            }
                                        )
                                    end
                                end
                            end,
                            icon = "fas fa-truck",
                            label = "Oslovit chlapíka"
                        }
                    },
                    distance = 0.2
                }
            )
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
                checkCentralBlipsExist()
            end
        end
    end
)

function openActiveContractMenu()
    if onJob.active then
        WarMenu.CreateMenu("truckers_active", "Kamióny", "Zvolte akci")
        WarMenu.SetMenuY("truckers_active", 0.35)
        WarMenu.CreateSubMenu("truckers_cancel", "truckers_active", "Potvrďte zrušení zakázky")
        WarMenu.OpenMenu("truckers_active")
        Citizen.CreateThread(
            function()
                while true do
                    if WarMenu.IsMenuOpened("truckers_active") then
                        if WarMenu.MenuButton("Zrušit zakázku", "truckers_cancel") then
                        elseif WarMenu.Button("Zeptat se na SPZ") then
                            exports.notify:display(
                                {
                                    type = "info",
                                    title = "Kamióny",
                                    text = "SPZ tvého tahače je: " .. GetVehicleNumberPlateText(onJob.truckData.truckEntity),
                                    icon = "fa fa-truck",
                                    length = 3000
                                }
                            )
                        elseif WarMenu.Button("Zavřít") then
                            WarMenu.CloseMenu()
                        end
                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("truckers_cancel") then
                        if WarMenu.Button("Potvrdit") then
                            returnContract(true)
                            WarMenu.CloseMenu()
                        elseif WarMenu.MenuButton("Vrátit se", "truckers") then
                        end
                        WarMenu.Display()
                    else
                        WarMenu.CloseMenu()
                        break
                    end

                    Citizen.Wait(0)
                end
            end
        )
    end
end

RegisterNetEvent("job_trucker:open")
AddEventHandler(
    "job_trucker:open",
    function(depoId, contracts)
        Citizen.CreateThread(
            function()
                inMenu = true
                WarMenu.CreateMenu("truckers", "Kamióny " .. depoId, "Zvolte akci")
                WarMenu.SetMenuY("truckers", 0.35)
                WarMenu.CreateSubMenu("truckers_jobs", "truckers", "Zvolte zakázku")
                WarMenu.CreateSubMenu("truckers_confirm", "truckers_jobs", "Potvrďte zakázku")
                WarMenu.OpenMenu("truckers")

                while true do
                    if WarMenu.IsMenuOpened("truckers") then
                        if WarMenu.MenuButton("Vybrat zakázku", "truckers_jobs") then
                        elseif WarMenu.Button("Zavřít") then
                            closeMenu(depoId)
                        end
                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("truckers_jobs") then
                        for k, v in pairsByKeys(contracts) do
                            if WarMenu.MenuButton(k, "truckers_confirm", v) then
                                contractId = k
                            end
                        end
                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("truckers_confirm") then
                        if WarMenu.Button("Potvrdit") then
                            TriggerServerEvent("job_trucker:takeContract", depoId, contractId, GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.Contracts[contractId].Arrive, 1))
                            closeMenu(depoId)
                        elseif WarMenu.MenuButton("Vrátit se", "truckers_jobs") then
                        end
                        WarMenu.Display()
                    else
                        closeMenu(depoId)
                        break
                    end

                    Citizen.Wait(0)
                end
            end
        )
    end
)

RegisterNetEvent("job_trucker:takeContract")
AddEventHandler(
    "job_trucker:takeContract",
    function(contract)
        -- choosing spawn point
        local sp = nil
        for i, coords in pairs(Config.Central[contract.depoId].SpawnLocations.Truck) do
            if not IsAnyVehicleNearPoint(coords.xyz, 2.5) and not IsAnyVehicleNearPoint(Config.Central[contract.depoId].SpawnLocations.Trailer[i].xyz, 2.5) then
                sp = i
                break
            end
        end

        if sp then
            onJob.contract = {
                contractId = contract.contractId,
                depoId = contract.depoId
            }

            contract.spawnPoint = sp
            TriggerServerEvent("job_trucker:startContract", contract)
        else
            exports.notify:display(
                {
                    type = "warning",
                    title = "Kamióny",
                    text = "Nikde není místo. Zkus to později..",
                    icon = "fa fa-truck",
                    length = 3000
                }
            )
            TriggerServerEvent("job_trucker:clearContract")
            closeMenu(contract.depoId)
        end
    end
)

local showHint = false
local deliverCoords = nil
local disabledReturn = false

RegisterNetEvent("job_trucker:startContract")
AddEventHandler(
    "job_trucker:startContract",
    function(contractData)
        onJob.truckData = {
            truck = contractData.Truck,
            trailer = contractData.Trailer
        }
        onJob.begin = contractData.Begin
        onJob.returning = false
        onJob.active = true



        requestModel(Config.Contracts[onJob.contract.contractId].Truck)
        onJob.truckData.truckEntity = CreateVehicle(Config.Contracts[onJob.contract.contractId].Truck, Config.Central[onJob.contract.depoId].SpawnLocations.Truck[contractData.spawnPoint], true, true)
        while not DoesEntityExist(onJob.truckData.truckEntity) do
            Citizen.Wait(200)
        end
        onJob.truckData.truckId = NetworkGetNetworkIdFromEntity(onJob.truckData.truckEntity)

        requestModel(Config.Contracts[onJob.contract.contractId].Trailer)
        onJob.truckData.trailerEntity = CreateVehicle(Config.Contracts[onJob.contract.contractId].Trailer, Config.Central[onJob.contract.depoId].SpawnLocations.Trailer[contractData.spawnPoint], true, true)
        while not DoesEntityExist(onJob.truckData.trailerEntity) do
            Citizen.Wait(200)
        end
        onJob.truckData.trailerId = NetworkGetNetworkIdFromEntity(onJob.truckData.trailerEntity)

        AttachVehicleToTrailer(onJob.truckData.truckEntity, onJob.truckData.trailerEntity, 20.0)

        TriggerServerEvent("job_trucker:updateEntities", onJob.contract.contractId, onJob.contract.depoId, onJob.truckData.truckId, onJob.truckData.trailerId)

        addNewContractBlip(Config.Contracts[onJob.contract.contractId].Destination, Config.BlipSettings["destination"].Sprite, Config.BlipSettings["destination"].Colour, Config.BlipSettings["destination"].Label)

        exports.notify:display(
            {
                type = "success",
                title = "Kamióny",
                text = "Tahač s SPZ " .. GetVehicleNumberPlateText(onJob.truckData.truckEntity) .. " máš přistavený na parkovišti!",
                icon = "fa fa-truck",
                length = 3000
            }
        )

        showHint = false
        disabledReturn = false
        deliverCoords = Config.Contracts[onJob.contract.contractId].Destination
        Citizen.CreateThread(function()
            while onJob.active do
                if IsControlJustReleased(0, 54) and showHint and not disabledReturn then
                    disabledReturn = true
                    showHint = false
                    exports.key_hints:hideHint({name = "truckers"})
                    currentContractOnReturn()

                    disabledReturn = false
                end
                Citizen.Wait(0)
            end
        end)
    end
)

Citizen.CreateThread(function()
    while true do
        if onJob.active and not isDead then
            if deliverCoords ~= nil then
                if #(GetEntityCoords(PlayerPedId()) - deliverCoords) <= 20.0 then
                    if not showHint then
                        showHint = true
                        exports.key_hints:displayHint(
                            {
                                name = "truckers",
                                key = "~INPUT_PICKUP~",
                                text = (onJob.returning and "Vrátit tahač" or "Vyložit zboží"),
                                coords = deliverCoords
                            }
                        )
                    end
                else
                    if showHint then
                        showHint = false
                        exports.key_hints:hideHint({name = "truckers"})
                    end
                end
            end
        end
        Citizen.Wait(5000)
    end
end)

RegisterNetEvent("job_trucker:finishContract")
AddEventHandler("job_trucker:finishContract",
    function(contractId, totalPay, cancel)
        if onJob.blipData.blip ~= nil then
            RemoveBlip(onJob.blipData.blip)
            SetBlipRoute(onJob.blipData.blip, false)
        end

        if DoesEntityExist(onJob.truckData.truckEntity) then
            DeleteEntity(onJob.truckData.truckEntity)
        end

        if DoesEntityExist(onJob.truckData.trailerEntity) then
            DeleteEntity(onJob.truckData.trailerEntity)
        end
        --
        onJob = {
            active = false,
            returning = false,
            truckData = nil,
            contract = {},
            blipData = {},
            begin = nil
        }
        deliverCoords = nil
        showHint = false
        disabledReturn = true
        --
        if not cancel then
            exports.notify:display(
                {
                    type = "success",
                    title = "Kamióny",
                    text = "Dobrá práce! " .. (totalPay == 0 and "" or "Za svou práci jste obdržel hotově $" .. totalPay),
                    icon = "fa fa-truck",
                    length = 3000
                }
            )
        else
            exports.notify:display(
                {
                    type = "info",
                    title = "Kamióny",
                    text = "Zakázka byla zrušena. ",
                    icon = "fa fa-truck",
                    length = 3000
                }
            )
        end
    end
)

function currentContractOnReturn()
    if onJob ~= nil then
        if not IsPedInVehicle(GetPlayerPed(-1), onJob.truckData.truckEntity, false) then
            exports.notify:display(
                {
                    type = "error",
                    title = "Kamióny",
                    text = "Přijel jsi v neregistrovaném tahači",
                    icon = "fa fa-truck",
                    length = 3000
                }
            )
            return "wrongTruck"
        end

        if onJob.returning then
            returnContract(false)
            return "done"
        else
            if not IsVehicleAttachedToTrailer(onJob.truckData.truckEntity) then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Kamióny",
                        text = "Nezapomněl jsi přívěs?",
                        icon = "fa fa-truck",
                        length = 3000
                    }
                )
                return "missingTrailer"
            end

            local _, _checkTrailer = GetVehicleTrailerVehicle(onJob.truckData.truckEntity)
            if _checkTrailer ~= onJob.truckData.trailerEntity then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Kamióny",
                        text = "To není to správné objednané zboží",
                        icon = "fa fa-truck",
                        length = 3000
                    }
                )
                return "wrongTrailer"
            end


            if onJob.blipData.blip ~= nil then
                RemoveBlip(onJob.blipData.blip)
                SetBlipRoute(onJob.blipData.blip, false)
            end

            DetachVehicleFromTrailer(onJob.truckData.truckEntity)
            DeleteEntity(onJob.truckData.trailerEntity)

            exports.notify:display(
                {
                    type = "success",
                    title = "Kamióny",
                    text = "Dobrá práce, dovez zpátky tahač!",
                    icon = "fa fa-truck",
                    length = 3000
                }
            )

            onJob.returning = true
            addNewContractBlip(Config.Central[onJob.contract.depoId].ReturnLocation, Config.BlipSettings["returning"].Sprite, Config.BlipSettings["returning"].Colour, Config.BlipSettings["returning"].Label)
            deliverCoords = Config.Central[onJob.contract.depoId].ReturnLocation
            return "done"
        end
    end
end
function returnContract(cancel)
    TriggerServerEvent("job_trucker:finishContract", onJob.contract.depoId, onJob.contract.contractId, not cancel, cancel)
end
function addNewContractBlip(location, sprite, colour, string)
    onJob.blipData.blip = createNewBlip(
        {
            coords = location,
            sprite = sprite,
            display = 4,
            scale = 0.6,
            colour = colour,
            isShortRange = true,
            text = string
        }
    )
    SetBlipRoute(onJob.blipData.blip, true)
end
function closeMenu(depoId)
    if inMenu then
        inMenu = false
        TriggerServerEvent("job_trucker:close", depoId)
        WarMenu.CloseMenu()
    end
end
function checkCentralBlipsExist()
    for k, v in pairs(Config.Central) do
        if not centralBlips[k] or not DoesBlipExist(centralBlips[k]) then
            centralBlips[k] = createNewBlip(
                {
                    coords = Config.Central[k].Coords,
                    sprite = 477,
                    display = 4,
                    scale = 0.6,
                    colour = 0,
                    isShortRange = true,
                    text = "Depo kamiónů"
                }
            )
            SetBlipCategory(centralBlips[k], 10)
        end
    end
end
function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end


RegisterCommand("job_trucker_contracttp",
    function(source, args)
        if exports.data:getUserVar("admin") < 2 then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo" }
                }
            )
            return "noPermission"
        end

        if args[1] == nil then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = { "Musíš zadat contract ID" }
                }
            )
            return "invalidFormat"
        end

        local contractId = args[1]
        if Config.Contracts[contractId] then
            SetEntityCoords(
                PlayerPedId(),
                Config.Contracts[contractId].Destination,
                false,
                false,
                false,
                true
            )

            TriggerServerEvent(
                "logs:sendToLog",
                {
                    channel = "admin-commands",
                    title = "Job trucker - port",
                    description = "Teleportoval se na job_trucker ContractId: " .. contractId,
                    color = "34749"
                }
            )
        end
    end
)

function requestModel(m)
    while not HasModelLoaded(m) do
        RequestModel(m)
        Citizen.Wait(1)
    end
end
