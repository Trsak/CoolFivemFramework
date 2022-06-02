RegisterNUICallback('GetTruckerData', function(data, cb)
    --local TruckerMeta = QBCore.Functions.GetPlayerData().metadata["jobrep"]["trucker"]
    --local TierData = exports['qb-trucker']:GetTier(TruckerMeta)
    cb(TierData)
end)