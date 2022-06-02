local isSpawned, isDead = false, false
local fines = nil
local inMenu, inSubMenu = false, false
local jobs = {}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
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

RegisterNetEvent("fines:sync")
AddEventHandler(
    "fines:sync",
    function(recievedFines)
        fines = recievedFines
    end
)

RegisterNetEvent("fines:give")
AddEventHandler(
    "fines:give",
    function(type, fineData)
        if type == "gave" then
            exports.notify:display(
                {type = "info", title = "Pokuta", text = "Předal jste pokutu", icon = "fas fa-scroll", length = 3500}
            )
        elseif type == "got" then
            exports.notify:display(
                {
                    type = "info",
                    title = "Dostal jsi pokutu" .. " (" .. getFormattedCurrency(fineData.price) .. ")",
                    text = fineData.label,
                    icon = "fas fa-scroll",
                    length = 7500
                }
            )
        end
    end
)

RegisterNetEvent("fines:pay")
AddEventHandler(
    "fines:pay",
    function(status)
        if status == "done" then
            exports.notify:display(
                {type = "info", title = "Pokuta", text = "Pokuta byla zaplacena", icon = "fas fa-scroll", length = 3500}
            )
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Pokuta",
                    text = "Nemáte dostatečný počet peněz",
                    icon = "fas fa-scroll",
                    length = 3500
                }
            )
        end
    end
)

RegisterCommand(
    "fine",
    function()
        tryFine()
    end
)

RegisterCommand(
    "pokuty",
    function()
        tryFine()
    end
)

function tryFine()
    if isDead then
        return
    end
    if isPolice() and not inMenu then
        inMenu = true
        exports.emotes:playEmoteByName("notepad")
        openFines({})
    else
        exports.notify:display(
            {
                type = "error",
                title = "Pokuta",
                text = "Nemáte příslušné oprávnění",
                icon = "fas fa-scroll",
                length = 3500
            }
        )
    end
end

Citizen.CreateThread(
    function()
        while true do
            Wait(700)
            if inMenu and not IsEntityPlayingAnim(PlayerPedId(), "missheistdockssetup1clipboard@base", "base", 3) then
                exports.emotes:playEmoteByName("notepad")
            end
        end
    end
)

function openFines(selectedFines)
    local editingFine
    local filter = ""
    local selectingPlayer = false

    WarMenu.CreateMenu("fines", "Pokutování", "Vytvořit pokutu")
    WarMenu.SetMenuY("fines", 0.35)
    WarMenu.OpenMenu("fines")

    WarMenu.CreateSubMenu("fines_create", "fines", "Zvolte pokutu")
    WarMenu.CreateSubMenu("fines_edit", "fines", "Změnit pokutu")

    while true do
        if WarMenu.IsMenuOpened("fines") then
            local totalValue = 0

            for i, fineData in each(selectedFines) do
                totalValue = totalValue + fineData.Price

                if WarMenu.Button(fineData.Label, getFormattedCurrency(fineData.Price)) then
                    editingFine = {
                        Id = fineData.Id,
                        currentId = i
                    }

                    WarMenu.OpenMenu("fines_edit")
                end
            end

            if WarMenu.MenuButton("~g~Přidat položku", "fines_create") then
                filter = ""
            end

            if #selectedFines > 0 then
                if WarMenu.Button("~o~Vystavit pokuty", getFormattedCurrency(totalValue)) then
                    WarMenu.CloseMenu()

                    TriggerEvent(
                        "util:closestPlayer",
                        {
                            radius = 2.0
                        },
                        function(player)
                            if player then
                                TriggerServerEvent("fines:giveFine", player, selectedFines)
                            else
                                selectingPlayer = true

                                Citizen.CreateThread(
                                    function()
                                        Wait(100)
                                        openFines(selectedFines)
                                    end
                                )
                            end
                        end
                    )
                end
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("fines_edit") then
            local fineData = fines[editingFine.Id]
            local currentFineData = selectedFines[editingFine.currentId]

            local finePriceRange = getFormattedCurrency(fineData.PriceMin)
            if fineData.PriceMin ~= fineData.PriceMax then
                finePriceRange = finePriceRange .. " - " .. getFormattedCurrency(fineData.PriceMax)
            end

            if fineData.PriceMin ~= fineData.PriceMax then
                if WarMenu.Button("Upravit částku", getFormattedCurrency(currentFineData.Price)) then
                    exports.input:openInput(
                        "number",
                        {title = "Zadejte částku", placeholder = finePriceRange, value = currentFineData.Price},
                        function(fineValue)
                            if fineValue == nil then
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Chyba",
                                        text = "Musíš zadat částku!",
                                        icon = "fas fa-times",
                                        length = 3500
                                    }
                                )
                            else
                                fineValue = tonumber(fineValue)
                                if fineValue == nil or fineValue < fineData.PriceMin or fineValue > fineData.PriceMax then
                                    exports.notify:display(
                                        {
                                            type = "error",
                                            title = "Chyba",
                                            text = "Musíš zadat částku v hodnotě " .. finePriceRange .. "!",
                                            icon = "fas fa-times",
                                            length = 3500
                                        }
                                    )
                                else
                                    selectedFines[editingFine.currentId].Price = fineValue
                                    WarMenu.OpenMenu("fines")
                                end
                            end
                        end
                    )
                end
            end

            if WarMenu.Button("Odstranit položku") then
                table.remove(selectedFines, editingFine.currentId)
                WarMenu.OpenMenu("fines")
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("fines_create") then
            if WarMenu.Button("~o~Filtr", "~o~" .. filter) then
                exports.input:openInput(
                    "text",
                    {title = "Zadejte filtr", value = filter},
                    function(newFilter)
                        if newFilter then
                            filter = newFilter
                        end
                    end
                )
            end

            for i, fineData in each(fines) do
                if filter == nil or filter == "" or matchesFilter(filter, fineData.Label) then
                    local finePriceRange = getFormattedCurrency(fineData.PriceMin)
                    if fineData.PriceMin ~= fineData.PriceMax then
                        finePriceRange = finePriceRange .. " - " .. getFormattedCurrency(fineData.PriceMax)
                    end

                    if WarMenu.Button(fineData.Label, finePriceRange) then
                        if fineData.PriceMin == fineData.PriceMax then
                            table.insert(
                                selectedFines,
                                {
                                    Label = fineData.Label,
                                    Price = fineData.PriceMin,
                                    Id = i
                                }
                            )
                            WarMenu.OpenMenu("fines")
                        else
                            exports.input:openInput(
                                "number",
                                {title = "Zadejte částku", placeholder = finePriceRange},
                                function(fineValue)
                                    if fineValue == nil then
                                        exports.notify:display(
                                            {
                                                type = "error",
                                                title = "Chyba",
                                                text = "Musíš zadat částku!",
                                                icon = "fas fa-times",
                                                length = 3500
                                            }
                                        )
                                    else
                                        fineValue = tonumber(fineValue)
                                        if
                                            fineValue == nil or fineValue < fineData.PriceMin or
                                                fineValue > fineData.PriceMax
                                         then
                                            exports.notify:display(
                                                {
                                                    type = "error",
                                                    title = "Chyba",
                                                    text = "Musíš zadat částku v hodnotě " .. finePriceRange .. "!",
                                                    icon = "fas fa-times",
                                                    length = 3500
                                                }
                                            )
                                        else
                                            table.insert(
                                                selectedFines,
                                                {
                                                    Label = fineData.Label,
                                                    Price = fineValue,
                                                    Id = i
                                                }
                                            )
                                            WarMenu.OpenMenu("fines")
                                        end
                                    end
                                end
                            )
                        end
                    end
                end
            end

            WarMenu.Display()
        else
            if not selectingPlayer then
                exports.emotes:cancelEmote()
            end
            break
        end
        Citizen.Wait(0)
    end

    inMenu = false
    inSubMenu = false
end

function isPolice()
    for _, data in pairs(jobs) do
        if Config.CanFine[data.Type] then
            return true
        end
    end
    return false
end

function loadJobs(Jobs)
    if not isSpawned then
        return
    end
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function matchesFilter(filter, label)
    filter = string.lower(filter)
    label = string.lower(label)

    if string.find(label, filter) then
        return true
    end

    return false
end
