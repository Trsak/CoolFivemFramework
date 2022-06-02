local CanDownloadApps = false

RegisterNUICallback('SetupStoreApps', function(data, cb)
    local data = {
        StoreApps = Config.StoreApps,
        PhoneData = PhoneData.Metadata
    }
    cb(data)
end)

RegisterNUICallback('RemoveApplication', function(data, cb)
    TriggerServerEvent('qb-phone:server:RemoveInstallation', PhoneData.MetaData, data.app)
end)

RegisterNUICallback('InstallApplication', function(data, cb)
    local ApplicationData = Config.StoreApps[data.app]
    local NewSlot = GetFirstAvailableSlot()
    local found = false
    if not CanDownloadApps then
        return
    end

    for _, v in each(ApplicationData) do
        if v.app == AplicationData.app then
            found = true
            break
        end
    end

    if NewSlot <= PhoneData.MetaData.MaxApps and not found then
        TriggerServerEvent('qb-phone:server:InstallApplication', {
            app = data.app,
            MData = PhoneData.MetaData
        })
        cb({
            app = data.app,
            data = ApplicationData
        })
    else
        cb(false)
    end
end)