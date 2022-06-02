local isSpawned, isDead = false, false
local currentBlips = {  }

Citizen.CreateThread(function()
    Citizen.CreateThread(
        function()
            while not exports.data:isUserLoaded() do
                Citizen.Wait(100)
            end

            local status = exports.data:getUserVar("status")
            if status == "spawned" or status == "dead" then
                isSpawned = true
                isDead = (status == "dead")
            end
        end
    )
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("active_blips:refresh")
AddEventHandler(
    "active_blips:refresh",
    function(blips)
        for k, _ in pairs(currentBlips) do
            if not blips[k] then
                if DoesBlipExist(currentBlips[k].blip) then
                    RemoveBlip(currentBlips[k].blip)
                    currentBlips[k] = nil
                end
            end
        end

        for k, v in pairs(blips) do
            updateblip(k, v)
        end
    end
)

RegisterCommand("refresh_blips",
    function(source, args)
        if isSpawned then
            for k, v in pairs(currentBlips) do
                if v.blip and DoesBlipExist(v.blip) then
                    RemoveBlip(v.blip)
                    currentBlips[k] = nil
                end
            end

            exports.notify:display(
                {
                    type = "info",
                    title = "Blipy",
                    text = "Blipy promazány",
                    icon = "fas fa-refresh",
                    length = 5000
                }
            )
        end
    end
)

Citizen.CreateThread(function()
    while true do
        if isSpawned then
            for k, v in pairs(currentBlips) do
                if v.blip and v.attached and not NetworkDoesEntityExistWithNetworkId(v.entityNetId) then
                    RemoveBlip(v.blip)
                    currentBlips[k] = new(v.entityNetId, v.blipData)
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

function updateblip(blipId, data)
    if not currentBlips[blipId] then
        currentBlips[blipId] = {}
    end

    if currentBlips[blipId].blip and DoesBlipExist(currentBlips[blipId].blip) then
        if data.blipData then
            if not currentBlips[blipId].fixedCoords then
                currentBlips[blipId].blipData.coords = data.blipData.coords
                if (not currentBlips[blipId].attached and NetworkDoesEntityExistWithNetworkId(data.entityNetId)) or (currentBlips[blipId].attached and not NetworkDoesEntityExistWithNetworkId(data.entityNetId)) then
                    RemoveBlip(currentBlips[blipId].blip)
                    currentBlips[blipId] = new(data.entityNetId, data.blipData)
                end
                SetBlipCoords(currentBlips[blipId].blip, data.blipData.coords)
                SetBlipRotation(currentBlips[blipId].blip, data.blipData.heading)
            end

            if not IsBlipFlashing(currentBlips[blipId].blip) then
                SetBlipSprite(currentBlips[blipId].blip, data.blipData.sprite)
                SetBlipScale(currentBlips[blipId].blip, data.blipData.scale)
                if data.blipData.flash then
                    SetBlipFlashTimer(currentBlips[blipId].blip, Config.flashTimeout)
                    SetBlipFlashInterval(currentBlips[blipId].blip, 500)
                end
            end

            SetBlipColour(currentBlips[blipId].blip, data.blipData.colour)
            renameExistingBlip({
                blip = currentBlips[blipId].blip,
                text = data.blipData.text
            })
        end
    else
        if data.blipData then
            currentBlips[blipId] = new(data.entityNetId, data.blipData)
        end
    end
end
function new(entityNetId, blipData)
    local blip, attached = nil, false
    if NetworkDoesEntityExistWithNetworkId(entityNetId) then
        blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(entityNetId))
        attached = true
    else
        blip = AddBlipForCoord(blipData.coords)
    end

    if blipData.sprite then
        SetBlipSprite(blip, blipData.sprite)
    else
        SetBlipSprite(blip, 1)
    end

    if blipData.scale then
        SetBlipScale(blip, blipData.scale)
    else
        SetBlipScale(blip, 0.8)
    end

    if blipData.colour then
        SetBlipColour(blip, blipData.colour)
    else
        SetBlipColour(blip, BLIP_COLOUR_WHITE)
    end

    if blipData.display then
        SetBlipDisplay(blip, blipData.display)
    else
        SetBlipDisplay(blip, 4)
    end

    if blipData.isShortRange then
        SetBlipAsShortRange(blip, blipData.isShortRange)
    else
        SetBlipAsShortRange(blip, true)
    end

    if blipData.alpha then
        SetBlipAlpha(blip, blipData.alpha)
    end

    if blipData.friendly then
        SetBlipAsFriendly(blip, blipData.friendly)
    end

    if blipData.isMissionCreatorBlip then
        SetBlipAsMissionCreatorBlip(blip, blipData.isMissionCreatorBlip)
    end

    if blipData.isBright then
        SetBlipBright(blip, blipData.isBright)
    end

    if blipData.category then
        SetBlipCategory(blip, blipData.category)
    end

    if blipData.fade then
        SetBlipFade(blip, blipData.fade.opacity, blipData.fade.duration)
    end

    if blipData.heading then
        SetBlipRotation(blip, blipData.heading)
    end


    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='AMSANSL'>" .. blipData.text .. "</FONT>")
    EndTextCommandSetBlipName(blip)

    if blipData.category then
        SetBlipCategory(blip, blipData.category)
    end

    if blipData.showHeight then
        ShowHeightOnBlip(blip, blipData.showHeight)
    end

    if blipData.showNumber then
        ShowNumberOnBlip(blip, blipData.showNumber)
    end

    if blipData.displayName then
        DisplayPlayerNameTagsOnBlips(blipData.displayName)
    end

    if blipData.priority then
        SetBlipPriority(blip, blipData.priority)
    end

    return { blip = blip, entityNetId = entityNetId, attached = attached, blipData = blipData}
end

createNewKeyMapping({
    command = "toggleAdminBlips",
    text = "Zapnutí/Vypnutí Admin blipu",
    key = "F4"
})
RegisterCommand("toggleAdminBlips", function()
    if exports.data:getUserVar("admin") >= 2 then
        ExecuteCommand("adminblips")
    end
end)