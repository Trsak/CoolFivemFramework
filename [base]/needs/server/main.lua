RegisterNetEvent("needs:update")
AddEventHandler("needs:update",
    function(needs)
        local _source = source 
        if needs then 
            exports.data:updateCharVar(_source, "needs", needs)
        end
    end
)