local isSpawned, isDead, jobs = false, false, {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(playerJobs)
        loadJobs(playerJobs)
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, jobs = false, false, {}
        elseif status == "spawned" or status == "dead" then
            if not isSpawned then
                loadJobs()
            end

            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

function loadJobs(playerJobs)
    local playerGroupRelationship = nil

    jobs = {}
    for _, data in pairs(playerJobs and playerJobs or exports.data:getCharVar("jobs")) do
        local jobTypeRelationGroup = Config.JobTypeRelationGroup[data.job]

        if jobTypeRelationGroup == nil then
            local jobType = exports.base_jobs:getJobVar(data.job, "type")
            jobTypeRelationGroup = Config.JobTypeRelationGroup[jobType]
        end

        if jobTypeRelationGroup then
            playerGroupRelationship = {
                job = data.job,
                group = jobTypeRelationGroup
            }
            break
        end
    end

    if playerGroupRelationship ~= nil then
        if DoesRelationshipGroupExist(GetHashKey(playerGroupRelationship.job)) then
            SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey(playerGroupRelationship.job))
        else
            createRelationshipGroup(playerGroupRelationship)
            SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey(playerGroupRelationship.job))
        end
    else
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER"))
    end
end

function createRelationshipGroup(relationshipGroup)
    local groupHashKey = GetHashKey(relationshipGroup.job)
    AddRelationshipGroup(relationshipGroup.job, groupHashKey)

    for _, group in each(Config.DefaultRelationshipGroups) do
        local relationship = GetRelationshipBetweenGroups(group, GetHashKey(relationshipGroup.group))
        SetRelationshipBetweenGroups(relationship, group, groupHashKey)
        SetRelationshipBetweenGroups(relationship, groupHashKey, group)
    end

    local playerHashKey = GetHashKey("PLAYER")
    SetRelationshipBetweenGroups(1, playerHashKey, groupHashKey)
    SetRelationshipBetweenGroups(1, groupHashKey, playerHashKey)
end

RegisterCommand("printallrelationships", function()
    for _, group in each(Config.DefaultRelationshipGroups) do
        print(group, GetHashKey(group))
    end
end
)
