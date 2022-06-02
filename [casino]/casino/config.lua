Config = {}

Config.Blip = {
    coords = vec3(931.519714, 43.515938, 81.088944),
    sprite = 679,
    display = 4,
    scale = 1.2,
    colour = 0,
    isShortRange = true,
    text = "Kasíno"
}

Config.ChipsPeds = {
    vector4(948.55206298828, 32.36018371582, 70.838455200196, 81.090286254882),
    vector4(949.1, 33.8, 70.838607788086, 68.284561157226),
    vector4(950.3, 35.0, 70.838607788086, 29.282768249512)
}

Config.Vehicle = {
    Coords = vec3(935.054810, 42.261760, 72.525024 + 0.05),
    Colors = {
        Primary = 88,
        Secondary = 41
    },
    Livery = 0,
    Model = "locust"
}

Config.ChipsPedsModels = {
    "u_f_m_casinocash_01",
    "u_f_m_casinoshop_01",
    "u_f_m_debbie_01"
}

Config.ChipSeatsPos = vec3(950.847230, 32.544490, 71.838738)

--
-- Video shown on screen. Default is "CASINO_DIA_PL".
--
-- CASINO_DIA_PL    - Falling Diamonds
-- CASINO_HLW_PL    - Falling Skulls
-- CASINO_SNWFLK_PL - Falling Snowflakes
--
Config.VideoType = "CASINO_DIA_PL"
