local isDead = false
local isNearShop = false
local isDisplayingHint = true
local closestShop = {
    coords = vec3(0, 0, 0),
    distance = 500000
}
local showBlips = true
local blips = {}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            showBlips = exports.settings:getSettingValue("tatoosBlips")
            isDead = (status == "dead")
            if showBlips then
                createBlips()
            end
        end

        

        while true do
            Citizen.Wait(1000)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            for i, tatooShop in each(Config.tattoosShops) do
                local distance = #(tatooShop - coords)
                if distance <= 4.0 then
                    isNearShop = true
                    break
                end

                if distance < closestShop.distance then
                    closestShop = {
                        coords = tatooShop,
                        distance = distance
                    }
                end

                if i == #Config.tattoosShops then
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
                            components = false,
                            props = false,
                            tattoos = true,
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
                    exports.key_hints:displayBottomHint({ name = "tattoos_open", key = "~INPUT_PICKUP~", text = "Zakoupit tetování" })
                end
            elseif isDisplayingHint and not isNearShop then
                isDisplayingHint = false
                exports.key_hints:hideBottomHint({ name = "tattoos_open" })
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

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "tatoosBlips" then
            showBlips = value
            if not showBlips then
                for i, blip in each(blips) do
                    RemoveBlip(blip)
                end
                blips = {}
            else
                createBlips()
            end
        end
    end
)

function createBlips()
    for _, coords in each(Config.tattoosShops) do
        local blip = createNewBlip(
            {
                coords = coords,
                sprite = 75,
                display = 4,
                scale = 0.8,
                colour = 4,
                isShortRange = true,
                text = "Tetovací salón"
            }
        )
        table.insert(blips, blip)
    end
end