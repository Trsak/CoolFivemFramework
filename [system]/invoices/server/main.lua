local invoices = {}

MySQL.ready(
    function()
        Wait(5)

        MySQL.Async.fetchAll(
            "SELECT * FROM invoices",
            {},
            function(result)
                if #result > 0 then
                    for i, res in each(result) do
                        invoices[res.id] = {
                            Id = res.id,
                            Owner = res.owner,
                            OwnerName = res.ownername,
                            Sender = res.sender,
                            SenderName = res.sendername,
                            SenderChar = res.senderchar,
                            Price = res.price,
                            Bank = res.bank,
                            Items = json.decode(res.items),
                            Date = res.date,
                            Datelabel = os.date("%x %X", res.date),
                            Paid = res.paid,
                            Removed = res.removed,
                            Changed = false
                        }
                    end
                end
                SetTimeout(60000, saveInvoices)
            end
        )
    end
)

RegisterNetEvent("invoices:ask")
AddEventHandler(
    "invoices:ask",
    function(target, invoice)
        local _source = source
        local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        local distance = #(sourceCoords - targetCoords)
        if distance <= 50.0 then
            invoice.SenderChar = exports.data:getCharVar(_source, "id")
            TriggerClientEvent("invoices:ask", target, _source, invoice)
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "invoices:ask",
                "Hráč se pokusil zeptat na fakturu někoho ve vzdálenosti " .. distance
            )
        end
    end
)

RegisterNetEvent("invoices:respond")
AddEventHandler(
    "invoices:respond",
    function(accepted, sender, invoice)
        if accepted then
            TriggerClientEvent(
                "notify:display",
                sender,
                {
                    type = "success",
                    title = "Faktura",
                    text = "Faktura byla přijata",
                    icon = "fas fa-receipt",
                    length = 3500
                }
            )
            giveInvoice(sender, source, invoice)
        else
            TriggerClientEvent(
                "notify:display",
                sender,
                {
                    type = "warning",
                    title = "Faktura",
                    text = "Faktura byla odmítnuta",
                    icon = "fas fa-receipt",
                    length = 3500
                }
            )
        end
    end
)

function giveInvoice(sender, target, invoice)
    local sourceCoords = GetEntityCoords(GetPlayerPed(sender))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    if distance <= 50.0 or sender == "" then
        local invoiceId = generateId()
        local date = os.time()
        if not invoice.SenderName then
            local senderFirstName = exports.data:getCharVar(sender, "firstname")
            local senderLastName = exports.data:getCharVar(sender, "lastname")
            senderName = senderFirstName ..
                " " .. senderLastName .. (tonumber(invoice.Sender) == nil and "" or "  (" .. invoice.Sender .. ")")
        else
            senderName = invoice.SenderName
        end

        local ownerName = exports.data:getCharVar(target, "firstname") .. " " .. exports.data:getCharVar(target, "lastname")

        local ownerId = exports.data:getCharVar(target, "id")
        invoices[invoiceId] = {
            Id = invoiceId,
            Owner = ownerId,
            OwnerName = ownerName,
            Sender = invoice.Sender,
            SenderName = senderName,
            SenderChar = invoice.SenderChar,
            Price = invoice.Price,
            Active = invoice.Active,
            Bank = invoice.Bank,
            Items = invoice.Items,
            Datelabel = os.date("%x %X", date),
            Date = date,
            Paid = 0,
            Removed = false,
            Changed = false
        }

        if not invoice.SenderName then
            exports.inventory:addPlayerItem(
                sender,
                "invoice",
                1,
                {
                    id = invoiceId,
                    date = date,
                    datelabel = os.date("%x %X", date),
                    sendername = senderName,
                    ownername = ownerName,
                    label = "(KOPIE) Faktura č. " .. invoiceId .. "<br>Datum vydání: " .. os.date("%x %X", date),
                    price = invoice.Price,
                    active = invoice.Active,
                    items = invoice.Items,
                    bank = invoice.Bank
                }
            )
        end

        local accountsToSend = {}
        if not invoice.Active then
            exports.inventory:addPlayerItem(
                target,
                "invoice",
                1,
                {
                    id = invoiceId,
                    date = date,
                    datelabel = os.date("%x %X", date),
                    sendername = senderName,
                    ownername = ownerName,
                    label = "Faktura č. " .. invoiceId .. "<br>Datum vydání: " .. os.date("%x %X", date),
                    price = invoice.Price,
                    active = invoice.Active,
                    items = invoice.Items,
                    bank = invoice.Bank
                }
            )

            MySQL.Async.execute(
                "INSERT INTO invoices (id, owner, ownername, sender, sendername, senderchar, price, bank, items, date) VALUES (@id, @owner, @ownername, @sender, @sendername, @senderchar, @price, @bank, @items, @date)",
                {
                    ["@id"] = invoiceId,
                    ["@owner"] = ownerId,
                    ["@ownername"] = ownerName,
                    ["@sender"] = invoice.Sender,
                    ["@sendername"] = senderName,
                    ["@senderchar"] = invoice.SenderChar,
                    ["@price"] = invoice.Price,
                    ["@bank"] = invoice.Bank,
                    ["@items"] = json.encode(invoice.Items),
                    ["@date"] = date
                }
            )
        else
            local canAccessChar = exports.bank:getPlayerAccesibleAccounts(target, "send")
            for number, accountData in pairs(canAccessChar) do
                table.insert(accountsToSend, { tostring(number), accountData.name })
            end
            local jobs = exports.data:getCharVar(target, "jobs")
            for i, job in each(jobs) do
                local canAccessAcount = exports.bank:getJobAccesibleAccounts(job.job, job.job_grade, "send")
                for number, accountData in pairs(canAccessAcount) do
                    table.insert(accountsToSend, { tostring(number), accountData.name })
                end
            end
        end
        TriggerClientEvent("invoices:give", target, invoices[invoiceId], sender, accountsToSend)
    else
        exports.admin:banClientForCheating(
            sender,
            "0",
            "Cheating",
            "invoices:respond",
            "Hráč se pokusil dát fakturu někomu, kdo je ve vzdálenosti " .. distance
        )
    end
end
RegisterNetEvent("invoices:activeDenied")
AddEventHandler(
    "invoices:activeDenied",
    function(id, target)
        local sender = source
        if invoices[id] then
            invoices[id] = nil
        end
        if GetPlayerName(target) then
            TriggerClientEvent("invoices:activeDenied", target, id)
        end

        TriggerClientEvent("invoices:activeDenied", sender, id)
    end
)

RegisterNetEvent("invoices:pay")
AddEventHandler(
    "invoices:pay",
    function(invoiceData, sourceAccount)
        local sender = source
        local paidAlready = false
        local paid = false

        local invoiceId = invoiceData.Id
        if invoiceId == nil then
            invoiceId = invoiceData.id
        end

        local invoice = invoices[invoiceId]
        local done = "alreadyPaid"

        if invoice and invoice.Paid <= 0 then
            done = exports.bank:payFromAccountToAccount(
                tostring(sourceAccount),
                tostring(invoice.Bank),
                invoice.Price,
                false,
                "Zaplacení faktury č. " ..
                    invoice.Id .. " provedl - " .. exports.data:getCharNameById(exports.data:getCharVar(sender, "id")),
                "Příchozí platba za fakturu s č. " ..
                    invoice.Id .. " provedl - " .. exports.data:getCharNameById(exports.data:getCharVar(sender, "id")),
                sender
            )
            if done == "done" then
                invoice.Paid = os.time()
                setPaidNotif(invoice)
                invoice.Changed = true
                exports.inventory:removePlayerItem(
                    sender,
                    "invoice",
                    1,
                    {
                        id = invoice.Id
                    }
                )
                paid = true
            elseif done == "destAccountDoesNotExist" then
                done = exports.bank:payFromAccount(
                    tostring(sourceAccount),
                    invoice.price,
                    false,
                    "Zaplacení faktury č. " ..
                        invoice.Id ..
                        " provedl - " .. exports.data:getCharNameById(exports.data:getCharVar(sender, "id")),
                    sender
                )
                if done == "done" then
                    invoice.Paid = os.time()
                    setPaidNotif(invoice)
                    invoice.Changed = true
                    exports.inventory:removePlayerItem(
                        sender,
                        "invoice",
                        1,
                        {
                            id = invoice.Id
                        }
                    )
                    paid = true
                end
            end

            if done == "done" and invoice.Active then
                exports.inventory:addPlayerItem(
                    sender,
                    "invoice",
                    1,
                    {
                        id = invoice.Id,
                        date = invoice.Date,
                        datelabel = os.date("%x %X", invoice.Date),
                        sendername = invoice.SenderName,
                        ownername = invoice.OwnerName,
                        label = "Faktura č. " .. invoice.Id .. "<br>Datum vydání: " .. os.date("%x %X", date),
                        price = invoice.Price,
                        active = invoice.Active,
                        items = invoice.Items,
                        bank = invoice.Bank
                    }
                )

                MySQL.Async.execute(
                    "INSERT INTO invoices (id, owner, ownername, sender, sendername, senderchar, price, bank, items, date) VALUES (@id, @owner, @ownername, @sender, @sendername, @senderchar, @price, @bank, @items, @date)",
                    {
                        ["@id"] = invoice.Id,
                        ["@owner"] = invoice.Owner,
                        ["@ownername"] = invoice.OwnerName,
                        ["@sender"] = invoice.Sender,
                        ["@sendername"] = invoice.SenderName,
                        ["@senderchar"] = invoice.SenderChar,
                        ["@price"] = invoice.Price,
                        ["@bank"] = invoice.Bank,
                        ["@items"] = json.encode(invoice.Items),
                        ["@date"] = invoice.Date
                    }
                )
            end
        else
            paidAlready = true

            exports.inventory:removePlayerItem(
                sender,
                "invoice",
                1,
                {
                    id = invoice.Id
                }
            )
        end

        if paidAlready then
            TriggerClientEvent(
                "notify:display",
                sender,
                {
                    type = "info",
                    title = "Faktura",
                    text = "Faktura již byla zaplacena",
                    icon = "fas fa-receipt",
                    length = 3500
                }
            )
        else
            if done == "done" then
                TriggerClientEvent(
                    "notify:display",
                    sender,
                    {
                        type = "success",
                        title = "Faktura",
                        text = "Faktura byla zaplacena",
                        icon = "fas fa-receipt",
                        length = 3500
                    }
                )
            else
                print("INVOICE FAILED: " .. done)
                TriggerClientEvent(
                    "notify:display",
                    sender,
                    {
                        type = "error",
                        title = "Faktura",
                        text = "Faktura nemohla být zaplacena.",
                        icon = "fas fa-receipt",
                        length = 3500
                    }
                )
            end
        end
    end
)

RegisterNetEvent("invoices:payCash")
AddEventHandler(
    "invoices:payCash",
    function(invoice, targetAccount)
        local sender = source
        local paidAlready = false
        local done = "alreadyPaid"
        local invoice = invoices[invoice]
        if invoice then
            if invoice.Paid <= 0 then
                local hasMoney = exports.inventory:checkPlayerItem(sender, "cash", invoice.Price, {})
                if hasMoney then
                    done = exports.inventory:removePlayerItem(sender, "cash", invoice.Price, {})
                    if done == "done" then
                        exports.inventory:removePlayerItem(
                            sender,
                            "invoice",
                            1,
                            {
                                id = invoice.Id
                            }
                        )
                        done = exports.bank:sendToAccount(
                            tostring(targetAccount),
                            invoice.Price,
                            "Faktura č. " .. invoice.Id .. " provedl -  " .. invoice.OwnerName
                        )
                        invoices[invoice.Id].Paid = os.time()
                        setPaidNotif(invoices[invoice.Id])
                        invoices[invoice.Id].Changed = true
                    end
                end
            else
                paidAlready = true
                exports.inventory:removePlayerItem(
                    sender,
                    "invoice",
                    1,
                    {
                        id = invoice.Id
                    }
                )
            end
        end
        TriggerClientEvent("invoices:paid", sender, done, paidAlready)
        if paidAlready then
            TriggerClientEvent(
                "notify:display",
                sender,
                {
                    type = "info",
                    title = "Faktura",
                    text = "Faktura je již zaplacena!",
                    icon = "fas fa-receipt",
                    length = 3500
                }
            )

            exports.inventory:removePlayerItem(
                sender,
                "invoice",
                1,
                {
                    id = invoice.Id
                }
            )
        else
            if done == "done" then
                TriggerClientEvent(
                    "notify:display",
                    sender,
                    {
                        type = "success",
                        title = "Faktura",
                        text = "Faktura byla zaplacena!",
                        icon = "fas fa-receipt",
                        length = 3500
                    }
                )
            else
                print("INVOICE FAILED: " .. done)
                TriggerClientEvent(
                    "notify:display",
                    sender,
                    {
                        type = "error",
                        title = "Faktura",
                        text = "Faktura nemohla být zaplacena.",
                        icon = "fas fa-receipt",
                        length = 3500
                    }
                )
            end
        end
    end
)

RegisterNetEvent("invoices:check")
AddEventHandler(
    "invoices:check",
    function(char)
        local _source = source
        local invoiceinTotal = {}
        for key, _ in pairs(invoices) do
            if invoices[key].Paid <= 0 and invoices[key].Owner == char then
                table.insert(invoiceinTotal, invoices[key])
            end
        end

        TriggerClientEvent("invoices:check", _source, invoiceinTotal)
    end
)

function setPaidNotif(invoice)
    local playerList = exports.data:getUsersBaseData(
        function(userData)
            return (userData.status == "spawned" or userData.status == "dead") and (userData.character ~= nil and (userData.character.id == tonumber(invoice.SenderChar) or userData.character.id == tonumber(invoice.Sender)))
        end
    )

    for _, userData in each(playerList) do
        TriggerClientEvent(
            "notify:display",
            userData.source,
            {
                type = "success",
                title = "Vydaná faktura uhrazena",
                text = "Faktura č. " .. invoice.Id .. " (za " .. exports.data:getFormattedCurrency(invoice.Price) .. ") byla uhrazena!",
                icon = "fas fa-receipt",
                length = 6000
            }
        )
        break
    end
end

function setInvoicePaid(invoiceId, status)
    if invoiceId == nil or status == nil then
        return "missingVariable"
    end

    if invoices[invoiceId] == nil then
        return "missingInvoice"
    end

    if status then
        invoices[invoiceId].Paid = os.time()
        setPaidNotif(invoices[invoiceId])
    else
        invoices[invoiceId].Paid = 0
    end

    invoices[invoiceId].Changed = true

    return "done"
end

function generateId()
    local id = ""
    for i = 1, 20 do
        id = id .. Config.IdChars[math.random(#Config.IdChars)]
    end

    while invoices[id] ~= nil do
        id = ""
        for i = 1, 20 do
            id = id .. Config.IdChars[math.random(#Config.IdChars)]
        end
    end

    return id
end

function getInvoiceList(charId, paid)
    local listInvoice = {}
    for key, invoice in pairs(invoices) do
        if invoice.Owner == charId and (not paid or (paid and invoice.Paid <= paid)) then
            table.insert(listInvoice, invoices[key])
        end
    end

    return listInvoice
end

function getSenderInvoiceList(senderId, paid)
    local listInvoice = {}
    for key, invoice in pairs(invoices) do
        if invoice.Sender == senderId and (paid == nil or (paid ~= nil and invoice.Paid == paid)) then
            table.insert(listInvoice, invoices[key])
        end
    end

    table.sort(listInvoice, function(a, b)
        return a.Date < b.Date
    end)

    return listInvoice
end

function getInvoiceData(invoiceId)
    local listInvoice = {}
    if invoices[invoiceId] then
        return invoices[invoiceId]
    end
    return nil
end

function saveInvoices()
    for key, invoice in pairs(invoices) do
        if invoice.Changed then
            invoice.Changed = false
            MySQL.Async.execute(
                "UPDATE invoices SET owner=@owner, ownername=@ownername, sender=@sender, sendername=@sendername, senderchar=@senderchar, price=@price, bank=@bank, items=@items, date=@date, paid=@paid, removed=@removed WHERE id=@id",
                {
                    ["@id"] = key,
                    ["@owner"] = invoice.Owner,
                    ["@ownername"] = invoice.OwnerName,
                    ["@sender"] = invoice.Sender,
                    ["@sendername"] = invoice.SenderName,
                    ["@senderchar"] = invoice.SenderChar,
                    ["@price"] = invoice.Price,
                    ["@bank"] = invoice.Bank,
                    ["@items"] = json.encode(invoice.Items),
                    ["@date"] = invoice.Date,
                    ["@paid"] = invoice.Paid,
                    ["@removed"] = invoice.Removed
                }
            )
        end
    end
    SetTimeout(60000, saveInvoices)
end
