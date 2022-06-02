local isChanging = false
playerSexPre = 0

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")

        if status == "spawned" or status == "dead" then
            loadSavedOutfit()
        end

        while true do
            Wait(2000)
            if isChanging then
                TriggerServerEvent("admin:playerGodModeWhitelist", true)
            end
        end
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName)
        if itemName == "cosmetickit" then
            local includeMask = false

            if getPlayerSex() == -1 then
                includeMask = true
            end

            openSkinMenu(
                {
                    ped = false,
                    headBlend = false,
                    faceFeatures = false,
                    headOverlays = true,
                    components = false,
                    props = false,
                    mask = includeMask,
                    tattoos = false,
                    canLeave = true,
                    vMenuPedsImportAllow = false
                },
                {
                    save = true
                }
            )
        end
    end
)

function getPlayerSex(target)
    local pedModel = exports["fivem-appearance"]:getPedModel(target or PlayerPedId())
    if pedModel == "mp_m_freemode_01" then
        return 0
    elseif pedModel == "mp_f_freemode_01" then
        return 1
    else
        return -1
    end
end


function setPlayerModel(model, save)
    if not model then
        return
    end

    exports["fivem-appearance"]:setPlayerModel(model)

    Wait(100)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100)

    if save then
        TriggerServerEvent("skinchooser:save", exports["fivem-appearance"]:getPedAppearance(PlayerPedId()))
    end
end

function setPlayerOutfit(outfit, save)
    if not outfit or not outfit.components or not outfit.props then
        return
    end

    exports["fivem-appearance"]:setPedComponents(PlayerPedId(), outfit.components)
    exports["fivem-appearance"]:setPedProps(PlayerPedId(), outfit.props)

    if save then
        TriggerServerEvent("skinchooser:save", exports["fivem-appearance"]:getPedAppearance(PlayerPedId()))
    end
end

function getPlayerOutfit(target)
    return {
        components = exports["fivem-appearance"]:getPedComponents(target or PlayerPedId()),
        props = exports["fivem-appearance"]:getPedProps(target or PlayerPedId())
    }
end

function loadSavedOutfit()
    while not exports.data:isCharLoaded() do
        Citizen.Wait(100)
    end

    local playerAppearance = exports.data:getCharVar("outfit")
    local playerTattoos = exports.data:getCharVar("tattoos")
    exports["fivem-appearance"]:setPlayerAppearance(playerAppearance, playerTattoos)
    exports["fivem-appearance"]:setPlayerAppearance(playerAppearance, playerTattoos)
end

function openSkinMenu(config, data)
    inShop = true
    playerSexPre = getPlayerSex()

    isChanging = true
    TriggerServerEvent("admin:playerGodModeWhitelist", true)

    exports["fivem-appearance"]:startPlayerCustomization(
        function(appearance, tattoos, price)
            isChanging = false
            TriggerServerEvent("admin:playerGodModeWhitelist", false)
            inShop = false

            if (appearance) then
                if price and price > 0 then
                    local currentCash = exports.inventory:getCurrentCash()
                    if currentCash < price then
                        loadSavedOutfit()
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
                        TriggerServerEvent("skinchooser:pay", price)
                    end
                end

                if data.callback then
                    data.callback(true, appearance, tattoos, price)
                end

                if data.save then
                    TriggerServerEvent("skinchooser:save", appearance, tattoos)
                end

                return true
            else
                if data.callback then
                    data.callback(false)
                end

                return false
            end

            
        end,
        config
    )
end
