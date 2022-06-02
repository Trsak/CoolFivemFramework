function setBindOverwritten(bindNumber, toggle)
    isBindOverwritten[bindNumber] = toggle
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if isSpawned and not isDead then
                DisableControlAction(0, 157)
                DisableControlAction(0, 158)
                DisableControlAction(0, 160)
                DisableControlAction(0, 164)
                DisableControlAction(0, 165)

                if not isBindOverwritten[1] and IsDisabledControlJustPressed(0, 157) then
                    useSlotBind(1)
                elseif not isBindOverwritten[2] and IsDisabledControlJustPressed(0, 158) then
                    useSlotBind(2)
                elseif not isBindOverwritten[3] and IsDisabledControlJustPressed(0, 160) then
                    useSlotBind(3)
                elseif not isBindOverwritten[4] and IsDisabledControlJustPressed(0, 164) then
                    useSlotBind(4)
                elseif not isBindOverwritten[5] and IsDisabledControlJustPressed(0, 165) then
                    useSlotBind(5)
                end
            end
        end
    end
)

function useSlotBind(bindNumber)
    local item = getItemBySlot(bindNumber)
    if item ~= nil then
        tryToUseItem(item.name, false, bindNumber)
    end
end