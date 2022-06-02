local smokeLocation = 31086

local smokeParticle = "exp_grd_bzgas_smoke"
local smokeParticleAsset = "core"

local createdSmoke, createdPart
local createdItemSmoke, createdItemSmokePart

RegisterNetEvent("smokable:startSmokeCigarette")
AddEventHandler(
    "smokable:startSmokeCigarette",
    function(prop)
        loadModel(prop)
        isSmoking = "cigarette"
        exports.emotes:DisableEmotes(true)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerCoords = vec3(playerCoords.xy, playerCoords.z + 0.9)
        startAnim("amb@world_human_smoking@male@male_a@enter", "enter", 9000)
        Citizen.Wait(800)
        local newCigarette = CreateObject(GetHashKey("prop_amb_ciggy_01"), playerCoords, true, true, true)
        AttachEntityToEntity(
            newCigarette,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            0.02,
            -0.008,
            100.0,
            0.0,
            100.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(newCigarette, false, true)
        Citizen.Wait(1700)
        DetachEntity(newCigarette, 1, 1)
        AttachEntityToEntity(
            newCigarette,
            playerPed,
            GetPedBoneIndex(playerPed, 47419),
            0.015,
            -0.009,
            0.003,
            55.0,
            0.0,
            110.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        Citizen.Wait(1100)
        local lighter = CreateObject(GetHashKey(prop), playerCoords, true, true, true)
        AttachEntityToEntity(
            lighter,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            -0.03,
            -0.010,
            100.0,
            0.0,
            150.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(lighter, false, true)
        Citizen.Wait(3100)
        TriggerServerEvent("smokable:lighterEffect", NetworkGetNetworkIdFromEntity(lighter))
        DetachEntity(newCigarette, 1, 1)
        DeleteObject(newCigarette)
        cigarette = CreateObject(GetHashKey("ng_proc_cigarette01a"), playerCoords, true, true, true)
        AttachEntityToEntity(
            cigarette,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            0.02,
            -0.008,
            100.0,
            0.0,
            100.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(cigarette, false, true)
        Citizen.Wait(2000)
        DetachEntity(lighter, 1, 1)
        DeleteObject(lighter)
        exports.key_hints:displayBottomHint(
            {
                name = "smoke",
                key = "~INPUT_REPLAY_SCREENSHOT~",
                text = "Potáhnout"
            }
        )
        exports.key_hints:displayBottomHint(
            {
                name = "stop_smoke",
                key = "~INPUT_REPLAY_SHOWHOTKEY~",
                text = "Típnout"
            }
        )

        createdItemSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
        createdItemSmokePart = StartNetworkedParticleFxLoopedOnEntity(smokeParticle, cigarette, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,0.05, 0.0, 0.0, 0.0)

        local smoking = false
        while isSmoking do
            local playerPed = PlayerPedId()
            if IsEntityInWater(playerPed) then
                Citizen.Wait(800)
                SmokeDone(cigarette)
            else
                if not smoking and IsControlJustReleased(0, 303) then
                    smoking = true
                    local anim = Config.SmokeAnims[math.random(1, #Config.SmokeAnims)]
                    startAnim(anim[1], anim[2], 5800)
                    Wait(2000)
                    createdSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
                    createdPart = StartNetworkedParticleFxLoopedOnEntityBone(smokeParticle, playerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(playerPed, smokeLocation), 0.15, 0.0, 0.0, 0.0)
                    Citizen.Wait(2000)
                    smokeStop()
                    smoking = false
                elseif not smoking and IsControlJustReleased(0, 311) then
                    SmokeDone(cigarette)
                end
            end
            Citizen.Wait(0)
        end
    end
)

RegisterNetEvent("smokable:lighterEffect")
AddEventHandler(
    "smokable:lighterEffect",
    function(lighter)
        local lighter = NetworkGetEntityFromNetworkId(lighter)
        if DoesEntityExist(lighter) then
            local fireDict = UseParticleFxAssetNextCall("core")
            local fireName = StartParticleFxLoopedOnEntity("ent_amb_torch_fire", lighter, 0.0, 0.0, 0.050, 0.0, 0.0, 0.0, 0.03, 0.0, 0.0, 0.0)
            Wait(400)

            StopParticleFxLooped(fireDict, 1)
            StopParticleFxLooped(fireName, 1)

            Wait(1900)
            RemoveParticleFxFromEntity(light)
        end
    end
)

function smokeStop()
    while createdSmoke and DoesParticleFxLoopedExist(createdSmoke) do
        StopParticleFxLooped(createdSmoke, 1)
        Wait(0)
    end

    while createdPart and DoesParticleFxLoopedExist(createdPart) do
        StopParticleFxLooped(createdPart, 1)
        Wait(0)
    end

    while smokeParticle and DoesParticleFxLoopedExist(smokeParticle) do
        StopParticleFxLooped(smokeParticle, 1)
        Wait(0)
    end

    while smokeParticleAsset and DoesParticleFxLoopedExist(smokeParticleAsset) do
        StopParticleFxLooped(smokeParticleAsset, 1)
        Wait(0)
    end

    Wait(250)
    RemoveParticleFxFromEntity(PlayerPedId())
end

function SmokeDone(item)
    startAnim("amb@world_human_smoking@male@male_a@exit", "exit", 3000)
    exports.key_hints:hideBottomHint({ name = "smoke" })
    exports.key_hints:hideBottomHint({ name = "stop_smoke" })
    local playerPed = PlayerPedId()
    Citizen.Wait(1700)

    while createdItemSmoke and DoesParticleFxLoopedExist(createdItemSmoke) do
        StopParticleFxLooped(createdItemSmoke, 1)
        Wait(0)
    end

    while createdItemSmokePart and DoesParticleFxLoopedExist(createdItemSmokePart) do
        StopParticleFxLooped(createdItemSmokePart, 1)
        Wait(0)
    end

    while smokeParticle and DoesParticleFxLoopedExist(smokeParticle) do
        StopParticleFxLooped(smokeParticle, 1)
        Wait(0)
    end

    while smokeParticleAsset and DoesParticleFxLoopedExist(smokeParticleAsset) do
        StopParticleFxLooped(smokeParticleAsset, 1)
        Wait(0)
    end

    Wait(250)
    RemoveParticleFxFromEntity(PlayerPedId())


    DetachEntity(item, 1, 1)
    Citizen.Wait(500)
    RemoveParticleFxFromEntity(item)
    isSmoking = false
    TriggerServerEvent("smokable:stopSmoke")
    exports.emotes:DisableEmotes(false)
end

function startAnim(dict, anim, dur)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 1.0, -1.0, dur, 49, 1, false, false, false)
    RemoveAnimDict(dict)
end
function loadModel(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(0)
    end
end

RegisterNetEvent("smokable:startSmokeCig")
AddEventHandler(
    "smokable:startSmokeCig",
    function(prop)
        loadModel(prop)
        isSmoking = "cig"
        exports.emotes:DisableEmotes(true)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerCoords = vec3(playerCoords.xy, playerCoords.z + 0.9)
        startAnim("amb@world_human_smoking@male@male_a@enter", "enter", 9000)
        Citizen.Wait(800)
        local newCigar = CreateObject(GetHashKey("prop_cigar_03"), playerCoords, true, true, true)
        AttachEntityToEntity(
            newCigar,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            0.02,
            -0.008,
            100.0,
            0.0,
            -100.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(newCigar, false, true)
        Citizen.Wait(1700)
        DetachEntity(newCigar, 1, 1)
        AttachEntityToEntity(
            newCigar,
            playerPed,
            GetPedBoneIndex(playerPed, 47419),
            0.010,
            0.0,
            0.0,
            50.0,
            0.0,
            -80.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        Citizen.Wait(1100)
        local lighter = CreateObject(GetHashKey(prop), pCoords, true, true, true)
        AttachEntityToEntity(
            lighter,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            -0.03,
            -0.010,
            100.0,
            0.0,
            150.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(lighter, false, true)
        Citizen.Wait(3100)
        TriggerServerEvent("smokable:lighterEffect", NetworkGetNetworkIdFromEntity(lighter))
        DetachEntity(newCigar, 1, 1)
        DeleteObject(newCigar)
        cigar = CreateObject(GetHashKey("prop_cigar_03"), pCoords, true, true, true)
        AttachEntityToEntity(
            cigar,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            0.02,
            -0.008,
            100.0,
            0.0,
            -100.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(cigar, false, true)
        Citizen.Wait(2000)
        DetachEntity(lighter, 1, 1)
        DeleteObject(lighter)
        exports.key_hints:displayBottomHint(
            {
                name = "smoke",
                key = "~INPUT_REPLAY_SCREENSHOT~",
                text = "Potáhnout"
            }
        )
        exports.key_hints:displayBottomHint(
            {
                name = "stop_smoke",
                key = "~INPUT_REPLAY_SHOWHOTKEY~",
                text = "Típnout"
            }
        )

        createdItemSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
        createdItemSmokePart = StartNetworkedParticleFxLoopedOnEntity(smokeParticle, cigar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,0.05, 0.0, 0.0, 0.0)

        local smoking = false
        while isSmoking do
            local playerPed = PlayerPedId()
            if IsEntityInWater(playerPed) then
                Citizen.Wait(800)
                SmokeDone(cigar)
            else
                if not smoking and IsControlJustReleased(0, 303) then
                    local anim = Config.SmokeAnims[math.random(1, #Config.SmokeAnims)]
                    startAnim(anim[1], anim[2], 2800)
                    Wait(2000)
                    createdSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
                    createdPart = StartNetworkedParticleFxLoopedOnEntityBone(smokeParticle, playerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(playerPed, smokeLocation), 0.3, 0.0, 0.0, 0.0)
                    Citizen.Wait(2000)
                    smokeStop()
                    smoking = false
                elseif not smoking and IsControlJustReleased(0, 311) then
                    SmokeDone(cigar)
                end
            end
            Citizen.Wait(0)
        end
    end
)

RegisterNetEvent("smokable:startSmokeJoint")
AddEventHandler(
    "smokable:startSmokeJoint",
    function(prop)
        loadModel(prop)
        isSmoking = "joint"
        exports.emotes:DisableEmotes(true)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        playerCoords = vec3(playerCoords.xy, playerCoords.z + 0.9)

        startAnim("amb@world_human_smoking@male@male_a@enter", "enter", 9000)
        Citizen.Wait(800)
        local newJoint = CreateObject(GetHashKey("prop_sh_joint_01"), playerCoords, true, true, true)
        AttachEntityToEntity(
            newJoint,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.0,
            0.00,
            -0.01,
            0.0,
            -90.0,
            90.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(newJoint, false, true)
        Citizen.Wait(1700)
        DetachEntity(newJoint, 1, 1)
        AttachEntityToEntity(
            newJoint,
            playerPed,
            GetPedBoneIndex(playerPed, 47419),
            -0.01,
            0.0,
            0.0,
            0.0,
            -90.0,
            90.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        Citizen.Wait(1100)
        local lighter = CreateObject(GetHashKey(prop), pCoords, true, true, true)
        AttachEntityToEntity(
            lighter,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.020,
            -0.03,
            -0.010,
            100.0,
            0.0,
            150.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(lighter, false, true)
        Citizen.Wait(3100)
        TriggerServerEvent("smokable:lighterEffect", NetworkGetNetworkIdFromEntity(lighter))
        DetachEntity(newJoint, 1, 1)
        DeleteObject(newJoint)
        joint = CreateObject(GetHashKey("prop_sh_joint_01"), pCoords, true, true, true)
        AttachEntityToEntity(
            joint,
            playerPed,
            GetPedBoneIndex(playerPed, 64097),
            0.0,
            0.00,
            -0.01,
            0.0,
            -90.0,
            90.0,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(joint, false, true)
        Citizen.Wait(2000)
        DetachEntity(lighter, 1, 1)
        DeleteObject(lighter)
        exports.key_hints:displayBottomHint(
            {
                name = "smoke",
                key = "~INPUT_REPLAY_SCREENSHOT~",
                text = "Potáhnout"
            }
        )
        exports.key_hints:displayBottomHint(
            {
                name = "stop_smoke",
                key = "~INPUT_REPLAY_SHOWHOTKEY~",
                text = "Zahodit"
            }
        )

        createdItemSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
        createdItemSmokePart = StartNetworkedParticleFxLoopedOnEntity(smokeParticle, joint, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,0.05, 0.0, 0.0, 0.0)

        local smoking = false
        while isSmoking do
            local playerPed = PlayerPedId()
            if IsEntityInWater(playerPed) then
                Citizen.Wait(800)
                SmokeDone(joint)
            else
                if not smoking and IsControlJustReleased(0, 303) then
                    local anim = Config.SmokeAnims[math.random(1, #Config.SmokeAnims)]
                    startAnim(anim[1], anim[2], 2800)
                    exports.needs:changeNeed("stress", -3.5)
                    Wait(2000)
                    createdSmoke = UseParticleFxAssetNextCall(smokeParticleAsset)
                    createdPart = StartNetworkedParticleFxLoopedOnEntityBone(smokeParticle, playerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(playerPed, smokeLocation), 0.5, 0.0, 0.0, 0.0)
                    Citizen.Wait(2000)
                    smokeStop()
                    smoking = false
                elseif not smoking and IsControlJustReleased(0, 311) then
                    SmokeDone(joint)
                end
            end
            Citizen.Wait(0)
        end
    end
)