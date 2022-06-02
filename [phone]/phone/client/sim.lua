local activeMobile = nil
local newActivePhone = false

AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if data.type == 'sim'  then
        if data.id ~= nil then
            local mobile = exports.inventory:getActiveMobile()
            createMenu(itemName, slot, data, mobile)
        else
            exports.notify:display({type = "error", title = "Chyba", text = "KADYYYY! 👿", icon = "fas fa-times", length = 5000})
        end
    end
end)

function ActivateMobile(mobile)
    if mobile then
        if mobile.data ~= nil then
            activeMobile = mobile
            isLoggedIn = false
            SetTimeout(50, function()
                TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
            end)
        end
    else
        isLoggedIn = false
        unLoad()
        SendNUIMessage({
            action = "close"
        })
    end
end

function setMobile()
    local mobile = exports.inventory:getActiveMobile()
    activeMobile = mobile
end

function getActiveMobile()
    return activeMobile
end

function getNewMobile()
    local mobile = exports.inventory:getActiveMobile()
    if mobile ~= nil and activeMobile.data.id == mobile.data.id then
        newActivePhone = false
    else
        newActivePhone = true
    end
    return newActivePhone
end

function ActiveSim(item, slot, data)
    local mobile = getActiveMobile()
    if mobile then
        createMenu(item, slot, data, mobile)
    end
end

function mobileMenu(itemName, slot, data)
    local mobile = getActiveMobile()
    PhoneData.phoneModel = data.phoneModel

    if data ~= nil and mobile ~= nil then
        SetTimeout(50, function()
            createMenu(itemName, slot, data, mobile)
            TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
        end)
        if Config.Debug then
            Utils.DumpTable(data)
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Nemáš el Mobile! 👿", icon = "fas fa-times", length = 5000})
    end
end

function createMenu(item, slot, data, mobile)
    local mobileData = mobile.data
    if not PhoneData.isOpen then
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("phone_sim_action", "Akce se Sim kartou", "Zvolte akci")
            WarMenu.OpenMenu("phone_sim_action")
            WarMenu.SetMenuY("phone_sim_action", 0.35)
            while true do
                if WarMenu.IsMenuOpened("phone_sim_action") then
                    if not mobileData.simActive.primary.active and item == "sim" and WarMenu.Button("Dát primární sim") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "primary", "insert")
                        WarMenu.CloseMenu()
                    elseif mobileData.simActive.primary.active and item == "sim" and WarMenu.Button("Vyměnit primární sim") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "primary", "change")
                        WarMenu.CloseMenu()
                    elseif mobileData.simActive.primary.active and item == "phone" and WarMenu.Button("Vytahnout primární sim") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "primary", "pull")
                        WarMenu.CloseMenu()
                    elseif mobileData.simActive.primary.active and mobileData.simActive.secondary.active and item == "phone" and WarMenu.Button("Prohodit sim") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "switch")
                        WarMenu.CloseMenu()
                    elseif mobileData.dualSim and not mobileData.simActive.secondary.active and item == "sim" and WarMenu.Button("Dát dual sim do mobilu") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "secondary", "insert")
                        WarMenu.CloseMenu()
                    elseif mobileData.dualSim and mobileData.simActive.secondary.active and item == "sim" and WarMenu.Button("Vyměnit dual sim do mobilu") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "secondary", "change")
                        WarMenu.CloseMenu()
                    elseif mobileData.dualSim and mobileData.simActive.secondary.active and item == "phone" and WarMenu.Button("Vytahnout dual sim do mobilu") then
                        TriggerServerEvent("qb-phone:server:UpdateSim", mobileData, data, "secondary", "pull")
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                else
                    break
                end
                Citizen.Wait(1)
            end
        end)
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Zavři ten mobil! 👿", icon = "fas fa-times", length = 5000})
    end
end