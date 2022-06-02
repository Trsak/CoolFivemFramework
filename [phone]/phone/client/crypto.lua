RegisterNUICallback('GetCryptoData', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-crypto:server:GetCryptoData', function(CryptoData)
            cb(CryptoData)
        end, data.crypto)]]
end)

RegisterNUICallback('BuyCrypto', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-crypto:server:BuyCrypto', function(CryptoData)
            cb(CryptoData)
        end, data)]]
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    --[[    QBCore.Functions.TriggerCallback('qb-crypto:server:SellCrypto', function(CryptoData)
            cb(CryptoData)
        end, data)]]
end)

RegisterNUICallback('TransferCrypto', function(data, cb)
    --[[    QBCore.Functions.TriggerCallback('qb-crypto:server:TransferCrypto', function(CryptoData)
            cb(CryptoData)
        end, data)]]
end)


RegisterNUICallback('GetCryptoTransactions', function(data, cb)
    local Data = {
        CryptoTransactions = PhoneData.CryptoTransactions
    }
    cb(Data)
end)