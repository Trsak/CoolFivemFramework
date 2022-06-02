local date = os.date("*t")
local secondOfDay = (math.random(0, 22) * 3600) + (math.random(0, 55) * 60) + math.random(0, 55)
local frozen = false

function freezeTime()
    frozen = not frozen
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(2000) -- Every Second, we check these idiots via a time sync with clients.
            TriggerClientEvent("updateFromServerTime", -1, secondOfDay, date, frozen)
            h = math.floor(secondOfDay / 3600)
            m = math.floor((secondOfDay - (h * 3600)) / 60)
            s = secondOfDay - (h * 3600) - (m * 60)
            --TraceMsg("CurrentTime: "..h..":"..m..":"..s)
        end
    end
)

Citizen.CreateThread(
    function()
        local timeBuffer = 0.0
        local h = 0
        local m = 0
        local s = 0
        while true do
            Citizen.Wait(33) -- (int)(GetMillisecondsPerGameMinute() / 60)
            date = os.date("*t") -- Update the in-game date data.
            if not frozen then
                local gameSecond = 33.33 / ss_night_time_speed_mult
                if secondOfDay >= 19800 and secondOfDay <= 75600 then
                    gameSecond = 33.333 / ss_day_time_speed_mult
                end
                timeBuffer = timeBuffer + round(33.0 / gameSecond, 4)
                if timeBuffer >= 1.0 then
                    local skipSeconds = math.floor(timeBuffer)
                    timeBuffer = timeBuffer - skipSeconds
                    secondOfDay = secondOfDay + skipSeconds
                    if secondOfDay >= 86400 then
                        secondOfDay = secondOfDay % 86400
                    end
                end
            end
            h = math.floor(secondOfDay / 3600)
            m = math.floor((secondOfDay - (h * 3600)) / 60)
            s = secondOfDay - (h * 3600) - (m * 60)
            secondOfDay = (h * 3600) + (m * 60) + s
        end
    end
)

RegisterCommand(
    "time",
    function(source, args, rawCommand)
        local _source = source
        if _source == 0 then
            if args[1] and args[2] and tonumber(args[1]) and tonumber(args[2]) then
                ProcessTimeCommand(args[1], args[2])
                h = math.floor(secondOfDay / 3600)
                m = math.floor((secondOfDay - (h * 3600)) / 60)
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "success",
                        args = { "Správný formát je /time <hour> <minute>" }
                    }
                )
            end
        else
            if exports.data:getUserVar(_source, "admin") > 1 then
                if args[1] and args[2] and tonumber(args[1]) and tonumber(args[2]) then
                    ProcessTimeCommand(args[1], args[2])
                    h = math.floor(secondOfDay / 3600)
                    m = math.floor((secondOfDay - (h * 3600)) / 60)

                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(70, 130, 180, 0.75); border-left: 10px solid rgb(70, 130, 180);">Nastavil jsi čas na {0}:{1}</div>',
                            args = {string.format("%02d", args[1]), string.format("%02d", args[2]) }
                        }
                    )

                    exports.logs:sendToDiscord(
                        {
                            channel = "admin-commands",
                            title = "Čas",
                            description = "Nastavil čas na " .. table.concat(args, " "),
                            color = "34749"
                        },
                        _source
                    )
                else
                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            templateId = "success",
                            args = { "Správný formát je /time <hour> <minute>" }
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "success",
                        args = { "Na toto nemáš právo!" }
                    }
                )
            end
        end
    end,
    false
)

RegisterCommand(
    "freezetime",
    function(source, args, rawCommand)
        local _source = source
        h = math.floor(secondOfDay / 3600)
        m = math.floor((secondOfDay - (h * 3600)) / 60)

        if _source == 0 then
            freezeTime()

            local freezeText = "pozastaven"
            if not frozen then
                freezeText = "opět spuštěn"
            end

            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(70, 130, 180, 0.75); border-left: 10px solid rgb(70, 130, 180);">Aktuální čas byl ' .. freezeText .. "</div>",
                    args = {}
                }
            )
        else
            if exports.data:getUserVar(_source, "admin") > 1 then
                exports.logs:sendToDiscord(
                    {
                        channel = "admin-commands",
                        title = "Zmrazení času",
                        description = "Zmrazil čas",
                        color = "34749"
                    },
                    _source
                )

                freezeTime()

                local freezeText = "pozastavil"
                if not frozen then
                    freezeText = "zrušil pozastavení pro"
                end

                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(70, 130, 180, 0.75); border-left: 10px solid rgb(70, 130, 180);"><strong>ČAS </strong>Úspěšně jsi ' .. freezeText .. " čas</div>",
                        args = {  }
                    }
                )
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "success",
                        args = { "Na toto nemáš právo!" }
                    }
                )
            end
        end
    end,
    false
)

function ProcessTimeCommand(arg1, arg2)
    local h = 0
    local m = 0
    local argh = tonumber(arg1)
    local argm = tonumber(arg2)
    if argh < 24 and argh then
        h = argh
    else
        h = 0
    end
    if argm < 60 and arm then
        m = argm
    else
        m = 0
    end
    secondOfDay = (tonumber(h) * 3600) + (tonumber(m) * 60) + 0
end
