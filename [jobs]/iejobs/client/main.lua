local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local EnterMarker, MarkerName, IsInMarker, FetchedData, JobName, isBoss, isInMenu, Steam = false, nil, false, false, nil, nil, false, nil
local prefIT, prefIL, prefCP, prefM = Config.Type, Config.List, Config.CheckPoints, Config.Menu

function isPlayerEligible()
    if JobName ~= nil then
        if MarkerName ~= nil then
            if JobName == prefM[MarkerName].Job then
                return true
            end
        else
            for k, v in each(prefM) do
                if JobName == prefM[k].Job then
                    return true
                end
            end
        end
    else
        for _, v in each(exports.data:getCharVar("jobs")) do
            if v['duty'] then
                JobName = v.job
                isBoss = exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss"
                break
            end
        end
    end
    return true
end

RNE("s:statusUpdated")
AEH("s:statusUpdated",
        function(status)
            if status == "choosing" then
                isSpawned = false
            elseif status == "spawned" or status == "dead" then
                isSpawned = true
                isDead = (status == "dead")
                if JobName == nil then
                    for _, v in each(exports.data:getCharVar("jobs")) do
                        if v['duty'] then
                            JobName = v.job
                            isBoss = exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss"
                            break
                        end
                    end
                end
            end
        end
)

RNE("s:jobUpdated")
AEH("s:jobUpdated",
        function(job)
            for _, v in each(job) do
                if v['duty'] then
                    JobName = v.job
                    isBoss = exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss"
                    break
                end
            end
        end
)

RNE(GetHandlerName('updateTime'))
AEH(GetHandlerName('updateTime'), function()
    if isPlayerEligible() then
        TSE(GetHandlerName('FetchData'))
    end
end)

TSE(GetHandlerName('GetSteam'))
RNE(GetHandlerName('GetSteam'))
AEH(GetHandlerName('GetSteam'), function(steam)
    Steam = steam
    SetNuiFocus(false, false)
end)

function getSteam()
    return Steam
end

AEH(GetHandlerName('draw'), function(status, menuOpen)
    if status == 'do' then
        status = true
    else
        status = false
    end
    isInMenu = menuOpen
    while status do
        Citizen.Wait(1)
        if MarkerName ~= nil and not isInMenu then
            Utils.DrawText3D(prefM[MarkerName]['Coords'].x, prefM[MarkerName]['Coords'].y, prefM[MarkerName]['Coords'].z, prefM[MarkerName].Text)
            if Utils.GetKeyPressed('E') then
                if getSteam() == nil then
                    TSE(GetHandlerName('GetSteam'))
                end
                if isPlayerEligible() then
                    TE(GetHandlerName('OpenMenu'), MarkerName)
                else
                    exports.tchaj_notify:Notify('error', ('Nejsi zaměstnancem %s'):format(prefM[MarkerName].Job))
                end
            end
        else
            break
        end
    end
end)


CCT(function()
        -- Utils Load
        CCT(function()
            while not FetchedData do
            Citizen.Wait(500)
                if isPlayerEligible() then
                    TSE(GetHandlerName('FetchData'))
                    FetchedData = true
                end
            end
        end)
        -- Menu Location Handler
        CCT(function()
            while true do
                Citizen.Wait(300)
                local coords = Utils.GetCoords()
                if not isInMenu then
                    for k, v in pairs(prefM) do
                        local chckDistance = GetDistanceBetweenCoords(coords, prefM[k]['Coords'].x, prefM[k]['Coords'].y, prefM[k]['Coords'].z, true)

                        if (chckDistance < prefM[k]['Coords'].Size) then
                            IsInMarker = true

                            if (IsInMarker and not EnterMarker) or MarkerName == nil then
                                EnterMarker	= true
                                MarkerName = k
                                TE(GetHandlerName('draw'), 'do', false)
                            end
                        else
                            if MarkerName == k then
                                IsInMarker = false
                            end
                        end
                    end

                    if not IsInMarker and MarkerName then
                        EnterMarker = false
                        MarkerName = nil
                        TE(GetHandlerName('draw'), 'ne', false)
                    end
                end
            end
        end)
    ----------------------------
end)