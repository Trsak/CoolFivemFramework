local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
AddEventHandler(
        "inventory:usedItem",
        function(itemName, slot, data)
            if itemName == 'restaurant_menu'  then
                if data.id ~= nil then
                    TSE(GetHandlerName('openMenu'), itemName, data.id)
                else
                    exports.notify:display({type = "error", title = "Chyba", text = "Tohle menu je prázdné! 👿", icon = "fas fa-times", length = 5000})
                end
            elseif itemName == 'alcohol_menu' then
                if data.id ~= nil then
                    TSE(GetHandlerName('openMenu'), itemName, data.id)
                end
            end
end)

function makeMenu(item, data)
    if item.data.id == nil then
        if jobName ~= nil then
            data = {
                item = item.name,
                id = jobName
            }
            TSE(GetHandlerName("makeMenu"), data)
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Přepisovat cizí práci?! 👿", icon = "fas fa-times", length = 5000})
    end
end

CCT(function()
    while true do
        local wait = 5000
        if jobName ~= nil then
            if Config.Menus[jobName] and not isDead and spawned then
                wait = 500
                if #(GetEntityCoords(PlayerPedId()) - Config.PapersPlease) < 2 then
                    if not isShowingHint then
                        isShowingHint = true
                        isClose = true
                        exports["key_hints"]:displayHint({["name"] = string.format("papers"), ["key"] = "~INPUT_DAF1F3B5~", ["text"] = string.format('Otevřít %s', "Papirnictví"), ["coords"] = Config.PapersPlease})
                    end
                else
                    isClose = false
                    exports["key_hints"]:hideHint({["name"] = string.format("papers")})
                    isShowingHint = false
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function textarea()
    local limit = 10
    local title = 'Kolik kusu chces koupit?'
    local text = ''

    AddTextEntry('FMMC_KEY_TIP8', title)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", text, "", "", "", limit)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        text = GetOnscreenKeyboardResult()
    end
    return text
end

RegisterCommand("openPapersPlease", function()
    if isShowingHint then
        local mainMenu = true
        local selectedItem = false
        local count = 0
        local price = 0
        WarMenu.CreateMenu("papers", "Papirnictví", "Možnosti")
        WarMenu.OpenMenu("papers")
        WarMenu.SetMenuY("papers", 0.35)

        while true do
            if not isClose then exports["key_hints"]:hideHint({["name"] = string.format("papers")}) isShowingHint = false break end
            if WarMenu.IsMenuOpened("papers") then
                if mainMenu then
                    if exports.job_default:GetJobSpec(jobName) == "restaurant" and WarMenu.Button("Nakoupit jídelní a nápojový lístek") then
                        selectedItem = "restaurant_menu"
                        --WarMenu.CloseMenu()
                        mainMenu = false
                        count = tonumber(textarea())
                    elseif exports.job_default:GetJobSpec(jobName) == "restaurant" and WarMenu.Button("Nakoupit barmenu") then
                        selectedItem = "alcohol_menu"
                        --WarMenu.CloseMenu()
                        mainMenu = false
                        count = tonumber(textarea())
                    end
                else
                    repeat if not isClose then break end until count ~= 0
                    price = Config.Price[selectedItem] * count
                    if WarMenu.Button(string.format("Zaplatit %s $", price)) then
                        data = {
                            item = selectedItem,
                            id = jobName
                        }
                        exports.inventory:addPlayerItem(source, data.item, count, data)
                        WarMenu.CloseMenu()
                    elseif  WarMenu.Button(string.format("Nezaplatit")) then
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
end, false)

createNewKeyMapping({command = "openPapersPlease", text = "Otevřít papírnictví", key = "E"})