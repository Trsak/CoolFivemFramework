local inCam = false
local canOpenMenu = false
local cameraConfig = {}
local isDead, isSpawned = false, false
local blackout = false
local showingHint = false
local isShowingHackHint = false
local currentNearestHack = nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")

            TriggerServerEvent("cctv:server:sync")
        end

        while true do
            pPed = PlayerPedId()
            pCoords = GetEntityCoords(pPed)
            Citizen.Wait(1500)
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
            TriggerServerEvent("cctv:server:sync")
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        while true do
            if not inCam then
                if GetDistanceBetweenCoords(pCoords, Config.Coords, true) <= 2.0 then
                    canOpenMenu = true

                    if not showingHint then
                        showingHint = true
                        exports.key_hints:displayHint(
                            {["name"] = "cctv", ["key"] = "~INPUT_1D793667~", ["text"] = "Otevrít kamery"}
                        )
                    end
                else
                    canOpenMenu = false

                    if showingHint then
                        showingHint = false
                        exports.key_hints:hideHint({["name"] = "cctv"})
                    end
                    WarMenu.CloseMenu()
                end

                local shouldBeDisplayingHint = false
                for place, _ in pairs(Config.Locations) do
                    local distance = GetDistanceBetweenCoords(pCoords, Config.Locations[place].HackCoords, true)
                    if distance <= 1.5 then
                        shouldBeDisplayingHint = true
                        currentNearestHack = place

                        if not isShowingHackHint then
                            isShowingHackHint = true
                            exports.key_hints:displayHint(
                                {
                                    ["name"] = "cctv",
                                    ["key"] = "~INPUT_1D793667~",
                                    ["text"] = "Hacknout kamery objektu"
                                }
                            )
                        end
                        break
                    end
                end
                if not shouldBeDisplayingHint and isShowingHackHint then
                    currentNearestHack = nil
                    isShowingHackHint = false
                    exports.key_hints:hideHint({["name"] = "cctv"})
                end
            end
            if blackout and inCam then
                inCam = false
            end
            Citizen.Wait(1000)
        end
    end
)

function openMenu()
    Citizen.CreateThread(
        function()
            WarMenu.CreateMenu("cameras_menu", "Kamerový systém LS", "Zvolte budovu")
            WarMenu.SetMenuY("cameras_menu", 0.35)
            WarMenu.CreateSubMenu("vangelico", "cameras_menu", "Zvolte kameru klenotnictví")
            WarMenu.CreateSubMenu("fleecabanks", "cameras_menu", "Zvolte Fleeca banku")
            WarMenu.CreateSubMenu("specific_building", "fleecabanks", "Zvolte kameru budovy")
            WarMenu.OpenMenu("cameras_menu")

            while true do
                if WarMenu.IsMenuOpened("cameras_menu") then -- Hlavní menu
                    if cameraConfig.Vangelico.Accesable then
                        if WarMenu.Button("Klenotnictví Vangelico", "~g~ Dostupné") then
                            WarMenu.OpenMenu("vangelico")
                        end
                    else
                        if WarMenu.Button("Klenotnictví Vangelico", "~r~Nedostupné") then
                            camerasOff()
                        end
                    end
                    if WarMenu.MenuButton("Fleeca Banky", "fleecabanks") then
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("vangelico") then
                    for camera, _ in pairs(cameraConfig.Vangelico.Cameras) do
                        if WarMenu.Button(camera) then
                            createCamera("Vangelico", camera)
                            WarMenu.CloseMenu()
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("fleecabanks") then
                    for interior, _ in pairs(cameraConfig) do
                        if cameraConfig[interior].Type == "bank" then
                            if cameraConfig[interior].Accesable then
                                if WarMenu.Button(interior, "~g~Dostupné") then
                                    buildingName = interior
                                    WarMenu.OpenMenu("specific_building")
                                end
                            else
                                if WarMenu.Button(interior, "~r~Nedostupné") then
                                    camerasOff()
                                end
                            end
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("shops") then
                    for interior, _ in pairs(cameraConfig) do
                        if cameraConfig[interior].Type == "shop" then
                            if cameraConfig[interior].Accesable then
                                if WarMenu.Button(interior, "~g~Dostupné") then
                                    buildingName = interior
                                    WarMenu.OpenMenu("specific_building")
                                end
                            else
                                if WarMenu.Button(interior, "~r~Nedostupné") then
                                    camerasOff()
                                end
                            end
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("specific_building") then
                    for camera, _ in pairs(cameraConfig[buildingName].Cameras) do
                        if WarMenu.Button(camera) then
                            print(camera)
                            createCamera(buildingName, camera)
                            WarMenu.CloseMenu()
                        end
                    end
                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(0)
            end
        end
    )
end

function createCamera(building, selectedCamera)
    inCam = true
    exports.key_hints:hideHint({["name"] = "cctv"})
    local path = cameraConfig[building]

    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(camera, path.Cameras[selectedCamera].Coords.xyz)
    SetCamRot(camera, path.Cameras[selectedCamera].Rotation.xyz)
    RenderScriptCams(true, false, 0, 1, 0)
    SetFocusArea(path.Cameras[selectedCamera].Coords.xyz, 0.0, 0.0, 0.0)

    PlaySoundFrontend(-1, "HACKING_SUCCESS", false)
    SetTimecycleModifier("camera_security")
    SetTimecycleModifierStrength(0.7)
    FreezeEntityPosition(pPed, true)

    if path.Type ~= "traffic" then
        scaleform = RequestScaleformMovie("SECURITY_CAM")
    end

    while not HasScaleformMovieLoaded(scaleform) do
        if path.Type ~= "traffic" then
            scaleform = RequestScaleformMovie("SECURITY_CAM")
        end
        Citizen.Wait(1)
    end

    while inCam do
        if IsControlJustReleased(0, 54) or not path.Accesable then
            inCam = false
        end

        BeginScaleformMovieMethod(scaleform, "SET_TIME")
        ScaleformMovieMethodAddParamInt(11, 11)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_LOCATION")
        ScaleformMovieMethodAddParamTextureNameString(building)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_DETAILS")
        ScaleformMovieMethodAddParamTextureNameString(selectedCamera)
        EndScaleformMovieMethod()

        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)

        Citizen.Wait(1)
    end

    ClearFocus()
    ClearTimecycleModifier()
    RenderScriptCams(false, false, 0, 1, 0)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    DestroyCam(camera, false)
    FreezeEntityPosition(pPed, false)
    exports.key_hints:displayHint({["name"] = "cctv", ["key"] = "~INPUT_1D793667~", ["text"] = "Otevrít kamery"})
end

RegisterNetEvent("cctv:client:sync")
AddEventHandler(
    "cctv:client:sync",
    function(data)
        cameraConfig = data.Info
        blackout = false
    end
)

RegisterCommand(
    "cctv",
    function()
        print "cs"
        if not blackout then
            if currentNearestHack ~= nil then
                TriggerServerEvent("cctv:server:systemHacked", currentNearestHack)
                print("System hacked in: " .. currentNearestHack)
            else
                if not inCam then
                    if canOpenMenu and not isDead and not WarMenu.IsAnyMenuOpened() then
                        openMenu()
                    end
                else
                    inCam = false
                    DestroyCam(camera, false)
                end
            end
        else
            camerasOff()
        end
    end
)

createNewKeyMapping({command = "cctv", text = "Otevřít menu", key = "E"})

function camerasOff()
    exports.notify:display(
        {
            type = "error",
            title = "CCTV",
            text = "Nepodařilo se navázat spojení",
            icon = "fa fa-shield",
            length = 3000
        }
    )
end
