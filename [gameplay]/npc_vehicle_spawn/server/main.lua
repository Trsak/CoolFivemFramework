AddEventHandler(
    "entityCreating",
    function(id)
        local _source = source
        local eType = GetEntityType(id)

        if eType == 2 then
            local speed = GetEntityVelocity(id)
            if #(speed - vector3(0, 0, 0)) > 5.0 then
                print("yayyy")
            end

            print(GetPedInVehicleSeat(id, 1))
        end
    end
)
