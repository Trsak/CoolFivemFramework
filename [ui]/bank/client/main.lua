local isSpawned, isDead, openedBank, isInMachine = false, false, 0, 0
local publicBlips = {}
local isUsingCard = false
local closestATM

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")

            createBankZones()
            showBlips = exports.settings:getSettingValue("bankBlips")
            if showBlips then
                createBankBlips()
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or "dead" then
            isSpawned = true
            isDead = (status == "dead")

            if isDead then
                if openedBank > 0 or isUsingCard then
                    close()
                end
            end
            createBankZones()
        end
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "bankcard" then
            if isUsingCard then
                return
            end
            isUsingCard = true

            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, modelATM in each(Config.ATMs) do
                closestATM = GetClosestObjectOfType(playerCoords, 1.8, GetHashKey(modelATM))
                if DoesEntityExist(closestATM) then
                    break
                end
            end

            if DoesEntityExist(closestATM) then
                local playerPed = PlayerPedId()
                TaskTurnPedToFaceEntity(playerPed, closestATM, 10000)
                RequestModel(GetHashKey("prop_cs_credit_card"))

                while not HasModelLoaded(GetHashKey("prop_cs_credit_card")) do
                    Wait(10)
                end

                local checks = 5

                local position = GetOffsetFromEntityInWorldCoords(closestATM, 0.0, -0.4, 0.05)
                if not IsEntityAtCoord(playerPed, position, 0.2, 0.1, 1.5, false, true, 0) then
                    while not IsEntityAtCoord(playerPed, position, 0.2, 0.1, 1.5, false, true, 0) do
                        TaskGoStraightToCoord(playerPed, position, 1.0, 20000, GetEntityHeading(closestATM), 0.5)
                        Citizen.Wait(250)

                        checks = checks - 1
                        if checks <= 0 then
                            break
                        end
                    end
                end

                RequestAnimDict("mp_common")
                while (not HasAnimDictLoaded("mp_common")) do
                    Wait(10)
                end

                Wait(350)
                local ppos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, -5.0)
                local ccspawned =
                    CreateObject(GetHashKey("prop_cs_credit_card"), ppos.x, ppos.y, ppos.z, true, false, false)
                SetCurrentPedWeapon(playerPed, 0xA2719263)
                SetModelAsNoLongerNeeded(GetHashKey("prop_cs_credit_card"))
                AttachEntityToEntity(
                    ccspawned,
                    playerPed,
                    GetPedBoneIndex(playerPed, 57005),
                    0.19,
                    0.04,
                    -0.05,
                    180.0,
                    0.0,
                    0.0,
                    1,
                    1,
                    0,
                    1,
                    0,
                    1
                )
                TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
                Wait(1000)
                PlaySoundFromEntity(-1, "PIN_BUTTON", closestATM, "ATM_SOUNDS", 1)
                DetachEntity(ccspawned, 1, 1)
                DeleteEntity(ccspawned)
                Wait(1000)
                ClearPedTasks(playerPed)

                exports.input:openInput(
                    "text",
                    {title = "Zadejte PIN kód", placeholder = "Čtyřmístný PIN", hidden = true},
                    function(pinCode)
                        if pinCode == nil then
                            exports.notify:display(
                                {
                                    type = "error",
                                    title = "Chyba",
                                    text = "Musíš zadat PIN!",
                                    icon = "fas fa-credit-card",
                                    length = 3500
                                }
                            )
                            takeOutCard()
                        else
                            pinCode = tostring(pinCode)
                            if pinCode == nil or string.len(pinCode) ~= 4 or tonumber(pinCode) == nil then
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Chyba",
                                        text = "PIN kód musí být čtyřmístné číslo!",
                                        icon = "fas fa-credit-card",
                                        length = 3500
                                    }
                                )
                                takeOutCard()
                            else
                                TriggerServerEvent("bank:checkCardPin", data.id, pinCode)
                            end
                        end
                    end
                )
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Karta",
                        text = "Musíš stát u bankomatu!",
                        icon = "fas fa-credit-card",
                        length = 2500
                    }
                )

                isUsingCard = false
            end
        end
    end
)

RegisterNetEvent("bank:cardFail")
AddEventHandler(
    "bank:cardFail",
    function(tries, errorType)
        if tries >= Config.maxCardPinTries or errorType == 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Karta",
                    text = "Karta je zablokovaná!",
                    icon = "fas fa-credit-card",
                    length = 3500
                }
            )
        elseif errorType == 1 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Karta",
                    text = "Tato karta byla zrušena!",
                    icon = "fas fa-credit-card",
                    length = 3500
                }
            )
        elseif errorType == 2 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Karta",
                    text = "Účet ke kartě byl zrušen!",
                    icon = "fas fa-credit-card",
                    length = 3500
                }
            )
        elseif errorType == 3 then
            local remainingTried = Config.maxCardPinTries - tries
            local textRemaining = "Zbývá ti 1 pokus!"
            if remainingTried > 1 then
                textRemaining = "Zbývají ti " .. remainingTried .. " pokusy!"
            end

            exports.notify:display(
                {
                    type = "error",
                    title = "Karta",
                    text = "Špatný PIN! " .. textRemaining,
                    icon = "fas fa-credit-card",
                    length = 3500
                }
            )
        end

        takeOutCard()
    end
)

RegisterNUICallback(
    "closepanel",
    function(data, cb)
        close()
        cb("ok")
    end
)

function close()
    SendNUIMessage({action = "hide"})
    SetNuiFocus(false, false)
    openedAccounts = nil
    isInMachine = false
    openedBank = 0

    if isUsingCard then
        takeOutCard()
    end

    ClearPedTasksImmediately(PlayerPedId())
end

function takeOutCard()
    isUsingCard = false

    if isDead then
        return
    end

    local playerPed = PlayerPedId()
    TaskTurnPedToFaceEntity(playerPed, closestATM, 10000)
    RequestModel(GetHashKey("prop_cs_credit_card"))

    while not HasModelLoaded(GetHashKey("prop_cs_credit_card")) do
        Wait(10)
    end

    RequestAnimDict("mp_common")
    while (not HasAnimDictLoaded("mp_common")) do
        Wait(10)
    end

    Wait(350)
    SetCurrentPedWeapon(playerPed, 0xA2719263)
    TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
    Wait(1000)
    PlaySoundFromEntity(-1, "PIN_BUTTON", closestATM, "ATM_SOUNDS", 1)
    local ppos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, -5.0)
    local ccspawned = CreateObject(GetHashKey("prop_cs_credit_card"), ppos.x, ppos.y, ppos.z, true, false, false)
    AttachEntityToEntity(
        ccspawned,
        playerPed,
        GetPedBoneIndex(playerPed, 57005),
        0.19,
        0.04,
        -0.05,
        180.0,
        0.0,
        0.0,
        1,
        1,
        0,
        1,
        0,
        1
    )
    SetModelAsNoLongerNeeded(GetHashKey("prop_cs_credit_card"))
    Wait(1000)
    DetachEntity(ccspawned, 1, 1)
    DeleteEntity(ccspawned)
    ClearPedTasks(playerPed)
end

function createBankZones()
    for i, bankData in each(Config.banks) do
        if bankData.zone then
            exports["target"]:AddBoxZone(
                "bankUse" .. i,
                bankData.zone[1],
                bankData.zone[2],
                bankData.zone[3],
                bankData.zone[4],
                {
                    actions = {
                        casinoChips = {
                            cb = function(currentBankData)
                                if not isDead and openedBank == 0 then
                                    openedBank = currentBankData.index
                                    TriggerServerEvent("bank:open")
                                end
                            end,
                            cbData = {
                                index = i
                            },
                            icon = "fas fa-university",
                            label = "Bankovní přepážka"
                        }
                    },
                    distance = 8.0
                }
            )
        end
    end
end

RegisterNetEvent("bank:openATM")
AddEventHandler(
    "bank:openATM",
    function(accountNumber, cardNumber, cardData, cardsWithdrawLimit, accountData)
        SendNUIMessage(
            {
                action = "showATM",
                accountNumber = accountNumber,
                cardNumber = cardNumber,
                cardData = cardData,
                cardsWithdrawLimit = cardsWithdrawLimit,
                accountData = accountData
            }
        )
        SetNuiFocus(true, true)

        playBaseAnimATM()
    end
)

function playBaseAnimATM(recall)
    if not isUsingCard then
        return
    end

    local sex = exports.skinchooser:getPlayerSex()
    local speed = 5.0
    if recall then
        speed = 0.1
    end

    if sex == 1 then
        RequestAnimDict("anim@amb@prop_human_atm@interior@female@base")
        while (not HasAnimDictLoaded("anim@amb@prop_human_atm@interior@female@base")) do
            Citizen.Wait(10)
        end

        TaskPlayAnim(
            PlayerPedId(),
            "anim@amb@prop_human_atm@interior@female@base",
            "base",
            speed,
            1.5,
            1.0,
            1,
            0.2,
            0,
            0,
            0
        )
    else
        RequestAnimDict("anim@amb@prop_human_atm@interior@male@base")
        while (not HasAnimDictLoaded("anim@amb@prop_human_atm@interior@male@base")) do
            Citizen.Wait(10)
        end

        TaskPlayAnim(
            PlayerPedId(),
            "anim@amb@prop_human_atm@interior@male@base",
            "base",
            speed,
            1.5,
            1.0,
            1,
            0.2,
            0,
            0,
            0
        )
    end

    Wait(math.random(2000, 4500))
    playRandomAnimATM(sex)
end

function playRandomAnimATM(sex)
    if not isUsingCard then
        return
    end

    local playedAnim

    if sex == 1 then
        local randomAnims = {"idle_a", "idle_b", "idle_c"}

        RequestAnimDict("anim@amb@prop_human_atm@interior@female@idle_a")
        while (not HasAnimDictLoaded("anim@amb@prop_human_atm@interior@female@idle_a")) do
            Citizen.Wait(10)
        end

        playedAnim = {
            "anim@amb@prop_human_atm@interior@female@idle_a",
            randomAnims[math.random(1, #randomAnims)]
        }
        TaskPlayAnim(
            PlayerPedId(),
            "anim@amb@prop_human_atm@interior@female@idle_a",
            playedAnim[2],
            5.0,
            0.1,
            1.0,
            0,
            0.2,
            0,
            0,
            0
        )
    else
        local randomAnims = {"idle_a", "idle_b", "idle_c"}

        RequestAnimDict("anim@amb@prop_human_atm@interior@male@idle_a")
        while (not HasAnimDictLoaded("anim@amb@prop_human_atm@interior@male@idle_a")) do
            Citizen.Wait(10)
        end

        playedAnim = {
            "anim@amb@prop_human_atm@interior@male@idle_a",
            randomAnims[math.random(1, #randomAnims)]
        }
        TaskPlayAnim(
            PlayerPedId(),
            "anim@amb@prop_human_atm@interior@male@idle_a",
            playedAnim[2],
            5.0,
            0.1,
            1.0,
            0,
            0.2,
            0,
            0,
            0
        )
    end

    Citizen.CreateThread(
        function()
            while true do
                Wait(100)
                if not IsEntityPlayingAnim(PlayerPedId(), playedAnim[1], playedAnim[2], 3) then
                    Wait(250)
                    playBaseAnimATM(true)
                    break
                end
            end
        end
    )
end

RegisterNetEvent("bank:refreshATM")
AddEventHandler(
    "bank:refreshATM",
    function(accountData, cardData, cardsWithdrawLimit)
        SendNUIMessage(
            {
                action = "refreshATM",
                cardData = cardData,
                cardsWithdrawLimit = cardsWithdrawLimit,
                accountData = accountData
            }
        )
    end
)

RegisterNetEvent("bank:refreshDetailsAccesses")
AddEventHandler(
    "bank:refreshDetailsAccesses",
    function(accountNumber, accessDetails, hasAccess, charNames, jobNames, setFocus)
        if setFocus ~= nil and setFocus == true then
            SendNUIMessage(
                {
                    action = "show"
                }
            )
            SetNuiFocus(true, true)
        end

        SendNUIMessage(
            {
                action = "refreshDetailsAccesses",
                accountNumber = accountNumber,
                accessDetails = accessDetails,
                hasAccess = hasAccess,
                charNames = charNames,
                jobNames = jobNames
            }
        )
    end
)

RegisterNetEvent("bank:refreshDetailsCards")
AddEventHandler(
    "bank:refreshDetailsCards",
    function(accountNumber, accountCards, accountData)
        SendNUIMessage(
            {
                action = "refreshDetailsCards",
                accountNumber = accountNumber,
                accountCards = accountCards,
                accountData = accountData
            }
        )
    end
)

RegisterNetEvent("bank:refreshDetails")
AddEventHandler(
    "bank:refreshDetails",
    function(accountNumber, accountDetails, logs, accessData, charId, graphPage)
        SendNUIMessage(
            {
                action = "refreshDetails",
                accountNumber = accountNumber,
                accountDetails = accountDetails,
                logs = logs,
                accessData = accessData,
                charId = charId,
                graphPage = graphPage
            }
        )
    end
)

RegisterNetEvent("bank:open")
AddEventHandler(
    "bank:open",
    function(numberOfAccountsLeft, accessibleAccounts)
        openBankMenu(accessibleAccounts, numberOfAccountsLeft)
    end
)

RegisterNetEvent("bank:loadFines")
AddEventHandler(
    "bank:loadFines",
    function(fines)
        if openedBank == 0 then
            openBankMenu()
        end

        SendNUIMessage(
            {
                action = "openFines",
                fines = fines
            }
        )
    end
)

RegisterNetEvent("bank:loadInvoices")
AddEventHandler(
    "bank:loadInvoices",
    function(invoices)
        if openedBank == 0 then
            openBankMenu()
        end

        SendNUIMessage(
            {
                action = "openInvoices",
                invoices = invoices
            }
        )
    end
)

RegisterNetEvent("bank:payFinesMenu")
AddEventHandler(
    "bank:payFinesMenu",
    function(fineData, usableAccounts)
        WarMenu.CreateMenu(
            "bank_fines_menu",
            "Pokuta: " .. fineData.Label,
            "Zvolte způsob úhrady (" .. exports.data:getFormattedCurrency(fineData.Price) .. ")"
        )
        WarMenu.OpenMenu("bank_fines_menu")

        WarMenu.CreateSubMenu("bank_fines_menu_account", "bank_fines_menu", "Zvol účet")

        while true do
            if WarMenu.IsMenuOpened("bank_fines_menu") then
                if WarMenu.Button("Zaplatit hotovostí") then
                    local currentCash = exports.inventory:getCurrentCash()
                    if currentCash < fineData.Price then
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Chyba",
                                text = "Nemáš u sebe dostatek hotovosti!",
                                icon = "fas fa-times",
                                length = 5000
                            }
                        )
                    else
                        TriggerServerEvent("bank:payFineFinal", fineData.Dbid, 0)
                        WarMenu.CloseMenu()
                    end
                end

                WarMenu.MenuButton("Uhradit převodem z účtu", "bank_fines_menu_account")
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("bank_fines_menu_account") then
                for accountNumber, accountData in pairs(usableAccounts) do
                    if WarMenu.Button(accountData.name, accountNumber) then
                        TriggerServerEvent("bank:payFineFinal", fineData.Dbid, accountNumber)
                        WarMenu.CloseMenu()
                    end
                end

                WarMenu.Display()
            else
                WarMenu.CloseMenu()
                break
            end

            Citizen.Wait(0)
        end
    end
)

RegisterNetEvent("bank:payInvoicesMenu")
AddEventHandler(
    "bank:payInvoicesMenu",
    function(invoiceData, usableAccounts)
        WarMenu.CreateMenu(
            "bank_invoices_menu",
            "Faktura: " .. invoiceData.Id,
            "Zvolte způsob úhrady (" .. exports.data:getFormattedCurrency(invoiceData.Price) .. ")"
        )
        WarMenu.OpenMenu("bank_invoices_menu")

        WarMenu.CreateSubMenu("bank_invoices_menu_account", "bank_invoices_menu", "Zvol účet")

        while true do
            if WarMenu.IsMenuOpened("bank_invoices_menu") then
                if WarMenu.Button("Zaplatit hotovostí") then
                    local currentCash = exports.inventory:getCurrentCash()
                    if currentCash < invoiceData.Price then
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Chyba",
                                text = "Nemáš u sebe dostatek hotovosti!",
                                icon = "fas fa-times",
                                length = 5000
                            }
                        )
                    else
                        TriggerServerEvent("bank:payInvoiceFinal", invoiceData.Id, 0)
                        WarMenu.CloseMenu()
                    end
                end

                WarMenu.MenuButton("Uhradit převodem z účtu", "bank_invoices_menu_account")
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("bank_invoices_menu_account") then
                for accountNumber, accountData in pairs(usableAccounts) do
                    if WarMenu.Button(accountData.name, accountNumber) then
                        TriggerServerEvent("bank:payInvoiceFinal", invoiceData.Id, accountNumber)
                        WarMenu.CloseMenu()
                    end
                end

                WarMenu.Display()
            else
                WarMenu.CloseMenu()
                break
            end

            Citizen.Wait(0)
        end
    end
)

function openBankMenu(accessibleAccounts, numberOfAccountsLeft)
    local company = nil
    if openedBank > 0 then
        company = Config.banks[openedBank].company
    end

    SendNUIMessage(
        {
            action = "show",
            accounts = accessibleAccounts,
            numberOfAccountsLeft = numberOfAccountsLeft,
            bankCompany = company
        }
    )
    SetNuiFocus(true, true)
end

RegisterNUICallback(
    "cardWithdraw",
    function(data, cb)
        local cardNumber = tostring(data.cardNumber)
        local amount = tonumber(data.amount)

        if amount == nil or amount < 0 or amount ~= math.floor(amount) then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Částka musí být celé kladné číslo!",
                    icon = "fas fa-credit-card",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:cardWithdraw", cardNumber, amount)
        end
        cb("done")
    end
)

RegisterNUICallback(
    "cardDeposit",
    function(data, cb)
        local cardNumber = tostring(data.cardNumber)
        local amount = tonumber(data.amount)

        if amount == nil or amount < 0 or amount ~= math.floor(amount) then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Částka musí být celé kladné číslo!",
                    icon = "fas fa-credit-card",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:cardDeposit", cardNumber, amount)
        end
        cb("done")
    end
)

RegisterNUICallback(
    "removeAccount",
    function(data, cb)
        local account = tostring(data.account)

        TriggerServerEvent("bank:removeAccount", account)
        cb("done")
    end
)

RegisterNUICallback(
    "removeAccess",
    function(data, cb)
        local account = tostring(data.account)
        local accessId = tostring(data.accessId)

        TriggerServerEvent("bank:removeAccess", account, accessId)
        cb("done")
    end
)

RegisterNUICallback(
    "removeCard",
    function(data, cb)
        local card = tostring(data.card)

        TriggerServerEvent("bank:removeCard", card)
        cb("done")
    end
)

RegisterNUICallback(
    "loadCards",
    function(data, cb)
        local account = tostring(data.account)

        TriggerServerEvent("bank:loadCards", account)
        cb("done")
    end
)

RegisterNUICallback(
    "loadAccesses",
    function(data, cb)
        local account = tostring(data.account)

        TriggerServerEvent("bank:loadAccesses", account)
        cb("done")
    end
)

RegisterNUICallback(
    "createNewCard",
    function(data, cb)
        local account = tostring(data.account)
        local name = tostring(data.name)
        local pin = tostring(data.pin)
        local withdrawLimit = tonumber(data.withdrawLimit)

        if pin == nil or string.len(pin) ~= 4 or tonumber(pin) == nil then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "PIN musí být čtyř místné číslo!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        elseif withdrawLimit == nil or withdrawLimit < 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Limity musí být celá kladná čísla!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:createNewCard", account, pin, name, withdrawLimit)
        end
        cb("done")
    end
)

RegisterNUICallback(
    "editAccess",
    function(data, cb)
        local account = tostring(data.account)
        local accessId = tonumber(data.accessId)
        local priority = tonumber(data.priority)
        local root = data.root
        local view = data.view
        local cards = data.cards
        local withdraw = data.withdraw
        local deposit = data.deposit
        local edit = data.edit
        local send = data.send
        local accesses = data.accesses

        if priority == nil or priority > 1000 or priority < -1000 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Priorita musí být celé číslo od -1000 do 1000!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent(
                "bank:editAccess",
                account,
                accessId,
                priority,
                root,
                view,
                cards,
                withdraw,
                deposit,
                edit,
                send,
                accesses
            )
        end
        cb("done")
    end
)

RegisterNUICallback(
    "editCard",
    function(data, cb)
        local card = tostring(data.card)
        local name = tostring(data.name)
        local pin = tostring(data.pin)
        local withdrawLimit = tonumber(data.withdrawLimit)

        if pin == nil or string.len(pin) ~= 4 or tonumber(pin) == nil then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "PIN musí být čtyř místné číslo!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        elseif withdrawLimit == nil or withdrawLimit < 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Limity musí být celá kladná čísla!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:editCard", card, pin, name, withdrawLimit)
        end
        cb("done")
    end
)

RegisterNUICallback(
    "editAccount",
    function(data, cb)
        local account = tostring(data.account)
        local name = tostring(data.name)
        local description = tostring(data.description)
        local icon = tostring(data.icon)

        TriggerServerEvent("bank:editAccount", account, name, description, icon)
        cb("done")
    end
)

RegisterNUICallback(
    "loadAccount",
    function(data, cb)
        local account = tostring(data.account)

        TriggerServerEvent("bank:loadAccount", account)
        cb("done")
    end
)

RegisterNUICallback(
    "loadAccountGraph",
    function(data, cb)
        local account = tostring(data.account)

        TriggerServerEvent("bank:loadAccountGraph", account)
        cb("done")
    end
)

RegisterNUICallback(
    "loadFines",
    function(data, cb)
        TriggerServerEvent("bank:loadFines")
        cb("done")
    end
)

RegisterNUICallback(
    "loadInvoices",
    function(data, cb)
        TriggerServerEvent("bank:loadInvoices")
        cb("done")
    end
)

RegisterNUICallback(
    "createAccount",
    function(data, cb)
        local name = tostring(data.name)
        local description = tostring(data.description)
        local icon = tostring(data.icon)

        TriggerServerEvent("bank:createAccount", name, description, icon)
        cb("done")
    end
)

RegisterNUICallback(
    "depositAmount",
    function(data, cb)
        local account = tostring(data.account)
        local amount = tonumber(data.amount)

        if amount == nil or amount <= 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Částka musí být kladné celé číslo větší než 0!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:depositToAccount", account, math.floor(amount))
        end

        cb("done")
    end
)

RegisterNUICallback(
    "withdrawAmount",
    function(data, cb)
        local account = tostring(data.account)
        local amount = tonumber(data.amount)

        if amount == nil or amount <= 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Částka musí být kladné celé číslo větší než 0!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent("bank:withdrawFromAccount", account, math.floor(amount))
        end

        cb("done")
    end
)

RegisterNUICallback(
    "sendMoney",
    function(data, cb)
        local account = tostring(data.account)
        local accountTarget = tostring(data.accountTarget)
        local amount = tonumber(data.amount)
        local descTo = tostring(data.descTo)
        local descFrom = tostring(data.descFrom)

        if amount == nil or amount <= 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Částka musí být kladné celé číslo větší než 0!",
                    icon = "fas fa-university",
                    length = 2500
                }
            )
        else
            TriggerServerEvent(
                "bank:sendMoneyFromAccount",
                account,
                accountTarget,
                math.floor(amount),
                descTo,
                descFrom
            )
        end

        cb("done")
    end
)

RegisterNUICallback(
    "createNewAccess",
    function(data, cb)
        local accountNumber = tostring(data.account)
        openCreateAccessMenu(accountNumber)

        cb("done")
    end
)

function openCreateAccessMenu(accountNumber)
    WarMenu.CreateMenu("bank_access_menu", "Banka", "Vytvoření přístupu")
    WarMenu.OpenMenu("bank_access_menu")

    WarMenu.CreateSubMenu("bank_access_menu_fraction", "bank_access_menu", "Zvol frakci")
    WarMenu.CreateSubMenu("bank_access_menu_fraction_grade", "bank_access_menu_fraction", "Zvol od jaké hodnosti")

    local selectedJob
    local playerJobs = exports.data:getCharVar("jobs")
    local jobs = exports.base_jobs:getJobs()
    local jobsTable = {}

    for jobName, jobData in pairs(jobs) do
        if doesPlayerHaveJob(playerJobs, jobName) then
            table.insert(jobsTable, jobData)
            jobsTable[#jobsTable].name = jobName
        end
    end

    table.sort(
        jobsTable,
        function(a, b)
            return a.label < b.label
        end
    )

    while true do
        if WarMenu.IsMenuOpened("bank_access_menu") then
            if WarMenu.Button("Vytvořit přístup pro osobu") then
                TriggerEvent(
                    "util:closestPlayer",
                    {
                        radius = 2.0
                    },
                    function(player)
                        if player then
                            TriggerServerEvent("bank:createNewAccess", accountNumber, "char", player)
                        end
                    end
                )
                WarMenu.CloseMenu()
            end

            WarMenu.MenuButton("Vytvořit přístup pro frakci", "bank_access_menu_fraction")
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("bank_access_menu_fraction") then
            for _, jobData in each(jobsTable) do
                if WarMenu.MenuButton(jobData.label, "bank_access_menu_fraction_grade") then
                    selectedJob = jobData.name
                end
            end

            if #jobsTable == 0 then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Nemáš žádnou frakci!",
                        icon = "fas fa-university",
                        length = 2500
                    }
                )
                WarMenu.OpenMenu("bank_access_menu")
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("bank_access_menu_fraction_grade") then
            for gradeId, gradeData in each(jobs[selectedJob].grades) do
                if WarMenu.Button(gradeData.label, gradeId) then
                    TriggerServerEvent("bank:createNewAccess", accountNumber, "job", selectedJob, gradeId)
                    WarMenu.CloseMenu()
                end
            end

            WarMenu.Display()
        else
            WarMenu.CloseMenu()
            break
        end

        Citizen.Wait(0)
    end
end

function doesPlayerHaveJob(playerJobs, jobName)
    for _, jobData in each(playerJobs) do
        if jobData.job == jobName then
            return true
        end
    end

    return false
end

RegisterNUICallback(
    "payFine",
    function(data, cb)
        local fineId = tonumber(data.fine)

        close()
        TriggerServerEvent("bank:payFine", fineId)
        cb("done")
    end
)

RegisterNUICallback(
    "payInvoice",
    function(data, cb)
        close()
        TriggerServerEvent("bank:payInvoice", data.invoice)
        cb("done")
    end
)

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "bankBlips" then
            showBlips = value
            if not showBlips then
                for i, blip in each(publicBlips) do
                    RemoveBlip(blip)
                end
                publicBlips = {}
            else
                createBankBlips()
            end
        end
    end
)

function createBankBlips()
    if #publicBlips <= 0 then
        for i, bankData in each(Config.banks) do
            local company = bankData["company"]
            if not bankData["hidden"] then
                local blip =
                    createNewBlip(
                    {
                        coords = bankData.zone[1],
                        sprite = Config.blips[company]["bType"],
                        display = Config.blips[company]["bDisplay"],
                        scale = Config.blips[company]["bScale"],
                        colour = Config.blips[company]["bColor"],
                        isShortRange = true,
                        text = Config.blips[company]["bLabel"]
                    }
                )

                table.insert(publicBlips, blip)
            end
        end
    end
end