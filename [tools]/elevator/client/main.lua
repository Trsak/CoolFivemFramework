local isSpawned, isDead = false, false
local isDisplayingHint = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
        for i, elevator in each(Config.Elevators) do
            for label, coords in pairs(elevator) do
                exports.target:AddCircleZone(
                    "elevator-" .. i .. "-floor-" .. label,
                    vec3(coords.xy, coords.z + 0.5),
                    1.0,
                    {
                        actions = {
                            action = {
                                cb = function(data)
                                    if not WarMenu.IsAnyMenuOpened() then
                                        openElevatorMenu(data.Elevator, data.CurrentFloor)
                                    end
                                end,
                                cbData = {Elevator = elevator, CurrentFloor = label},
                                icon = "fas fa-list-ol",
                                label = label
                            }
                        },
                        distance = 1.0
                    }
                )
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead = false, false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

function openElevatorMenu(elevator, currentFloor)
    WarMenu.CreateMenu("elevator", "Výtah", "Zvolte podlaží")
    WarMenu.OpenMenu("elevator")
    while WarMenu.IsMenuOpened("elevator") do
        for label, coords in pairsByKeys(elevator) do
            if WarMenu.Button(label, label == currentFloor and "Aktuální" or nil) then
                if label == currentFloor then
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Výtah",
                            text = "Již jsi v tomto patře!",
                            icon = "fas fa-list-ol",
                            length = 3000
                        }
                    )
                else
                    SetEntityCoords(PlayerPedId(), coords.xyz)
                    SetEntityHeading(PlayerPedId(), coords.w)
                    WarMenu.CloseMenu()
                end
            end
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end