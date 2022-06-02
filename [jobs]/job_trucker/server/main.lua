local contracts = {}
local userContracts = {}

local isMenuLocked = {}

Citizen.CreateThread(
    function()
        reloadContracts()
    end
)

function reloadContracts()
    contracts = {}

    for key, depo in pairs(Config.Central) do
        isMenuLocked[key] = false
        contracts[key] = {}

        for ckey, contract in pairs(Config.Contracts) do
            contracts[key][ckey] = {
                Taken = false,
                OnReturn = false,
                CurrentTruck = nil,
                CurrentTrailer = nil,
                BlockedFor = contract.BlockedFor or nil,
                Wage = contract.Wage
            }
        end
    end

    print("[JOB_TRUCKER]", "CONTRACTS RELOADED")
end

RegisterNetEvent("job_trucker:open")
AddEventHandler(
        "job_trucker:open",
        function(depoId)
            local _source = source
            if contracts ~= nil then
                if isMenuLocked[depoId] then
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "error",
                            title = "Kamióny",
                            text = "Právě si někdo zakázku vybírá, vydrž dokud neodejde nebo 30 sekund",
                            icon = "fas fa-truck",
                            length = 4000
                        }
                    )
                    return
                end

                isMenuLocked[depoId] = _source
                TriggerClientEvent("job_trucker:open", _source, depoId, getAvailableContractsToList(depoId))

                Citizen.Wait(30000)
                if isMenuLocked[depoId] == _source then
                    isMenuLocked[depoId] = false
                end
            end
        end
)

function getAvailableContractsToList(depoId)
    local _temp = {}
    for key, contract in pairs(contracts[depoId]) do
        if not contract.Taken and (not contract.BlockedFor or contract.BlockedFor and not contract.BlockedFor[depoId]) then
            _temp[key] = Config.Contracts[key].LocationLabel
        end
    end

    return _temp
end

RegisterNetEvent("job_trucker:close")
AddEventHandler(
    "job_trucker:close",
    function(depoId)
        local _source = source
        if _source == isMenuLocked[depoId] then
            isMenuLocked[depoId] = false
        end
    end
)

RegisterNetEvent("job_trucker:takeContract")
AddEventHandler(
    "job_trucker:takeContract",
    function(depoId, contractId)
        local _source = source
        local done = takeContract(_source, depoId, contractId)
        if done == "alreadyHasContract" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Kamióny",
                    text = "Už jednu zakázku vezeš.",
                    icon = "fas fa-truck",
                    length = 3000
                }
            )
        elseif done ~= "done" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Kamióny",
                    text = "Tuto zakázku nemůžeš vzít, protože ji jede někdo jiný.",
                    icon = "fas fa-truck",
                    length = 3000
                }
            )
        end

    end
)
function takeContract(source, depoId, contractId)
    if userContracts[source] ~= nil then
        return "alreadyHasContract"
    end

    if contracts[depoId][contractId].Taken then
        return "contractAlreadyTaken"
    end

    TriggerClientEvent("job_trucker:takeContract", source, {
        contractId = contractId,
        depoId = depoId
    })

    contracts[depoId][contractId].Taken = source

    userContracts[source] = {
        contractId = contractId,
        depoId = depoId
    }

    return "done"
end

RegisterNetEvent("job_trucker:startContract")
AddEventHandler("job_trucker:startContract",
    function(contractData)
        local _source = source

        if userContracts[_source] == nil then
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "job_trucker:startContract",
                "Hráč se pokusil spustit event bez oprávnění!"
            )
            return
        end

        contractData.Begin = os.time()

        TriggerClientEvent("job_trucker:startContract", _source, contractData)
    end
)
RegisterNetEvent("job_trucker:updateEntities")
AddEventHandler("job_trucker:updateEntities",
    function(contractId, depoId, truckNetId, trailerNetId)
        local client = source
        if contracts[depoId][contractId].Taken ~= client then

            return
        end

        contracts[depoId][contractId].CurrentTruckId = truckNetId
        contracts[depoId][contractId].CurrentTrailerId = trailerNetId

        contracts[depoId][contractId].CurrentTruck = NetworkGetEntityFromNetworkId(truckNetId)
        contracts[depoId][contractId].CurrentTrailer = NetworkGetEntityFromNetworkId(trailerNetId)
    end
)

RegisterNetEvent("job_trucker:clearContract")
AddEventHandler("job_trucker:clearContract",
    function()
        local client = source
        if userContracts[client] then
            contracts[userContracts[client].depoId][userContracts[client].contractId].Taken = nil

            userContracts[source] = nil
        end
    end
)


RegisterNetEvent("job_trucker:finishContract")
AddEventHandler(
    "job_trucker:finishContract",
    function(depoId, contractId, payWage, cancel)
        local _source = source
        if finishContract(_source, depoId, contractId, payWage, cancel) ~= "done" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Kamióny",
                    text = "Tuto zakázku nemůžeš vrátit, protože ji jede někdo jiný.",
                    icon = "fas fa-truck",
                    length = 3000
                }
            )
        end
    end
)
function finishContract(source, depoId, contractId, payWage, cancel)
    if contracts[depoId][contractId].Taken and userContracts[source] ~= nil and userContracts[source].contractId == contractId then

        contracts[depoId][contractId].Taken = false
        userContracts[source] = nil

        if GetPlayerName(source) then
            local totalPay = 0
            if payWage and not cancel then
                totalPay = contracts[depoId][contractId].Wage[depoId]
                if totalPay == nil then
                    totalPay = Config.baseReward
                    print("[JOB_TRUCKER] MISSING REWARD. ", depoId, contractId)
                end

                local isOverLimit = exports.daily_limits:checkIfIsOverLimit(source, "truck")
                if isOverLimit then
                    TriggerClientEvent(
                        "notify:display",
                        source,
                        {
                            type = "warning",
                            title = "Kamióny",
                            text = "Dnes jsi již vydělal přes limit, další dnešní zakázky budou hůře placené!",
                            icon = "fas fa-truck",
                            length = 5000
                        }
                    )

                    totalPay = totalPay / 6
                end

                totalPay = math.ceil(totalPay)

                exports.daily_limits:addLimitCount(source, "truck", totalPay)
                exports.inventory:addPlayerItem(source, "cash", totalPay, {})
            end
            TriggerClientEvent("job_trucker:finishContract", source, contractId, totalPay, cancel)
        end

        return "done"
    end
    return "contractNotTaken"
end

AddEventHandler(
    "playerDropped",
    function()
        local _source = source

        if userContracts[_source] ~= nil then
            local currentContract = contracts[userContracts[_source].depoId][userContracts[_source].contractId]
            if DoesEntityExist(currentContract.CurrentTruck) then
                DeleteEntity(currentContract.CurrentTruck)
            end

            if DoesEntityExist(currentContract.CurrentTrailer) then
                DeleteEntity(currentContract.CurrentTrailer)
            end

            contracts[userContracts[_source].depoId][userContracts[_source].contractId].Taken = false
            userContracts[_source] = nil
        end
    end
)

-- ADMIN CMDS

RegisterCommand("job_trucker_reload",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") < 3 then
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo" }
                }
            )
            return "noPermission"
        end

        reloadContracts()

        TriggerClientEvent(
            "notify:display",
            _source,
            {
                type = "success",
                title = "Kamióny",
                text = "Contracts reloaded.",
                icon = "fas fa-truck",
                length = 4000
            }
        )
    end
)

RegisterCommand("job_trucker_finishcontract",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") < 2 then
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo" }
                }
            )
            return "noPermission"
        end

        if args[1] == nil then
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Musíš zadat ID hráče!" }
                }
            )
            return "invalidFormat"
        end

        local playerId = tonumber(args[1])
        if not GetPlayerName(playerId) then
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Hráč není připojen" }
                }
            )
            return "playerNotConnected"
        end

        if not userContracts[playerId] then
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Hráč žádnou zakázku pro truckers nedělá" }
                }
            )
            return "playerNotInJob"
        end

        local done = finishContract(playerId, userContracts[playerId].depoId, userContracts[playerId].contractId, (args[2] ~= nil and args[2] == "pay"))

        if done == "done" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "success",
                    title = "Kamióny",
                    text = "Odebral jste hráči " .. GetPlayerName(playerId) .. " zakázku.",
                    icon = "fas fa-truck",
                    length = 4000
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Kamióny",
                    text = "Chyba při odebírání zakázky: " .. done,
                    icon = "fas fa-truck",
                    length = 4000
                }
            )
        end
    end
)