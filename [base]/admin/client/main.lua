local isSpawned = false
local spawnedVeh = nil
local lastSpectateCoord = nil
local spectateTarget
local isSpectating = false
local isFrozen = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            cmdSuggestions()
            isSpawned = true
        end
    end
)

function cmdSuggestions()
    local adminlvl = exports.data:getUserVar("admin")
    exports.chat:addSuggestion(
        "/report",
        "Nahlášení",
        {
            {name = "Zpráva", help = "Zpráva"}
        }
    )

    exports.chat:addSuggestion(
        "/video",
        "Rockstar Editor a nahrávání",
        {
            {name = "akce", help = "Akce: editor / record / save / discard"}
        }
    )

    if adminlvl > 1 then
        exports.chat:addSuggestion("/coords", "Zašle souřadnice do serverové konzole")
        exports.chat:addSuggestion("/adminmenu", "Otevře admin menu", {})
        exports.chat:addSuggestion("/clearchat", "Pročistí chat", {})
        exports.chat:addSuggestion(
            "/spectate",
            "Spectate hráče",
            {
                {name = "ID HRÁČE", help = "ID HRÁČE"}
            }
        )
        exports.chat:addSuggestion(
            "/ac",
            "Admin chat",
            {
                {name = "Zpráva", help = "Zpráva"}
            }
        )
        exports.chat:addSuggestion(
            "/msg",
            "Admin zpráva hráči",
            {
                {name = "ID HRÁČE", help = "ID HRÁČE"},
                {name = "Zpráva", help = "Zpráva"}
            }
        )
        exports.chat:addSuggestion(
            "/setplayerpedmodel",
            "Nastaví model hráči",
            {
                {name = "ID HRÁČE", help = "ID HRÁČE"},
                {name = "MODEL", help = "MODEL"}
            }
        )
        exports.chat:addSuggestion(
            "/tr",
            "Převzetí reportu",
            {
                {name = "ID HRÁČE", help = "ID HRÁČE"}
            }
        )
        exports.chat:addSuggestion(
            "/tp",
            "Teleport na zadané souřadnice",
            {
                {name = "X", help = "Souřadnice X"},
                {name = "Y", help = "Souřadnice Y"},
                {name = "Z", help = "Souřadnice Z"}
            }
        )
        exports.chat:addSuggestion("/freezetime", "Zastaví nebo spustí čas", {})
        exports.chat:addSuggestion(
            "/time",
            "Nastaví čas",
            {
                {name = "hodiny", help = "Hodiny"},
                {name = "minuty", help = "Minuty"}
            }
        )
        exports.chat:addSuggestion(
            "/weather",
            "Nastaví počasí",
            {
                {name = "typ", help = "Typ počasí"}
            }
        )
        exports.chat:addSuggestion(
            "/kick",
            "Vyhodí hráče",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "důvod", help = "Důvod banu"}
            }
        )
        exports.chat:addSuggestion(
            "/openinventory",
            "Otevře inventář hráče",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/clearplayerinventory",
            "Vyprázdní inventář hráče",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/ban",
            "Zabanuje hráče",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "délka banu", help = "Délka banu"},
                {name = "důvod", help = "Důvod banu"}
            }
        )
        exports.chat:addSuggestion(
            "/car",
            "Spawne|opraví vozidlo dle názvu modelu",
            {
                {name = "action: spz|repair", help = "Akce"},
                {name = "model je-li třeba | id", help = "Náze vozu | 'id'"},
                {name = "id vozu, je-li třeba", help = "ID vozu (/vehids)"}
            }
        )
        exports.chat:addSuggestion(
            "/giveweapon",
            "Givne hráče zbraň",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "WEAPON_xxx", help = "Zbraň ve tvaru WEAPON_xxx"},
                {name = "počet nábojů", help = "Počet nábojů"},
                {name = "Nelegální", help = "ano / ne"}
            }
        )
        exports.chat:addSuggestion(
            "/setjob",
            "Nastaví hráči zaměstnání",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "název jobu", help = "Jméno zaměstnání"},
                {name = "pozice (1..)", help = "Hodnost"}
            }
        )
        exports.chat:addSuggestion(
            "/setdutyjob",
            "Nastaví hráči službu na daný job",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "název jobu", help = "Jméno zaměstnání"},
                {name = "stav", help = "ON/OFF"}
            }
        )
        exports.chat:addSuggestion(
            "/removejob",
            "Odstraní hráči zaměstnání",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "název jobu", help = "Jméno zaměstnání"}
            }
        )
        exports.chat:addSuggestion(
            "/revive",
            "Vzkřísí hráče",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/giveitem",
            "Dá předmět hráči",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "item", help = "Název předmetu"},
                {name = "počet", help = "Počet"}
            }
        )
        exports.chat:addSuggestion(
            "/findItem",
            "Slouží k vyhledání dostupných itemu ve hře",
            {
                {name = "název", help = "název předmětu"}
            }
        )
        exports.chat:addSuggestion(
            "/findPlayer",
            "Slouží k vyhledání hráče a jeho ID ve hře",
            {
                {name = "název", help = "Nick / část nicku hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/heal",
            "Uzdraví hráče",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/needs",
            "Doplní hráči potřeby (hlad, žízeň)",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/cardel",
            "Smazat vozidlo ve kterém sedíte | před vámi | dle ID (/vehids)",
            {
                {name = "action: id", help = "Akce"},
                {name = "id vozidla", help = "ID vozu (/vehids)"}
            }
        )
        exports.chat:addSuggestion(
            "/deleteobject",
            "Smaže nejbližší objekt se zadaným modelem",
            {
                {name = "model", help = "Název modelu objektu"}
            }
        )
        exports.chat:addSuggestion(
            "/spawnobject",
            "Vytvoří objekt se zadaným modelem",
            {
                {name = "model", help = "Model objektu (hash nebo název)"}
            }
        )
        exports.chat:addSuggestion(
            "/dv",
            "Smazat vozidlo ve kterém sedíte | před vámi | dle ID (/vehids)",
            {
                {name = "action: id", help = "Akce"},
                {name = "id vozidla", help = "ID vozu (/vehids)"}
            }
        )
        exports.chat:addSuggestion(
            "/skinmenu",
            "Otevře menu pro úpravu postavy",
            {
                {name = "id hráče", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion("/wptp", "Teleportuje tě na waypoint", {})
        exports.chat:addSuggestion("/vehids", "Zobrazí v okruhu ID vozidel", {})
        exports.chat:addSuggestion(
            "/givemobile",
            "Givneš hráči mobil, nebo sim",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "Název itemu", help = "Název itemu"}
            }
        )

        exports.chat:addSuggestion(
            "/showme",
            "Zobrazí ti hráče na mapě",
            {
                {name = "action: all|id|del", help = "Koho zobrazí"},
                {name = "id", help = "ID hráče"}
            }
        )
        exports.chat:addSuggestion(
            "/givelicense",
            "Předá hráči licenci",
            {
                {name = "ID hráče", help = "ID hráče"},
                {name = "TR | A | B | C | D", help = "TR | A | B | C | D"}
            }
        )
        exports.chat:addSuggestion(
            "/blockEmail",
            "Zablokovat email účet",
            {
                {name = "Email účet", help = "Email účet"},
                {name = "ID hráče", help = "Může být prázdné"}
            }
        )
        exports.chat:addSuggestion(
            "/blockTwitter",
            "Zablokovat twitter účet",
            {
                {name = "Twitter účet", help = "Twitter účet"},
                {name = "ID hráče", help = "Může být prázdné"}
            }
        )
        exports.chat:addSuggestion(
            "/getFirstEntityOwner",
            "Zjistí prvního majitele entiy",
            {
                {name = "Typ objektu", help = "ped / veh"}
            }
        )
    end

    if adminlvl > 3 then
        exports.chat:addSuggestion(
            "/getcharvar",
            "Získá variable charakteru",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "var", help = "Variable"}
            }
        )

        exports.chat:addSuggestion(
            "/getuservar",
            "Získá variable uživatele",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "var", help = "Variable"}
            }
        )

        exports.chat:addSuggestion(
            "/setskill",
            "Získá variable uživatele",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "skillname", help = "Skill"},
                {name = "value", help = "Hodnota"}
            }
        )

        exports.chat:addSuggestion(
            "/setuservar",
            "Nastaví variable uživatele",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "variable", help = "Variable"},
                {name = "value", help = "Hodnota"}
            }
        )

        exports.chat:addSuggestion(
            "/setcharvar",
            "Nastaví variable charakteru",
            {
                {name = "id hráče", help = "ID hráče"},
                {name = "variable", help = "Variable"},
                {name = "value", help = "Hodnota"}
            }
        )
    end
end

RegisterNetEvent("admin:setskill")
AddEventHandler(
    "admin:setskill",
    function(skill, value)
        exports.skills:changeSkill(skill, true, value, true)
    end
)

RegisterNetEvent("admin:setPlayerPed")
AddEventHandler(
    "admin:setPlayerPed",
    function(playerPed)
        local hash = GetHashKey(playerPed)

        if IsModelInCdimage(hash) then
            exports.skinchooser:setPlayerModel(playerPed, true)
        end
    end
)

RegisterNetEvent("admin:freezePlayer")
AddEventHandler(
    "admin:freezePlayer",
    function()
        isFrozen = not isFrozen

        FreezeEntityPosition(PlayerPedId(), isFrozen)
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" then
            isSpawned = true
            cmdSuggestions()
        end
    end
)

RegisterNetEvent("admin:heal")
AddEventHandler(
    "admin:heal",
    function(value)
        SetEntityHealth(PlayerPedId(), value)
    end
)

RegisterNetEvent("admin:needs")
AddEventHandler(
    "admin:needs",
    function()
        exports.needs:setNeed("hunger", 100.0)
        exports.needs:setNeed("thirst", 100.0)
    end
)

RegisterNetEvent("admin:armour")
AddEventHandler(
    "admin:armour",
    function(value)
        SetPedArmour(PlayerPedId(), value)
    end
)

RegisterNetEvent("admin:skinmenu")
AddEventHandler(
    "admin:skinmenu",
    function()
        exports.skinchooser:openSkinMenu(
            {
                ped = true,
                headBlend = true,
                faceFeatures = true,
                headOverlays = true,
                components = true,
                props = true,
                mask = true,
                tattoos = true,
                canLeave = true,
                vMenuPedsImportAllow = true
            },
            {
                save = true
            }
        )
    end
)

RegisterCommand(
    "givemobile",
    function(source, args)
        if args[1] == nil then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"ID hráče"}
                }
            )
        elseif args[2] == nil then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Název itemu"}
                }
            )
        else
            TriggerServerEvent("qb-phone:server:giveMobile", args)
        end
    end
)

RegisterCommand(
    "blockEmail",
    function(source, args)
        if args[1] == nil then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Email účet"}
                }
            )
        else
            TriggerServerEvent("Email:server:blockEmail", args)
        end
    end
)

RegisterCommand(
    "blockTwitter",
    function(source, args)
        if args[1] == nil then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Twitter účet"}
                }
            )
        else
            TriggerServerEvent("Twitter:server:blockTwitter", args)
        end
    end
)

RegisterCommand(
    "tp",
    function(source, args)
        if exports.data:getUserVar("admin") > 1 then
            if
                args[1] == nil or args[2] == nil or args[3] == nil or tonumber(args[1]) == nil or
                    tonumber(args[2]) == nil or
                    tonumber(args[3]) == nil
             then
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = {"Musíš zadat souřadnice!"}
                    }
                )
            else
                SetEntityCoords(
                    PlayerPedId(),
                    tonumber(args[1]),
                    tonumber(args[2]),
                    tonumber(args[3]) + 0.5,
                    false,
                    false,
                    false,
                    true
                )

                TriggerServerEvent(
                    "logs:sendToLog",
                    {
                        channel = "admin-commands",
                        title = "Souřadnice",
                        description = "Teleportoval se na souřadnice " .. args[1] .. " " .. args[2] .. " " .. args[3],
                        color = "34749"
                    }
                )
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)

RegisterCommand(
    "wptp",
    function()
        if exports.data:getUserVar("admin") > 1 then
            local WaypointHandle = GetFirstBlipInfoId(Config.waypointSprite)

            if DoesBlipExist(WaypointHandle) then
                local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

                local playerPed = PlayerPedId()
                for height = 1, 1000 do
                    SetPedCoordsKeepVehicle(playerPed, waypointCoords.x, waypointCoords.y, height + 0.0)

                    local foundGround, zPos =
                        GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)

                    if foundGround then
                        SetPedCoordsKeepVehicle(playerPed, waypointCoords.x, waypointCoords.y, height + 0.0)
                        break
                    end

                    Citizen.Wait(5)
                end

                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "success",
                        args = {"Byl/a jsi teleportován/a na tvůj waypoint!"}
                    }
                )

                TriggerServerEvent(
                    "logs:sendToLog",
                    {
                        channel = "admin-commands",
                        title = "Waypoint",
                        description = "Teleportoval/a se na waypoint.",
                        color = "34749"
                    }
                )
            else
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = {"Musíš mít nastavený waypoint na mapě!"}
                    }
                )
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)

RegisterCommand(
    "video",
    function(source, args)
        if args[1] == "editor" then
            NetworkSessionLeaveSinglePlayer()
            ActivateRockstarEditor()
        elseif args[1] == "record" then
            StartRecording(1)
        elseif args[1] == "save" then
            StopRecordingAndSaveClip()
        elseif args[1] == "discard" then
            StopRecordingAndDiscardClip()
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Musíš zadat akci!"}
                }
            )
        end
    end
)

RegisterNetEvent("admin:spawnVehicle")
AddEventHandler(
    "admin:spawnVehicle",
    function(args)
        if args[1] ~= nil then
            if args[1] == "repair" then
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if IsEntityAVehicle(veh) then
                        TriggerServerEvent("s:vehicleSync_fix", veh)
                    end
                else
                    local pcoords = GetEntityCoords(PlayerPedId(), 1)
                    local pcoordsFar = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 7.0, 0.0)
                    local veh = getVehicleInDirection(pcoords, pcoordsFar)
                    if IsEntityAVehicle(veh) then
                        TriggerServerEvent("s:vehicleSync_fix", veh)
                    end
                end
                return
            elseif args[1] == "clean" then
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if IsEntityAVehicle(veh) then
                        TriggerServerEvent("s:vehicleSync_clean", veh)
                    end
                else
                    local pcoords = GetEntityCoords(PlayerPedId(), 1)
                    local pcoordsFar = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 7.0, 0.0)
                    local veh = getVehicleInDirection(pcoords, pcoordsFar)
                    if IsEntityAVehicle(veh) then
                        TriggerServerEvent("s:vehicleSync_clean", veh)
                    end
                end
                return
            elseif args[1] == "spz" and args[2] and tostring(args[2]) then
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if IsEntityAVehicle(veh) then
                        SetVehicleNumberPlateText(veh, args[2])
                    end
                else
                    local pcoords = GetEntityCoords(PlayerPedId(), 1)
                    local pcoordsFar = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 7.0, 0.0)
                    local veh = getVehicleInDirection(pcoords, pcoordsFar)
                    if IsEntityAVehicle(veh) then
                        SetVehicleNumberPlateText(veh, args[2])
                    end
                end
                return
            else
                local hash = GetHashKey(args[1])

                if not IsModelInCdimage(hash) then
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "error",
                            args = {"Takový model vozidla neexistuje!"}
                        }
                    )
                    return
                end

                while not HasModelLoaded(hash) do
                    RequestModel(hash)
                    Citizen.Wait(1)
                end

                local coords = GetEntityCoords(PlayerPedId(), false)
                spawnedVeh = CreateVehicle(hash, coords.x, coords.y, coords.z, 10.0, true, false)
                SetVehRadioStation(spawnedVeh, "OFF")

                if Config.warpToVehicle then
                    TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVeh, -1)
                else
                    TaskEnterVehicle(PlayerPedId(), spawnedVeh, 1.0, -1, 1, 0)
                end
            end
        end
    end
)

RegisterNetEvent("admin:deleteobject")
AddEventHandler(
    "admin:deleteobject",
    function(objectName)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestObject =
            GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 4.0, tonumber(objectName))
        local wasRemoved = false

        if DoesEntityExist(closestObject) then
            SetEntityAsMissionEntity(closestObject, 1, 1)
            DeleteEntity(closestObject)
            wasRemoved = true
        else
            closestObjectByHash =
                GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 4.0, GetHashKey(objectName))

            if DoesEntityExist(closestObjectByHash) then
                SetEntityAsMissionEntity(closestObjectByHash, 1, 1)
                DeleteEntity(closestObjectByHash)
                wasRemoved = true
            end
        end

        if wasRemoved then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "success",
                    args = {"Objekt byl smazán"}
                }
            )
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Objekt se nepodařilo smazat"}
                }
            )
        end
    end
)

RegisterNetEvent("admin:spectate")
AddEventHandler(
    "admin:spectate",
    function(targetPlayer, coords)
        if isSpectating then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Už někoho sleduješ, nejprve sledování zruš přes E!"}
                }
            )
            return
        end

        local myPed = PlayerPedId()

        isSpectating = true
        SetEntityVisible(myPed, false)

        TriggerServerEvent("admin:playerGodModeWhitelist", true)
        SetEntityInvincible(myPed, true)

        lastSpectateCoord = GetEntityCoords(myPed)

        SetEntityCollision(myPed, false, false)
        RequestCollisionAtCoord(coords)
        SetEntityCoords(myPed, coords)
        FreezeEntityPosition(myPed, true)

        TriggerServerEvent("admin:isSpectating", targetPlayer)

        local firstTime = true

        Citizen.CreateThread(
            function()
                while isSpectating do
                    Citizen.Wait(0)
                    DisableControlAction(0, 51, true)
                    if IsDisabledControlJustPressed(0, 51) then
                        TriggerServerEvent("admin:stopSpectating")
                        Wait(500)
                    end
                end
            end
        )

        while isSpectating do
            Wait(5)

            local targetLocalPlayer = GetPlayerFromServerId(targetPlayer)
            if targetLocalPlayer ~= -1 then
                local lastSpecateTarget = spectateTarget
                spectateTarget = GetPlayerPed(targetLocalPlayer)

                if firstTime then
                    firstTime = false
                    exports["key_hints"]:displayBottomHint(
                        {
                            name = "stop_spectate",
                            key = "~INPUT_CONTEXT~",
                            text = "Konec sledování (" .. GetPlayerName(targetLocalPlayer) .. ")"
                        }
                    )
                end

                if DoesEntityExist(spectateTarget) then
                    if NetworkIsInSpectatorMode() and lastSpecateTarget ~= spectateTarget then
                        NetworkSetInSpectatorModeExtended(false, lastSpecateTarget, false)
                        Citizen.Wait(10)
                    end

                    while not NetworkIsInSpectatorMode() do
                        NetworkSetInSpectatorModeExtended(true, spectateTarget, true)
                        Citizen.Wait(50)
                    end
                end
            end

            Citizen.Wait(250)
        end
    end
)

RegisterNetEvent("admin:stopSpectate")
AddEventHandler(
    "admin:stopSpectate",
    function()
        stopSpectating()
    end
)

function stopSpectating()
    if isSpectating and lastSpectateCoord ~= nil then
        local myPed = PlayerPedId()
        exports.key_hints:hideBottomHint({name = "stop_spectate"})
        isSpectating = false
        NetworkSetInSpectatorModeExtended(false, spectateTarget, false)
        FreezeEntityPosition(myPed, false)
        SetEntityCoords(myPed, lastSpectateCoord)
        SetEntityCollision(myPed, true, true)

        SetEntityInvincible(myPed, false)
        TriggerServerEvent("admin:playerGodModeWhitelist", false)

        spectateTarget = nil
        lastSpectateCoord = nil

        Wait(250)
        SetEntityVisible(myPed, true)
    end
end

RegisterNetEvent("admin:spawnObject")
AddEventHandler(
    "admin:spawnObject",
    function(objectName)
        local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.05)
        local createObjectByHash = nil
        local createdObject =
            CreateObject(tonumber(objectName), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
        local wasCreated = false

        if DoesEntityExist(createdObject) then
            PlaceObjectOnGroundProperly(createdObject)
            wasCreated = true
        else
            createObjectByHash =
                CreateObject(GetHashKey(objectName), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)

            if DoesEntityExist(createObjectByHash) then
                PlaceObjectOnGroundProperly(createObjectByHash)
                wasCreated = true
            end
        end

        if wasCreated then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "success",
                    args = {"Objekt byl vytvořen"}
                }
            )
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Objekt se nepodařilo vytvořit"}
                }
            )
        end
    end
)

RegisterNetEvent("s:vehicleSync_fix")
AddEventHandler(
    "s:vehicleSync_fix",
    function(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleBodyHealth(vehicle, 1000.00)
        SetVehicleEngineHealth(vehicle, 1000.00)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
    end
)
RegisterNetEvent("s:vehicleSync_clean")
AddEventHandler(
    "s:vehicleSync_clean",
    function(vehicle)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleDirtLevel(vehicle)
    end
)

RegisterNetEvent("admin:clearArea")
AddEventHandler(
    "admin:clearArea",
    function(coords)
        if #(GetEntityCoords(PlayerPedId()) - coords) < 50.0 then
            for vehicle in EnumerateVehicles() do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local vehicleCoords = GetEntityCoords(vehicle)
                if #(playerCoords - vehicleCoords) < 50.0 then
                    if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then
                        SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                        SetEntityAsMissionEntity(vehicle, false, false)
                        DeleteEntity(vehicle)
                        if (DoesEntityExist(vehicle)) then
                            DeleteEntity(vehicle)
                        end
                    end
                end
            end
        end
    end
)

function deleteVehicle()
    if exports.data:getUserVar("admin") > 1 then
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, true) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            TriggerServerEvent("admin:deleteVehicle", NetworkGetNetworkIdFromEntity(veh))
        else
            local playerCoords = GetEntityCoords(playerPed)
            local pcoordsFar = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 7.0, 0.0)
            local veh = getVehicleInDirection(playerCoords, pcoordsFar)
            if DoesEntityExist(veh) then
                TriggerServerEvent("admin:deleteVehicle", NetworkGetNetworkIdFromEntity(veh))
            end
        end
    else
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "error",
                args = {"Na toto nemáš právo!"}
            }
        )
    end
end

RegisterCommand(
    "cardel",
    function(source, args)
        deleteVehicle()
    end
)

RegisterCommand(
    "dv",
    function(source, args)
        ExecuteCommand("cardel")
    end
)

RegisterCommand(
    "vehids",
    function()
        if exports.data:getUserVar("admin") > 1 then
            TriggerServerEvent(
                "logs:sendToLog",
                {
                    channel = "admin-commands",
                    title = "Vehids",
                    description = "Použil příkaz vehids",
                    color = "34749"
                }
            )
            debugmode()
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)

RegisterCommand(
    "getFirstEntityOwner",
    function(source, args)
        if exports.data:getUserVar("admin") > 1 then
            local targetType = args[1]
            if targetType and (targetType == "ped" or targetType == "veh") then
                local coords = GetEntityCoords(PlayerPedId())
                local entity = nil
                if targetType == "ped" then
                    entity = GetClosestPed(coords, 5.0, 0, 0, 0, 0, -1)
                else
                    entity = GetClosestVehicle(coords, 5.0, 0, 23)
                end
                if DoesEntityExist(entity) then
                    TriggerServerEvent("admin:getFirstEntityOwner", NetworkGetNetworkIdFromEntity(entity))
                else
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "error",
                            args = {"Zadaný typ entity nebyl poblíž nalezen!"}
                        }
                    )
                end
            else
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = {"Špatně zadaný typ entity!"}
                    }
                )
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)

local indebugmode = false
function debugmode()
    if indebugmode then
        indebugmode = false
    else
        indebugmode = true
        while indebugmode do
            Citizen.Wait(1)
            getVehicle()
        end
    end
end

function vehicleAction(id, action)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local handle, ped = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
        if canPedBeUsed(ped) and distance < 60.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped
            if id == tostring(ped) then
                if action == "del" or action == "delete" then
                    DeleteEntity(ped)
                elseif action == "rep" or action == "repair" then
                end
                return
            end
        end
        success, ped = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return rped
end

function getVehicle()
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
        if canPedBeUsed(ped) and distance < 60.0 and (distanceFrom == nil or distance < distanceFrom) then
            distanceFrom = distance
            rped = ped
            exports.font:DrawText3D(pos.x, pos.y, pos["z"] + 1, ped)
        end
        success, ped = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return rped
end

function canPedBeUsed(ped)
    if ped == nil then
        return false
    end
    if ped == PlayerPedId() then
        return false
    end
    if not DoesEntityExist(ped) then
        return false
    end
    return true
end

--Citizen.CreateThread(
--    function()
--        while true do
--            Citizen.Wait(3000)
--            if spawnedVeh ~= nil and isSpawned then
--                if Config.deleteVehicleAfterLeaving and not IsPedInVehicle(PlayerPedId(), spawnedVeh, false) then
--                    SetEntityAsMissionEntity(spawnedVeh, false, true)
--                    DeleteVehicle(spawnedVeh)
--                end
--            end
--        end
--    end
--)

function getVehicleInDirection(coordFrom, coordTo)
    local rayHandle =
        CastRayPointToPoint(
        coordFrom.x,
        coordFrom.y,
        coordFrom.z,
        coordTo.x,
        coordTo.y,
        coordTo.z,
        10,
        PlayerPedId(),
        0
    )
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function sortBanLengths(a, b)
    if a.minutes == 0 then
        return false
    elseif b.minutes == 0 then
        return true
    end

    return a.minutes < b.minutes
end

function getBanKeyByMinutes(minutes)
    for length, data in pairs(Config.banLengths) do
        if data.minutes == minutes then
            return length
        end
    end
end

function getStatusText(status)
    if status == "spawned" then
        return "Spawnutý"
    elseif status == "connecting" then
        return "Připojuje se"
    elseif status == "choosing" then
        return "Vybírá si postavu"
    elseif status == "dead" then
        return "Mrtvý"
    elseif status == "disconnected" then
        return "Odpojený"
    end

    return status
end

function getPermissionsText(admin)
    if admin <= 0 then
        return "Hráč"
    end

    return Config.namedAdmin[admin].label
end

Citizen.CreateThread(
    function()
        Citizen.Wait(25000)

        while true do
            local resourceList = {}
            for i = 0, GetNumResources() - 1 do
                resourceList[i + 1] = GetResourceByFindIndex(i)
            end
            TriggerServerEvent("admin:collectAndSendResourceList", resourceList)

            Citizen.Wait(math.random(60000, 120000))
        end
    end
)

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = {handle = iter, destructor = disposeFunc}
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end
