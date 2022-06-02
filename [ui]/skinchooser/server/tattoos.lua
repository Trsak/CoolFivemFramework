local maleTattoos = {}
local femaleTattoos = {}

RegisterCommand("reloadTattoosList",
    function(source)
        if exports.data:getUserVar(source, "admin") > 1 then
            local newMaleTattoos = {}
            local newFemaleTattoos = {}

            for _, tattooCollection in each(TattooList) do
                if tattooCollection.HashNameMale and tattooCollection.HashNameMale ~= "" then
                    local price = math.floor(tattooCollection.Price / 5)
                    if price == 0 then
                        price = 20
                    end

                    table.insert(newFemaleTattoos, {
                        collection = tattooCollection.Collection,
                        label = tattooCollection.Name,
                        price = price,
                        zone = getActualZoneName(tattooCollection.Zone),
                        sex = 0,
                        name = tattooCollection.HashNameMale
                    })
                end

                if tattooCollection.HashNameFemale and tattooCollection.HashNameFemale ~= "" then
                    local price = math.floor(tattooCollection.Price / 5)
                    if price == 0 then
                        price = 20
                    end

                    table.insert(newFemaleTattoos, {
                        collection = tattooCollection.Collection,
                        label = tattooCollection.Name,
                        price = price,
                        zone = getActualZoneName(tattooCollection.Zone),
                        sex = 1,
                        name = tattooCollection.HashNameFemale
                    })
                end
            end

            TriggerClientEvent("skinchooser:getTattoosLabels", source, newMaleTattoos, newFemaleTattoos)
        end
    end,
    true
)

RegisterNetEvent("skinchooser:setTattoosLabels")
AddEventHandler(
    "skinchooser:setTattoosLabels",
    function(maleTattoosLabeled, femaleTattoosLabeled)
        local _source = source

        if exports.data:getUserVar(_source, "admin") > 1 then
            MySQL.Sync.execute("TRUNCATE tattoos_list")
            Citizen.Wait(200)

            for _, tattooData in each(maleTattoosLabeled) do
                MySQL.Async.insert(
                    'INSERT INTO tattoos_list (`collection`, `name`, `label`, `sex`, `zone`, `price`) VALUES (@collection, @name, @label, @sex, @zone, @price)', tattooData
                )
                Wait(0)
            end

            for _, tattooData in each(femaleTattoosLabeled) do
                MySQL.Async.insert(
                    'INSERT INTO tattoos_list (`collection`, `name`, `label`, `sex`, `zone`, `price`) VALUES (@collection, @name, @label, @sex, @zone, @price)', tattooData
                )
                Wait(0)
            end

            reloadTattoosList()
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "skinchooser:getTattoosLabels",
                "Hráč se pokusil přepsat tetování!"
            )
        end
    end
)

function getActualZoneName(zone)
    if zone == "ZONE_HEAD" then
        return "Hlava"
    elseif zone == "ZONE_LEFT_ARM" then
        return "Levá ruka"
    elseif zone == "ZONE_LEFT_LEG" then
        return "Levá noha"
    elseif zone == "ZONE_RIGHT_ARM" then
        return "Pravá ruka"
    elseif zone == "ZONE_RIGHT_LEG" then
        return "Pravá noha"
    elseif zone == "ZONE_TORSO" then
        return "Trup"
    end
end

MySQL.ready(function()
    reloadTattoosList()
end)

function reloadTattoosList()
    Wait(250)

    MySQL.Async.fetchAll('SELECT * FROM tattoos_list', {}, function(tattoos)
        for _, tattoo in each(tattoos) do
            if tattoo.sex == 0 then
                if maleTattoos[tattoo.zone] == nil then
                    maleTattoos[tattoo.zone] = {}
                end

                table.insert(maleTattoos[tattoo.zone], {
                    collection = tattoo.collection,
                    name = tattoo.name,
                    label = tattoo.label,
                    price = tattoo.price
                })
            else
                if femaleTattoos[tattoo.zone] == nil then
                    femaleTattoos[tattoo.zone] = {}
                end

                table.insert(femaleTattoos[tattoo.zone], {
                    collection = tattoo.collection,
                    name = tattoo.name,
                    label = tattoo.label,
                    price = tattoo.price
                })
            end
        end

        TriggerClientEvent("skinchooser:reloadTattoosList", -1, maleTattoos, femaleTattoos)
    end)
end

RegisterNetEvent("skinchooser:requestReloadTattoosList")
AddEventHandler(
    "skinchooser:requestReloadTattoosList",
    function()
        local _source = source
        TriggerClientEvent("skinchooser:reloadTattoosList", _source, maleTattoos, femaleTattoos)
    end
)