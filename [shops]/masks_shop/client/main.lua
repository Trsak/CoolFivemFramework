local isDead = false
local isNearShop = false
local isDisplayingHint = true
local closestShop = {
    coords = vec3(0, 0, 0),
    distance = 500000
}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        if exports.data:getUserVar("status") == "dead" then
            isDead = true
        end

        for _, coords in each(Config.Shops) do
            createNewBlip(
                {
                    coords = coords,
                    sprite = 362,
                    display = 4,
                    scale = 0.8,
                    colour = 4,
                    isShortRange = true,
                    text = "Prodej masek"
                }
            )
        end

        while true do
            Citizen.Wait(1000)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            for i, shop in each(Config.Shops) do
                local distance = #(shop - coords)
                if distance <= 4.0 then
                    isNearShop = true
                    break
                end

                if distance < closestShop.distance then
                    closestShop = {
                        coords = shop,
                        distance = distance
                    }
                end

                if i == #Config.Shops then
                    isNearShop = false
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            if not isDead and isNearShop then
                if IsControlJustReleased(0, 38) then
                    exports.skinchooser:openSkinMenu(
                        {
                            ped = false,
                            headBlend = false,
                            faceFeatures = false,
                            headOverlays = false,
                            components = true,
                            props = false,
                            mask = true,
                            tattoos = false,
                            canLeave = true,
                            vMenuPedsImportAllow = false,
                            isShop = true
                        },
                        {
                            save = true
                        }
                    )
                end

                if not isDisplayingHint then
                    isDisplayingHint = true
                    exports.key_hints:displayBottomHint({ name = "masks_open", key = "~INPUT_PICKUP~", text = "Zakoupit masku" })
                end
            elseif isDisplayingHint and not isNearShop then
                isDisplayingHint = false
                exports.key_hints:hideBottomHint({ name = "masks_open" })
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "dead" then
            isDead = true
        else
            isDead = false
        end
    end
)

