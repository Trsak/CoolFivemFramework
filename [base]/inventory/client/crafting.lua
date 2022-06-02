local defaultAnim = {
    animDict = "mp_arresting",
    anim = "a_uncuff",
    flags = 51
}
RegisterNUICallback("startItemCrafting", function(data, cb)
    local id = tonumber(data.id) + 1
    local craftingData = CRAFTING_RECIPES[id]
    local itemsToCraft = data.count

    if not craftingData then
        return
    end

    craftItem(id, craftingData, itemsToCraft)

    cb(true);
end)

function craftItem(id, craftingData, itemsToCraft)
    if itemsToCraft <= 0 then
        return
    end
    exports.progressbar:startProgressBar({
        Duration = craftingData.duration,
        Label = craftingData.actionText,
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = craftingData.anim or defaultAnim
    }, function(finished)
        if finished then
            TriggerServerEvent("inventory:craftItem", id, itemsToCraft)
            craftItem(id, craftingData, itemsToCraft - 1)
        else
            TriggerServerEvent("inventory:stopCraft")
            return
        end
    end)
end

function getRecipes(item)
    local recipes = {}
    for i, data in each(CRAFTING_RECIPES) do
        if data.item == item then

        end
    end
end
