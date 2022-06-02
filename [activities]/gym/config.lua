Config = {}

Config.Exercises = {
    ["Kliky"] = {
        idleDict = "amb@world_human_push_ups@male@idle_a",
        idleAnim = "idle_c",
        actionDict = "amb@world_human_push_ups@male@base",
        actionAnim = "base",
        actionTime = 1100,
        enterDict = "amb@world_human_push_ups@male@enter",
        enterAnim = "enter",
        enterTime = 3050,
        exitDict = "amb@world_human_push_ups@male@exit",
        exitAnim = "exit",
        exitTime = 3400,
        actionProcent = 3,
        actionProcentTimes = 5,
        skills = {
            strength = 0.3,
            stamina = 0.1
        }
    },
    ["Sedy lehy"] = {
        idleDict = "amb@world_human_sit_ups@male@idle_a",
        idleAnim = "idle_a",
        actionDict = "amb@world_human_sit_ups@male@base",
        actionAnim = "base",
        actionTime = 3400,
        enterDict = "amb@world_human_sit_ups@male@enter",
        enterAnim = "enter",
        enterTime = 4200,
        exitDict = "amb@world_human_sit_ups@male@exit",
        exitAnim = "exit",
        exitTime = 3700,
        actionProcent = 5,
        actionProcentTimes = 5,
        skills = {
            strength = 0.2,
            stamina = 0.2
        }
    },
    ["Shyby"] = {
        idleDict = "amb@prop_human_muscle_chin_ups@male@idle_a",
        idleAnim = "idle_a",
        actionDict = "amb@prop_human_muscle_chin_ups@male@base",
        actionAnim = "base",
        actionTime = 3000,
        enterDict = "amb@prop_human_muscle_chin_ups@male@enter",
        enterAnim = "enter",
        enterTime = 1600,
        exitDict = "amb@prop_human_muscle_chin_ups@male@exit",
        exitAnim = "exit",
        exitTime = 3700,
        actionProcent = 4,
        actionProcentTimes = 5,
        skills = {
            strength = 0.25,
            stamina = 0.15
        }
    }
}

Config.Locations = {
    -- Vespucci Beach Gym
    {Coords = vec4(-1200.08, -1571.15, 4.6115, 214.37), Exercise = "Shyby"},
    {Coords = vec4(-1205.01, -1560.06, 4.61 - 0.98, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(-1203.30, -1570.67, 4.60 - 0.98, 0.0), Exercise = "Kliky"},
    {Coords = vec4(-1200.40, -1564.32, 4.61 - 0.98, 0.0), Exercise = "Kliky"},
    {Coords = vec4(-1196.43, -1568.73, 4.61 - 0.98, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(-1204.76, -1564.40, 4.60, 32.14), Exercise = "Shyby"},
    -- Bolingbroke Penitentiary
    {Coords = vec4(1643.14, 2527.88, 44.06, 225.13), Exercise = "Shyby"},
    {Coords = vec4(1648.85, 2529.75, 44.06, 224.16), Exercise = "Shyby"},
    {Coords = vec4(1641.86, 2519.85, 44.06, 0.0), Exercise = "Kliky"},
    {Coords = vec4(1634.79, 2524.90, 44.06, 0.0), Exercise = "Sedy lehy"},
    -- LSSD Sandy Shores
    {Coords = vec4(1833.23, 3678.06, 29.7, 164.1351011331836), Exercise = "Kliky"},
    {Coords = vec4(1829.93, 3677.90, 29.7, 224.16), Exercise = "Sedy lehy"},
    {Coords = vec4(1830.09, 3676.37, 29.7, 295.92), Exercise = "Shyby"},
    -- LSPD Vespucci
    {Coords = vec4(-1104.039673, -838.350220, 26.827585, 125.00), Exercise = "Shyby"},
    {Coords = vec4(-1105.166016, -836.902344, 26.827557, 125.00), Exercise = "Shyby"},
    {Coords = vec4(-1108.975342, -836.290039, 26.847427 - 0.98, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(-1110.471436, -837.482422, 26.847418 - 0.98, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(-1100.220947, -839.833862, 26.847912 - 0.98, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(-1105.480591, -834.180542, 26.827578 - 0.98, 0.0), Exercise = "Kliky"},
    {Coords = vec4(-1100.685669, -846.958069, 26.827578 - 0.98, 0.0), Exercise = "Kliky"},
    {Coords = vec4(-1097.668701, -842.032043, 26.827578 - 0.98, 0.0), Exercise = "Kliky"},
    -- Paleto Bay Opičí dráha
    {Coords = vec4(75.643036, 6900.791016, 13.838606, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(75.598274, 6901.868652, 13.797314, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(78.445702, 6895.313965, 14.381229, 0.0), Exercise = "Sedy lehy"},
    {Coords = vec4(75.222137, 6892.853516, 14.240383, 0.0), Exercise = "Kliky"},
    {Coords = vec4(73.200592, 6894.329590, 14.130930, 0.0), Exercise = "Kliky"},
    {Coords = vec4(71.849762, 6896.198242, 13.971716, 0.0), Exercise = "Kliky"},
    -- Artix JFC Fight Club
    {Coords = vec4(1076.8099365234, -2385.5603027344, 25.892726898194, 98.544067382812), Exercise = "Kliky"},
    {Coords = vec4(1075.5411376954, -2383.3464355468, 25.892734527588, 99.217491149902), Exercise = "Kliky"},
    {Coords = vec4(1075.5411376954, -2383.3464355468, 25.892734527588, 99.217491149902), Exercise = "Sedy lehy"},
    {Coords = vec4(1072.6867675782, -2385.3366699218, 25.892738342286, 177.87536621094), Exercise = "Sedy lehy"},
    {Coords = vec4(1071.967163086, -2389.46875, 25.892738342286, 168.57354736328), Exercise = "Sedy lehy"},
    {Coords = vec4(1071.4714355468, -2393.1110839844, 25.892738342286, 66.80428314209), Exercise = "Kliky"},
    -- Mission Row - alespon neco
    {Coords = vec4(440.88571166992, -980.03240966796, 34.971752166748, 268.10083007812), Exercise = "Kliky"},
    {Coords = vec4(441.61367797852, -977.92889404296, 34.971752166748, 286.15124511718), Exercise = "Kliky"},
    {Coords = vec4(444.61459350586, -979.19384765625, 34.971744537354, 245.96057128906), Exercise = "Sedy lehy"},
    -- Jail
    {Coords = vec4(1716.8308105468, 2521.6352539062, 45.573608398438, 124.72441101074), Exercise = "Sedy lehy"},
    {Coords = vec4(1710.3956298828, 2518.2197265625, 45.573608398438, 303.30709838868), Exercise = "Sedy lehy"},
    {Coords = vec4(1718.0439453125, 2518.7077636718, 45.573608398438, 124.72441101074), Exercise = "Kliky"},
    {Coords = vec4(1712.0834960938, 2515.8198242188, 45.573608398438, 303.30709838868), Exercise = "Kliky"},
}

Config.Blips = {
    vec3(-1201.00, -1568.39, 4.61)
}
