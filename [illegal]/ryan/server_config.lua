ServerConfig = {}

ServerConfig.SpawnCoords = {
    vector4(1010.2815551758, -1935.9543457032, 31.128856658936, 90.678329467774),
    vector4(-291.74810791016, 2528.7087402344, 74.604354858398, 177.41680908204),
    vector4(1072.1407470704, -1288.6123046875, 19.97956085205, 42.673458099366),
    vector4(815.09393310546, -492.29956054688, 30.55078125, 278.20788574218),
    vector4(473.17813110352, -2137.40234375, 5.917534828186, 231.0807800293),
    vector4(-36.972797393798, -1978.442993164, 5.9760055541992, 44.198986053466),
    vector4(166.92903137208, 2228.9680175782, 90.78158569336, 50.810676574708),
    vector4(-1818.2545166016, 4819.3154296875, 4.8518943786622, 129.71258544922),
    vector4(-275.1185913086, -776.998046875, 43.605087280274, 64.528846740722),
    vector4(1626.1977539062, -2285.703125, 106.143699646, 305.02392578125),
    vector4(-1287.9036865234, -250.92553710938, 56.101928710938, 348.14837646484),
    vector4(-673.8369140625, -634.69567871094, 25.301832199096, 3.6805572509766),
    vector4(147.45010375976, -2265.0270996094, 6.081552028656, 3.0344953536988),
    vector4(729.2300415039, -1147.0356445312, 23.234058380126, 181.78536987304),
    vector4(-284.67068481446, 6310.4838867188, 31.49217224121, 65.473426818848),
    vector4(-611.83917236328, 5713.2602539062, 30.360715866088, 331.31475830078),
    vector4(1639.4138183594, 4877.5625, 42.030448913574, 57.006481170654),
    vector4(2273.0849609375, 1995.7200927734, 132.16648864746, 328.4412536621),
    vector4(1545.551147461, 3811.376953125, 30.100351333618, 339.17477416992),
    vector4(-1601.7316894532, 5191.025390625, 4.310091495514, 116.29656982422)
}

ServerConfig.HoursToSpawnIn = { 15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 1, 2 }

ServerConfig.ItemTiers = {
    ["high"] = 1,
    ["mid"] = 2,
    ["low"] = 3
}

ServerConfig.Items = {
    { Name = "weapon_smg_mk2", Type = "ammoWeapon", Min = 1, Max = 2, Tier = "high", Chance = 20, Price = 37500 },
    { Name = "weapon_minismg", Type = "ammoWeapon", Min = 1, Max = 2, Tier = "high", Chance = 20, Price = 25000 },
    { Name = "weapon_bullpupshotgun", Type = "ammoWeapon", Min = 1, Max = 2, Tier = "mid", Chance = 2, Price = 70000 },
    { Name = "weapon_pistol50", Type = "ammoWeapon", Min = 1, Max = 3, Tier = "low", Chance = 3, Price = 6250 },
    { Name = "weapon_snspistol", Type = "ammoWeapon", Min = 1, Max = 3, Tier = "low", Chance = 3, Price = 1872 },
    { Name = "weapon_snspistol_mk2", Type = "ammoWeapon", Min = 1, Max = 2, Tier = "low", Chance = 3, Price = 2500 },
    { Name = "hack_usb", Type = "item", Min = 1, Max = 1, Tier = "low", Chance = 35, Price = 500 },
    { Name = "hack_card", Type = "item", Min = 1, Max = 1, Tier = "low", Chance = 25, Price = 900 },
    { Name = "ammo_pistol", Type = "item", Min = 20, Max = 100, Tier = "low", Chance = 15, Price = 2 },
    { Name = "cigars_estancia", Type = "item", Min = 1, Max = 3, Tier = "low", Chance = 25, Price = 200 },
    { Name = "medium_scope", Type = "item", Min = 1, Max = 2, Tier = "mid", Chance = 2, Price = 5500 },
    { Name = "suppressor", Type = "item", Min = 1, Max = 1, Tier = "high", Chance = 15, Price = 10000 },
    { Name = "grip", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "lockpick", Type = "item", Min = 2, Max = 7, Tier = "low", Chance = 30, Price = 25 },
    { Name = "c4", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 10, Price = 5000 },
    { Name = "small_scope", Type = "item", Min = 1, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "detonator", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 10, Price = 2000 },
    { Name = "thermite", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 5, Price = 30000 },
    { Name = "ammo_shotgun", Type = "item", Min = 10, Max = 50, Tier = "mid", Chance = 8, Price = 5 },
    { Name = "ammo_smg", Type = "item", Min = 30, Max = 80, Tier = "mid", Chance = 8, Price = 7 },
    { Name = "laptop", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 20, Price = 4000 },
    { Name = "drill", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 20, Price = 5000 },
    { Name = "chip_10000", Type = "item", Min = 1, Max = 1, Tier = "mid", Chance = 5, Price = 7500 },
    { Name = "weapon_assaultrifle_mk2", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "high", Chance = 1, Price = 130000 },
    { Name = "weapon_assaultrifle", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "high", Chance = 3, Price = 75000 },
    { Name = "weapon_compactrifle", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "high", Chance = 10, Price = 70000 },
    { Name = "weapon_assaultsmg", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "high", Chance = 3, Price = 100000 },
    { Name = "weapon_sawnoffshotgun", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "mid", Chance = 2, Price = 12500 },
    { Name = "weapon_heavypistol", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "mid", Chance = 15, Price = 18750 },
    { Name = "ammo_rifle", Type = "item", Min = 20, Max = 60, Tier = "mid", Chance = 8, Price = 10 },
    { Name = "weapon_machinepistol", Type = "ammoWeapon", Min = 1, Max = 1, Tier = "high", Chance = 25, Price = 50000 },
    { Name = "weaponspray_army", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_defaultblack", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_gold", Type = "item", Min = 0, Max = 2, Tier = "high", Chance = 2, Price = 3500 },
    { Name = "weaponspray_green", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_lspd", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_mk2bluecontrast", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldbluewhite", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldcyanfeatures", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldgreenfeatures", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldgreenpurple", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldorange", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldpink", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldpurpleyellow", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldredfeatures", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldredwhite", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2boldyellowfeatures", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicbeige", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicblack", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicblue", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicbrownblack", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicearth", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicgray", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicgreen", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classictwotone", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2classicwhite", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicblue", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicgold", Type = "item", Min = 0, Max = 2, Tier = "high", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicgraylilac", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicgreen", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicplatinum", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicpurplelime", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicred", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicredyellow", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2metallicwhiteaqua", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2orangecontrast", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2redcontrast", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_mk2yellowcontrast", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 1, Price = 3500 },
    { Name = "weaponspray_orange", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_pink", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weaponspray_platinum", Type = "item", Min = 0, Max = 2, Tier = "mid", Chance = 2, Price = 3500 },
    { Name = "weapontoolkit", Type = "item", Min = 0, Max = 1, Tier = "high", Chance = 2, Price = 25000 }
}

ServerConfig.WeaponMagazines = {
    weapon_microsmg = {
        { Name = "magazine_microsmg_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_microsmg_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_smg_mk2 = {
        { Name = "magazine_smg_mk2_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_smg_mk2_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_pistol50 = {
        { Name = "magazine_pistol50_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_pistol50_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_snspistol = {
        { Name = "magazine_snspistol_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_snspistol_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_snspistol_mk2 = {
        { Name = "magazine_snspistol_mk2_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_snspistol_mk2_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_minismg = {
        { Name = "magazine_minismg_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_minismg_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_dbshotgun = {
        { Name = "ammo_shotgun", Type = "item", Min = 10, Max = 40, Chance = 8, Price = 3 }
    },
    weapon_bullpupshotgun = {
        { Name = "ammo_shotgun", Type = "item", Min = 10, Max = 40, Chance = 8, Price = 3 }
    },
    weapon_sawnoffshotgun = {
        { Name = "ammo_shotgun", Type = "item", Min = 10, Max = 40, Chance = 8, Price = 3 }
    },
    weapon_assaultrifle = {
        { Name = "magazine_assaultrifle_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_assaultrifle_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 },
        { Name = "magazine_assaultrifle_box", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_assaultrifle_mk2 = {
        { Name = "magazine_assaultrifle_mk2_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_assaultrifle_mk2_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_specialcarbine_mk2 = {
        { Name = "magazine_specialcarbine_mk2_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_specialcarbine_mk2_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_compactrifle = {
        { Name = "magazine_compactrifle_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_compactrifle_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 },
        { Name = "magazine_compactrifle_box", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_assaultsmg = {
        { Name = "magazine_assaultsmg_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_assaultsmg_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_bullpuprifle = {
        { Name = "magazine_bullpuprifle_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_bullpuprifle_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_pumpshotgun = {
        { Name = "ammo_shotgun", Type = "item", Min = 10, Max = 40, Chance = 8, Price = 3 }
    },
    weapon_heavypistol = {
        { Name = "magazine_heavypistol_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_heavypistol_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    },
    weapon_machinepistol = {
        { Name = "magazine_machinepistol_default", Type = "item", Min = 1, Max = 5, Chance = 5, Price = 500 },
        { Name = "magazine_machinepistol_extended", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 },
        { Name = "magazine_machinepistol_box", Type = "item", Min = 1, Max = 2, Chance = 5, Price = 1500 }
    }
}
