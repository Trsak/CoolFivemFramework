Config = {}

Config.ReduceTimer = 60000

Config.Needs = {
    hunger = {
        min = 0.0,
        max = 100.0,
        default = 100.0,
        reducer = 0.38,
        healthDamage = 1
    },
    thirst = {
        min = 0.0,
        max = 100.0,
        default = 100.0,
        reducer = 0.42,
        healthDamage = 1
    },
    drunk = {
        min = 0.0,
        max = 100.0,
        default = 0.0,
        reducer = 2.0
    },
    stress = {
        min = 0.0,
        max = 100.0,
        default = 0.0,
        reducer = 5.5
    },
    coke = {
        min = 0.0,
        max = 30.0,
        default = 0.0,
        reducer = 1.0
    },
    meth = {
        min = 0.0,
        max = 30.0,
        default = 0.0,
        reducer = 1.0
    }
}

Config.DrunkVehActions = {
	{Int = 27, Time = 3000},
	{Int = 6, Time = 2000},
	{Int = 7, Time = 1600}, --turn left and accel
	{Int = 8, Time = 1600}, --turn right and accel
	{Int = 10, Time = 1600}, --turn left and restore wheel pos
	{Int = 11, Time = 1600}, --turn right and restore wheel pos
	{Int = 23, Time = 4000}, -- accel fast
	{Int = 31, Time = 4000} -- accel fast and then handbrake 
}