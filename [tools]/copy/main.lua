function copyToInsert(text)
    SendNUIMessage(
        {
            action = "copy",
            data = tostring(text)
        }
    )
end

RegisterNetEvent("copy:copyToInsert")
AddEventHandler("copy:copyToInsert",
    function(text)
        copyToInsert(text)
    end
)
