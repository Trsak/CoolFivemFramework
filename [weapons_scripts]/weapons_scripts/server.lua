--Investigate
local investigate = {
    shell = {},
    blood = {}
}
RegisterNetEvent('weapons_scripts:server:shot')
AddEventHandler('weapons_scripts:server:shot', function(coords, weapon, clothes)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local shell = Config.Shell[weapon.ammoType]
    --local newObj = CreateObject(GetHashKey(shell), coords.x, coords.y, coords.z + 0.2, true, true, false)
    --SetEntityRotation(newObj, -90.0, 0.0, 0.0, 2, false)
    --FreezeEntityPosition(newObj, true)
    table.insert(investigate.shell,{ pos = coords, type = shell, obj = newObj,  charid = Player, data = weapon })
    gsr_test(coords, weapon, Player, clothes)
end)

RegisterNetEvent('weapons_scripts:server:getshot')
AddEventHandler('weapons_scripts:server:getshot', function(coords, weapon)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local newObj = CreateObject(GetHashKey(Config.BloodObject), coords.x, coords.y, coords.z, true, true, false)
    SetEntityRotation(newObj, -90.0, 0.0, 0.0, 2, false)
    FreezeEntityPosition(newObj, true)
    table.insert(investigate.blood,{ pos = coords, type = Config.BloodObject, obj = newObj, charid = Player, data = weapon })
end)

--Gsr
local GSR = {}
function getKey(charid)
    local key = false
    for k, v in each(GSR) do
        if v.charid == charid then
            key = k
            break
        end
    end
    return key
end

function gsr_test(coords, weapon, Player, clothes)
    local key = getKey(Player)
    if key then
        if GSR[key].clothes ~= nil then
            for i=1, #GSR[key].clothes do
                if GSR[key].clothes[i].number ~= clothes[i].number then
                    GSR[key].clothes[i] = clothes[i]
                end
                GSR[key].clothes[i].powder = GSR[key].clothes[i].powder + 1
            end
        end
    else
        for i=1, #clothes do
            clothes[i].powder = clothes[i].powder + 1
        end
        local data = {
            coords = coords,
            weapon = weapon,
            charid = Player,
            clothes = clothes
        }
        table.insert(GSR, data)
    end
    --TriggerClientEvent('weapons_scripts:client:GSR', -1)
end

RegisterNetEvent('weapons_scripts:server:GSR')
AddEventHandler('weapons_scripts:server:GSR', function(data)
    local src = source
    local Player = exports.data:getCharVar(data.player, 'id')
    local found = false
    if Player then
        local key = getKey(Player)
        if key then
            Utils.DumpTable(GSR[key])
            Utils.DumpTable(data)
            if GSR[key].clothes[data.selected].number == data.clothes[data.selected].number then
                if GSR[key].clothes[data.selected].texture == data.clothes[data.selected].texture then
                    if GSR[key].clothes[data.selected].powder ~= 0 then
                        found = GSR[key].clothes[data.selected].powder
                    end
                else
                    GSR[key].clothes[data.selected].texture = data.clothes[data.selected].texture
                    GSR[key].clothes[data.selected].powder = 0
                end
            else
                GSR[key].clothes[data.selected] = data.clothes[data.selected]
                if GSR[key].clothes[data.selected].powder ~= 0 then
                    found = data.clothes[data.selected].powder
                end
            end
            if found then
                TriggerClientEvent('notify:display', src, {type = "success", title = "GSR Test Kit", text = string.format("Byly nalezeny stopy střelného prachu na %s", data.clothes[data.selected].name), icon = "fas fa-times", length = 5000})
            else
                TriggerClientEvent('notify:display', src, {type = "error", title = "GSR Test Kit", text = string.format("Nebyly nalezeny žádne stopy střelného prachu na %s", data.clothes[data.selected].name), icon = "fas fa-times", length = 5000})
            end
        else
            TriggerClientEvent('notify:display', src, {type = "success", title = "GSR Test Kit", text = string.format("Nebyly nalezeny žádne stopy střelného prachu na %s", data.clothes[data.selected].name), icon = "fas fa-times", length = 5000})
        end
    end
end)

RegisterNetEvent('weapons_scripts:server:clean')
AddEventHandler('weapons_scripts:server:clean', function(data)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local key = getKey(Player)
    if data.type == "water" then
        if key and GSR[key].clothes[1].powder ~= 0 then
            GSR[key].clothes = data.clothes
            TriggerClientEvent('notify:display', src, {type = "success", title = "Umytí", text = string.format("Umyl ses celej"), icon = "fas fa-shower", length = 5000})
        else
            TriggerClientEvent('notify:display', src, {type = "error", title = "Umytí", text = string.format("Jsi umytý"), icon = "fas fa-shower", length = 5000})
        end
    else
        if key and GSR[key].clothes[data.selected].powder ~= 0 then
            if data.clothes[data.selected].number == GSR[key].clothes[data.selected].number then
                GSR[key].clothes[data.selected].powder = 0
                TriggerClientEvent('notify:display', src, {type = "success", title = "Umytí", text = string.format("Umyl sis %s", GSR[key].clothes[data.selected].name), icon = "fas fa-shower", length = 5000})
            else
                --GSR[key].clothes[data.selected] = data.clothes[data.selected]
            end
        else
            TriggerClientEvent('notify:display', src, {type = "error", title = "Umytí", text = string.format("Nepotřebuješ se umýt."), icon = "fas fa-shower", length = 5000})
        end
    end
end)

function hasWeaponFireMods(weapon)
    local weaponHash = type(weapon) == "number" and weapon or GetHashKey(weapon)
    if Config.WeaponData[weaponHash] then
        return Config.WeaponData[weaponHash].fireMode
    elseif Config.WeaponData[weaponHash % 0x100000000] then
        return Config.WeaponData[weaponHash % 0x100000000].fireMode
    end
    return "disabled"
end