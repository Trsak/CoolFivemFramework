math.randomseed(os.time())
local accounts = {}
local accountLogs = {}
local accountAccess = {}

local cards = {}
local bankCardTries = {}
local cardsWithdrawLimits = {}

MySQL.ready(
    function()
        Wait(250)

        MySQL.Async.execute("DELETE FROM bank_logs where `date` < NOW() - INTERVAL 21 DAY", {})

        MySQL.Async.fetchAll(
            "SELECT * FROM bank_accounts",
            {},
            function(accountsData)
                for _, accountData in each(accountsData) do
                    accounts[accountData.number] = {
                        name = accountData.name,
                        description = accountData.description,
                        founder = tonumber(accountData.founder),
                        balance = accountData.balance,
                        freeCard = (accountData.free_card == 1 or accountData.free_card) and true or false,
                        icon = accountData.icon,
                        changed = false
                    }
                end
            end
        )

        MySQL.Async.fetchAll(
            "SELECT * FROM bank_access",
            {},
            function(accessesData)
                for _, accessData in each(accessesData) do
                    if accountAccess[accessData.account] == nil then
                        accountAccess[accessData.account] = {}
                    end

                    table.insert(
                        accountAccess[accessData.account],
                        {
                            id = accessData.id,
                            type = accessData.type,
                            who = accessData.who,
                            grade = tonumber(accessData.grade),
                            priority = tonumber(accessData.priority),
                            root = accessData.root == 1 and true or false,
                            view = accessData.view == 1 and true or false,
                            cards = accessData.cards == 1 and true or false,
                            deposit = accessData.deposit == 1 and true or false,
                            withdraw = accessData.withdraw == 1 and true or false,
                            edit = accessData.edit == 1 and true or false,
                            send = accessData.send == 1 and true or false,
                            accesses = accessData.accesses == 1 and true or false,
                            changed = false
                        }
                    )
                end

                for accountNumber, _ in each(accountAccess) do
                    table.sort(
                        accountAccess[accountNumber],
                        function(a, b)
                            return a.priority > b.priority
                        end
                    )
                end
            end
        )

        MySQL.Async.fetchAll(
            "SELECT * FROM bank_cards",
            {},
            function(cardsData)
                for _, cardData in each(cardsData) do
                    cards[cardData.number] = {
                        pin = tostring(cardData.pin),
                        name = cardData.name,
                        account = tostring(cardData.account),
                        withdrawLimit = cardData.withdraw_limit,
                        changed = false
                    }
                end
            end
        )

        MySQL.Async.fetchAll(
            "SELECT * FROM bank_logs ORDER BY date DESC",
            {},
            function(logsData)
                for _, logData in each(logsData) do
                    if accountLogs[logData.source_acc] == nil then
                        accountLogs[logData.source_acc] = {}
                    end

                    local logInfo = {
                        sourceAccount = logData.source_acc,
                        action = logData.action,
                        amount = logData.amount,
                        targetAccount = logData.target_acc,
                        description = logData.description,
                        charId = logData.char_id,
                        negative = logData.negative,
                        balance = tonumber(logData.balance),
                        date = logData.date
                    }
                    table.insert(accountLogs[logData.source_acc], logInfo)
                end
            end
        )

        SetTimeout(30000, saveAccountsAndCards)
    end
)

function saveAccountsAndCards()
    for accountNumber, accountData in pairs(accounts) do
        if accountData.changed then
            accounts[accountNumber].changed = false

            MySQL.Async.execute(
                "INSERT INTO `bank_accounts` (`number`, `name`, `description`, `founder`, `balance`, `free_card`, `icon`) VALUES (@number, @name, @description, @founder, @balance, @free_card, @icon) ON DUPLICATE KEY UPDATE name = @name, description = @description, balance = @balance, free_card = @free_card, icon = @icon",
                {
                    ["@number"] = accountNumber,
                    ["@name"] = accountData.name,
                    ["@description"] = accountData.description,
                    ["@founder"] = accountData.founder,
                    ["@balance"] = math.floor(accountData.balance),
                    ["@free_card"] = accountData.freeCard == true and 1 or 0,
                    ["@icon"] = accountData.icon
                }
            )
        end
    end

    for accountNumber, accessesList in each(accountAccess) do
        for i, accessData in each(accessesList) do
            if accessData.changed then
                accountAccess[accountNumber][i].changed = false

                MySQL.Async.execute(
                    "INSERT INTO `bank_access` (`id`, `account`, `type`, `who`, `grade`, `priority`, `root`, `view`, `cards`, `deposit`, `withdraw`, `edit`, `send`, `accesses`) VALUES (@id, @account, @type, @who, @grade, @priority, @root, @view, @cards, @deposit, @withdraw, @edit, @send, @accesses) ON DUPLICATE KEY UPDATE priority = @priority, root = @root, view = @view, cards = @cards, deposit = @deposit, withdraw = @withdraw, edit = @edit, send = @send, accesses = @accesses",
                    {
                        ["@id"] = accessData.id,
                        ["@account"] = accountNumber,
                        ["@type"] = accessData.type,
                        ["@who"] = accessData.who,
                        ["@grade"] = accessData.grade,
                        ["@priority"] = accessData.priority,
                        ["@root"] = accessData.root == true and 1 or 0,
                        ["@view"] = accessData.view == true and 1 or 0,
                        ["@cards"] = accessData.cards == true and 1 or 0,
                        ["@deposit"] = accessData.deposit == true and 1 or 0,
                        ["@withdraw"] = accessData.withdraw == true and 1 or 0,
                        ["@edit"] = accessData.edit == true and 1 or 0,
                        ["@send"] = accessData.send == true and 1 or 0,
                        ["@accesses"] = accessData.accesses == true and 1 or 0
                    }
                )
            end
        end
    end

    for cardNumber, cardData in pairs(cards) do
        if cardData.changed then
            cards[cardNumber].changed = false

            MySQL.Async.execute(
                "INSERT INTO `bank_cards` (`number`, `pin`, `withdraw_limit`, `name`, `account`) VALUES (@number, @pin, @withdraw_limit, @name, @account) ON DUPLICATE KEY UPDATE pin = @pin, withdraw_limit = @withdraw_limit, name = @name, account = @account",
                {
                    ["@number"] = cardNumber,
                    ["@pin"] = cardData.pin,
                    ["@name"] = cardData.name,
                    ["@withdraw_limit"] = cardData.withdrawLimit,
                    ["@account"] = cardData.account
                }
            )
        end
    end

    SetTimeout(30000, saveAccountsAndCards)
end

RegisterNetEvent("bank:open")
AddEventHandler(
    "bank:open",
    function()
        local client = source
        bankOpen(client)
    end
)

function bankOpen(client)
    local accessibleAccounts = {}

    local charId = exports.data:getCharVar(client, "id")
    local charJobs = exports.data:getCharVar(client, "jobs")

    for accountNumber, accountData in pairs(accounts) do
        if getAccess(accountNumber, "view", charId, charJobs) ~= nil then
            accessibleAccounts[accountNumber] = accountData
        end
    end
    TriggerClientEvent("bank:open", client, getNumberOfAccountsLeft(client), accessibleAccounts)
end

function getAccessJob(accountNumber, job, jobGrade, rule)
    local accountData = accounts[accountNumber]
    if accountData == nil then
        return false
    end

    if rule == "remove" then
        return nil
    end

    if accountAccess[accountNumber] ~= nil then
        for _, accessData in each(accountAccess[accountNumber]) do
            if accessData.type == "job" and tostring(accessData.who) == job and accessData.grade >= jobGrade then
                if accessData[rule] == true or accessData["root"] == true then
                    return accessData
                else
                    return nil
                end
            end
        end
    end

    return nil
end

function getAccess(accountNumber, rule, charId, jobs)
    local accountData = accounts[accountNumber]
    if accountData == nil then
        return false
    end

    if accountData.founder == charId then
        return {
            root = true
        }
    end

    if rule == "remove" then
        return nil
    end

    if accountAccess[accountNumber] ~= nil then
        for _, accessData in each(accountAccess[accountNumber]) do
            if accessData.type == "char" and tonumber(accessData.who) == charId then
                if accessData[rule] == true or accessData["root"] == true then
                    return accessData
                else
                    return nil
                end
            elseif accessData.type == "job" and doesHaveJobWithGrade(jobs, tostring(accessData.who), accessData.grade) then
                if accessData[rule] == true or accessData["root"] == true then
                    return accessData
                else
                    return nil
                end
            end
        end
    end

    return nil
end

function doesHaveJobWithGrade(jobs, job, jobGrade)
    for _, jobData in each(jobs) do
        if jobData.job == job and jobData.job_grade >= jobGrade then
            return true
        end
    end

    return false
end

RegisterNetEvent("bank:createAccount")
AddEventHandler(
    "bank:createAccount",
    function(name, description, icon)
        local client = source
        local charId = exports.data:getCharVar(client, "id")
        local accountsLeft = getNumberOfAccountsLeft(client)

        if accountsLeft <= 0 then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Nemůžeš si založit další účet!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
            return
        end

        exports.data:updateCharVar(client, "bank_accounts_left", accountsLeft - 1)
        local newBankAccountNumber = getUniqueBankAccountNumber()

        accounts[newBankAccountNumber] = {
            name = name,
            description = description,
            founder = charId,
            balance = 0,
            icon = icon,
            freeCard = true,
            changed = true
        }

        bankOpen(client)

        exports.logs:sendToDiscord(
            {
                channel = "bank",
                title = "Založení účtu",
                description = "Založil účet " .. name .. " s číslem " .. newBankAccountNumber,
                color = "7601682"
            },
            client
        )
        TriggerClientEvent(
            "notify:display",
            client,
            { type = "success", title = "Úspech", text = "Účet byl založen!", icon = "fas fa-university", length = 5000 }
        )
    end
)

function getUniqueBankAccountNumber()
    while true do
        local generatedNumber = tostring(math.random(1000000000, 9999999999))
        if accounts[generatedNumber] == nil then
            return generatedNumber
        end
    end
end

RegisterNetEvent("bank:createNewAccess")
AddEventHandler(
    "bank:createNewAccess",
    function(accountNumber, type, who, grade)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "accesses", charId, charJobs) ~= nil then
            if accountAccess[accountNumber] == nil then
                accountAccess[accountNumber] = {}
            end

            if grade == nil then
                grade = 0
            end

            if type == "char" then
                who = exports.data:getCharVar(tonumber(who), "id")
            end

            MySQL.Async.insert(
                "INSERT INTO `bank_access` (`account`, `type`, `who`, `grade`, `priority`, `root`, `view`, `cards`, `deposit`, `withdraw`, `edit`, `send`, `accesses`) VALUES (@account, @type, @who, @grade, @priority, @root, @view, @cards, @deposit, @withdraw, @edit, @send, @accesses)",
                {
                    ["@account"] = accountNumber,
                    ["@type"] = type,
                    ["@who"] = who,
                    ["@grade"] = tonumber(grade),
                    ["@priority"] = 0,
                    ["@root"] = 0,
                    ["@view"] = 0,
                    ["@cards"] = 0,
                    ["@deposit"] = 0,
                    ["@withdraw"] = 0,
                    ["@edit"] = 0,
                    ["@send"] = 0,
                    ["@accesses"] = 0
                },
                function(insertedId)
                    table.insert(
                        accountAccess[accountNumber],
                        {
                            id = insertedId,
                            type = type,
                            who = who,
                            grade = tonumber(grade),
                            priority = 0,
                            root = false,
                            view = false,
                            cards = false,
                            deposit = false,
                            withdraw = false,
                            edit = false,
                            send = false,
                            accesses = false,
                            changed = false
                        }
                    )

                    table.sort(
                        accountAccess[accountNumber],
                        function(a, b)
                            return a.priority > b.priority
                        end
                    )

                    if type == "job" then
                        exports.logs:sendToDiscord(
                            {
                                channel = "bank",
                                title = "Vytvořené přístupu",
                                description = "Vytvořil přístup k účtu " ..
                                    accountNumber .. " pro frakci " .. who .. " a hodnost " .. grade,
                                color = "7601682"
                            },
                            client
                        )
                    else
                        exports.logs:sendToDiscord(
                            {
                                channel = "bank",
                                title = "Vytvořené přístpu",
                                description = "Vytvořil přístup k účtu " .. accountNumber .. " pro osobu " .. who,
                                color = "7601682"
                            },
                            client
                        )
                    end

                    bankOpenDetailAccessesLoad(client, accountNumber, charId, charJobs, true)
                end
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:createNewAccess",
                "Pokusil se vytvořit přístup k " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:removeAccess")
AddEventHandler(
    "bank:removeAccess",
    function(accountNumber, accessId)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local accessIndexById = findAccessIndexById(accountAccess[accountNumber], accessId)
        if accessIndexById == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "accesses", charId, charJobs) ~= nil then
            table.remove(accountAccess[accountNumber], accessIndexById)
            bankOpenDetailAccesses(client, accountNumber, charId, charJobs, accountAccess[accountNumber])

            MySQL.Async.execute(
                "DELETE FROM `bank_access` WHERE id = @accessId",
                {
                    ["@accessId"] = accessId
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Smazání přístpu",
                    description = "Smazal přístup " .. accessId .. " k účtu " .. accountNumber,
                    color = "16656146"
                },
                client
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:removeAccess",
                "Pokusil se smazat přístup " .. accessId
            )
        end
    end
)

RegisterNetEvent("bank:removeAccount")
AddEventHandler(
    "bank:removeAccount",
    function(accountNumber)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "remove", charId, charJobs) ~= nil then
            local name = accounts[accountNumber].name
            local balance = accounts[accountNumber].balance

            if balance >= 0 then
                removeAccount(accountNumber, client)
                bankOpen(client)

                exports.logs:sendToDiscord(
                    {
                        channel = "bank",
                        title = "Smazání účtu",
                        description = "Smazal účet " ..
                            name ..
                            " s číslem " ..
                            accountNumber .. " a zůstatkem " .. exports.data:getFormattedCurrency(balance),
                        color = "16656146"
                    },
                    client
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Nemůžeš smazat účet se záporným zůstatkem!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:removeAccount",
                "Pokusil se smazat účet " .. accountNumber
            )
        end
    end
)

function removeAccount(accountNumber, client)
    accounts[accountNumber] = nil
    accountAccess[accountNumber] = nil
    accountLogs[accountNumber] = nil

    MySQL.Async.execute(
        "DELETE FROM `bank_logs` WHERE source_acc LIKE @source_acc",
        {
            ["@source_acc"] = accountNumber
        }
    )

    MySQL.Async.execute(
        "DELETE FROM `bank_cards` WHERE account LIKE @account",
        {
            ["@account"] = accountNumber
        }
    )

    MySQL.Async.execute(
        "DELETE FROM `bank_accounts` WHERE number LIKE @number",
        {
            ["@number"] = accountNumber
        }
    )

    MySQL.Async.execute(
        "DELETE FROM `bank_access` WHERE account LIKE @number",
        {
            ["@number"] = accountNumber
        }
    )

    for cardNumber, cardData in each(cards) do
        if cardData.account == accountNumber then
            exports.inventory:removePlayerItem(client, "bankcard", 1, { id = cardNumber })
            cards[cardNumber] = nil
        end
    end
end

RegisterNetEvent("bank:removeCard")
AddEventHandler(
    "bank:removeCard",
    function(cardNumber)
        local client = source

        if cards[cardNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        local cardData = cards[cardNumber]
        if getAccess(cardData.account, "cards", charId, charJobs) ~= nil then
            local name = cardData.name

            exports.inventory:removePlayerItem(client, "bankcard", 1, { id = cardNumber })
            removeCard(cardNumber)
            bankOpenDetailCards(client, cardData.account, getAccountCards(cardData.account))

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Smazání karty",
                    description = "Smazal kartu " .. name .. " s číslem " .. cardNumber,
                    color = "16656146"
                },
                client
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:removeCard",
                "Pokusil se smazat kartu " .. cardNumber
            )
        end
    end
)

function removeCard(cardNumber)
    cards[cardNumber] = nil

    MySQL.Async.execute(
        "DELETE FROM `bank_cards` WHERE number LIKE @number",
        {
            ["@number"] = cardNumber
        }
    )
end

RegisterNetEvent("bank:depositToAccount")
AddEventHandler(
    "bank:depositToAccount",
    function(accountNumber, amount)
        local client = source
        amount = math.floor(tonumber(amount))

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "deposit", charId, charJobs) ~= nil then
            local removeCash = exports.inventory:removePlayerItem(client, "cash", amount, {})
            if removeCash == "done" then
                addToAccount(accountNumber, amount)

                local charFistName = exports.data:getCharVar(client, "firstname")
                local charLastName = exports.data:getCharVar(client, "lastname")
                logBankAction(
                    accountNumber,
                    "DEPOSIT_CASH",
                    amount,
                    "",
                    0,
                    "Vklad hotovosti v bance - provedl " .. charFistName .. " " .. charLastName,
                    charId
                )

                bankOpenDetail(client, accountNumber)

                exports.logs:sendToDiscord(
                    {
                        channel = "bank",
                        title = "Vklad na účet",
                        description = "Vložil " ..
                            exports.data:getFormattedCurrency(amount) .. " na učet s číslem " .. accountNumber,
                        color = "2061822"
                    },
                    client
                )
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Úspech",
                        text = "Vložil jsi hotovost na účet!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Nemáš u sebe dostatek hotovosti!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:depositToAccount",
                "Pokusil se vložit " .. amount .. " na účet " .. accountNumber
            )
        end
    end
)

function addToAccount(accountNumber, amount)
    amount = math.floor(tonumber(amount))
    accounts[accountNumber].balance = accounts[accountNumber].balance + amount
    accounts[accountNumber].changed = true
end

RegisterNetEvent("bank:withdrawFromAccount")
AddEventHandler(
    "bank:withdrawFromAccount",
    function(accountNumber, amount)
        local client = source
        amount = math.floor(tonumber(amount))

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "withdraw", charId, charJobs) ~= nil then
            if accounts[accountNumber].balance >= amount then
                local addCash = exports.inventory:addPlayerItem(client, "cash", amount, {})
                if addCash == "done" then
                    addToAccount(accountNumber, -amount)

                    local charFistName = exports.data:getCharVar(client, "firstname")
                    local charLastName = exports.data:getCharVar(client, "lastname")
                    logBankAction(
                        accountNumber,
                        "WITHDRAW_CASH",
                        amount,
                        "",
                        1,
                        "Výběr hotovosti v bance - provedl " .. charFistName .. " " .. charLastName,
                        charId
                    )

                    bankOpenDetail(client, accountNumber)

                    exports.logs:sendToDiscord(
                        {
                            channel = "bank",
                            title = "Výběr z účtu",
                            description = "Vybral " ..
                                exports.data:getFormattedCurrency(amount) .. " z účtu s číslem " .. accountNumber,
                            color = "16689183"
                        },
                        client
                    )
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Úspech",
                            text = "Vybral jsi hotovost z účtu!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe dostatek místa na hotovost!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Tolik peněz na účtu není!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:withdrawFromAccount",
                "Pokusil se vybrat " .. amount .. " z účtu " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:loadCards")
AddEventHandler(
    "bank:loadCards",
    function(accountNumber)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "cards", charId, charJobs) ~= nil then
            bankOpenDetailCards(client, accountNumber, getAccountCards(accountNumber))
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:loadAccount",
                "Pokusil se načíst karty účtu " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:loadFines")
AddEventHandler(
    "bank:loadFines",
    function()
        local client = source
        local charId = exports.data:getCharVar(client, "id")

        TriggerClientEvent("bank:loadFines", client, exports.fines:getFineList(charId, 0))
    end
)

RegisterNetEvent("bank:loadInvoices")
AddEventHandler(
    "bank:loadInvoices",
    function()
        local client = source
        local charId = exports.data:getCharVar(client, "id")

        TriggerClientEvent("bank:loadInvoices", client, exports.invoices:getInvoiceList(charId, 0))
    end
)

RegisterNetEvent("bank:payFine")
AddEventHandler(
    "bank:payFine",
    function(fineId)
        local client = source

        local usableAccounts = {}

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        for accountNumber, accountData in pairs(accounts) do
            if getAccess(accountNumber, "send", charId, charJobs) ~= nil then
                usableAccounts[accountNumber] = accountData
            end
        end

        TriggerClientEvent("bank:payFinesMenu", client, exports.fines:getFineData(charId, fineId), usableAccounts)
    end
)

RegisterNetEvent("bank:payFineFinal")
AddEventHandler(
    "bank:payFineFinal",
    function(fineId, accountNumber)
        local client = source
        local charId = exports.data:getCharVar(client, "id")
        local fineData = exports.fines:getFineData(charId, fineId)

        if fineData == nil or fineData.Paid > 0 then
            return
        end

        if accountNumber == 0 then
            local removeCash = exports.inventory:removePlayerItem(client, "cash", fineData.Price, {})
            if removeCash ~= "done" then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Nemáš u sebe dostatek hotovosti!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
                return
            end
        else
            local charJobs = exports.data:getCharVar(client, "jobs")

            if getAccess(accountNumber, "send", charId, charJobs) ~= nil then
                if accounts[accountNumber] == nil then
                    return
                end

                if accounts[accountNumber].balance >= fineData.Price then
                    addToAccount(accountNumber, -fineData.Price)

                    local charFistName = exports.data:getCharVar(client, "firstname")
                    local charLastName = exports.data:getCharVar(client, "lastname")
                    logBankAction(
                        accountNumber,
                        "SEND_MONEY",
                        fineData.Price,
                        "",
                        1,
                        "Uhrazení pokuty " .. fineData.Label .. " - od " .. charFistName .. " " .. charLastName,
                        charId
                    )
                    if fineData.Job and exports.base_jobs:getJob(fineData.Job) then
                        local destAccount = Config.BankAccounts[fineData.Job]
                        logBankAction(destAccount, "RECEIVE_MONEY", fineData.Price, accountNumber, 0, "Uhrazení pokuty " .. fineData.Label .. " - provedl " .. charFistName .. " " .. charLastName, 0)
                        addToAccount(destAccount, fineData.Price)
                    end

                    bankOpenDetail(client, accountNumber)

                    exports.logs:sendToDiscord(
                        {
                            channel = "bank",
                            title = "Uhazení pokuty z účtu",
                            description = "Uhradil " ..
                                exports.data:getFormattedCurrency(fineData.Price) ..
                                " za " .. fineData.Label .. " z účtu s číslem " .. accountNumber,
                            color = "16689183"
                        },
                        client
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Tolik peněz na účtu není!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                    return
                end
            else
                exports.admin:banClientForCheating(
                    client,
                    "0",
                    "Cheating",
                    "bank:payFineFinal",
                    "Pokusil se zaplatit pokutu " .. fineId .. " z účtu " .. accountNumber
                )
                return
            end
        end

        exports.fines:markFineAsPaid(client, charId, fineId)
        local fineList = exports.fines:getFineList(charId, 0)
        TriggerClientEvent("bank:loadFines", client, fineList)
    end
)

RegisterNetEvent("bank:payInvoice")
AddEventHandler(
    "bank:payInvoice",
    function(invoiceId)
        local client = source

        local usableAccounts = {}

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        for accountNumber, accountData in pairs(accounts) do
            if getAccess(accountNumber, "send", charId, charJobs) ~= nil then
                usableAccounts[accountNumber] = accountData
            end
        end
        TriggerClientEvent("bank:payInvoicesMenu", client, exports.invoices:getInvoiceData(invoiceId), usableAccounts)
    end
)

RegisterNetEvent("bank:payInvoiceFinal")
AddEventHandler(
    "bank:payInvoiceFinal",
    function(invoiceId, accountNumber)
        local client = source
        local charId = exports.data:getCharVar(client, "id")
        local invoiceData = exports.invoices:getInvoiceData(invoiceId)

        if not invoiceData or invoiceData.Paid > 0 then
            return
        end

        if accountNumber == 0 then
            local removeCash = exports.inventory:removePlayerItem(client, "cash", invoiceData.Price, {})
            if removeCash ~= "done" then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Nemáš u sebe dostatek hotovosti!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
                return
            end

            local done = sendToAccount(tostring(invoiceData.Bank), invoiceData.Price, "Příchozí platba za fakturu s č. " .. invoiceData.Id)
            if done == "done" then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "info",
                        title = "Faktura",
                        text = "Faktura byla zaplacena",
                        icon = "fas fa-scroll",
                        length = 3500
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Faktura",
                        text = "Někde nastala chyba!",
                        icon = "fas fa-scroll",
                        length = 3500
                    }
                )
            end
        else
            local charJobs = exports.data:getCharVar(client, "jobs")

            if getAccess(accountNumber, "send", charId, charJobs) then
                if not accounts[accountNumber] then
                    return
                end

                if accounts[accountNumber].balance >= invoiceData.Price then
                    local charFistName = exports.data:getCharVar(client, "firstname")
                    local charLastName = exports.data:getCharVar(client, "lastname")
                    local done = payFromAccountToAccount(
                        accountNumber,
                        tostring(invoiceData.Bank),
                        invoiceData.Price,
                        false,
                        "Uhrazení faktury " .. invoiceData.Id .. " - provedl " .. charFistName .. " " .. charLastName,
                        "Příchozí platba za fakturu s č. " .. invoiceData.Id,
                        client
                    )

                    bankOpenDetail(client, accountNumber)
                    if done == "done" then
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "info",
                                title = "Faktura",
                                text = "Faktura byla zaplacena",
                                icon = "fas fa-scroll",
                                length = 3500
                            }
                        )
                    else
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "warning",
                                title = "Faktura",
                                text = "Někde nastala chyba!",
                                icon = "fas fa-scroll",
                                length = 3500
                            }
                        )
                    end
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Tolik peněz na účtu není!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                    return
                end
            else
                exports.admin:banClientForCheating(
                    client,
                    "0",
                    "Cheating",
                    "bank:payFineFinal",
                    "Pokusil se zaplatit fakturu " .. invoiceId .. " z účtu " .. accountNumber
                )
                return
            end
        end

        exports.invoices:setInvoicePaid(invoiceId, "paid")
        TriggerClientEvent("bank:loadInvoices", client, exports.invoices:getInvoiceList(charId, 0))
    end
)

RegisterNetEvent("bank:loadAccesses")
AddEventHandler(
    "bank:loadAccesses",
    function(accountNumber)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "accesses", charId, charJobs) ~= nil then
            bankOpenDetailAccessesLoad(client, accountNumber, charId, charJobs, false)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:loadAccesses",
                "Pokusil se načíst přístupy účtu " .. accountNumber
            )
        end
    end
)

function getAccountCards(accountNumber)
    local accountCards = {}

    for cardNumber, cardData in pairs(cards) do
        if cardData.account == accountNumber then
            accountCards[cardNumber] = cardData
        end
    end

    return accountCards
end

RegisterNetEvent("bank:loadAccount")
AddEventHandler(
    "bank:loadAccount",
    function(accountNumber)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        local access = getAccess(accountNumber, "view", charId, charJobs)
        if access ~= nil then
            bankOpenDetail(client, accountNumber, access)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:loadAccount",
                "Pokusil se načíst účet " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:loadAccountGraph")
AddEventHandler(
    "bank:loadAccountGraph",
    function(accountNumber)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        local access = getAccess(accountNumber, "view", charId, charJobs)
        if access ~= nil then
            bankOpenDetailGraph(client, accountNumber, access)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:loadAccountGraph",
                "Pokusil se načíst účet " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:editAccount")
AddEventHandler(
    "bank:editAccount",
    function(accountNumber, name, description, icon)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "edit", charId, charJobs) ~= nil then
            accounts[accountNumber].name = name
            accounts[accountNumber].description = description
            accounts[accountNumber].icon = icon
            accounts[accountNumber].changed = true

            bankOpenDetail(client, accountNumber)

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Úprava účtu",
                    description = "Upravil účet " .. accountNumber .. ". Název " .. name .. ". Popis " .. description,
                    color = "16776960"
                },
                client
            )
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Úspech",
                    text = "Účet byl upraven!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:editAccount",
                "Pokusil se upravit účet " .. accountNumber
            )
        end
    end
)

function bankOpenDetailAccessesLoad(client, accountNumber, charId, charJobs, setFocus)
    local charNames = {}
    local jobNames = {}

    local founder = accounts[accountNumber].founder
    charNames[tostring(founder)] = exports.data:getCharNameById(founder)

    if accountAccess[accountNumber] ~= nil then
        for _, accessData in each(accountAccess[accountNumber]) do
            if accessData.type == "char" then
                if charNames[tostring(accessData.who)] == nil then
                    charNames[tostring(accessData.who)] = exports.data:getCharNameById(accessData.who)
                end
            elseif accessData.type == "job" then
                if jobNames[tostring(accessData.who)] == nil then
                    jobNames[tostring(accessData.who)] = exports.base_jobs:getJob(accessData.who)
                end
            end
        end
    end

    bankOpenDetailAccesses(client, accountNumber, charId, charJobs, accountAccess[accountNumber], charNames, jobNames, setFocus)
end

function bankOpenDetailAccesses(client, accountNumber, charId, charJobs, accessDetails, charNames, jobNames, setFocus)
    local hasAccess = getAccess(accountNumber, "accesses", charId, charJobs)
    if hasAccess == nil then
        hasAccess = false
    else
        hasAccess = true
    end

    TriggerClientEvent(
        "bank:refreshDetailsAccesses",
        client,
        accountNumber,
        accessDetails,
        hasAccess,
        charNames,
        jobNames,
        setFocus
    )
end

function bankOpenDetailCards(client, accountNumber, accountCards)
    TriggerClientEvent("bank:refreshDetailsCards", client, accountNumber, accountCards, accounts[accountNumber])
end

function bankOpenDetail(client, accountNumber, access)
    TriggerClientEvent(
        "bank:refreshDetails",
        client,
        accountNumber,
        accounts[accountNumber],
        accountLogs[accountNumber],
        access,
        exports.data:getCharVar(client, "id")
    )
end

function bankOpenDetailGraph(client, accountNumber, access)
    TriggerClientEvent(
        "bank:refreshDetails",
        client,
        accountNumber,
        accounts[accountNumber],
        accountLogs[accountNumber],
        access,
        exports.data:getCharVar(client, "id"),
        true
    )
end

function logBankAction(sourceAccount, action, amount, targetAccount, negative, description, charId)
    local balance = 0
    if accounts[sourceAccount] ~= nil then
        balance = accounts[sourceAccount].balance
    end

    MySQL.Async.execute(
        "INSERT INTO `bank_logs` (`source_acc`, `action`, `amount`, `target_acc`, `description`, `negative`, `balance`, `char_id`) VALUES (@source_acc, @action, @amount, @target_acc, @description, @negative, @balance, @char_id)",
        {
            ["@source_acc"] = sourceAccount,
            ["@action"] = action,
            ["@amount"] = amount,
            ["@target_acc"] = targetAccount,
            ["@description"] = description,
            ["@negative"] = negative,
            ["@balance"] = balance,
            ["@char_id"] = charId
        }
    )

    if accountLogs[sourceAccount] == nil then
        accountLogs[sourceAccount] = {}
    end

    local logInfo = {
        sourceAccount = sourceAccount,
        action = action,
        amount = amount,
        targetAccount = targetAccount,
        description = description,
        charId = charId,
        negative = negative,
        balance = balance,
        date = os.time()
    }
    table.insert(accountLogs[sourceAccount], 1, logInfo)
end

RegisterNetEvent("bank:sendMoneyFromAccount")
AddEventHandler(
    "bank:sendMoneyFromAccount",
    function(accountNumber, accountTarget, amount, descTo, descFrom)
        local client = source
        amount = math.floor(tonumber(amount))

        if accounts[accountNumber] == nil then
            return
        end

        if accounts[accountTarget] == nil then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Účet s takovým číslem neexistuje!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
            return
        end

        if accountNumber == accountTarget then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Nemůžeš posílat peníze na stejný účet!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "send", charId, charJobs) ~= nil then
            if accounts[accountNumber].balance >= amount then
                addToAccount(accountNumber, -amount)
                addToAccount(accountTarget, amount)

                local message = "Odeslaná platba na účet " .. accountTarget
                if descFrom and type(descFrom) == "string" and string.len(descFrom) > 0 then
                    message = message .. " - " .. descFrom
                end

                logBankAction(accountNumber, "SEND_MONEY", amount, accountTarget, 1, message, charId)

                message = "Přijatá platba z účtu " .. accountNumber
                if descTo and type(descTo) == "string" and string.len(descTo) > 0 then
                    message = message .. " - " .. descTo
                end
                logBankAction(accountTarget, "RECEIVE_MONEY", amount, accountNumber, 0, message, charId)

                bankOpenDetail(client, accountNumber)

                exports.logs:sendToDiscord(
                    {
                        channel = "bank",
                        title = "Platba",
                        description = "Odeslal " ..
                            exports.data:getFormattedCurrency(amount) ..
                            " z účtu " .. accountNumber .. " na účet " .. accountTarget,
                        color = "8388736"
                    },
                    client
                )
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Úspech",
                        text = "Peníze byly odeslány!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Tolik peněz na účtu není!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:sendMoneyFromAccount",
                "Pokusil se poslat " .. amount .. " z účtu " .. accountNumber .. " na účet " .. accountTarget
            )
        end
    end
)

RegisterNetEvent("bank:checkCardPin")
AddEventHandler(
    "bank:checkCardPin",
    function(cardNumber, pin)
        local client = source

        if bankCardTries[cardNumber] ~= nil and bankCardTries[cardNumber] >= Config.maxCardPinTries then
            TriggerClientEvent("bank:cardFail", client, bankCardTries[cardNumber], 0)
            return
        end

        if cards[cardNumber] == nil then
            TriggerClientEvent("bank:cardFail", client, 0, 1)
            return
        end

        local accountNumber = cards[cardNumber].account
        if accounts[accountNumber] == nil then
            TriggerClientEvent("bank:cardFail", client, 0, 2)
            return
        end

        if cards[cardNumber].pin ~= tostring(pin) then
            if bankCardTries[cardNumber] == nil then
                bankCardTries[cardNumber] = 1
            else
                bankCardTries[cardNumber] = bankCardTries[cardNumber] + 1
            end

            TriggerClientEvent("bank:cardFail", client, bankCardTries[cardNumber], 3)
            return
        end

        if cardsWithdrawLimits[cardNumber] == nil then
            cardsWithdrawLimits[cardNumber] = 0
        end

        bankCardTries[cardNumber] = 0
        TriggerClientEvent(
            "bank:openATM",
            client,
            accountNumber,
            cardNumber,
            cards[cardNumber],
            cardsWithdrawLimits[cardNumber],
            accounts[accountNumber]
        )
    end
)

RegisterNetEvent("bank:cardDeposit")
AddEventHandler(
    "bank:cardDeposit",
    function(cardNumber, amount)
        local client = source

        if cards[cardNumber] == nil then
            return
        end

        local accountNumber = cards[cardNumber].account
        if accounts[accountNumber] == nil then
            return
        end

        if not exports.inventory:checkPlayerItem(client, "bankcard", 1, { id = cardNumber }) then
            return
        end

        local removeCash = exports.inventory:removePlayerItem(client, "cash", amount, {})
        if removeCash == "done" then
            addToAccount(accountNumber, amount)

            local charId = exports.data:getCharVar(client, "id")
            logBankAction(
                accountNumber,
                "DEPOSIT_CASH",
                amount,
                "",
                0,
                "Vklad hotovosti kartou - " .. cardNumber,
                charId
            )

            TriggerClientEvent(
                "bank:refreshATM",
                client,
                accounts[accountNumber],
                cards[cardNumber],
                cardsWithdrawLimits[cardNumber]
            )

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Vklad na účet kartou",
                    description = "Vložil " ..
                        exports.data:getFormattedCurrency(amount) ..
                        " na učet s číslem " .. accountNumber .. " kartou " .. cardNumber,
                    color = "2061822"
                },
                client
            )
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Úspech",
                    text = "Vložil jsi hotovost na účet!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Nemáš u sebe tolik hotovosti!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        end
    end
)

RegisterNetEvent("bank:cardWithdraw")
AddEventHandler(
    "bank:cardWithdraw",
    function(cardNumber, amount)
        local client = source

        if cards[cardNumber] == nil then
            return
        end

        local accountNumber = cards[cardNumber].account
        if accounts[accountNumber] == nil then
            return
        end

        if not exports.inventory:checkPlayerItem(client, "bankcard", 1, { id = cardNumber }) then
            return
        end

        if cardsWithdrawLimits[cardNumber] == nil then
            cardsWithdrawLimits[cardNumber] = 0
        end

        if accounts[accountNumber].balance >= amount then
            local limit = cardsWithdrawLimits[cardNumber] + amount
            if cards[cardNumber].withdrawLimit == 0 or cards[cardNumber].withdrawLimit >= limit then
                local addCash = exports.inventory:addPlayerItem(client, "cash", amount, {})
                if addCash == "done" then
                    addToAccount(accountNumber, -amount)
                    cardsWithdrawLimits[cardNumber] = cardsWithdrawLimits[cardNumber] + amount

                    local charId = exports.data:getCharVar(client, "id")
                    logBankAction(
                        accountNumber,
                        "WITHDRAW_CASH",
                        amount,
                        "",
                        1,
                        "Výběr hotovosti kartou - " .. cardNumber,
                        charId
                    )

                    TriggerClientEvent(
                        "bank:refreshATM",
                        client,
                        accounts[accountNumber],
                        cards[cardNumber],
                        cardsWithdrawLimits[cardNumber]
                    )

                    exports.logs:sendToDiscord(
                        {
                            channel = "bank",
                            title = "Výběr z účtu kartou",
                            description = "Vybral " ..
                                exports.data:getFormattedCurrency(amount) ..
                                " z účtu s číslem " .. accountNumber .. " kartou " .. cardNumber,
                            color = "16689183"
                        },
                        client
                    )
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Úspech",
                            text = "Vybral jsi hotovost!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe dostatek místa na hotovost!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Překročil bys limit výběrů na kartě!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Tolik peněz na účtu není!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        end
    end
)

RegisterNetEvent("bank:createNewCard")
AddEventHandler(
    "bank:createNewCard",
    function(accountNumber, pin, name, withdrawLimit)
        local client = source

        if accounts[accountNumber] == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "cards", charId, charJobs) ~= nil then
            local paid = false

            if accounts[accountNumber].freeCard then
                accounts[accountNumber].freeCard = false
                accounts[accountNumber].changed = true
                paid = true
            elseif accounts[accountNumber].balance >= 100 then
                addToAccount(accountNumber, -100)

                local charFistName = exports.data:getCharVar(client, "firstname")
                local charLastName = exports.data:getCharVar(client, "lastname")
                logBankAction(
                    accountNumber,
                    "SEND_MONEY",
                    100,
                    "",
                    1,
                    "Založení nové karty - provedl " .. charFistName .. " " .. charLastName,
                    charId
                )

                paid = true
            end

            if paid then
                local newCardNumber = getUniqueCardNumber()
                local addCard = exports.inventory:addPlayerItem(
                    client,
                    "bankcard",
                    1,
                    {
                        label = "Kreditní karta " .. newCardNumber .. "\nÚčet " .. accountNumber,
                        id = newCardNumber,
                        account = accountNumber
                    }
                )

                if addCard == "done" then
                    cards[newCardNumber] = {
                        pin = tostring(pin),
                        name = name,
                        account = accountNumber,
                        withdrawLimit = tonumber(withdrawLimit),
                        changed = true
                    }

                    bankOpenDetailCards(client, accountNumber, getAccountCards(accountNumber))

                    exports.logs:sendToDiscord(
                        {
                            channel = "bank",
                            title = "Vytvoření karty",
                            description = "Vytvořil kartu " .. name .. " s číslem " .. newCardNumber,
                            color = "7601682"
                        },
                        client
                    )
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Úspech",
                            text = "Dostal jsi novou kartu!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe dostatek místa na kartu!",
                            icon = "fas fa-university",
                            length = 5000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Na účtu není $100 na zaplacení karty!",
                        icon = "fas fa-university",
                        length = 5000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:createNewCard",
                "Pokusil se vytvořit kartu k účtu " .. accountNumber
            )
        end
    end
)

RegisterNetEvent("bank:editAccess")
AddEventHandler(
    "bank:editAccess",
    function(accountNumber, accessId, priority, root, view, cardsAccess, withdraw, deposit, edit, send, accesses)
        local client = source

        if accountAccess[accountNumber] == nil then
            return
        end

        local accessIndexById = findAccessIndexById(accountAccess[accountNumber], accessId)
        if accessIndexById == nil then
            return
        end

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountNumber, "accesses", charId, charJobs) ~= nil then
            accountAccess[accountNumber][accessIndexById].priority = priority
            accountAccess[accountNumber][accessIndexById].root = root
            accountAccess[accountNumber][accessIndexById].view = view
            accountAccess[accountNumber][accessIndexById].cards = cardsAccess
            accountAccess[accountNumber][accessIndexById].withdraw = withdraw
            accountAccess[accountNumber][accessIndexById].deposit = deposit
            accountAccess[accountNumber][accessIndexById].edit = edit
            accountAccess[accountNumber][accessIndexById].send = send
            accountAccess[accountNumber][accessIndexById].accesses = accesses
            accountAccess[accountNumber][accessIndexById].changed = true

            table.sort(
                accountAccess[accountNumber],
                function(a, b)
                    return a.priority > b.priority
                end
            )

            bankOpenDetailAccesses(client, accountNumber, charId, charJobs, accountAccess[accountNumber])

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Upravení přístupu",
                    description = "Upravil přístup " .. accessId .. " u účtu " .. accountNumber,
                    color = "16776960"
                },
                client
            )
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Úspech",
                    text = "Přístupy upraveny!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:editAccess",
                "Pokusil se upravit přístup u účtu " .. accountNumber
            )
        end
    end
)

function findAccessIndexById(accessList, accessId)
    for index, accessData in each(accessList) do
        if accessData.id == tonumber(accessId) then
            return index
        end
    end

    return nil
end

RegisterNetEvent("bank:editCard")
AddEventHandler(
    "bank:editCard",
    function(cardNumber, pin, name, withdrawLimit)
        local client = source

        if cards[cardNumber] == nil then
            return
        end
        local accountData = cards[cardNumber]

        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(accountData.account, "cards", charId, charJobs) ~= nil then
            cards[cardNumber].name = name
            cards[cardNumber].pin = tostring(pin)
            cards[cardNumber].withdrawLimit = tonumber(withdrawLimit)
            cards[cardNumber].changed = true

            bankOpenDetailCards(client, accountData.account, getAccountCards(accountData.account))

            exports.logs:sendToDiscord(
                {
                    channel = "bank",
                    title = "Upravení karty",
                    description = "Upravil kartu " .. name .. " s číslem " .. cardNumber,
                    color = "16776960"
                },
                client
            )
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Úspech",
                    text = "Dostal jsi novou kartu!",
                    icon = "fas fa-university",
                    length = 5000
                }
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "bank:editCard",
                "Pokusil se upravit kartu " .. cardNumber
            )
        end
    end
)

function getUniqueCardNumber()
    while true do
        local generatedNumber = tostring(math.random(1000, 9999)) ..
            "-" .. tostring(math.random(1000, 9999)) .. "-" .. tostring(math.random(1000, 9999))
        if cards[generatedNumber] == nil then
            return generatedNumber
        end
    end
end

function getNumberOfAccountsLeft(client)
    local accountsLeft = (exports.data:getCharVar(client, "bank_accounts_left") or 0)
    local charId = exports.data:getCharVar(client, "id")

    local accountsToRemove = 0
    if accountsLeft <= 10 then
        for _, accountData in pairs(accounts) do
            if accountData.founder == charId then
                accountsToRemove = accountsToRemove + 1
            end
        end
    end

    if accountsLeft < 10 then
        accountsLeft = 10
    end

    return (accountsLeft - accountsToRemove)
end

function getPlayerAccesibleAccounts(client, rule)
    local accessibleAccounts = {}

    local charId = exports.data:getCharVar(client, "id")
    local charJobs = exports.data:getCharVar(client, "jobs")

    for accountNumber, accountData in pairs(accounts) do
        if getAccess(accountNumber, rule, charId, charJobs) ~= nil then
            accessibleAccounts[accountNumber] = accountData
        end
    end

    return accessibleAccounts
end

function getJobAccesibleAccounts(job, jobGrade, rule)
    local accessibleAccounts = {}

    for accountNumber, accountData in pairs(accounts) do
        if getAccessJob(accountNumber, job, jobGrade, rule) ~= nil then
            accessibleAccounts[accountNumber] = accountData
        end
    end

    return accessibleAccounts
end

function payFromAccountToAccount(
    sourceAccount,
    destAccount,
    amount,
    canGoNegative,
    paymentDescriptionSender,
    paymentDescriptionReciever,
    client)
    if accounts[sourceAccount] == nil then
        return "sourceAccountDoesNotExist"
    elseif accounts[destAccount] == nil then
        return "destAccountDoesNotExist"
    elseif sourceAccount == destAccount then
        return "sameAccounts"
    end

    if client ~= nil then
        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(sourceAccount, "send", charId, charJobs) == nil then
            return "noAccess"
        end
    end

    amount = math.floor(tonumber(amount))

    if canGoNegative or accounts[sourceAccount].balance >= amount then
        addToAccount(sourceAccount, -amount)
        addToAccount(destAccount, amount)

        local charId = 0
        if client ~= nil then
            charId = exports.data:getCharVar(client, "id")
        end

        logBankAction(sourceAccount, "SEND_MONEY", amount, destAccount, 1, paymentDescriptionSender, charId)
        logBankAction(destAccount, "RECEIVE_MONEY", amount, sourceAccount, 0, paymentDescriptionReciever, charId)

        exports.logs:sendToDiscord(
            {
                channel = "bank",
                title = "Platba z účtu na účet",
                description = "Z účtu " ..
                    sourceAccount ..
                    " na účet" ..
                    destAccount ..
                    "\nČástka: " ..
                    exports.data:getFormattedCurrency(amount) ..
                    "\nZpráva odesílatel: " ..
                    paymentDescriptionSender ..
                    "\nZpráva příjemce: " .. paymentDescriptionReciever,
                color = "16752384"
            },
            client
        )

        return "done"
    else
        return "notEnoughBalance"
    end
end

function payFromAccount(sourceAccount, amount, canGoNegative, paymentDescriptionSender, client)
    if amount == nil then
        return "noAmount"
    end

    if accounts[sourceAccount] == nil then
        return "sourceAccountDoesNotExist"
    end

    if client ~= nil then
        local charId = exports.data:getCharVar(client, "id")
        local charJobs = exports.data:getCharVar(client, "jobs")

        if getAccess(sourceAccount, "send", charId, charJobs) == nil then
            return "noAccess"
        end
    end

    amount = math.floor(tonumber(amount))

    if canGoNegative or accounts[sourceAccount].balance >= amount then
        addToAccount(sourceAccount, -amount)

        local charId = 0
        if client ~= nil then
            charId = exports.data:getCharVar(client, "id")
        end

        logBankAction(sourceAccount, "SEND_MONEY", amount, "", 1, paymentDescriptionSender, charId)

        exports.logs:sendToDiscord(
            {
                channel = "bank",
                title = "Platba z účtu",
                description = "Z účtu " ..
                    sourceAccount ..
                    "\nČástka: " ..
                    exports.data:getFormattedCurrency(amount) ..
                    "\nZpráva odesílatel: " .. paymentDescriptionSender,
                color = "16752384"
            },
            client
        )

        return "done"
    else
        return "notEnoughBalance"
    end
end

function sendToAccount(destAccount, amount, paymentDescriptionReciever)
    if accounts[destAccount] == nil then
        return "destAccountDoesNotExist"
    end

    amount = math.floor(tonumber(amount))
    addToAccount(destAccount, amount)
    logBankAction(destAccount, "RECEIVE_MONEY", amount, "", 0, paymentDescriptionReciever, 0)

    exports.logs:sendToDiscord(
        {
            channel = "bank",
            title = "Platba na účet",
            description = "Na účet " ..
                destAccount ..
                "\nČástka: " ..
                exports.data:getFormattedCurrency(amount) .. "\nZpráva příjemci: " .. paymentDescriptionReciever,
            color = "16752384"
        },
        nil
    )

    return "done"
end

function doesAccountExist(accountNumber)
    if accounts[accountNumber] == nil then
        return false
    end

    return true
end
