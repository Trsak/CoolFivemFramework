local isPlaying = false

bet = 0
hand = {}
splitHand = {}
timeLeft = 0
playerBusy = false

local selectedBet
local betLabel
local limitTableLabel, limitTableMinLabel = 0, 0
local currentlySpawnedPeds = {}
local isInCasino = exports.casino:getIsInCasino()

RegisterNetEvent("casino:leave")
AddEventHandler("casino:leave", function()
    isInCasino = false
    for i, v in each(spawnedPeds) do
        DeleteEntity(v)
    end
    for i, v in each(spawnedObjects) do
        DeleteEntity(v)
    end
    spawnedPeds = {}
    spawnedObjects = {}
end)

RegisterNetEvent("casino:enter")
AddEventHandler("casino:enter", function()
    isInCasino = true
    setupBlackjack()
end)

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    return t < -180 and t + 180 or t
end

function cardValue(card)
    local rank = 10
    for i = 2, 11 do
        if string.find(card, tostring(i)) then
            rank = i
        end
    end
    if string.find(card, 'ACE') then
        rank = 11
    end

    return rank
end

function handValue(hand)
    local tmpValue = 0
    local numAces = 0

    for i, v in each(hand) do
        tmpValue = tmpValue + cardValue(v)
    end

    for i, v in each(hand) do
        if string.find(v, 'ACE') then
            numAces = numAces + 1
        end
    end

    repeat
        if tmpValue > 21 and numAces > 0 then
            tmpValue = tmpValue - 10
            numAces = numAces - 1
        else
            break
        end
    until numAces == 0

    return tmpValue
end

function CanSplitHand(hand)
    if hand[1] and hand[2] then
        if hand[1]:sub(-3) == hand[2]:sub(-3) and #hand == 2 then
            if cardValue(hand[1]) == cardValue(hand[2]) then
                return true
            end
        end
    end

    return false
end

function getChips(amount)
    if amount < 500000 then
        local props = {}
        local propTypes = {}

        local d = #chipValues

        for i = 1, #chipValues do
            local iter = #props + 1
            while amount >= chipValues[d] do
                local model = chipModels[chipValues[d]]

                if not props[iter] then
                    local propType = string.sub(model, 0, string.len(model) - 3)

                    if propTypes[propType] then
                        iter = propTypes[propType]
                    else
                        props[iter] = {}
                        propTypes[propType] = iter
                    end
                end

                props[iter][#props[iter] + 1] = model
                amount = amount - chipValues[d]
            end

            d = d - 1
        end

        return false, props
    elseif amount <= 500000 then
        return true, "vw_prop_vw_chips_pile_01a"
    elseif amount <= 5000000 then
        return true, "vw_prop_vw_chips_pile_03a"
    else
        return true, "vw_prop_vw_chips_pile_02a"
    end
end

function leaveBlackjack()
    leavingBlackjack = true
    renderScaleform = false
    renderTime = false
    renderBet = false
    renderHand = false
    hand = {}
    splitHand = {}
end

RegisterCommand("addClosestBlackjackTable",
    function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, tableModel in each(TableModels) do
            local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 1.5, GetHashKey(tableModel))
            if DoesEntityExist(object) then
                print(vector4(GetEntityCoords(object), GetEntityHeading(object)))
                break
            end
        end
    end,
    false
)

function s2m(s)
    if s <= 0 then
        return "00:00"
    else
        local m = string.format("%02.f", math.floor(s / 60))
        return m .. ":" .. string.format("%02.f", math.floor(s - m * 60))
    end
end

spawnedPeds = {}
spawnedObjects = {}
AddEventHandler("onResourceStop", function(r)
    if r == GetCurrentResourceName() then
        for i, v in each(spawnedPeds) do
            SetEntityAsNoLongerNeeded(v)
            DeletePed(v)
        end
        for i, v in each(spawnedObjects) do
            SetEntityAsNoLongerNeeded(v)
            DeleteEntity(v)
        end
    end
end)

RegisterNetEvent("casino:blackjack:clear")
AddEventHandler("casino:blackjack:clear", function()
    for i, v in each(spawnedPeds) do
        SetEntityAsNoLongerNeeded(v)
        DeletePed(v)
    end
    for i, v in each(spawnedObjects) do
        SetEntityAsNoLongerNeeded(v)
        DeleteEntity(v)
    end
    spawnedPeds = {}
    spawnedObjects = {}
    Citizen.Wait(500)
    setupBlackjack()
end)

renderScaleform = false
renderTime = false
renderBet = false
renderHand = false

Citizen.CreateThread(function()

    scaleform = RequestScaleformMovie_2("INSTRUCTIONAL_BUTTONS")

    repeat Wait(0) until HasScaleformMovieLoaded(scaleform)
    local gotCurrentChips = false
    local currentChips

    while true do
        Wait(0)
        if isInCasino then
            if renderScaleform == true then
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            end

            local barCount = { 1 }

            if renderBet == true then
                if not gotCurrentChips then
                    gotCurrentChips = true
                    currentChips = exports.data:getFormattedCurrency(exports.inventory:getCasinoChipsTotalValue())
                end

                DrawTimerBar(barCount, "TVOJE ŽETONY", currentChips)
                DrawTimerBar(barCount, "MAXIMÁLNÍ SÁZKA", limitTableLabel)
                DrawTimerBar(barCount, "MINIMÁLNÍ SÁZKA", limitTableMinLabel)
                DrawTimerBar(barCount, "AKTUÁLNÍ SÁZKA", betLabel)
            else
                gotCurrentChips = false
            end

            if renderTime == true and timeLeft ~= nil then
                if timeLeft > 0 then
                    DrawTimerBar(barCount, "ČAS DO HRY", s2m(timeLeft))
                end
            end

            if renderHand == true then
                if #splitHand > 0 then
                    DrawTimerBar(barCount, "SPLIT", handValue(splitHand))
                end
                DrawTimerBar(barCount, "TVOJE KARTY", handValue(hand))
                DrawTimerBar(barCount, "DEALER", dealerValue[g_seat])
            end
        end
    end
end)

function IsSeatOccupied(coords, radius)
    local players = GetActivePlayers()
    local playerId = PlayerId()
    for i = 1, #players do
        if players[i] ~= playerId then
            local ped = GetPlayerPed(players[i])
            if IsEntityAtCoord(ped, coords, radius, radius, radius, 0, 0, 0) then
                return true
            end
        end
    end

    return false
end

dealerHand = {}
dealerValue = {}
dealerHandObjs = {}
handObjs = {}

function CreatePeds()
    if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@dealer") then
        RequestAnimDict("anim_casino_b@amb@casino@games@blackjack@dealer")
        repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@dealer")
    end

    if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@") then
        RequestAnimDict("anim_casino_b@amb@casino@games@shared@dealer@")
        repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@")
    end

    if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@player") then
        RequestAnimDict("anim_casino_b@amb@casino@games@blackjack@player")
        repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@player")
    end

    chips = {}

    hand = {}
    splitHand = {}
    handObjs = {}

    for i, v in each(tables) do
        local tableObject

        for _, tableModel in each(TableModels) do
            RequestModel(GetHashKey(tableModel))
            while not HasModelLoaded(GetHashKey(tableModel)) do
                Wait(500)
            end
            tableObject = GetClosestObjectOfType(v.coords.x, v.coords.y, v.coords.z, 1.5, GetHashKey(tableModel))
            if DoesEntityExist(tableObject) then
                break
            end
        end

        if DoesEntityExist(tableObject) then
            dealerHand[i] = {}
            dealerValue[i] = {}
            dealerHandObjs[i] = {}
            local model = "s_f_y_casino_01"

            chips[i] = {}

            for x = 1, 4 do
                chips[i][x] = {}
            end
            handObjs[i] = {}

            for x = 1, 4 do
                handObjs[i][x] = {}
            end

            if not HasModelLoaded(model) then
                RequestModel(model)
                repeat Wait(0) until HasModelLoaded(model)
            end

            local pedExists = false
            local dealer
            if currentlySpawnedPeds[i] ~= nil then
                if DoesEntityExist(currentlySpawnedPeds[i]) and not NetworkHasControlOfEntity(currentlySpawnedPeds[i]) then
                    pedExists = true
                    dealer = currentlySpawnedPeds[i]
                end
            end

            if not pedExists then
                dealer = CreatePed(4, model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, true)
                currentlySpawnedPeds[i] = dealer
            end

            SetEntityCanBeDamaged(dealer, false)
            SetBlockingOfNonTemporaryEvents(dealer, true)
            SetPedCanRagdollFromPlayerImpact(dealer, false)

            -- SetPedVoiceGroup(dealer, 'S_F_Y_Casino_01_ASIAN_02')

            -- SetPedDefaultComponentVariation(dealer)

            SetPedResetFlag(dealer, 249, true)
            SetPedConfigFlag(dealer, 185, true)
            SetPedConfigFlag(dealer, 108, true)
            SetPedConfigFlag(dealer, 208, true)

            exports.casino:setCasinoPedRandomClothes(dealer, tableObject)

            Citizen.CreateThread(
                function()
                    Wait(1000)
                    FreezeEntityPosition(dealer, true)
                end
            )

            -- NetworkSetEntityInvisibleToNetwork(dealer, true)

            -- N_0x352e2b5cf420bf3b(dealer, true)
            -- N_0x2f3c3d9f50681de4(dealer, true)

            -- SetNetworkIdCanMigrate(PedToNet(dealer), false)

            -- local scene = NetworkCreateSynchronisedScene(v.coords.x, v.coords.y, v.coords.z, vector3(0.0, 0.0, v.coords.w), 2, true, true, 1065353216, 0, 1065353216)
            -- NetworkAddPedToSynchronisedScene(dealer, scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 2.0, -2.0, 13, 16, 1148846080, 0)
            -- NetworkStartSynchronisedScene(scene)

            local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
            TaskSynchronizedScene(dealer, scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 1000.0, -8.0, 4, 1, 1148846080, 0)

            -- TaskLookAtEntity(dealer, PlayerPedId(), -1, 2048, 3)

            -- Wait(1500)

            -- TaskPlayAnim(dealer, anim, "idle", 4.0, -1.0, -1, 0, -1.0, true, true, true)

            spawnedPeds[i] = dealer
        else
            return false
        end
    end

    return true
end

-- function getCardOffset(seat, cardIndex)
-- if seat == 1 then
-- if cardIndex =
-- end
-- end

RegisterNetEvent("BLACKJACK:SyncTimer")
AddEventHandler("BLACKJACK:SyncTimer", function(_timeLeft)
    if not isInCasino then
        return
    end

    timeLeft = _timeLeft
end)

RegisterNetEvent("BLACKJACK:PlayDealerAnim")
AddEventHandler("BLACKJACK:PlayDealerAnim", function(i, animDict, anim)
    if not isInCasino then
        return
    end

    Citizen.CreateThread(function()

        local v = tables[i]

        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            repeat Wait(0) until HasAnimDictLoaded(animDict)
        end

        -- if GetEntityModel(spawnedPeds[i]) == 's_f_y_casino_01' then
        -- anim = "female_"..anim
        -- end

        DebugPrint("PLAYING " .. anim:upper() .. " ON DEALER " .. i)

        -- if seat == 0 then
        -- local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
        -- TaskSynchronizedScene(spawnedPeds[i], scene, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_self", 1000.0, -8.0, 4, 1, 1148846080, 0)
        -- else
        -- local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
        -- TaskSynchronizedScene(spawnedPeds[i], scene, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_player_0" .. 5-seat, 1000.0, -8.0, 4, 1, 1148846080, 0)
        -- end

        local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
        TaskSynchronizedScene(spawnedPeds[i], scene, animDict, anim, 8.0, 8.0, 4, 1, 1148846080, 0)

    end)
end)

RegisterNetEvent("BLACKJACK:PlayDealerSpeech")
AddEventHandler("BLACKJACK:PlayDealerSpeech", function(i, speech)
    if not isInCasino then
        return
    end

    Citizen.CreateThread(function()
        DebugPrint("PLAYING SPEECH " .. speech:upper() .. " ON DEALER " .. i)
        StopCurrentPlayingAmbientSpeech(spawnedPeds[i])
        PlayAmbientSpeech1(spawnedPeds[i], speech, "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
    end)
end)

RegisterNetEvent("BLACKJACK:DealerTurnOverCard")
AddEventHandler("BLACKJACK:DealerTurnOverCard", function(i)
    if not isInCasino then
        return
    end

    SetEntityRotation(dealerHandObjs[i][1], 0.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[1].z)
end)

RegisterNetEvent("BLACKJACK:SplitHand")
AddEventHandler("BLACKJACK:SplitHand", function(index, seat, splitHandSize, _hand, _splitHand)
    if not isInCasino then
        return
    end

    hand = _hand
    splitHand = _splitHand

    DebugPrint("splitHandSize = " .. splitHandSize)
    DebugPrint("split card coord = " .. tostring(GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, cardSplitOffsets[seat][1])))

    SetEntityCoordsNoOffset(handObjs[index][seat][#handObjs[index][seat]], GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, cardSplitOffsets[5 - seat][1]))
    SetEntityRotation(handObjs[index][seat][#handObjs[index][seat]], 0.0, 0.0, cardSplitRotationOffsets[seat][splitHandSize])
end)

--[[
	--Get chip offsets
	Citizen.CreateThread(function()
		local selectedOffset = { x=0.0, y=0.0, z=0.0 }
		while true do
			Citizen.Wait(0)

			if selectedTable and selectedChip then
				if IsDisabledControlPressed(1, 108) then -- y-selectedOffset.x, selectedOffset.y
					selectedOffset.y = selectedOffset.y - 0.01
				end

				if IsDisabledControlPressed(1, 107) then -- y+
					selectedOffset.y = selectedOffset.y + 0.01
				end

				if IsDisabledControlPressed(1, 111) then -- x-
					selectedOffset.x = selectedOffset.x - 0.01
				end

				if IsDisabledControlPressed(1, 112) then -- x+
					selectedOffset.x = selectedOffset.x + 0.01
				end

				if IsDisabledControlPressed(1, 117) then -- rotate left
					selectedOffset.z = selectedOffset.z - 0.1
					if selectedOffset.z < 0 then selectedOffset.z = 360.0 end
				end

				if IsDisabledControlPressed(1, 118) then -- rotate right
					selectedOffset.z = selectedOffset.z + 0.1
					if selectedOffset.z > 360 then selectedOffset.z = 0.0 end
				end

				SetEntityCoordsNoOffset(selectedChip, GetObjectOffsetFromCoords(tables[selectedTable].coords.x, tables[selectedTable].coords.y, tables[selectedTable].coords.z, tables[selectedTable].coords.w, selectedOffset.x, selectedOffset.y, chipHeights[1]))
				SetEntityRotation(selectedChip, 0.0, 0.0, tables[selectedTable].coords.w + selectedOffset.z)

				SetTextScale(0.5, 0.5)
				SetTextColour(255,255,255,255)
				SetTextDropShadow(0, 0, 0, 0,255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString("~b~"..selectedOffset.x..", "..selectedOffset.y..", "..selectedOffset.z)
				DrawText(0.3,0.8)
			end
		end
	end)
--]]

RegisterNetEvent("BLACKJACK:PlaceBetChip")
AddEventHandler("BLACKJACK:PlaceBetChip", function(index, seat, bet, double, split)
    if not isInCasino then
        return
    end

    Citizen.CreateThread(function()
        local chipPile, props = getChips(bet)

        if chipPile then
            local model = GetHashKey(props)

            DebugPrint(bet)
            DebugPrint(seat)
            DebugPrint(tostring(props))
            DebugPrint(tostring(pileOffsets[seat]))

            RequestModel(model)
            repeat Wait(0) until HasModelLoaded(model)
            local location = 1
            if double == true then
                location = 2
            end

            local chip = CreateObjectNoOffset(model, tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, false, false, false)

            table.insert(spawnedObjects, chip)
            table.insert(chips[index][seat], chip)

            if split == false then
                SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, pileOffsets[seat][location].x, pileOffsets[seat][location].y, chipHeights[1]))
                SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + pileRotationOffsets[seat][3 - location].z)
            else
                SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, pileOffsets[seat][2].x, pileOffsets[seat][2].y, chipHeights[1]))
                SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + pileRotationOffsets[seat][3 - location].z)
            end

            --Get chip offsets
            --selectedChip = chip
            --selectedTable = index
        else
            local chipXOffset = 0.0
            local chipYOffset = 0.0

            if split or double then
                if seat == 1 then
                    chipXOffset = chipXOffset + 0.03
                    chipYOffset = chipYOffset + 0.05
                elseif seat == 2 then
                    chipXOffset = chipXOffset + 0.05
                    chipYOffset = chipYOffset + 0.02
                elseif seat == 3 then
                    chipXOffset = chipXOffset + 0.05
                    chipYOffset = chipYOffset - 0.02
                elseif seat == 4 then
                    chipXOffset = chipXOffset + 0.02
                    chipYOffset = chipYOffset - 0.05
                end
            end

            for i = 1, #props do
                local chipGap = 0.0

                for j = 1, #props[i] do
                    local model = GetHashKey(props[i][j])

                    DebugPrint(bet)
                    DebugPrint(seat)
                    DebugPrint(tostring(props[i][j]))
                    DebugPrint(tostring(chipOffsets[seat]))

                    RequestModel(model)
                    repeat Wait(0) until HasModelLoaded(model)

                    local location = i
                    -- if double == true then location = 2 end

                    local chip = CreateObjectNoOffset(model, tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, false, false, false)

                    table.insert(spawnedObjects, chip)
                    table.insert(chips[index][seat], chip)

                    -- if split == false and double == false then
                    SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, chipOffsets[seat][location].x + chipXOffset, chipOffsets[seat][location].y + chipYOffset, chipHeights[1] + chipGap))
                    SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + chipRotationOffsets[seat][location].z)
                    -- else
                    -- SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, chipSplitOffsets[seat][location].x + chipXOffset, chipSplitOffsets[seat][location].y + chipYOffset, chipHeights[1] + chipGap))
                    -- SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + chipSplitRotationOffsets[seat][location].z)
                    -- end

                    chipGap = chipGap + ((chipThickness[model] ~= nil) and chipThickness[model] or 0.0)
                end

                -- Hacky way to setup each seats split chips
            end
        end
    end)
end)

RegisterNetEvent("BLACKJACK:BetReceived")

local downPressed = false

RegisterNetEvent("BLACKJACK:RequestBets")
AddEventHandler("BLACKJACK:RequestBets", function(index, _timeLeft)
    timeLeft = _timeLeft
    if leavingBlackjack == true then
        leaveBlackjack()
        return
    end

    Citizen.CreateThread(function()
        scrollerIndex = index
        renderScaleform = true
        renderTime = true
        renderBet = true

        exports.key_hints:hideBottomHint({ name = "blackjack_stand" })
        exports.key_hints:hideBottomHint({ name = "blackjack_hit" })
        exports.key_hints:hideBottomHint({ name = "blackjack_double" })
        exports.key_hints:hideBottomHint({ name = "blackjack_split" })
        exports.key_hints:displayBottomHint({ name = "blackjack_standup", key = "~INPUT_FRONTEND_RRIGHT~", text = "Vstát" })
        exports.key_hints:displayBottomHint({ name = "blackjack_money", key = "~INPUT_RELOAD~", text = "Upravit sázku" })
        exports.key_hints:displayBottomHint({ name = "blackjack_bet", key = "~INPUT_JUMP~", text = "Vsadit" })
        local lastBet = 0

        local tableLimit = (tables[scrollerIndex].highStakes == true) and highableLimit or lowTableLimit
        local tableLimitMin = (tables[scrollerIndex].highStakes == true) and highableLimitMin or lowTableLimitMin

        while true do
            Wait(0)

            if IsDisabledControlJustPressed(1, 194) then
                -- ESC / B
                leavingBlackjack = true
                renderScaleform = false
                renderTime = false
                renderBet = false
                renderHand = false
                selectedBet = 10
                return
            end

            if IsDisabledControlJustPressed(1, 45) then
                exports.input:openInput(
                    "number",
                    { title = "Za kolik $ chcete vsázet?", placeholder = "Minimálně " .. exports.data:getFormattedCurrency(tableLimitMin) .. " a maximálně " .. exports.data:getFormattedCurrency(tableLimit) },
                    function(buyValue)
                        if buyValue == nil then
                            exports.notify:display(
                                {
                                    type = "error",
                                    title = "Chyba",
                                    text = "Musíš zadat částku!",
                                    icon = "fas fa-times",
                                    length = 3500
                                }
                            )
                        else
                            buyValue = tonumber(buyValue)
                            if buyValue == nil or buyValue < tableLimitMin or (buyValue % 10) ~= 0 or buyValue > tableLimit then
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Chyba",
                                        text = "Částka musí být číslo násobkem 10, minimálně " .. exports.data:getFormattedCurrency(tableLimitMin) .. " a maximálně " .. exports.data:getFormattedCurrency(tableLimit) .. "!",
                                        icon = "fas fa-times",
                                        length = 3500
                                    }
                                )
                            else
                                selectedBet = buyValue
                            end
                        end
                    end
                )
            end

            bet = selectedBet
            if lastBet ~= bet then
                lastBet = bet
                limitTableLabel = exports.data:getFormattedCurrency(tableLimit)
                limitTableMinLabel = exports.data:getFormattedCurrency(tableLimitMin)
                betLabel = exports.data:getFormattedCurrency(bet)
            end

            if IsDisabledControlJustPressed(1, 22) then
                TriggerServerEvent("BLACKJACK:CheckPlayerBet", g_seat, bet)

                local betCheckRecieved = false
                local canBet = false
                local eventHandler = AddEventHandler("BLACKJACK:BetReceived", function(_canBet)
                    betCheckRecieved = true
                    canBet = _canBet
                end)

                repeat Wait(0) until betCheckRecieved == true

                RemoveEventHandler(eventHandler)

                if canBet then
                    renderScaleform = false
                    renderTime = false
                    renderBet = false
                    if selectedBet < 27 then
                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        hideAllHints()
                        local anim = "place_bet_small"

                        playerBusy = true
                        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                        NetworkStartSynchronisedScene(scene)

                        Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false)

                        Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        playerBusy = false

                        local idleVar = "idle_var_0" .. math.random(1, 5)

                        DebugPrint("IDLING POST-BUSY: " .. idleVar)

                        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                        NetworkStartSynchronisedScene(scene)
                    else
                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        hideAllHints()
                        local anim = "place_bet_large"

                        playerBusy = true
                        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                        NetworkStartSynchronisedScene(scene)

                        Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false)

                        Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                        if leavingBlackjack == true then
                            leaveBlackjack()
                            return
                        end

                        playerBusy = false

                        local idleVar = "idle_var_0" .. math.random(1, 5)

                        DebugPrint("IDLING POST-BUSY: " .. idleVar)

                        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                        NetworkStartSynchronisedScene(scene)
                    end
                    return
                else
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe tolik žetonů!",
                            icon = "fas fa-coins",
                            length = 3500
                        }
                    )
                end
            end
        end
        -- TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet)
    end)
end)

RegisterNetEvent("BLACKJACK:RequestMove")
AddEventHandler("BLACKJACK:RequestMove", function(_timeLeft)
    if not isInCasino then
        return
    end

    Citizen.CreateThread(function()
        timeLeft = _timeLeft
        if leavingBlackjack == true then
            leaveBlackjack()
            return
        end

        renderScaleform = true
        renderTime = true
        renderHand = true

        exports.key_hints:hideBottomHint({ name = "blackjack_money" })
        exports.key_hints:hideBottomHint({ name = "blackjack_bet" })
        exports.key_hints:hideBottomHint({ name = "blackjack_standup" })
        exports.key_hints:displayBottomHint({ name = "blackjack_stand", key = "~INPUT_FRONTEND_X~", text = "Stand" })
        exports.key_hints:displayBottomHint({ name = "blackjack_hit", key = "~INPUT_FRONTEND_ACCEPT~", text = "Hit" })

        if #hand < 3 and #splitHand == 0 then
            exports.key_hints:displayBottomHint({ name = "blackjack_double", key = "~INPUT_FRONTEND_RUP~", text = "Double" })
        end

        if CanSplitHand(hand) == true then
            exports.key_hints:displayBottomHint({ name = "blackjack_split", key = "~INPUT_FRONTEND_LS~", text = "Split" })
        end

        while true do
            Wait(0)
            if IsDisabledControlJustPressed(1, 201) then
                if leavingBlackjack == true then
                    DebugPrint("returning")
                    return
                end

                hideAllHints()
                TriggerServerEvent("BLACKJACK:ReceivedMove", "hit")

                renderScaleform = false
                renderTime = false
                renderHand = false
                local anim = requestCardAnims[math.random(1, #requestCardAnims)]

                playerBusy = true
                local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                NetworkStartSynchronisedScene(scene)
                Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 990))

                if leavingBlackjack == true then
                    leaveBlackjack()
                    return
                end

                playerBusy = false

                local idleVar = "idle_var_0" .. math.random(1, 5)

                DebugPrint("IDLING POST-BUSY: " .. idleVar)

                local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                NetworkStartSynchronisedScene(scene)

                return
            end
            if IsDisabledControlJustPressed(1, 203) then
                if leavingBlackjack == true then
                    leaveBlackjack()
                    return
                end

                hideAllHints()
                TriggerServerEvent("BLACKJACK:ReceivedMove", "stand")

                renderScaleform = false
                renderTime = false
                renderHand = false
                local anim = declineCardAnims[math.random(1, #declineCardAnims)]

                playerBusy = true
                local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                NetworkStartSynchronisedScene(scene)
                Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 990))

                if leavingBlackjack == true then
                    leaveBlackjack()
                    return
                end

                playerBusy = false

                local idleVar = "idle_var_0" .. math.random(1, 5)

                DebugPrint("IDLING POST-BUSY: " .. idleVar)

                local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                NetworkStartSynchronisedScene(scene)

                return
            end
            if IsDisabledControlJustPressed(1, 192) and #hand == 2 and #splitHand == 0 then
                if leavingBlackjack == true then
                    leaveBlackjack()
                    return
                end

                TriggerServerEvent("BLACKJACK:CheckPlayerBet", g_seat, bet)

                local betCheckRecieved = false
                local canBet = false
                local eventHandler = AddEventHandler("BLACKJACK:BetReceived", function(_canBet)
                    betCheckRecieved = true
                    canBet = _canBet
                end)

                repeat Wait(0) until betCheckRecieved == true

                RemoveEventHandler(eventHandler)

                if canBet then
                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    hideAllHints()
                    TriggerServerEvent("BLACKJACK:ReceivedMove", "double")

                    renderScaleform = false
                    renderTime = false
                    renderHand = false
                    local anim = "place_bet_double_down"

                    playerBusy = true
                    local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                    NetworkStartSynchronisedScene(scene)
                    Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, true)

                    Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    playerBusy = false

                    local idleVar = "idle_var_0" .. math.random(1, 5)

                    DebugPrint("IDLING POST-BUSY: " .. idleVar)

                    local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                    NetworkStartSynchronisedScene(scene)

                    return
                else
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe dostatek žetonů na double!",
                            icon = "fas fa-coins",
                            length = 3500
                        }
                    )
                end
            end
            if IsDisabledControlJustPressed(1, 209) and CanSplitHand(hand) == true then
                if leavingBlackjack == true then
                    leaveBlackjack()
                    return
                end

                TriggerServerEvent("BLACKJACK:CheckPlayerBet", g_seat, bet)

                local betCheckRecieved = false
                local canBet = false
                local eventHandler = AddEventHandler("BLACKJACK:BetReceived", function(_canBet)
                    betCheckRecieved = true
                    canBet = _canBet
                end)

                repeat Wait(0) until betCheckRecieved == true

                RemoveEventHandler(eventHandler)

                if canBet then
                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    hideAllHints()
                    TriggerServerEvent("BLACKJACK:ReceivedMove", "split")

                    renderScaleform = false
                    renderTime = false
                    renderHand = false
                    local anim = "place_bet_small_split"

                    if selectedBet > 27 then
                        anim = "place_bet_large_split"
                    end

                    playerBusy = true
                    local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
                    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, 2.0, 13, 16, 0, 0)
                    NetworkStartSynchronisedScene(scene)
                    Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false, true)

                    Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim) * 500))

                    if leavingBlackjack == true then
                        leaveBlackjack()
                        return
                    end

                    playerBusy = false

                    local idleVar = "idle_var_0" .. math.random(1, 5)

                    DebugPrint("IDLING POST-BUSY: " .. idleVar)

                    local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
                    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
                    NetworkStartSynchronisedScene(scene)

                    return
                else
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe dostatek žetonů na split!",
                            icon = "fas fa-coins",
                            length = 3500
                        }
                    )
                end
            end
        end
    end)
end)

RegisterNetEvent("BLACKJACK:GameEndReaction")
AddEventHandler("BLACKJACK:GameEndReaction", function(result, win)
    if not isInCasino then
        return
    end

    Citizen.CreateThread(function()

        if #hand == 2 and handValue(hand) == 21 and result == "good" then
            exports.notify:display(
                {
                    type = "success",
                    title = "Blackjack",
                    text = "Máš blackjack! Vyhrál jsi " .. exports.data:getFormattedCurrency(win),
                    icon = "fas fa-coins",
                    length = 8000
                }
            )
        elseif handValue(hand) > 21 and result ~= "good" then
            exports.notify:display(
                {
                    type = "error",
                    title = "Bust",
                    text = "Máš nad 21! Tuto handu jsi prohrál.",
                    icon = "fas fa-times",
                    length = 8000
                }
            )
        else
            if result == "good" then
                exports.notify:display(
                    {
                        type = "success",
                        title = "Výhra",
                        text = "Vyhrál jsi " .. exports.data:getFormattedCurrency(win) .. " s " .. handValue(hand) .. ", dealer měl " .. dealerValue[g_seat],
                        icon = "fas fa-coins",
                        length = 8000
                    }
                )
            elseif result == "bad" then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Prohra",
                        text = "Prohrál jsi s " .. handValue(hand) .. ", dealer měl " .. dealerValue[g_seat],
                        icon = "fas fa-times",
                        length = 8000
                    }
                )
            else
                exports.notify:display(
                    {
                        type = "info",
                        title = "Push",
                        text = "Pushnul jsi s " .. handValue(hand) .. "!",
                        icon = "fas fa-info",
                        length = 8000
                    }
                )
            end
        end

        hand = {}
        splitHand = {}
        renderHand = false
        -- handObjs = {}
        -- handObjs[i] = {}

        -- for x=1,4 do
        -- handObjs[i][x] = {}
        -- end
        if leavingBlackjack == true then
            leaveBlackjack()
            return
        end

        local anim = "reaction_" .. result .. "_var_0" .. math.random(1, 4)

        DebugPrint("Reacting: " .. anim)

        playerBusy = true
        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, false, false, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", anim, 2.0, 2.0, 13, 16, 0, 0)
        NetworkStartSynchronisedScene(scene)
        Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", anim) * 990))

        if leavingBlackjack == true then
            leaveBlackjack()
            return
        end

        playerBusy = false

        idleVar = "idle_var_0" .. math.random(1, 5)

        local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, 2.0, 13, 16, 0, 0)
        NetworkStartSynchronisedScene(scene)
    end)
end)

RegisterNetEvent("BLACKJACK:RetrieveCards")
AddEventHandler("BLACKJACK:RetrieveCards", function(i, seat)
    if not isInCasino then
        return
    end

    DebugPrint("TABLE " .. i .. ": DELETE SEAT " .. seat .. " CARDS")
    -- if g_seat == i then
    -- for z,v in each(chips[i]) do
    -- if v then
    -- DeleteEntity(v)
    -- end
    -- end
    -- end

    -- DeleteEntity(chips[i][seat])

    if seat == 0 then
        for x, v in each(dealerHandObjs[i]) do
            DeleteEntity(v)
            dealerHandObjs[i][x] = nil
        end
    else
        for x, v in each(handObjs[i][seat]) do
            DeleteEntity(v)
            -- handObjs[i][seat][x] = nil
            -- table.remove(handObjs[i][seat], i)
        end
        for x, v in each(chips[i][5 - seat]) do
            DeleteEntity(v)
        end
    end
end)

RegisterNetEvent("BLACKJACK:UpdateDealerHand")
AddEventHandler("BLACKJACK:UpdateDealerHand", function(i, v)
    if not isInCasino then
        return
    end

    dealerValue[i] = v
end)

RegisterNetEvent("BLACKJACK:GiveCard")
AddEventHandler("BLACKJACK:GiveCard", function(i, seat, handSize, card, flipped, split)
    if not isInCasino then
        return
    end

    flipped = flipped or false
    split = split or false

    if i == g_seat and seat == closestChair then
        if split == true then
            table.insert(splitHand, card)
        else
            table.insert(hand, card)
        end

        DebugPrint("GOT CARD " .. card .. " (" .. cardValue(card) .. ")")
        DebugPrint("HAND VALUE " .. handValue(hand))
    elseif seat == 0 then
        table.insert(dealerHand[i], card)
    end

    local model = GetHashKey("vw_prop_cas_card_" .. card)

    RequestModel(model)
    repeat Wait(0) until HasModelLoaded(model)

    local cardCoords = GetPedBoneCoords(spawnedPeds[i], 28422, 0.0, 0.0, 0.0)
    local card = CreateObjectNoOffset(model, cardCoords.x, cardCoords.y, cardCoords.z, false, false, false)

    table.insert(spawnedObjects, card)

    -- if seat == closestChair then
    -- table.insert(handObjs, card)
    -- end

    if seat > 0 then
        table.insert(handObjs[i][seat], card)
    end

    -- SetNetworkIdCanMigrate(ObjToNet(card), false)

    AttachEntityToEntity(card, spawnedPeds[i], GetPedBoneIndex(spawnedPeds[i], 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 1, 2, 1)

    Wait(500)

    -- AttachEntityToEntity(card, spawnedPeds[i], GetPedBoneIndex(spawnedPeds[i], 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 1, 2, 1)

    Wait(800)

    DetachEntity(card, 0, true)

    if seat == 0 then
        table.insert(dealerHandObjs[i], card)

        SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardOffsetsDealer[handSize]))

        if flipped == true then
            SetEntityRotation(card, 180.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[handSize].z)
        else
            SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[handSize].z)
        end
    else
        if split == true then
            SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardSplitOffsets[5 - seat][handSize]))
            SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardSplitRotationOffsets[5 - seat][handSize])
        else
            SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardOffsets[5 - seat][handSize]))
            SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardRotationOffsets[5 - seat][handSize])
        end
    end
end)

function setupBlackjack()
    if isInCasino then
        local isNearBy = false
        while isInCasino and not isNearBy do
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - vec3(tables[1].coords.x, tables[1].coords.y, tables[1].coords.z)) <= 60.0 then
                isNearBy = true
                break
            end

            Wait(250)
        end

        if isNearBy then
            RequestAnimDict("anim_casino_b@amb@casino@games@shared@player@")

            local result
            while not result and isInCasino do
                Wait(0)
                result = CreatePeds()

                if not result then
                    Wait(50)
                end
            end

        end
    end
end

Citizen.CreateThread(function()
    local tableModelHashes = {}
    for _, tableModel in each(TableModels) do
        table.insert(tableModelHashes, GetHashKey(tableModel))
    end

    setupBlackjack()

    exports["target"]:AddTargetObject(tableModelHashes, {
        actions = {
            use_blackjack_table = {
                cb = function(tableData)
                    if isPlaying then
                        return
                    end

                    isPlaying = true

                    local tableObj = tableData.entity

                    local closestChairData = getClosestChairData(tableObj)
                    if closestChairData == nil then
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Chyba",
                                text = "Musíš stát u židle na kterou si chceš sednout!",
                                icon = "fas fa-chair",
                                length = 3500
                            }
                        )
                        return
                    end

                    startPlaying(closestChairData, getEntityIndex(tableObj))
                end,
                cbData = {},
                icon = "fas fa-coins",
                label = "Zahrát si Blackjack",
            }
        },
        distance = 1.5
    })
end)

function getEntityIndex(entity)
    for i, tableData in each(tables) do
        for _, tableModel in each(TableModels) do
            local object = GetClosestObjectOfType(tableData.coords.x, tableData.coords.y, tableData.coords.z, 1.5, GetHashKey(tableModel))
            print(DoesEntityExist(object))
            if DoesEntityExist(object) then
                if object == entity then
                    return i
                end
            end
        end
    end

    return nil
end

function startPlaying(closestChairData, i)
    if IsSeatOccupied(closestChairData.position, 0.5) then
        exports.notify:display(
            {
                type = "error",
                title = "Chyba",
                text = "Nejbližší židle je obsazená!",
                icon = "fas fa-chair",
                length = 3500
            }
        )
        isPlaying = false
        return
    end

    local coords = closestChairData.position
    local rot = closestChairData.rotation

    g_coords = coords
    g_rot = rot

    closestChair = closestChairData.chairId
    SITTING_SCENE = NetworkCreateSynchronisedScene(coords, rot, 2, 1, 0, 1065353216, 0, 1065353216)
    RequestAnimDict('anim_casino_b@amb@casino@games@shared@player@')
    while not HasAnimDictLoaded('anim_casino_b@amb@casino@games@shared@player@') do
        Citizen.Wait(1)
    end

    local randomSit = ({ 'sit_enter_left', 'sit_enter_right' })[math.random(1, 2)]
    NetworkAddPedToSynchronisedScene(PlayerPedId(), SITTING_SCENE, 'anim_casino_b@amb@casino@games@shared@player@', randomSit, 2.0, -2.0, 13, 16, 2.0, 0)
    NetworkStartSynchronisedScene(SITTING_SCENE)

    Wait(50)

    SetPedCurrentWeaponVisible(PlayerPedId(), 0, true, 0, 0)

    scene = NetworkConvertSynchronisedSceneToSynchronizedScene(scene)
    repeat Wait(0) until GetSynchronizedScenePhase(scene) >= 0.99 or HasAnimEventFired(PlayerPedId(), 2038294702) or HasAnimEventFired(PlayerPedId(), -1424880317)

    Wait(1000)

    idleVar = "idle_cardgames"

    scene = NetworkCreateSynchronisedScene(coords, rot, 2, 1, 0, 1065353216, 0, 1065353216)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 2.0, 2.0, 13, 16, 2.0, 0)
    NetworkStartSynchronisedScene(scene)

    repeat Wait(0) until IsEntityPlayingAnim(PlayerPedId(), "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 3) == 1

    g_seat = i

    leavingBlackjack = false

    selectedBet = (tables[i].highStakes == true) and highableLimitMin or lowTableLimitMin
    TriggerServerEvent("BLACKJACK:PlayerSatDown", i, closestChair)

    exports.target:DisableTarget(true)
    exports.emotes:DisableEmotes(true)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            SetPauseMenuActive(false)
            DisableAllControlActions(0)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 289, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 3, true)
            EnableControlAction(0, 4, true)
            EnableControlAction(0, 5, true)
            EnableControlAction(0, 6, true)

            if leavingBlackjack then
                hideAllHints()
                exports.target:DisableTarget(false)
                exports.emotes:DisableEmotes(false)

                SetPauseMenuActive(true)
                break
            end
        end
    end)

    while true do
        Wait(0)

        if leavingBlackjack == true then
            if standUpCallback ~= nil then
                standUpCallback()
            end

            scene = NetworkCreateSynchronisedScene(coords, rot, 2, false, false, 1065353216, 0, 1065353216)
            NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left", 2.0, 2.0, 13, 16, 0, 0)
            NetworkStartSynchronisedScene(scene)
            TriggerServerEvent("BLACKJACK:PlayerSatUp", i)
            Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left") * 800))
            ClearPedTasks(PlayerPedId())
            isPlaying = false
            break
        end
    end
end

function getClosestChairData(tableObject)
    local localPlayer = PlayerPedId()
    local playerpos = GetEntityCoords(localPlayer)
    if DoesEntityExist(tableObject) then
        local chairs = { 'Chair_Base_01', 'Chair_Base_02', 'Chair_Base_03', 'Chair_Base_04' }
        local closest = 50.0
        local closestData

        for i = 1, #chairs, 1 do
            local objcoords = GetWorldPositionOfEntityBone(tableObject, GetEntityBoneIndexByName(tableObject, chairs[i]))
            local dist = Vdist(playerpos, objcoords)
            if dist < 1.7 then
                if dist < closest then
                    closest = dist
                    closestData = {
                        position = objcoords,
                        rotation = GetWorldRotationOfEntityBone(tableObject, GetEntityBoneIndexByName(tableObject, chairs[i])),
                        chairId = chair_indexes[chairs[i]]
                    }
                end
            end
        end

        return closestData
    end
end

function hideAllHints()
    exports.key_hints:hideBottomHint({ name = "blackjack_money" })
    exports.key_hints:hideBottomHint({ name = "blackjack_bet" })
    exports.key_hints:hideBottomHint({ name = "blackjack_standup" })
    exports.key_hints:hideBottomHint({ name = "blackjack_hit" })
    exports.key_hints:hideBottomHint({ name = "blackjack_double" })
    exports.key_hints:hideBottomHint({ name = "blackjack_split" })
    exports.key_hints:hideBottomHint({ name = "blackjack_stand" })
end

--TODO: ON DEATH TriggerServerEvent("BLACKJACK:PlayerRemove", i) ClearPedTasks(playerPed) leaveBlackjack()