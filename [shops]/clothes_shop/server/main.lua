local clothesData = {}

RegisterNetEvent("clothes_shop:loadCharClothes")
AddEventHandler(
    "clothes_shop:loadCharClothes",
    function()
        local client = source
        local char = exports.data:getCharVar(client, "id")

        if not clothesData[char] then
            local clothes = MySQL.Sync.fetchAll(
                "SELECT id, name, data FROM clothes WHERE owner = :char",
                {
                    char = char
                }
            )

            clothesData[char] = {}
            if clothes then
                for i, clothe in each(clothes) do
                    local clothData = {}
                    clothData.id = clothe.id
                    clothData.data = json.decode(clothe.data)
                    clothData.name = string.lower(clothe.name)

                    table.insert(clothesData[char], clothData)
                end
            end
        end

        TriggerClientEvent("clothes_shop:loadedCharClothes", client, clothesData[char])
    end
)

RegisterNetEvent("clothes_shop:buyClothes")
AddEventHandler(
    "clothes_shop:buyClothes",
    function(outfit, name)
        local client = source
        if outfit then
            newOutfit(client, outfit, name, "buy")
        end
    end
)

RegisterNetEvent("clothes_shop:newOutfit")
AddEventHandler(
    "clothes_shop:newOutfit",
    function(outfit, name, onExit)
        local client = source
        if outfit then
            newOutfit(client, outfit, name, "save")
        end
    end
)

RegisterNetEvent("clothes_shop:removeClothe")
AddEventHandler(
    "clothes_shop:removeClothe",
    function(index)
        local client = source
        local char = exports.data:getCharVar(client, "id")

        for i, clothe in each(clothesData[char]) do
            if clothe.id == index then
                table.remove(clothesData[char], i)

                MySQL.Async.execute(
                    "DELETE FROM `clothes` WHERE `owner` = :char AND `id` = :id",
                    {
                        char = char,
                        id = index
                    }
                )
                break
            end
        end

        TriggerClientEvent("clothes_shop:loadedCharClothes", client, clothesData[char])
        TriggerClientEvent("clothes_shop:removedClothe", client)
    end
)

RegisterNetEvent("clothes_shop:updateOutfitName")
AddEventHandler(
    "clothes_shop:updateOutfitName",
    function(index, newName)
        local client = source
        local char = exports.data:getCharVar(client, "id")
        local newName = string.lower(newName)

        for i, clothe in each(clothesData[char]) do
            if clothe.id == index then
                clothesData[char][i].name = newName

                MySQL.Async.execute(
                    "UPDATE `clothes` SET `name` = :name WHERE `owner` = :char AND `id` = :id",
                    {
                        char = char,
                        id = index,
                        name = newName
                    }
                )
                break
            end
        end

        TriggerClientEvent("clothes_shop:loadedCharClothes", client, clothesData[char])
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "success",
                title = "Úspěch",
                text = "Outfit přejmenován!",
                icon = "fas fa-tshirt",
                length = 3000
            }
        )
    end
)

function newOutfit(client, outfit, name, newType)
    local clothData = {}
    clothData.data = outfit
    clothData.name = string.lower(name)

    local char = exports.data:getCharVar(client, "id")
    MySQL.Async.insert(
        "INSERT INTO `clothes` (`owner`, `name`, `data`) VALUES (:char, :name, :outfit)",
        {
            char = char,
            name = clothData.name,
            outfit = json.encode(outfit)
        },
        function(newrow)
            clothData.id = newrow
            table.insert(clothesData[char], clothData)
            TriggerClientEvent("clothes_shop:loadedCharClothes", client, clothesData[char])
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Úspěch",
                    text = newType == "save" and "Oblečení bylo uloženo!" or "Oblečení bylo zakoupeno!",
                    icon = "fas fa-tshirt",
                    length = 3000
                }
            )
        end
    )
end
