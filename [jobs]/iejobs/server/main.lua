local TE, TCE,TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent,TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local prefIT, prefIL, prefCP, prefM, prefMJ, prefMnJ, prefRT = Config.Type, Config.List, Config.CheckPoints, Config.Menu, Config.MaxJobs, Config.MinJobs, Config.RefreshTime
local load, update, updateTimeLeft, started = nil, nil, false, 0, false
local steamIdentifier
local work, workInProgress, Works = {}, {}, {}

CCT(function()  while true do awake() Citizen.Wait(1) if started then break end end end)

CCT(function()  while true do Citizen.Wait(Config.MinuteInMsec) if updateTimeLeft == prefRT then awake() end if load and updateTimeLeft ~= prefRT  then updateTimeLeft = updateTimeLeft + 1  end end end)


MySQL.ready(function()
    --aaaaairjobs = MySQL.Sync.fetchAll('SELECT * FROM airjobs')
end)

RNE('playerDropped')
AEH('playerDropped', function()
    delete(source)
end)

RNE('deleteWork')
AEH('deleteWork', function()
    delete(source)
end)

function delete(source)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local indentifier = nil
    for _, v in each(identifiers) do
        if string.find(v, "steam") then
            if workInProgress[v] then
                indentifier = v
                workInProgress[v] = nil
                break
            end
        end
    end
    if indentifier then
        for k, v in each(Works) do
            if indentifier == v then
                table.remove(Works, k)
                print(#Works)
            end
        end
    end
end

TE('esx:getSharedObject', function(obj)
    ESX = obj
end)

RSE(GetHandlerName('GetSteam'))
AEH(GetHandlerName('GetSteam'), function()
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    for _, v in each(identifiers) do
        if string.find(v, "steam") then
            steamIdentifier = v
            break
        end
    end
    TCE(GetHandlerName('GetSteam'), player, steamIdentifier)
end)

RSE(GetHandlerName('FetchData'))
AEH(GetHandlerName('FetchData'), function()
    local _source = source
    CCT(function() while work['Fetched'] == nil do Citizen.Wait(0) end end)

    if work['Fetched'] == true then
        --print('AirJobs:Work '.. ' '.. _source .. ' ' .. 'Data send')
        if started then
            updateTimeLeft = 0
        end
        TCE(GetHandlerName('SendData'), _source, work)
        started = true
        --print(Utils.DumpTable(work))
    else
        if work['Fetched'] ~= nil then
            --print('AirJobs - Work:'..work['Fetched'])
        else
            --print('AirJobs: Work Not Created')
        end
    end
end)

RSE(GetHandlerName('checkItems'))
AEH(GetHandlerName('checkItems'), function(items)
local _source = source
local success = 0
local total_count = 0
    for k, v in ieach(items) do
        if exports.inventory:checkPlayerItem(_source, v[1], v[3]) then
            success = success + 1
            total_count = total_count + v[3]
        end
    end
    if success == #items then
        for _, v in ieach(items) do
            exports.inventory:removePlayerItem(_source, v[1], v[3])
        end
        TCE(GetHandlerName('packaging'), _source, true, total_count)
    else
        TriggerClientEvent('server_oznameni:client:SendAlert', _source, { type = 'info', text = ('Nemáš dostatek věcí!')})
    end
end)

RSE(GetHandlerName('payOut'))
AEH(GetHandlerName('payOut'), function(data)
    local _source = source
    Payout(_source, data)
end)

function Payout(_source, data)
    local identifier = getSteamIde(_source)
    data.uuid = tonumber(data.uuid)
    if workInProgress[identifier] ~= nil then
        if work[data.company][data.key][data.uuid].WorkDone == false then
--[[            xPlayer.addAccountMoney('bank', data.payout)
            TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
                if society ~= nil then
                    TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
                        account.addMoney(data.companyTake)
                    end)
                end
            end)]]
            work[data.company][data.key][data.uuid].WorkDone = true
            work[data.company][data.key][data.uuid]['Payout'] = data.payout
            work[data.company][data.key][data.uuid]['companyTake'] = data.companyTake
            workInProgress[identifier] = nil
            TCE(GetHandlerName('SendData'), _source, work)
            table.remove(Works, 1)
            --[[MySQL.Sync.execute('INSERT INTO airjobs (steam, data) VALUES (@steam, @data)', {
                ['@steam'] 	= identifier,
                ['@data'] 	= json.encode(work[data.company][data.key][data.uuid])
            }, function (rowsChanged) end)]]
        else
            --print('chyba!')
        end
    else
        --print('chyba!')
    end
end

RSE(GetHandlerName('updateWorks'))
AEH(GetHandlerName('updateWorks'), function(data, type, cData)
    local _source = source
	local identifier = getSteamIde(_source)

    if type == 'taken' then
        if workInProgress[identifier] == nil then
            if work[data.company][data.key][data.uuid].WorkTaken == false then
                work[data.company][data.key][data.uuid].WorkTaken = true
                work[data.company][data.key][data.uuid].Steam = identifier
                workInProgress[identifier] = {data.company, data.key, data.uuid, data.workR }
                table.insert(Works, identifier)
                TCE(GetHandlerName('setWork'), _source, true)
                TCE(GetHandlerName('SendData'), _source, work)
            else
                TCE(GetHandlerName('setWork'), _source, false, false)
            end
        else
            TCE(GetHandlerName('setWork'), _source, false, true)
        end
    end

    if type == 'WorkRDone' then
        if workInProgress[identifier] ~= nil then
            if work[data.company][data.key][data.uuid].WorkRDone == false then
                work[data.company][data.key][data.uuid].WorkRDone = true
                work[data.company][data.key][data.uuid].Distance = cData.distance
                work[data.company][data.key][data.uuid].startFuel = cData.startFuel
                work[data.company][data.key][data.uuid].endFuel = cData.endFuel
                TCE(GetHandlerName('SendData'), _source, work)
            else
                --print('chyba!')
            end
        else
            --print('chyba!')
        end
    end

    if type == 'End' then
        if workInProgress[identifier] ~= nil then
            workInProgress[identifier] = nil
            TCE(GetHandlerName('SendData'), _source, work)
            table.remove(Works, 1)
        end
    end

end)


function getSteamIde(source)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local steamIde
    for _, v in each(identifiers) do
        if string.find(v, "steam") then
            steamIde = v
            break
        end
    end
    return steamIde
end


function awake()
    local prework = {}
    local name = nil
    local Type = nil
    local Jobs = nil
    if load == nil then
        for k, v in each(prefM) do
            name = k
            prework[name] = {}
            for y = 1, #v.JobTypes do
            Jobs = math.random(prefMnJ, prefMJ)
            Type = v.JobTypes[y]
            prework[name][Type] = {}
                for i = 1, Jobs do
                    table.insert(prework[name][Type], built(name, Type))
                    Citizen.Wait(10)
                end
            end
        end

        if prework[name] ~= nil then
            if #prework[name][Type] == (Jobs) then
                load = true
                work = prework
                work['Fetched'] = true
                --print('AirJobs: Work Created')
                --print(Utils.DumpTable(work))
                if update then
                --    print('AirJobs: Updated')
                    while true do
                        Citizen.Wait(10)
                        if #Works == 0 then
                            TCE(GetHandlerName('updateTime'), -1)
                            break
                        end
                    end
                end
            else
                --print('AirJobs: Creating work interupted')
                awake()
            end
        end
    else
        load = nil
        update = true
        awake()
    end
end

function built(name, Types)
    Type = Types
    JT = math.random(1, #prefM[name].Type)
    IT = math.random(1, #prefIT)
    IL = ItemList(JT, IT)
    CP = math.random(1, #prefCP[Types])
    return {
        WorkType = prefM[name].Type[JT],
        ItemType = prefIT[IT],
        WorkTaken = false,
        WorkRDone = false,
        WorkDone = false,
        Steam = nil,
        Distance = 0,
        startFuel = 0,
        endFuel = 0,
        Payout = 0,
        companyTake = 0,
        WorkRoute = CP,
        ItemList = IL
    }
end

function ItemList(JT, IT)
    local ItemList = {}
    max = math.random(1, 4)
    --max = math.random(1, #prefIL[JT][IT])
    for i = 1, max do
        ItemList[i] = prefIL[JT][IT][i]
    end
    return ItemList
end