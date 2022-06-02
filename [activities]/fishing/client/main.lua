local isSpawned, isDead = false, false
local check = false
local isFishing = false
local peds = {}
Citizen.CreateThread(
    function()
        createFisherman()
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")

            if not DoesEntityExist(fisherman) then
                createFisherman()
            end
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
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if string.find(itemName, "fishingrod") ~= nil and isFishing == false then
            isFishing = true
            TriggerEvent("fishing:start")
        end
    end
)

RegisterNetEvent("fishing:start")
AddEventHandler(
    "fishing:start",
    function()
        local pedCoords = GetEntityCoords(PlayerPedId())
        local boat = GetClosestVehicle(pedCoords.x, pedCoords.y, pedCoords.z, 5.0, 0, 12294)
        if IsEntityInWater(boat) then
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if not IsPedSwimming(PlayerPedId()) then
                    check = true
                    exports.emotes:playEmoteByName("fishing")
                    exports.notify:display(
                        {
                            type = "success",
                            title = "Rybaření",
                            text = "Začal si rybařit",
                            icon = "fas fa-fish",
                            length = 5000
                        }
                    )
                    catchfish()
                else
                    exports.notify:display(
                        {
                            type = "info",
                            title = "Rybaření",
                            text = "Musíš si vybrat jestli budeš rybařit nebo plavat",
                            icon = "fas fa-fish",
                            length = 5000
                        }
                    )
                end
            end
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Rybaření",
                    text = "Tady nemůžeš rybařit..",
                    icon = "fas fa-fish",
                    length = 5000
                }
            )
        end
    end
)

function catchfish()
    if check then
        local randomTime = math.random(5000, Config.FishingTime - 3000)
        Citizen.Wait(randomTime)
        local chance = math.random(1, 100)
        print("šance:", chance)
        if chance > 45 then --45
            exports.rprogress:MiniGame(
                {
                    Difficulty = "Hard",
                    onComplete = function(success)
                        if success then
                            exports.emotes:playEmoteByName("fishing3")
                            Citizen.Wait(1000)
                            exports.notify:display(
                                {
                                    type = "success",
                                    title = "Rybaření",
                                    text = "Něco si chytil!",
                                    icon = "fas fa-fish",
                                    length = 5000
                                }
                            )
                            TriggerServerEvent("fishing:giveFish")
                            Citizen.Wait(3000)
                            exports.emotes:cancelEmote()
                        else
                            exports.notify:display(
                                {
                                    type = "error",
                                    title = "Rybaření",
                                    text = "Nic si nechytil",
                                    icon = "fas fa-fish",
                                    length = 5000
                                }
                            )
                            print("bad attempt")
                            exports.emotes:cancelEmote()
                        end
                    end
                }
            )
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Rybaření",
                    text = "Ryba ti uplavala",
                    icon = "fas fa-fish",
                    length = 5000
                }
            )
            exports.emotes:cancelEmote()
        end
        check = false
        isFishing = false
    end
end

function createFisherman()
    for k, v in pairs(Config.Npc) do
        if v.available then
            if peds[k] ~= nil and peds[k].ped ~= nil then
                DeletePed(peds[k].ped)
            end

            RequestModel(v.model.key)
            while not HasModelLoaded(v.model.key) do
                Wait(5)
            end

            peds[k] = {}
            peds[k].ped = CreatePed(v.model.type, v.model.key, v.pos.x, v.pos.y, v.pos.z, false, false)
            SetEntityHeading(peds[k].ped, v.pos.heading)
            SetEntityAsMissionEntity(peds[k].ped, true, true)
            SetPedHearingRange(peds[k].ped, 0.0)
            SetPedSeeingRange(peds[k].ped, 0.0)
            SetPedAlertness(peds[k].ped, 0.0)
            SetPedFleeAttributes(peds[k].ped, 0, 0)
            SetBlockingOfNonTemporaryEvents(peds[k].ped, true)
            SetPedCombatAttributes(peds[k].ped, 46, true)
            SetPedFleeAttributes(peds[k].ped, 0, 0)
            SetEntityInvincible(peds[k].ped, true)
            FreezeEntityPosition(peds[k].ped, true)
            Citizen.Wait(1000)

            exports.target:AddCircleZone(
                "fisherman",
                vec3(v.pos.x, v.pos.y, v.pos.z),
                1.0,
                {
                    actions = {
                        action = {
                            cb = function()
                                if not WarMenu.IsAnyMenuOpened() then
                                    createMenu()
                                end
                            end,
                            icon = "fas fa-comments",
                            label = "Promluvit s rybářem"
                        },
                        action2 = {
                            cb = function()
                                if not WarMenu.IsAnyMenuOpened() then
                                    TriggerServerEvent("fishing:rentCheck")
                                end
                            end,
                            icon = "fas fa-comments",
                            label = "Pronajmout si loď"
                        }
                    },
                    distance = 0.2
                }
            )
            if v.anim.task ~= nil then
                TaskStartScenarioInPlace(peds[k].ped, v.anim.task, 0, false)
            else
                while not HasAnimDictLoaded(v.anim.animDict) do
                    RequestAnimDict(v.anim.animDict)
                    Wait(10)
                end

                TaskPlayAnim(peds[k].ped, v.anim.animDict, v.anim.anim, 2.0, 2.0, -1, 1, 0, false, false, false)
            end
            Citizen.Wait(500)
        end
    end
end

function createMenu()
    Citizen.CreateThread(
        function()
            WarMenu.CreateMenu("fisherman", "Výkup", "Výkup ryb")
            WarMenu.OpenMenu("fisherman")
            while WarMenu.IsMenuOpened("fisherman") do
                for k, data in pairs(Config.Fishes) do
                    if WarMenu.Button(data.label) then
                        exports.input:openInput(
                            "number",
                            {title = "Zadejte počet", placeholder = ""},
                            function(amount)
                                amount = tonumber(amount)
                                if amount and amount > 0 then
                                    TriggerEvent(
                                        "mythic_progbar:client:progress",
                                        {
                                            name = "fishing_stuff",
                                            duration = 750,
                                            label = "Prodáváš věci",
                                            useWhileDead = false,
                                            canCancel = true,
                                            controlDisables = {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true
                                            }
                                        },
                                        function(status)
                                            if not status then
                                                TriggerServerEvent("fishing:sell", amount, data)
                                                print("sell", amount, k)
                                            end
                                        end
                                    )
                                end
                            end
                        )
                    end
                end
                WarMenu.Display()

                Citizen.Wait(0)
            end
        end
    )
end

RegisterNetEvent("fishing:rentBoat")
AddEventHandler(
    "fishing:rentBoat",
    function()
        Citizen.CreateThread(
            function()
                local boat = GetHashKey("dinghy")
                while not HasModelLoaded("dinghy") do
                    RequestModel("dinghy")
                    Wait(5)
                end

                fishingBoat =
                    CreateVehicle(
                    "dinghy",
                    -1601.6417236328,
                    5258.2172851562,
                    1.7900912761688,
                    20.067070007324,
                    true,
                    true
                )
                SetVehicleOnGroundProperly(fishingBoat)
                SetEntityAsNoLongerNeeded(fishingBoat)
                Citizen.Wait(1000)
            end
        )
    end
)
