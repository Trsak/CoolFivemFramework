RegisterNetEvent("vehiclelock:setVehicleLockStatus")
AddEventHandler("vehiclelock:setVehicleLockStatus",
    function(vehNetId, locked)
        local client = source
        local vehEntity

        local i = 0
        while i < 20 do
            vehEntity = NetworkGetEntityFromNetworkId(vehNetId)
            if vehEntity ~= 0 then
                break
            end

            Wait(200)
            i = i + 1
        end

        local owner = NetworkGetEntityOwner(vehEntity)
        if owner == nil or owner <= 0 then
            owner = client
        end

        local ent = Entity(vehEntity)
        ent.state.locked = locked

        TriggerClientEvent("vehiclelock:setVehicleLockStatus", owner, vehNetId, locked)

        if locked then
            lockVehicle(vehEntity)
        else
            unlockVehicle(vehEntity)
        end
    end
)

function lockVehicle(veh)
    SetVehicleDoorsLocked(veh, 2)
end

function unlockVehicle(veh)
    SetVehicleDoorsLocked(veh, 1)
end
