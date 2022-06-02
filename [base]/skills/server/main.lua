RegisterNetEvent("skills:update")
AddEventHandler("skills:update",
    function(skills)
        local _source = source 
        if skills ~= nil then
            exports.data:updateCharVar(_source, "skills", skills)
            TriggerEvent("skills:updated", _source, skills)
        end
    end
)
