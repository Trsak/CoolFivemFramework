local inCam = false
local vision = "normal"
local detectedVehicle = nil
local lockedVehicle = nil
local isSpawned, isDead = false, false

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterCommand("helicam", function()
    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed)
    local model = GetEntityModel(playerVehicle)
    local height = GetEntityHeightAboveGround(playerVehicle)

    if Config.Helies[model] then
        if height >= 1.5 and GetPedInVehicleSeat(playerVehicle, 0) == playerPed and not isDead then
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
            if not inCam then
                inCam = true
                Citizen.CreateThread(function()
                    while inCam do
                        Citizen.Wait(1)
                        DisableControlAction(0, 30, true)
                        DisableControlAction(0, 31, true)
                        DisableControlAction(0, 32, true)
                        DisableControlAction(0, 33, true)
                        DisableControlAction(0, 34, true)
                        DisableControlAction(0, 35, true)
                        DisableControlAction(0, 22, true)
                        DisableControlAction(0, 44, true)
                        DisableControlAction(0, 85, true)
                        -- Actions
                        DisableControlAction(0, 45, true)
                        DisableControlAction(0, 37, true)
                        DisableControlAction(0, 23, true)
                        -- UI
                        DisableControlAction(0, 14, true)
                        DisableControlAction(0, 15, true)
                        DisableControlAction(0, 16, true)
                        DisableControlAction(0, 17, true)
                        DisableControlAction(0, 50, true)
                        DisableControlAction(0, 99, true)
                        DisableControlAction(0, 115, true)
                        DisableControlAction(0, 261, true)
                        DisableControlAction(0, 262, true)
                        DisableControlAction(0, 288, true)
                        DisableControlAction(0, 289, true)
                        DisableControlAction(0, 170, true)
                        DisableControlAction(0, 166, true)
                        DisableControlAction(0, 167, true)
                        DisableControlAction(0, 168, true)
                        DisableControlAction(2, 199, true)
                        DisableControlAction(0, 200, true)
                        DisableControlAction(2, 241, true)
                        DisableControlAction(2, 242, true)
                        DisableControlAction(2, 332, true)
                        DisableControlAction(2, 333, true)
                        local height = GetEntityHeightAboveGround(playerVehicle)
                        if isDead or height <= 1.4 then
                            inCam = false
                            vision = "normal"
                        end
                    end
                end)
                openCamera()
            elseif inCam then
                inCam = false
                vision = "normal"
            end
        end
    end
end)

RegisterCommand("helivision", function()
    if inCam then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        if vision == "normal" then
            SetNightvision(true)
            vision = "night"
        elseif vision == "night" then
            SetNightvision(false)
            SetSeethrough(true)
            SeethroughSetMaxThickness(1.0)
            vision = "thermal"
        elseif vision == "thermal" then
            SetSeethrough(false)
            vision = "normal"
        end
    end
end)

createNewKeyMapping({
    command = "helicam",
    text = "Zapnutí / vypnutí kamery",
    key = "E"
})
createNewKeyMapping({
    command = "helivision",
    text = "Změna vize kamery",
    key = "INSERT"
})

function openCamera()
    fov = (Config.Fov.Max + Config.Fov.Min) * 0.5
    local lockedVehicle = nil
    local helicopter = GetVehiclePedIsIn(PlayerPedId())
    local vHeading = GetEntityHeading(helicopter)

    SetTimecycleModifier("heliGunCam")
    SetTimecycleModifierStrength(0.3)

    local scaleform = RequestScaleformMovie("HELI_CAM")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    local camera = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

    AttachCamToEntity(camera, helicopter, 0.0, 0.0, -1.5, true)
    SetCamRot(camera, 0.0, 0.0, vHeading)
    SetCamFov(camera, fov)
    RenderScriptCams(true, false, 0, 1, 0)

    BeginScaleformMovieMethod(scaleform, "SET_CAM_LOGO")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    while inCam do
        if lockedVehicle == nil then
            zoomValue = math.floor((1.0 / (Config.Fov.Max - Config.Fov.Min)) * (fov - Config.Fov.Min))
            moveCam(camera, zoomValue)

            local detectedVehicle = getVehicle(camera)
            if DoesEntityExist(detectedVehicle) then
                vehicleInfo(detectedVehicle)
                if IsDisabledControlJustReleased(0, 22) then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    lockedVehicle = detectedVehicle
                    PointCamAtEntity(camera, lockedVehicle, 0.0, 0.0, 0.0, true)
                end
            end
        else
            if DoesEntityExist(lockedVehicle) then
                vehicleInfo(lockedVehicle)
                local visibleVeh = getVehicle(camera)
                if IsDisabledControlJustReleased(0, 22) or visibleVeh ~= lockedVehicle then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    lockedVehicle = nil

                    local rotation = GetCamRot(camera, 2)
                    local fov = GetCamFov(camera)
                    DestroyCam(camera, false)
                    camera = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                    AttachCamToEntity(camera, helicopter, 0.0, 0.0, -1.5, true)
                    SetCamRot(camera, rotation, 2)
                    SetCamFov(camera, fov)
                    RenderScriptCams(true, false, 0, 1, 0)
                end
            else
                lockedVehicle = nil
            end
        end

        BeginScaleformMovieMethod(scaleform, "SET_ALT_FOV_HEADING")
        ScaleformMovieMethodAddParamFloat(GetEntityCoords(helicopter).z)
        ScaleformMovieMethodAddParamFloat(zoomValue)
        ScaleformMovieMethodAddParamFloat(GetCamRot(camera, 2).z)
        EndScaleformMovieMethod()

        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)

        changeFov(camera)

        Citizen.Wait(1)
    end

    ClearFocus()
    ClearTimecycleModifier()
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    DestroyCam(camera, false)
    RenderScriptCams(false, false, 0, 1, 0)
    SetNightvision(false)
    SetSeethrough(false)
end

function moveCam(camera, zoom)
    local controlX = GetDisabledControlNormal(0, 220)
    local controlY = GetDisabledControlNormal(0, 221)
    local camRotation = GetCamRot(camera, 2)
    if controlX ~= 0.0 or controlY ~= 0.0 then
        newZ = camRotation.z + controlX * -1.0 * Config.Speeds.Altitude * (zoom + 0.1)
        newX = math.max(math.min(20.0, camRotation.x + controlY * -1.0 * Config.Speeds.Sides * (zoom + 0.1)), -89.5)
        SetCamRot(camera, newX, 0.0, newZ, 2)
    end
end

function changeFov(camera)
    local currentFov = GetCamFov(camera)
    if IsDisabledControlJustPressed(0, 241) then
        fov = math.max(fov - Config.Speeds.Zoom, Config.Fov.Min)
    elseif IsDisabledControlJustPressed(0, 242) then
        fov = math.min(fov + Config.Speeds.Zoom, Config.Fov.Max)
    end

    if math.abs(fov - currentFov) < 0.1 then
        fov = currentFov
    end

    SetCamFov(camera, currentFov + (fov - currentFov) * 0.05)
end

function getVehicle(camera)
    local camCoords = GetCamCoord(camera)
    local vector = getVector(GetCamRot(camera, 2))
    local ray = StartExpensiveSynchronousShapeTestLosProbe(camCoords, camCoords + (vector * 200.0), 19,
        GetVehiclePedIsIn(PlayerPedId()), 0)
    local x, x, x, x, entityHit = GetShapeTestResult(ray)

    if entityHit > 0 and IsEntityAVehicle(entityHit) then
        return entityHit
    else
        return nil
    end
end

function getVector(rotation)
    local vecZ = math.rad(rotation.z)
    local vecX = math.rad(rotation.x)
    local vecNum = math.abs(math.cos(vecX))
    return vector3(-math.sin(vecZ) * vecNum, math.cos(vecZ) * vecNum, math.sin(vecX))
end

function vehicleInfo(vehicle)
    local vehLabel = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    local vehPlate = GetVehicleNumberPlateText(vehicle)
    if vehPlate == "" or vehPlate == " " or vehPlate == "        " then
        vehPlate = "nenalezena"
    end
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("Model vozidla: " .. vehLabel .. "\n SPZ vozidla: " .. vehPlate)
    DrawText(0.40, 0.9)
end

RegisterCommand("rapple", function()

    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)

    if GetVehicleClass(playerVeh) ~= 15 then
        exports.notify:display({
            type = "error",
            title = "Sklaňování",
            text = "Nejsi ve vrtulníku!",
            icon = "fas fa-hand-rock",
            length = 3000
        })
        return
    end

    if GetPedInVehicleSeat(playerVeh, 1) ~= playerPed and GetPedInVehicleSeat(playerVeh, 2) ~= playerPed then
        exports.notify:display({
            type = "error",
            title = "Sklaňování",
            text = "Z tvého místa se nemůžeš slaňovat!",
            icon = "fas fa-hand-rock",
            length = 4000
        })
        return
    end

    if not DoesVehicleAllowRappel(playerVeh) then
        exports.notify:display({
            type = "error",
            title = "Sklaňování",
            text = "Tenhle vrtulník nemá slaňování!",
            icon = "fas fa-hand-rock",
            length = 4000
        })
        return
    end

    local height = GetEntityHeightAboveGround(playerVeh)
    if height > 15.0 then
        exports.notify:display({
            type = "error",
            title = "Sklaňování",
            text = "Jsi moc vysoko na slaňování!",
            icon = "fas fa-hand-rock",
            length = 4000
        })
    else
        TriggerServerEvent("heli_cam:startRapple")
    end
end)

createNewKeyMapping({
    command = "rapple",
    text = "Slaňování z vrtulníku",
    key = ""
})

RegisterNetEvent("heli_cam:startRapple")
AddEventHandler("heli_cam:startRapple", function(source)
    if not NetworkDoesEntityExistWithNetworkId(source) then
        return
    end
    local playerPed = NetToPed(source)
    TaskRappelFromHeli(playerPed, 10)

end)