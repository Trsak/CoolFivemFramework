local isSpawned, isDead = nil, false
local currentWeapon = nil
local isCuffed = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")

        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()

            selectedweapon = GetSelectedPedWeapon(GetPlayerPed(-1))
        end
    end
)

RegisterNetEvent("rp:updateCuffed")
AddEventHandler(
    "rp:updateCuffed",
    function(status)
        isCuffed = status
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end
    end
)

RegisterNetEvent("s:jobsUpdated")
AddEventHandler(
    "s:jobsUpdated",
    function(jobsData)
        jobs = jobsData
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if isSpawned and not isDead and not isCuffed and not IsPedInAnyVehicle(PlayerPedId(), false) then
                if selectedweapon ~= GetSelectedPedWeapon(PlayerPedId()) then
                    local selectingweapon = GetSelectedPedWeapon(PlayerPedId())
                    local okay = true
                    if not IsPedInCover(PlayerPedId(), false) or (Config.IgnoreInCover and IsPedInCover(PlayerPedId(), false)) then
                        if selectedweapon ~= selectingweapon then
                            if selectingweapon ~= -1569615261 then -- fist
                                for i, weapon in each(Config.Weapons) do
                                    if GetHashKey(weapon.Name) == selectedweapon then
                                        while (not HasAnimDictLoaded(weapon.AnimDict)) do
                                            RequestAnimDict(weapon.AnimDict)
                                            Citizen.Wait(5)
                                        end

                                        TaskPlayAnim(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 8.0, 8.0, (isPolice() and weapon.QuickCop) and 400 or weapon.AnimDuration, 48, 0.0, false, false, false)
                                        Citizen.Wait(50)
                                        while (IsEntityPlayingAnim(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 3)) do
                                            Wait(200)
                                            SetCurrentPedWeapon(PlayerPedId(), -1569615261, true)
                                            if IsPedFalling(PlayerPedId()) or IsPedShooting(PlayerPedId()) or isDead or IsPedInMeleeCombat(PlayerPedId()) then
                                                okay = false
                                                StopAnimTask(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 1.0)
                                                break
                                            end
                                        end
                                        break
                                    end
                                end

                                if okay then
                                    for i, weapon in each(Config.Weapons) do
                                        if GetHashKey(weapon.Name) == selectingweapon then
                                            while not HasAnimDictLoaded(weapon.AnimDict) do
                                                RequestAnimDict(weapon.AnimDict)
                                                Citizen.Wait(5)
                                            end

                                            TaskPlayAnim(PlayerPedId(), weapon.AnimDict, weapon.sAnim, 8.0, 8.0, (isPolice() and weapon.QuickCop) and 400 or weapon.AnimDuration, 48, 0.0, false, false, false)
                                            Citizen.Wait(50)

                                            while (IsEntityPlayingAnim(PlayerPedId(), weapon.AnimDict, weapon.sAnim, 3)) do
                                                Wait(200)
                                                SetCurrentPedWeapon(PlayerPedId(), selectingweapon, true)
                                                if IsPedFalling(PlayerPedId()) or IsPedShooting(PlayerPedId()) or isDead or IsPedInMeleeCombat(PlayerPedId()) then
                                                    okay = false
                                                    StopAnimTask(PlayerPedId(), weapon.AnimDict, weapon.sAnim, 1.0)
                                                    break
                                                end
                                            end
                                            break
                                        end
                                    end
                                end
                            else
                                for i, weapon in each(Config.Weapons) do
                                    if GetHashKey(weapon.Name) == selectedweapon then
                                        while not HasAnimDictLoaded(weapon.AnimDict) do
                                            RequestAnimDict(weapon.AnimDict)
                                            Citizen.Wait(5)
                                        end

                                        SetCurrentPedWeapon(PlayerPedId(), selectedweapon, true)
                                        TaskPlayAnim(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 8.0, 8.0, (isPolice() and weapon.QuickCop) and 400 or weapon.AnimDuration, 48, 0.0, false, false, false)
                                        Citizen.Wait(50)
                                        while (IsEntityPlayingAnim(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 3)) do
                                            Wait(100)
                                            if IsPedFalling(PlayerPedId()) or IsPedShooting(PlayerPedId()) or isDead or IsPedInMeleeCombat(PlayerPedId()) then
                                                okay = false
                                                StopAnimTask(PlayerPedId(), weapon.AnimDict, weapon.eAnim, 1.0)
                                                break
                                            end
                                        end

                                        break
                                    end
                                end
                            end
                        end
                    end

                    if okay then
                        selectedweapon = selectingweapon
                        SetCurrentPedWeapon(PlayerPedId(), selectedweapon, true)
                    end
                end
            end
        end
    end
)

function isPolice()
    for _, data in pairs(jobs) do
        if Config.CanUse[data.Type] then
            return true
        end
    end
    return false
end
function loadJobs()
    local recievedData = exports.data:getCharVar("jobs")
    jobs = {}
    for _, jobData in pairs(recievedData) do
        jobs[jobData.job] = {
            Name = jobData.job,
            Type = exports.base_jobs:getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
        }
    end
end