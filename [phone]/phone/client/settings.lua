RegisterNUICallback('SetBackground', function(data)
    local background = data.background

    PhoneData.MetaData.settings.background = background
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
end)

RegisterNUICallback('SetLockBackground', function(data)
    local lockscreen = data.lockscreen

    PhoneData.MetaData.settings.lockscreen = lockscreen
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
end)

RegisterNUICallback('SaveSettings', function(data, cb)
    PhoneData.MetaData.settings = data.data
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
    SendNUIMessage({
        action = "RefreshData",
        MetaData = PhoneData.MetaData
    })
    cb(true)
end)