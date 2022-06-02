local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local prefIT, prefIL, prefCP, prefM, prefOT = Config.Type, Config.List, Config.CheckPoints, Config.Menu, Config.OtherTexts
local jobTaken, WorkComplete, MarkerName1, open = false, false, nil, false
local work = {}
local currentWork = {}

RNE(GetHandlerName('SendData'))
AEH(GetHandlerName('SendData'),function(result)
    if result ~= nil then
        if result['Fetched'] then
            print('EEEJ!')
            work = result
            if open then
                SNM({ action = "open", data = work[MarkerName1], JobTypes = prefM[MarkerName1].JobTypes, company = MarkerName1, can = jobTaken, steam = getSteam() })
            end
        end
    else
        Citizen.Wait(1000)
        TSE(GetHandlerName('FetchData'))
    end
end)

RNE(GetHandlerName('OpenMenu'))
AEH(GetHandlerName('OpenMenu'), function(MarkerName)
    MarkerName1 = MarkerName
    if work['Fetched'] then
        SetNuiFocus(true, true)
        if not WorkComplete then
            SNM({ action = "open", data = work[MarkerName], JobTypes = prefM[MarkerName].JobTypes, company = MarkerName, can = jobTaken, steam = getSteam() })
            open = true
        else
            SNM({ action = "open2", data = work[MarkerName], JobTypes = prefM[MarkerName].JobTypes, company = MarkerName, can = jobTaken, steam = getSteam() })
            open = true
        end
        TE(GetHandlerName('draw'), 'ne', true)
    else
        TSE(GetHandlerName('FetchData'))
        exports.tchaj_notify:Notify('error', (prefOT['nUpdateW']):format(prefM[MarkerName].Job))
    end
end)

RNE(GetHandlerName('setWork'))
AEH(GetHandlerName('setWork'), function(status, tt)
    if status then
        jobTaken = true
        uuid = math.floor(currentWork.uuid - 1)
        SNM({ action = "success", data = work[currentWork.company], currentWork = { key = currentWork.key, uuid = uuid }, company = currentWork.company, can = jobTaken, steam = getSteam() })
        TE(GetHandlerName('work'), currentWork)
        exports.tchaj_notify:Notify('Success', (prefOT['nJobTake']):format(prefM[currentWork.company].Job))
    else
        if tt then
            exports.tchaj_notify:Notify('error', (prefOT['nAlreadyInJob']):format(prefM[currentWork.company].Job))
        else
            exports.tchaj_notify:Notify('error', (prefOT['nJobtaken']):format(prefM[currentWork.company].Job))
        end
    end
end)

RNC('close', function()
    SetNuiFocus(false, false)
    SNM({ action = "close" })
    TE(GetHandlerName('draw'), 'do', false)
    open = false
end)

RNC('submit', function(data)
    if data.alreadyInWork == false then
        data.uuid = math.floor(data.uuid + 1)
        data.cost = tonumber(data.cost)
        data.workR = tonumber(data.workR)
        currentWork = data
        work[data.company][data.key][data.uuid]['Steam'] = getSteam()
        TSE(GetHandlerName('updateWorks'), data, 'taken')
    else
        exports.tchaj_notify:Notify('error', (prefOT['nAlreadyInJob']):format())
    end
end)

RNC('payout', function(data)
    if data.payout == nil then
        data.uuid = math.floor(data.uuid + 1)
        data.cost = tonumber(data.cost)
        data.workR = tonumber(data.workR)
        SNM({ action = "payout", data = work[currentWork.company], currentWork = { key = currentWork.key, uuid = uuid, cost = currentWork.cost }, company = currentWork.company, can = jobTaken, steam = getSteam() })
        TE(GetHandlerName('drawT'), false)
    else
        if jobTaken then
            data.payout = math.floor(tonumber(data.payout))
            data.companyTake = math.floor(tonumber(data.companyTake))
            TE(GetHandlerName('drawT'), false)
            work[currentWork.company][currentWork.key][currentWork.uuid]['WorkDone'] = true
            work[currentWork.company][currentWork.key][currentWork.uuid]['Payout'] = data.payout
            work[currentWork.company][currentWork.key][currentWork.uuid]['companyTake'] = data.companyTake
            TSE(GetHandlerName('payOut'), data, getSteam())
            jobTaken = false
            fuha()
            currentWork = {}
            SNM({ action = "open2", data = work[MarkerName1], JobTypes = prefM[MarkerName1].JobTypes, company = MarkerName1, can = jobTaken, steam = getSteam() })
            exports.tchaj_notify:Notify('success', (prefOT['nAlreadyInJob']):format(data.payout))
        else
            exports.tchaj_notify:Notify('msg', (prefOT['nCheater']))
        end
    end
end)

function getItems()
    return work[currentWork.company][currentWork.key][currentWork.uuid]['ItemList']
end

function getWPs()
    return prefCP[currentWork.key][currentWork.workR]
end

function workComplete(distance)
    startFuel, endFuel = GetFuel()
    work[currentWork.company][currentWork.key][currentWork.uuid]['Distance'] = math.floor(distance * 2)
    work[currentWork.company][currentWork.key][currentWork.uuid]['WorkRDone'] = true
    work[currentWork.company][currentWork.key][currentWork.uuid]['startFuel'] = startFuel
    work[currentWork.company][currentWork.key][currentWork.uuid]['endFuel'] = endFuel
    TSE(GetHandlerName('updateWorks'), currentWork, 'WorkRDone', { distance = math.floor(distance * 2), startFuel = startFuel, endFuel = endFuel})
    tst2()
    Citizen.Wait(50)
    SetNewWaypoint(prefCP[currentWork.key][currentWork.workR]['GetPoint'].x, prefCP[currentWork.key][currentWork.workR]['GetPoint'].y)
    TE(GetHandlerName('drawT'), true, prefOT['routeBack'])
end

RegisterCommand('endWork', function(source, args)
    if jobTaken then
        TSE(GetHandlerName('deleteWork'))
        tst2()
        TSE(GetHandlerName('updateWorks'), currentWork, 'End')
        currentWork = {}
        jobTaken = false
        fuha()
    end
    exports.tchaj_notify:Notify('msg', (prefOT['nCancelJob']))
    TE(GetHandlerName('chckdistance'), false, nil)
end, false)