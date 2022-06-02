local using = false
local isSpawned, isDead, isCuffed = false, false, false
local usingCamera = false

local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0
local fov_max = 70.0
local fov_min = 5.0
local fov = (fov_max + fov_min) * 0.5

local UI = {
    x = 0.000,
    y = -0.001,
}

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if Config.Items[itemName] and not using then
            using = itemName
            if itemName == "microphone" then
                takeMicrophone()
            elseif itemName == "microphone_weazel" then
                takeMicrophoneWeazel()
            elseif itemName == "microphonebig" then
                takeBigMicrophone()
            elseif itemName == "cam_recording" then
                takeCamera()
            end
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == ("spawned" or "dead") then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == ("spawned" or "dead") then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

function takeMicrophone()
    local model = GetHashKey("ba_prop_battle_mic")
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end

    loadAnimDict("missheistdocksprep1hold_cellphone")

    local pCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local microphone = CreateObject(model, pCoords, 1, 1, 1)
    Citizen.Wait(1000)
    local microphoneNetId = NetworkGetNetworkIdFromEntity(microphone)
    AttachEntityToEntity(
        microphone,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 60309),
        0.055,
        0.05,
        0.0,
        240.0,
        0.0,
        0.0,
        1,
        1,
        0,
        1,
        0,
        1
    )
    exports.key_hints:displayBottomHint(
        {
            name = "recording_equipment",
            key = "~INPUT_VEH_HEADLIGHT~",
            text = "Schovat mikrofon"
        }
    )
    TaskPlayAnim(PlayerPedId(), "missheistdocksprep1hold_cellphone", "hold_cellphone", 1.0, -1, -1, 50, 0, 0, 0, 0)
    while using == "microphone" do
        if IsControlJustReleased(0, 74) or isDead then
            ClearPedSecondaryTask(PlayerPedId())
            local micObject = NetworkGetEntityFromNetworkId(microphoneNetId)
            DetachEntity(micObject, 1, 1)
            DeleteEntity(micObject)
            using = false
        end
        Citizen.Wait(1)
    end
    exports.key_hints:hideBottomHint({ name = "recording_equipment" })
end

function takeMicrophoneWeazel()
    local model = GetHashKey("p_ing_microphonel_01")
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end

    loadAnimDict("missheistdocksprep1hold_cellphone")

    local pCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local microphone = CreateObject(model, pCoords, 1, 1, 1)
    Citizen.Wait(1000)
    local microphoneNetId = NetworkGetNetworkIdFromEntity(microphone)
    AttachEntityToEntity(
        microphone,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 60309),
        0.055,
        0.05,
        0.0,
        240.0,
        0.0,
        0.0,
        1,
        1,
        0,
        1,
        0,
        1
    )
    exports.key_hints:displayBottomHint(
        {
            name = "recording_equipment",
            key = "~INPUT_VEH_HEADLIGHT~",
            text = "Schovat mikrofon"
        }
    )
    TaskPlayAnim(PlayerPedId(), "missheistdocksprep1hold_cellphone", "hold_cellphone", 1.0, -1, -1, 50, 0, 0, 0, 0)
    while using == "microphone_weazel" do
        if IsControlJustReleased(0, 74) or isDead then
            ClearPedSecondaryTask(PlayerPedId())
            local micObject = NetworkGetEntityFromNetworkId(microphoneNetId)
            DetachEntity(micObject, 1, 1)
            DeleteEntity(micObject)
            using = false
        end
        Citizen.Wait(1)
    end
    exports.key_hints:hideBottomHint({ name = "recording_equipment" })
end

function takeBigMicrophone()
    local model = GetHashKey("prop_v_bmike_01")
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end

    loadAnimDict("missfra1")

    local pCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local bigMicrophone = CreateObject(model, pCoords, 1, 1, 1)
    Citizen.Wait(1000)
    local bigMicrophoneNetId = NetworkGetNetworkIdFromEntity(bigMicrophone)
    AttachEntityToEntity(
        bigMicrophone,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 28422),
        -0.08,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1,
        1,
        0,
        1,
        0,
        1
    )
    exports.key_hints:displayBottomHint(
        {
            name = "recording_equipment",
            key = "~INPUT_VEH_HEADLIGHT~",
            text = "Schovat velký mikrofon"
        }
    )
    TaskPlayAnim(PlayerPedId(), "missfra1", "mcs2_crew_idle_m_boom", 1.0, -1, -1, 50, 0, 0, 0, 0)

    while using == "microphonebig" do
        if not IsEntityPlayingAnim(PlayerPedId(), "missfra1", "mcs2_crew_idle_m_boom", 3) then
            TaskPlayAnim(PlayerPedId(), "missfra1", "mcs2_crew_idle_m_boom", 1.0, -1, -1, 50, 0, 0, 0, 0)
        end

        if IsControlJustReleased(0, 74) or isDead then
            ClearPedSecondaryTask(PlayerPedId())
            local micObject = NetworkGetEntityFromNetworkId(bigMicrophoneNetId)
            DetachEntity(micObject, 1, 1)
            DeleteEntity(micObject)
            using = false
        end

        Citizen.Wait(1)
    end
    exports.key_hints:hideBottomHint({ name = "recording_equipment" })
end

function takeCamera()
    local model = GetHashKey("prop_v_cam_01")
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
    loadAnimDict("missfinale_c2mcs_1")

    local pCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local camera = CreateObject(model, pCoords, 1, 1, 1)
    Citizen.Wait(1000)
    local cameraNetId = NetworkGetNetworkIdFromEntity(camera)
    AttachEntityToEntity(
        camera,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 28422),
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1,
        1,
        0,
        1,
        0,
        1
    )

    exports.key_hints:displayBottomHint(
        {
            name = "recording_equipment",
            key = "~INPUT_VEH_HEADLIGHT~",
            text = "Schovat kameru"
        }
    )
    exports.key_hints:displayBottomHint(
        {
            name = "recording_equipment_use",
            key = "~INPUT_PICKUP~",
            text = "Použít kameru"
        }
    )
    TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, -1, -1, 50, 0, 0, 0, 0)

    while using == "cam_recording" do
        if not IsEntityPlayingAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3) then
            TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, -1, -1, 50, 0, 0, 0, 0)
        end

        if IsControlJustReleased(0, 74) or isDead then
            ClearPedSecondaryTask(PlayerPedId())
            local camObject = NetworkGetEntityFromNetworkId(cameraNetId)
            DetachEntity(camObject, 1, 1)
            DeleteEntity(camObject)
            using = false
        end

        if IsControlJustReleased(0, 38) then
            usingCamera = true
            SetTimecycleModifier("default")

            SetTimecycleModifierStrength(0.3)

            Citizen.Wait(10)

            local lPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(lPed)
            local cam1 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

            AttachCamToEntity(cam1, lPed, 0.0, 0.65, 0.6, true)
            SetCamRot(cam1, 2.0, 1.0, GetEntityHeading(lPed))
            SetCamFov(cam1, fov)
            RenderScriptCams(true, false, 0, 1, 0)

            while usingCamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) do
                if IsControlJustReleased(0, 38) then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    usingCamera = false
                end

                SetEntityRotation(lPed, 0, 0, new_z, 2, true)

                local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
                CheckInputRotation(cam1, zoomvalue)

                HandleZoom(cam1)
                HideHUDThisFrame()

                local camHeading = GetGameplayCamRelativeHeading()
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Heading", camHeading * -1.0 + 1.0)

                Citizen.Wait(0)
            end

            usingCamera = false
            ClearTimecycleModifier()
            fov = (fov_max + fov_min) * 0.5
            RenderScriptCams(false, false, 0, 1, 0)
            DestroyCam(cam1, false)
            SetNightvision(false)
            SetSeethrough(false)
        end

        Citizen.Wait(1)
    end
    exports.key_hints:hideBottomHint({ name = "recording_equipment" })
    exports.key_hints:hideBottomHint({ name = "recording_equipment_use" })
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(11)
    HideHudComponentThisFrame(12)
    HideHudComponentThisFrame(15)
    HideHudComponentThisFrame(18)
    HideHudComponentThisFrame(19)
end

function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        new_z = rotation.z + rightAxisX * -1.0 * (speed_ud) * (zoomvalue + 0.1)
        new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (speed_lr) * (zoomvalue + 0.1)), -89.5)
        SetCamRot(cam, new_x, 0.0, new_z, 2)
    end
end

function HandleZoom(cam)
    local lPed = PlayerPedId()
    if not (IsPedSittingInAnyVehicle(lPed)) then

        if IsControlJustPressed(0, 241) then
            fov = math.max(fov - zoomspeed, fov_min)
        end
        if IsControlJustPressed(0, 242) then
            fov = math.min(fov + zoomspeed, fov_max)
        end
        local current_fov = GetCamFov(cam)
        if math.abs(fov - current_fov) < 0.1 then
            fov = current_fov
        end
        SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
    else
        if IsControlJustPressed(0, 17) then
            fov = math.max(fov - zoomspeed, fov_min)
        end
        if IsControlJustPressed(0, 16) then
            fov = math.min(fov + zoomspeed, fov_max)
        end
        local current_fov = GetCamFov(cam)
        if math.abs(fov - current_fov) < 0.1 then
            fov = current_fov
        end
        SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
    end
end
