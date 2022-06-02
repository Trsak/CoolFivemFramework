RegisterNetEvent('qb-phone:client:RemoveBankMoney')
AddEventHandler('qb-phone:client:RemoveBankMoney', function(amount)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Bank",
            text = "$"..amount.." has been removed from your balance!",
            icon = "fas fa-university",
            color = "#ff002f",
            timeout = 3500,
        },
    })
end)

RegisterNetEvent("qb-phone:client:BankNotify")
AddEventHandler("qb-phone:client:BankNotify", function(text)
    SendNUIMessage({
        action = "PhoneNotification",
        NotifyData = {
            title = "Bank",
            content = text,
            icon = "fas fa-university",
            timeout = 3500,
            color = "#ff002f",
        },
    })
end)

RegisterNetEvent('qb-phone:client:AddTransaction')
AddEventHandler('qb-phone:client:AddTransaction', function(SenderData, TransactionData, Message, Title)
    local Data = {
        TransactionTitle = Title,
        TransactionMessage = Message,
    }

    table.insert(PhoneData.CryptoTransactions, Data)

    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Crypto",
            text = Message,
            icon = "fas fa-chart-pie",
            color = "#04b543",
            timeout = 1500,
        },
    })

    SendNUIMessage({
        action = "UpdateTransactions",
        CryptoTransactions = PhoneData.CryptoTransactions
    })

    TriggerServerEvent('qb-phone:server:AddTransaction', Data)
end)

RegisterNetEvent('qb-phone:client:TransferMoney')
AddEventHandler('qb-phone:client:TransferMoney', function(amount, newmoney)
    PhoneData.PlayerData.money.bank = newmoney
    --[[if PhoneData.isOpen then
        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "QBank", text = "&#36;"..amount.." has been added to your account!", icon = "fas fa-university", color = "#8c7ae6", }, })
        SendNUIMessage({ action = "UpdateBank", NewBalance = PhoneData.PlayerData.money.bank })
    else
        SendNUIMessage({ action = "Notification", NotifyData = { title = "QBank", content = "&#36;"..amount.." has been added to your account!", icon = "fas fa-university", timeout = 2500, color = nil, }, })
    end]]
end)

RegisterNUICallback('GetBank', function(data, cb)
    TriggerServerEvent('qb-phone:server:GetBank')
    RegisterNetEvent("qb-phone:client:GetBank")
    AddEventHandler("qb-phone:client:GetBank", function(bank, fine, invo)
        cb(bank)
        PhoneData.Fines = fine
        PhoneData.Invoices = invo
    end)
end)

RegisterNUICallback('TransferMoney', function(data, cb)
    data.amount = tonumber(data.amount)
    if tonumber(PhoneData.PlayerData.money.bank) >= data.amount then
        local amaountata = PhoneData.PlayerData.money.bank - data.amount
        TriggerServerEvent('qb-phone:server:TransferMoney', data.iban, data.amount)
        local cbdata = {
            CanTransfer = true,
            NewAmount = amaountata
        }
        cb(cbdata)
    else
        local cbdata = {
            CanTransfer = false,
            NewAmount = nil,
        }
        cb(cbdata)
    end
end)

RegisterNUICallback('CanTransferMoney', function(data, cb)
    TriggerServerEvent("qb-phone:server:TransferMoney", data)
    RegisterNetEvent('qb-phone:client:CanTransferMoney')
    AddEventHandler('qb-phone:client:CanTransferMoney', function(status, bank)
        PhoneData.PlayerData.bank = bank
        Bank = bank
        cb({TransferedMoney = status, Bank = bank})
    end)
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    TriggerServerEvent("qb-phone:server:TransferMoney", data)
    RegisterNetEvent('qb-phone:client:CanTransferMoney')
    AddEventHandler('qb-phone:client:CanTransferMoney', function(status, bank)
        PhoneData.PlayerData.bank = bank
        Bank = bank
        cb({TransferedMoney = status, Bank = bank})
    end)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local sender = data.sender
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId

    --[[    QBCore.Functions.TriggerCallback('qb-phone:server:DeclineInvoice', function(CanPay, Invoices)
            PhoneData.Invoices = Invoices
            cb('ok')
        end, society, amount, invoiceId)]]
    --TriggerServerEvent('qb-phone:server:BillingEmail', data, false)
end)

RegisterNUICallback('PayFine', function(data, cb)
    TriggerServerEvent("qb-phone:server:TransferMoney", data)
    RegisterNetEvent('qb-phone:client:CanTransferMoney')
    AddEventHandler('qb-phone:client:CanTransferMoney', function(status, bank)
        PhoneData.PlayerData.bank = bank
        Bank = bank
        cb({TransferedMoney = status, Bank = bank})
    end)
end)

RegisterNUICallback('DeclineFine', function(data, cb)
    local sender = data.sender
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId

    --[[    QBCore.Functions.TriggerCallback('qb-phone:server:DeclineInvoice', function(CanPay, Invoices)
            PhoneData.Invoices = Invoices
            cb('ok')
        end, society, amount, invoiceId)]]
    --TriggerServerEvent('qb-phone:server:BillingEmail', data, false)
end)