local cops = 0
local isSpawned, isDead, isDuty = false, false, false
local isCop = false
local restartDelay = false

local shops = nil
local robbing = nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()

            if not shops then
                TriggerServerEvent("rob_shops:askForShops")
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, jobs = false, false, {}
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            end
            if not shops then
                TriggerServerEvent("rob_shops:askForShops")
            end

            if isDead and robbing then
                robbing = nil
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterNetEvent("rob_shops:countCops")
AddEventHandler(
    "rob_shops:countCops",
    function(counted)
        cops = counted
    end
)

RegisterNetEvent("rob_shops:syncRobbed")
AddEventHandler(
    "rob_shops:syncRobbed",
    function(robbedShops)
        if shops ~= nil then
            for shop, _ in pairs(shops) do
                local isRobbed = false

                if robbedShops[shop] ~= nil then
                    isRobbed = true
                end

                shops[shop].robbed = isRobbed
            end
        end
    end
)

RegisterNetEvent("rob_shops:updateShops")
AddEventHandler(
    "rob_shops:updateShops",
    function(shopData, robbedShops, rstDelay)
        first = (shops == nil)
        shops = shopData

        if rstDelay ~= nil then restartDelay = rstDelay end 

        if first then
            for shop, _ in pairs(shops) do
                recreateShop(shop)

                if robbedShops[shop] ~= nil then
                    shops[shop].robbed = true
                end

                Citizen.Wait(200)
            end
        end
    end
)

RegisterNetEvent("rob_shops:restartDelaySync")
AddEventHandler("rob_shops:restartDelaySync",  
    function(rstDelay)
        restartDelay = rstDelay
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(15000)
            if isSpawned and not isDead then
                TriggerServerEvent("rob_shops:countCops")
            end
        end
    end
)

RegisterNetEvent("rob_shops:triggerAnim")
AddEventHandler(
    "rob_shops:triggerAnim",
    function(shop, anim)
        if isSpawned and shops then
            if shops[shop].ped then
                if anim == "money" then
                    RequestAnimDict("mp_am_hold_up")
                    while not HasAnimDictLoaded("mp_am_hold_up") do
                        RequestAnimDict("mp_am_hold_up")
                        Citizen.Wait(5)
                    end

                    while not IsEntityPlayingAnim(shops[shop].ped, "mp_am_hold_up", "holdup_victim_20s", 3) do
                        TaskPlayAnim(
                            shops[shop].ped,
                            "mp_am_hold_up",
                            "holdup_victim_20s",
                            8.0,
                            -8.0,
                            -1,
                            2,
                            0,
                            false,
                            false,
                            false
                        )
                        Wait(0)
                    end

                    local time = GetGameTimer()
                    while time + 20000 >= GetGameTimer() do
                        Wait(0)
                    end
                    TriggerServerEvent("rob_shops:triggerAnim", shop, "hidden")
                else
                    RequestAnimDict(Config.Anims[anim].dict)
                    while (not HasAnimDictLoaded(Config.Anims[anim].dict)) do
                        RequestAnimDict(Config.Anims[anim].dict)
                        Citizen.Wait(5)
                    end

                    TaskPlayAnim(
                        shops[shop].ped,
                        Config.Anims[anim].dict,
                        Config.Anims[anim].name,
                        8.0,
                        8.0,
                        60000,
                        1,
                        0.0,
                        false,
                        false,
                        false
                    )
                end
            end
        end
    end
)

RegisterNetEvent("rob_shops:cashierDeath")
AddEventHandler(
    "rob_shops:cashierDeath",
    function(shop, ped)
        if isSpawned and shops then
            shops[shop].robber = 0
            if shops[shop].ped then
                DeletePed(shops[shop].ped)
            else
                DeletePed(NetworkGetEntityFromNetworkId(ped))
            end
            if robbing == shop then
                robbing = nil
            end
        end
    end
)

RegisterNetEvent("rob_shops:robbed")
AddEventHandler(
    "rob_shops:robbed",
    function(shop, result)
        if isSpawned and shops then
            shops[shop].robbed = true
            shops[shop].robber = 0
            if robbing == shop then
                robbing = nil
            end
        end
    end
)

RegisterNetEvent("rob_shops:recreateShop")
AddEventHandler(
    "rob_shops:recreateShop",
    function(shop)
        if isSpawned and shops then
            recreateShop(shop)
        end
    end
)

function recreateShop(shop)
    local shopData = shops[shop]
    if shopData then
        if shopData.ped_coords then
            shopData.robber = 0
            shopData.rob_total = 0
            shopData.rob_percent = 0
            shopData.scared = 0
            if shopData.ped then
                DeletePed(shopData.ped)
            end

            while not HasModelLoaded(shopData.rob_details.ped.model) do
                RequestModel(shopData.rob_details.ped.model)
                Wait(5)
            end

            shopData.ped =
                CreatePed(
                4,
                shopData.rob_details.ped.model,
                shopData.ped_coords.x,
                shopData.ped_coords.y,
                shopData.ped_coords.z,
                false,
                false
            )
            SetEntityHeading(shopData.ped, shopData.ped_coords.w)
            SetEntityAsMissionEntity(shopData.ped, true, true)
            SetPedHearingRange(shopData.ped, 0.0)
            SetPedSeeingRange(shopData.ped, 0.0)
            SetPedAlertness(shopData.ped, 0.0)
            SetPedFleeAttributes(shopData.ped, 0, 0)
            SetBlockingOfNonTemporaryEvents(shopData.ped, true)
            SetPedCombatAttributes(shopData.ped, 46, true)
            SetPedFleeAttributes(shopData.ped, 0, 0)

            Citizen.CreateThread(
                function()
                    while true do
                        Citizen.Wait(1500)
                        if not hasWhitelistedJob() and robbing == nil then
                            if IsPlayerFreeAimingAtEntity(PlayerId(), shopData.ped) and IsPedArmed(PlayerPedId(), 7) then
                                if shopData.robbed then
                                    TriggerEvent(
                                        "chat:addMessage",
                                        {
                                            templateId = "error",
                                            args = {
                                                "Tento obchod byl nedávno již vykradený!"
                                            }
                                        }
                                    )
                                    Citizen.Wait(10000)
                                elseif cops < Config.copsAllowed then
                                    TriggerEvent(
                                        "chat:addMessage",
                                        {
                                            templateId = "error",
                                            args = {
                                                "Pro vykrádání obchodu není na serveru dostatek policistů!"
                                            }
                                        }
                                    )
                                    Citizen.Wait(10000)
                                else
                                    if HasEntityClearLosToEntityInFront(PlayerPedId(), shopData.ped) then
                                        if countCurrentRoberries() < 6 then
                                            if not shopData.robbed and not restartDelay then
                                                robbing = shop
                                                shopData.rob_percent = 2
                                                shopData.robbed = true
                                                shopData.robber = GetPlayerServerId(PlayerId())
                                                shopData.scared = 5
                                                TriggerServerEvent("rob_shops:beginRob", shop)
                                                break
                                            else
                                                TriggerEvent(
                                                    "chat:addMessage",
                                                    {
                                                        templateId = "error",
                                                        args = {
                                                            "Tento obchod byl nedávno již vykradený!"
                                                        }
                                                    }
                                                )
                                                Citizen.Wait(10000)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    Citizen.Wait(500)
                    local aimingAt, tooLow = false, 0
                    Citizen.CreateThread(
                        function()
                            while robbing do
                                Citizen.Wait(1)
                                if IsPedShooting(PlayerPedId()) then
                                    shops[robbing].rob_percent = shops[robbing].rob_percent + 3
                                    shops[robbing].scared = shops[robbing].scared + 2
                                end
                                DrawTimerProgressBar({1}, "STRACH", shopData.rob_percent)
                            end
                        end
                    )

                    if robbing then
                        local isDefending = math.random(0, 20)
                        if isDefending <= Config.defenceChance then
                            GiveWeaponToPed(shopData.ped, GetHashKey("WEAPON_PISTOL"), 1, false, true)
                            TaskShootAtEntity(
                                shopData.ped,
                                PlayerPedId(),
                                10000,
                                GetHashKey("FIRING_PATTERN_FULL_AUTO")
                            )
                            TriggerServerEvent("rob_shops:robbed", shop)
                            robbing = nil
                        else
                            TriggerServerEvent("rob_shops:triggerAnim", shop, "scared")
                        end
                    end

                    while robbing do
                        Citizen.Wait(2000)
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local distance = #(playerCoords - GetEntityCoords(shopData.ped))

                        if distance < 3.5 then
                            if shopData.scared > 0 then
                                shopData.scared = shopData.scared - 1
                                shopData.rob_percent = shopData.rob_percent + 2
                            else
                                shopData.rob_percent = shopData.rob_percent - 1
                            end
                            if IsPlayerFreeAimingAtEntity(PlayerId(), shopData.ped) == 1 then
                                shopData.rob_percent = shopData.rob_percent + 2
                                shopData.scared = shopData.scared + 2
                                aimingAt = true
                            else
                                if aimingAt then
                                    aimingAt = false
                                    shopData.rob_percent = shopData.rob_percent - 1
                                end
                            end

                            if shopData.scared <= 0 then
                                shopData.scared = 0
                            end
                            if shopData.rob_percent < 0 then
                                shopData.rob_percent = 0
                            end

                            if robbing then
                                if shopData.rob_percent <= 0 then
                                    GiveWeaponToPed(shopData.ped, GetHashKey("WEAPON_PISTOL"), 1, false, true)
                                    TaskShootAtEntity(
                                        shopData.ped,
                                        PlayerPedId(),
                                        10000,
                                        GetHashKey("FIRING_PATTERN_FULL_AUTO")
                                    )
                                    TriggerServerEvent("rob_shops:robbed", shop)
                                    robbing = nil
                                elseif shopData.rob_percent >= 100 then
                                    robbing = nil
                                    TriggerServerEvent("rob_shops:robbed", shop, "money")
                                end
                            end
                        end

                        if distance > 6.0 then
                            GiveWeaponToPed(shopData.ped, GetHashKey("WEAPON_PISTOL"), 1, false, true)
                            TaskShootAtEntity(
                                shopData.ped,
                                PlayerPedId(),
                                10000,
                                GetHashKey("FIRING_PATTERN_FULL_AUTO")
                            )
                            TriggerServerEvent("rob_shops:robbed", shop)
                            robbing = nil
                        end
                    end
                end
            )
        end
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(7000)
            if shops and isSpawned then
                for i, shop in pairs(shops) do
                    if shop.ped then
                        if DoesEntityExist(shop.ped) and IsPedDeadOrDying(shop.ped) then
                            TriggerServerEvent("rob_shops:cashierDeath", i, NetworkGetNetworkIdFromEntity(shop.ped))
                        end
                    end
                end
            end
        end
    end
)

local safeZone = (1.0 - GetSafeZoneSize()) * 0.5
local timerBar = {
    baseX = 0.918,
    baseY = 0.984,
    baseWidth = 0.165,
    baseHeight = 0.035,
    baseGap = 0.038,
    titleX = 0.012,
    titleY = -0.009,
    textX = 0.0785,
    textY = -0.0165,
    progressX = 0.047,
    progressY = 0.0015,
    progressWidth = 0.0616,
    progressHeight = 0.0105,
    txtDict = "timerbars",
    txtName = "all_black_bg"
}

function DrawTimerProgressBar(idx, title, progress)
    local progress = progress / 100
    local titleColor = {255, 255, 255, 255}
    local fgColor = {190, 1, 41, 255}
    local bgColor = {145, 124, 129, 255}
    local titleScale = usePlayerStyle and 0.465 or 0.3
    local titleFont = usePlayerStyle and 4 or 0
    local titleFontOffset = usePlayerStyle and 0.00625 or 0.0

    local yOffset = (timerBar.baseY - safeZone) - ((idx[1] or 0) * timerBar.baseGap)

    if not HasStreamedTextureDictLoaded(timerBar.txtDict) then
        RequestStreamedTextureDict(timerBar.txtDict, true)

        local t = GetGameTimer() + 5000

        repeat
            Citizen.Wait(0)
        until HasStreamedTextureDictLoaded(timerBar.txtDict) or (GetGameTimer() > t)
    end

    DrawSprite(
        timerBar.txtDict,
        timerBar.txtName,
        timerBar.baseX - safeZone,
        yOffset,
        timerBar.baseWidth,
        timerBar.baseHeight,
        0.0,
        255,
        255,
        255,
        160
    )

    BeginTextCommandDisplayText("CELL_EMAIL_BCON")
    SetTextFont(titleFont)
    SetTextScale(titleScale, titleScale)
    SetTextColour(titleColor[1], titleColor[2], titleColor[3], titleColor[4])
    SetTextRightJustify(true)
    SetTextWrap(0.0, (timerBar.baseX - safeZone) + timerBar.titleX)
    AddTextComponentSubstringPlayerName(title)
    EndTextCommandDisplayText(
        (timerBar.baseX - safeZone) + timerBar.titleX,
        yOffset + timerBar.titleY - titleFontOffset
    )

    local progress = (progress < 0.0) and 0.0 or ((progress > 1.0) and 1.0 or progress)
    local progressX = (timerBar.baseX - safeZone) + timerBar.progressX
    local progressY = yOffset + timerBar.progressY
    local progressWidth = timerBar.progressWidth * progress

    DrawRect(
        progressX,
        progressY,
        timerBar.progressWidth,
        timerBar.progressHeight,
        bgColor[1],
        bgColor[2],
        bgColor[3],
        bgColor[4]
    )
    DrawRect(
        (progressX - timerBar.progressWidth / 2) + progressWidth / 2,
        progressY,
        progressWidth,
        timerBar.progressHeight,
        fgColor[1],
        fgColor[2],
        fgColor[3],
        fgColor[4]
    )

    if idx ~= nil then
        if idx[1] then
            idx[1] = idx[1] + 1
        end
    end
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function hasWhitelistedJob()
    for job, data in pairs(jobs) do
        if Config.WhitelistedJobTypes[data.Type] and data.Duty then
            return true
        end
    end

    return false
end

function countCurrentRoberries()
    local robberies = 0
    for _, shop in pairs(shops) do
        if shop.robbed then
            robberies = robberies + 1
        end
    end
    return robberies
end
