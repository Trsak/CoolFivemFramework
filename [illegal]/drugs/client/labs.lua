local labs = {}

RegisterNetEvent("drugs:sendLabs", function(newLabs)
    labs = newLabs
    createPoints(labs)
end)

RegisterNetEvent("drugs:answerItemCheck", function(pointIndex, canCraft)
    
    if canCraft then
        craft(pointIndex)
    else
        exports.notify:display({
            type = "error",
            title = "Výroba drog",
            text = "Na výrobu ti něco chybí!",
            icon = "fas fa-prescription-bottle",
            length = 5000
        })
    end
end)

function craft(pointIndex)
    local labData = labs[pointIndex]

    if not labData then
        return
    end

    local sceneId, sceneProps = startAnim(labData.Drug, labData.Type, pointIndex)

    local data = Config.Dependencies[labData.Drug][labData.Type]
    exports.progressbar:startProgressBar({
        Duration = data.Length,
        Label = data.Label,
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = (sceneId and sceneProps) and nil or data.Anim
    }, function(finished)

        if finished then
            TriggerServerEvent("drugs:craftItem", pointIndex)
        end

        if sceneId and sceneProps then
            NetworkStopSynchronisedScene(sceneId)
            for _, objId in pairs(sceneProps) do
                DeleteEntity(objId)
            end
        end
    end)
end

function createPoints(newLabs)
    for pointId, pointData in pairs(newLabs) do
        print (pointData.Drug .. "-" .. pointData.Type)
        exports.target:AddCircleZone(pointData.Drug .. "-" .. pointData.Type .. "-" .. pointId, pointData.Coords, 1.0, {
            actions = {
                enter = {
                    cb = function(data)
                        TriggerServerEvent("drugs:checkItems", data.Index)
                    end,
                    cbData = {
                        Index = pointId
                    },
                    icon = "fas fa-prescription-bottle",
                    label = Config.Dependencies[pointData.Drug][pointData.Type].Target
                }
            },
            distance = 0.2
        })
    end
end

function startAnim(drug, type, index)
    local typeData = Config.Dependencies[drug][type]

    if not typeData.Anims or not typeData.Anims.AnimDict then
        return nil, nil
    end

    while not HasAnimDictLoaded(typeData.Anims.AnimDict) do
        RequestAnimDict(typeData.Anims.AnimDict)
        Wait(0)
    end
    
    local labData = labs[index]
    local coords = labData.Type == "mixing" and (labData.Coords - labData.Offset) or (labData.Coords + labData.Offset)
    
    local scene = NetworkCreateSynchronisedScene(coords, labData.Rot, 2, false, false, 1.0, 0, 1.0)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, typeData.Anims.AnimDict, typeData.Anims.Player, 1.0, 1.0, 0,
        0, 1.0, 0)
        
    local props = {}
    for name, prop in pairs(typeData.Props) do
        
        local model = GetHashKey(prop)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Wait(0)
        end
        props[name] = CreateObject(model, coords, true)
        
        SetModelAsNoLongerNeeded(model)
        while not DoesEntityExist(props[name]) do
            Wait(0)
        end
        SetEntityCollision(props[name], false, false)
        NetworkAddEntityToSynchronisedScene(props[name], scene, typeData.Anims.AnimDict, typeData.Anims.Props[name],
            1.0, 1.0, 1)
    end
    NetworkStartSynchronisedScene(scene)
    return scene, props
end
