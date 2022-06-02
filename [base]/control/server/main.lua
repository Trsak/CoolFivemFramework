local isdev = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        local tags = GetConvar("tags", false)
        if tags == "DEV" then
            isdev = true
        end
    end
)

function isDev()
    return isdev
end

exports(
    "isDev",
    function()
        return isdev
    end
)
