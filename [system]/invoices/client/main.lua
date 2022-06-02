local isSpawned, isDead = false, false
local jobs = {}

local lastInvoice = nil

local recievedInvoice = nil
Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        exports.chat:addSuggestion("/invoice", "Vytvoří fakturu", {})
        exports.chat:addSuggestion("/faktura", "Vytvoří fakturu", {})

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
            TriggerServerEvent("fines:sync")
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
                TriggerServerEvent("fines:sync")
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterCommand(
    "invoice",
    function()
        giveInvoice()
    end
)
RegisterCommand(
    "faktura",
    function()
        giveInvoice()
    end
)

function giveInvoice()
    if isDead then
        return
    end
    exports.emotes:playEmoteByName("notepad")

    WarMenu.CreateMenu("createinvoice", "ZAPIŠTE FAKTURU", "")
    WarMenu.OpenMenu("createinvoice")

    WarMenu.CreateSubMenu("invoice_point_add", "createinvoice", "Přidat položku")
    WarMenu.CreateSubMenu("invoice_point_edit", "createinvoice", "Upravit položku")
    WarMenu.CreateSubMenu("invoice_changesender", "createinvoice", "Zvolit vydavatele")

    local pChar = exports.data:getCharVar("id")
    local pName = exports.data:getCharVar("firstname") .. " " .. exports.data:getCharVar("lastname")

    local invoice = {
        Sender = pChar,
        SenderName = pName,
        Active = false,
        Price = 0,
        Bank = "",
        Items = {}
    }

    if lastInvoice ~= nil then
        invoice = lastInvoice
    end

    local currentItem = {
        label = "",
        price = 0
    }

    while true do
        local isInSubmenu = false
        if WarMenu.IsMenuOpened("createinvoice") then
            WarMenu.MenuButton("Vydavatel faktury: ~b~", "invoice_changesender", invoice.SenderName)

            for i, item in each(invoice.Items) do
                if
                    WarMenu.MenuButton(
                        "~b~" .. item.label,
                        "invoice_point_edit",
                        "~g~" .. getFormattedCurrency(item.price)
                    )
                 then
                    currentItem = {
                        Label = item.label,
                        Price = item.price,
                        Index = i
                    }
                end
            end
            if WarMenu.MenuButton("Přidat položku", "invoice_point_add") then
            elseif WarMenu.Button("Splátka na bankovní účet:", "~g~" .. invoice.Bank) then
                if invoice.Sender == pChar then
                    exports.input:openInput(
                        "number",
                        {title = "Zadejte číslo bankovního účtu", value = invoice.Bank},
                        function(acc)
                            if acc then
                                invoice.Bank = acc
                            end
                        end
                    )
                end
            elseif WarMenu.Button("Splátka: ", (invoice.Active and "Okamžitá" or "Do doby určité")) then
                invoice.Active = not invoice.Active
            elseif WarMenu.Button("Celková částka:", "~g~$" .. invoice.Price) then
            elseif WarMenu.Button("Uložit rozdělanou fakturu") then
                lastInvoice = invoice
                exports.notify:display(
                    {type = "info", title = "Faktura", text = "Faktura uložena", icon = "fas fa-receipt", length = 2000}
                )
            elseif WarMenu.Button("Předat fakturu") then
                if #invoice.Items > 0 and invoice.Bank ~= "" then
                    WarMenu.CloseMenu()
                    Citizen.Wait(100)
                    TriggerEvent(
                        "util:closestPlayer",
                        {
                            radius = 2.0
                        },
                        function(player)
                            if player then
                                TriggerServerEvent("invoices:ask", player, invoice)
                                exports.emotes:cancelEmote()
                            end
                        end
                    )
                else
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Faktura",
                            text = "Musíte vyplnit všechny údaje a nesmí být bez položky",
                            icon = "fas fa-receipt",
                            length = 2000
                        }
                    )
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("invoice_point_add") then
            isInSubmenu = true
            if WarMenu.Button("Název položky:", "~b~" .. currentItem.label) then
                exports.input:openInput(
                    "text",
                    {title = "Zadejte název položky", value = currentItem.label},
                    function(label)
                        if label then
                            currentItem.label = label
                        end
                    end
                )
            elseif WarMenu.Button("Cena položky:", "~g~$" .. currentItem.price) then
                exports.input:openInput(
                    "number",
                    {title = "Zadejte cenu položky", value = currentItem.price},
                    function(price)
                        if price then
                            currentItem.price = tonumber(price)
                        end
                    end
                )
            elseif WarMenu.MenuButton("Přidat položku", "createinvoice") then
                if currentItem.label ~= "" and currentItem.price > 0 then
                    exports.notify:display(
                        {
                            type = "info",
                            title = "Faktura",
                            text = "Položka přidána",
                            icon = "fas fa-receipt",
                            length = 2000
                        }
                    )
                    table.insert(invoice.Items, currentItem)
                    invoice.Price = invoice.Price + currentItem.price
                    currentItem = {
                        label = "",
                        price = 0
                    }
                else
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Faktura",
                            text = "Musíte vyplnit všechny údaje položky",
                            icon = "fas fa-receipt",
                            length = 4000
                        }
                    )
                end
            elseif WarMenu.MenuButton("Zrušit položku", "createinvoice") then
                currentItem = {
                    label = "",
                    price = 0
                }
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("invoice_point_edit") then
            isInSubmenu = true
            if WarMenu.Button("Název položky:", "~b~" .. currentItem.label) then
                exports.input:openInput(
                    "text",
                    {title = "Zadejte název položky", value = currentItem.label},
                    function(label)
                        if label then
                            currentItem.label = label
                        end
                    end
                )
            elseif WarMenu.Button("Cena položky:", " ~g~$" .. currentItem.price) then
                exports.input:openInput(
                    "number",
                    {title = "Zadejte cenu položky", value = currentItem.price},
                    function(price)
                        if price then
                            currentItem.price = tonumber(price)
                        end
                    end
                )
            elseif WarMenu.MenuButton("Uložit položku", "createinvoice") then
                if currentItem.label ~= "" and currentItem.price > 0 then
                    invoice.Items[currentItem.index] = currentItem
                    currentItem = {
                        label = "",
                        price = 0
                    }
                else
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Faktura - úprava položky",
                            text = "Musíte vyplnit všechny údaje položky",
                            icon = "fas fa-atlas",
                            length = 3500
                        }
                    )
                end
            elseif WarMenu.MenuButton("Zrušit úpravu", "createinvoice") then
                currentItem = {
                    label = "",
                    price = 0
                }
            elseif WarMenu.MenuButton("~r~Odebrat položku", "createinvoice") then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Faktura - úprava položky",
                        text = "Položka odebrána",
                        icon = "fas fa-receipt",
                        length = 2000
                    }
                )
                invoice.price = invoice.price - invoice.Items[currentItem.index].price
                table.remove(invoice.Items, currentItem.index)
                currentItem = {
                    label = "",
                    price = 0
                }
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("invoice_changesender") then
            isInSubmenu = true

            if WarMenu.MenuButton(pName, "createinvoice", "osoba") then
                invoice.Bank = (currentBank == nil and "" or currentBank)
                invoice.Sender = pChar
                invoice.SenderName = pName
            end

            for name, jobData in pairs(jobs) do
                if WarMenu.MenuButton(jobData.Label, "createinvoice", "firma") then
                    local bank = exports.base_jobs:getJobVar(name, "bank")
                    if bank then
                        invoice.Bank = bank
                        invoice.Sender = name
                        invoice.SenderName = exports.base_jobs:getJobVar(name, "label")
                    end
                end
            end

            WarMenu.Display()
        else
            if not isInSubmenu then
                exports.emotes:cancelEmote()
                break
            end
            break
        end
        Citizen.Wait(0)
    end
end

RegisterNetEvent("invoices:ask")
AddEventHandler(
    "invoices:ask",
    function(source, invoice)
        exports.notify:display(
            {
                type = "info",
                title = "Faktura",
                text = "Dostal jste nabídku faktury",
                icon = "fas fa-receipt",
                length = 3500
            }
        )
        TriggerEvent(
            "chat:addMessage",
            {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(100, 149, 237, 0.75); border-left: 10px solid rgb(100, 149, 237);">Použij klávesu <strong>Y</strong> pro přijmutí faktury. Použij klávesu <strong>N</strong> pro odmítnutí.</div>'
            }
        )
        while true do
            Citizen.Wait(1)
            local sourcePed = GetEntityCoords(PlayerPedId(), false)
            local targetPed = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(source)), false)
            local distance = #(sourcePed - targetPed)
            if distance <= 50 then 
                if IsControlJustReleased(0, 20) then
                    if distance < 3.0 then
                        TriggerServerEvent("invoices:respond", true, source, invoice)
                        break
                    else
                        exports.notify:display(
                            {
                                type = "warning",
                                title = "Faktura",
                                text = "Jste daleko od zadavatele faktury",
                                icon = "fas fa-receipt",
                                length = 3500
                            }
                        )
                    end
                elseif IsControlJustReleased(0, 306) then
                    if distance < 3.0 then
                        TriggerServerEvent("invoices:respond", false, source, invoice)
                        break
                    else
                        exports.notify:display(
                            {
                                type = "warning",
                                title = "Faktura",
                                text = "Jste daleko od zadavatele faktury",
                                icon = "fas fa-receipt",
                                length = 3500
                            }
                        )
                    end
                end
            else
                TriggerServerEvent("invoices:respond", false)
                break
            end
        end
    end
)

RegisterNetEvent("invoices:give")
AddEventHandler(
    "invoices:give",
    function(invoice, source, accounts)
        if invoice.Active then
            if #accounts > 0 then
                WarMenu.CreateMenu("invoices-accounts", "Dostupné účty", "Vyberte účet pro platbu")
                WarMenu.OpenMenu("invoices-accounts")

                while WarMenu.IsMenuOpened("invoices-accounts") do
                    for _, data in each(accounts) do
                        if WarMenu.Button(data[2], data[1]) then
                            TriggerServerEvent("invoices:pay", invoice, data[1])
                            WarMenu.CloseMenu()
                        end
                    end
                    WarMenu.Display()
                    Citizen.Wait(0)
                end
            else
                TriggerServerEvent("invoices:activeDenied", invoice.Id, source)
            end
        end
        exports.notify:display(
            {
                type = "info",
                title = "Faktura",
                text = "Faktura s číslem " .. invoice.Id .. " Vám byla přiřazena",
                icon = "fas fa-receipt",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("invoices:activeDenied")
AddEventHandler(
    "invoices:activeDenied",
    function(invoiceId)
        exports.notify:display(
            {
                type = "warning",
                title = "Faktura",
                text = "Faktura s číslem " .. invoiceId .. " NEBYLA zaplacena",
                icon = "fas fa-receipt",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "invoice" then
            exports.emotes:playEmoteByName("notepad")
            local invoice = data

            WarMenu.CreateMenu("showinvoice", "Faktura", invoice.id)
            WarMenu.SetMenuY("showinvoice", 0.35)
            WarMenu.OpenMenu("showinvoice")

            while true do
                if WarMenu.IsMenuOpened("showinvoice") then
                    if WarMenu.Button("Číslo faktury:", "~b~" .. invoice.id) then
                    end
                    if invoice.sendername then
                        if WarMenu.Button("Vydavatel faktury:", "~b~" .. invoice.sendername) then
                        end
                    end
                    if WarMenu.Button("~b~Položek: ", #invoice.items) then
                    end
                    for i, item in each(invoice.items) do
                        if WarMenu.Button(i .. ". " .. item.label .. ":", "~g~$" .. item.price) then
                        end
                    end
                    if WarMenu.Button("Celková částka:", "~g~$" .. invoice.price) then
                    elseif WarMenu.Button("Splátka na bankovní účet:", "~g~" .. invoice.bank) then
                    elseif WarMenu.Button("Psáno na:", "~b~" .. invoice.ownername) then
                    elseif WarMenu.Button("Datum vydání:", "~b~" .. invoice.datelabel) then
                    elseif WarMenu.Button("Zaplatit fakturu převodem") then
                        exports.input:openInput(
                            "text",
                            {title = "Zadejte bankovní účet", placeholder = "Váš bankovní účet"},
                            function(acc)
                                if acc then
                                    TriggerServerEvent("invoices:pay", invoice, acc)
                                    WarMenu.CloseMenu()
                                end
                            end
                        )
                    elseif WarMenu.Button("Zaplatit fakturu hotově") then
                        TriggerServerEvent("invoices:payCash", invoice.id, invoice.bank)
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                else
                    exports.emotes:cancelEmote()
                    break
                end
                Citizen.Wait(0)
            end
        end
    end
)

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Label = exports.base_jobs:getJobVar(data.job, "label"),
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end
