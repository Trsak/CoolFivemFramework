Config = {}

Config.WhitelistedJobTypes = {
    police = true,
    medic = true
}

Config.Sound = vector3(246.72, 220.93, 108.05)

Config.Points = {
    {
        -- Main doors
        Coords = vec3(256.975739, 220.609161, 106.285309),
        Prop = GetHashKey("hei_v_ilev_bk_gate_pris"),
        DoorLockID = 1,
        Actions = {
            Smoke = vec3(257.39, 221.20, 106.29),
            Thermite = vec4(257.40, 220.20, 106.35, 336.48)
        }
    },
    {
        -- Hack and Thermite
        Coords = vec3(261.920288, 221.722305, 106.284523),
        Prop = GetHashKey("hei_v_ilev_bk_gate2_pris"),
        DoorLockID = 3,
        Actions = {
            Smoke = vec3(261.763214, 222.402328, 106.383813),
            Thermite = vec4(261.754883, 221.376358, 106.387917, 249.731),
            Hack = vec4(262.65, 222.75, 105.90, 244.19)
        }
    },
    {
        -- Main for Silent
        Coords = vec3(237.100250, 228.001862, 106.286751),
        DoorLockID = 2,
        Actions = {
            Lockpick = vec4(236.419022, 227.746368, 106.286896, 348.56)
        }
    },
    {
        -- Hack
        Coords = vec3(252.879105, 228.562439, 101.676491),
        Actions = {
            Hack = vec4(253.34, 228.25, 101.39, 63.60)
        }
    },
    {
        -- First doors in vault
        Coords = vec3(252.472519, 220.874496, 101.683479),
        Prop = GetHashKey("hei_v_ilev_bk_safegate_pris"),
        DoorLockID = 4,
        Actions = {
            Smoke = vec3(252.985, 221.70, 101.72),
            Thermite = vec4(252.95, 220.70, 101.76, 160.0)
        }
    }
}

Config.ModelSwaps = {
    [GetHashKey("hei_v_ilev_bk_gate_pris")] = GetHashKey("hei_v_ilev_bk_gate_molten"),
    [GetHashKey("hei_v_ilev_bk_gate2_pris")] = GetHashKey("hei_v_ilev_bk_gate2_molten"),
    [GetHashKey("hei_v_ilev_bk_safegate_pris")] = GetHashKey("hei_v_ilev_bk_safegate_molten")
}

Config.Models = {
    gold = GetHashKey("ch_prop_gold_trolly_01c"),
    money = GetHashKey("hei_prop_hei_cash_trolly_01")
}

Config.TrollyPlaces = {
    vec4(249.631729, 218.509598, 100.683350, 286.09),
    vec4(262.525513, 213.114990, 100.683464, 353.46),
    vec4(263.876770, 215.720245, 100.683464, 127.94),
    vec4(260.680969, 217.036621, 100.683464, 140.48),
}