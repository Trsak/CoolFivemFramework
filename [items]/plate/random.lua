local events = {
    {
        money = 10000,
        guards = {
            {
                seat = 1,
                armor = 100,
                weapon = "weapon_carbinerilfe"
            }
        }
    },
    {
        money = 50000,
        guards = {
            {
                seat = 1,
                armor = 100,
                weapon = "weapon_carbinerilfe"
            },
            {
                seat = 2,
                armor = 100,
                weapon = "weapon_carbinerilfe"
            },
            {
                seat = 3,
                armor = 50,
                weapon = "weapon_pistol"
            }
        }
    }
}

local randomEvent = getRandom(events)
for _, guard in each(randomEvent.guards) do 
    local guardPed = SpawnPed("model_peda")
    SetVehicleSeat(guardPed, guard.seat)
    SetPedArmor(guardPed, guard.armor)
    GiveWeaponToPed(guardPed, guard.weapon)
end