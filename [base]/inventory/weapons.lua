Config.Weapons = {
    --Melee
    ["weapon_unarmed"] = {
        label = "Pěsti",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Síla",
        weight = 0.0,
        hash = GetHashKey("weapon_unarmed")
    },
    ["weapon_katana"] = {
        label = "Katana",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Katana",
        weight = 1.0,
        hash = GetHashKey("weapon_katana")
    },
    ["weapon_flashlight"] = {
        label = "Baterka",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Baterka",
        weight = 0.85,
        hash = GetHashKey("weapon_flashlight")
    },
    ["weapon_nightstick"] = {
        label = "Obušek",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Obušek",
        weight = 0.1,
        hash = GetHashKey("weapon_nightstick")
    },
    ["weapon_dagger"] = {
        label = "Dýka",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Dýka",
        weight = 0.45,
        hash = GetHashKey("weapon_dagger")
    },
    ["weapon_bat"] = {
        label = "Baseballová pálka",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Baseballová pálka",
        weight = 0.9,
        hash = GetHashKey("weapon_bat")
    },
    ["weapon_dildobat"] = {
        label = "Dildo pálka",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Dildo pálka",
        weight = 0.9,
        hash = GetHashKey("weapon_dildobat")
    },
    ["weapon_bottle"] = {
        label = "Rozbitá láhev",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Rozbitá láhev",
        weight = 0.2,
        hash = GetHashKey("weapon_bottle")
    },
    ["weapon_crowbar"] = {
        label = "Páčidlo",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Páčidlo",
        weight = 0.6,
        hash = GetHashKey("weapon_crowbar")
    },
    ["weapon_hatchet"] = {
        label = "Sekera",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Sekera",
        weight = 0.6,
        hash = GetHashKey("weapon_hatchet")
    },
    ["weapon_battleaxe"] = {
        label = "BattleAxe",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "BattleAxe",
        weight = 0.6,
        hash = GetHashKey("weapon_battleaxe")
    },
    ["weapon_stone_hatchet"] = {
        label = "Kamená Sekera",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Kamena Sekera",
        weight = 0.6,
        hash = GetHashKey("weapon_stone_hatchet")
    },
    ["weapon_knife"] = {
        label = "Nůž",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Nůž",
        weight = 0.2,
        hash = GetHashKey("weapon_knife")
    },
    ["weapon_golfclub"] = {
        label = "Golfová hůl",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Golfová hůl",
        weight = 2.5,
        hash = GetHashKey("weapon_golfclub")
    },
    ["weapon_machete"] = {
        label = "Mačeta",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Mačeta",
        weight = 1.15,
        hash = GetHashKey("weapon_machete")
    },
    ["weapon_knuckle"] = {
        label = "Boxer",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Boxer",
        weight = 0.15,
        hash = GetHashKey("weapon_knuckle")
    },
    ["weapon_switchblade"] = {
        label = "Vystřelovací nůž",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Vystřelovací nůž",
        weight = 0.15,
        hash = GetHashKey("weapon_switchblade")
    },
    ["weapon_hammer"] = {
        label = "Kladivo",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Kladivo",
        weight = 0.4,
        hash = GetHashKey("weapon_hammer")
    },
    ["weapon_wrench"] = {
        label = "Klíč",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Klíč",
        weight = 1.0,
        hash = GetHashKey("weapon_wrench")
    },
    ["weapon_poolcue"] = {
        label = "Lusil",
        hasAmmo = false,
        hasClip = false,
        isMelee = true,
        ammoType = "Lusil",
        weight = 1.0,
        hash = GetHashKey("weapon_poolcue")
    },
    --HandGuns
    ["weapon_pistol"] = {
        label = "[Shrewsbury] Endurance Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.1,
        hash = GetHashKey("weapon_pistol")
    },
    ["weapon_pistol_mk2"] = {
        label = "[Hawk & Little] Pistol Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.5,
        hash = GetHashKey("weapon_pistol_mk2")
    },
    ["weapon_combatpistol"] = {
        label = "[Vom Feuer] Combat Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.65,
        hash = GetHashKey("weapon_combatpistol")
    },
    ["weapon_appistol"] = {
        label = "[Vom Feuer] AP Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.65,
        hash = GetHashKey("weapon_appistol")
    },
    ["weapon_stungun"] = {
        label = "[Coil] Stun Gun",
        hasAmmo = false,
        hasClip = false,
        isGun = true,
        ammoType = "Taser",
        weight = 0.15,
        hash = GetHashKey("weapon_stungun")
    },
    ["weapon_pistol50"] = {
        label = "[Hawk & Little] Pistol .50",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.65,
        hash = GetHashKey("weapon_pistol50")
    },
    ["weapon_snspistol"] = {
        label = "[Shrewsbury] SNS Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.35,
        hash = GetHashKey("weapon_snspistol")
    },
    ["weapon_snspistol_mk2"] = {
        label = "[Shrewsbury] SNS Pistol Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.7,
        hash = GetHashKey("weapon_snspistol_mk2")
    },
    ["weapon_heavypistol"] = {
        label = "[Hawk & Little] Pistol .45",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.1,
        hash = GetHashKey("weapon_heavypistol")
    },
    ["weapon_vintagepistol"] = {
        label = "[Vom Feuer] Vintage Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 0.9,
        hash = GetHashKey("weapon_vintagepistol")
    },
    ["weapon_revolver"] = {
        label = "[Hawk & Little] Heavy Revolver",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_revolver")
    },
    ["weapon_revolver_mk2"] = {
        label = "[Hawk & Little] Heavy Revolver Mk II",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_revolver_mk2")
    },
    ["weapon_marksmanpistol"] = {
        label = "[Hawk & Little] Marksman Pistol",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_marksmanpistol")
    },
    ["weapon_doubleaction"] = {
        label = "[D.D.P.] Double-Action Revolver",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_doubleaction")
    },
    ["weapon_ceramicpistol"] = {
        label = "[Vom Feuer] Ceramic Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_ceramicpistol")
    },
    ["weapon_navyrevolver"] = {
        label = "[D.D.P.] Navy Revolver",
        hasAmmo = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_navyrevolver")
    },
    ["weapon_gadgetpistol"] = {
        label = "[Vom Feuer] Perico Pistol",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_PISTOL"),
        weight = 1.25,
        hash = GetHashKey("weapon_gadgetpistol")
    },
    ["weapon_paintballgun"] = {
        label = "Paintball Pistole",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_PAINTBALLS"),
        weight = 0.75,
        hash = GetHashKey("weapon_paintballgun")
    },
    --Submachine
    ["weapon_machinepistol"] = {
        label = "[Vom Feuer] Machine Pistol",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 0.7,
        hash = GetHashKey("weapon_machinepistol")
    },
    ["weapon_microsmg"] = {
        label = "[Shrewsbury] Micro SMG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 2.0,
        hash = GetHashKey("weapon_microsmg")
    },
    ["weapon_assaultsmg"] = {
        label = "[Vom Feuer] Assault SMG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 2.0,
        hash = GetHashKey("weapon_assaultsmg")
    },
    ["weapon_combatpdw"] = {
        label = "[Coil] Combat PDW",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 2.0,
        hash = GetHashKey("weapon_combatpdw")
    },
    ["weapon_smg"] = {
        label = "[Hawk & Little] SMG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 3.0,
        hash = GetHashKey("weapon_smg")
    },
    ["weapon_minismg"] = {
        label = "[Hawk & Little] Mini SMG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 2.0,
        hash = GetHashKey("weapon_minismg")
    },
    ["weapon_smg_mk2"] = {
        label = "[Hawk & Little] SMG Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SMG"),
        weight = 2.8,
        hash = GetHashKey("weapon_smg_mk2")
    },
    --Shotguns
    ["weapon_pumpshotgun"] = {
        label = "[Shrewsbury] Pump Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 3.0,
        hash = GetHashKey("weapon_pumpshotgun")
    },
    ["weapon_pumpshotgun_mk2"] = {
        label = "[Vom Feuer] Pump Shotgun Mk II",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 3.5,
        hash = GetHashKey("weapon_pumpshotgun_mk2")
    },
    ["weapon_sawnoffshotgun"] = {
        label = "[Shrewsbury] Sawed-off Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 3.5,
        hash = GetHashKey("weapon_sawnoffshotgun")
    },
    ["weapon_assaultshotgun"] = {
        label = "[Vom Feuer] Assault Shotgun",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 3.75,
        hash = GetHashKey("weapon_assaultshotgun")
    },
    ["weapon_bullpupshotgun"] = {
        label = "[Hawk & Little] Bullpup Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 4.0,
        hash = GetHashKey("weapon_bullpupshotgun")
    },
    ["weapon_musket"] = {
        label = "[D.D.P.] Musket",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_HUNTING"),
        weight = 4.0,
        hash = GetHashKey("weapon_musket")
    },
    ["weapon_heavyshotgun"] = {
        label = "[Shrewsbury] Heavy Shotgun",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 5.0,
        hash = GetHashKey("weapon_heavyshotgun")
    },
    ["weapon_dbshotgun"] = {
        label = "[Hawk & Little] Double Barrel Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 2.0,
        hash = GetHashKey("weapon_dbshotgun")
    },
    ["weapon_autoshotgun"] = {
        label = "[Shrewsbury] Sweeper Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 2.0,
        hash = GetHashKey("weapon_autoshotgun")
    },
    ["weapon_combatshotgun"] = {
        label = "[Vom Feuer] Combat Shotgun",
        hasAmmo = true,
        hasClip = false,
        isGun = true,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        weight = 2.0,
        hash = GetHashKey("weapon_combatshotgun")
    },
    --Rifles
    ["weapon_assaultrifle"] = {
        label = "[Shrewsbury] Assault Rifle Classic",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 4.75,
        hash = GetHashKey("weapon_assaultrifle")
    },
    ["weapon_assaultrifle_mk2"] = {
        label = "[Shrewsbury] Assault Rifle Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 4.5,
        hash = GetHashKey("weapon_assaultrifle_mk2")
    },
    ["weapon_carbinerifle"] = {
        label = "[Vom Feuer] Carbine Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 4.0,
        hash = GetHashKey("weapon_carbinerifle")
    },
    ["weapon_carbinerifle_mk2"] = {
        label = "[Vom Feuer] Carbine Rifle Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 3.5,
        hash = GetHashKey("weapon_carbinerifle_mk2")
    },
    ["weapon_advancedrifle"] = {
        label = "[Vom Feuer] Advanced Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 4.0,
        hash = GetHashKey("weapon_advancedrifle")
    },
    ["weapon_specialcarbine"] = {
        label = "[Vom Feuer] Special Carbine",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 3.8,
        hash = GetHashKey("weapon_specialcarbine")
    },
    ["weapon_specialcarbine_mk2"] = {
        label = "[Vom Feuer] Special Carbine Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 3.5,
        hash = GetHashKey("weapon_specialcarbine_mk2")
    },
    ["weapon_bullpuprifle"] = {
        label = "[Hawk & Little] Bullpup Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 3.8,
        hash = GetHashKey("weapon_bullpuprifle")
    },
    ["weapon_bullpuprifle_mk2"] = {
        label = "[Hawk & Little] Bullpup Rifle Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 3.2,
        hash = GetHashKey("weapon_bullpuprifle_mk2")
    },
    ["weapon_compactrifle"] = {
        label = "[Shrewsbury] Not-so-Compact Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 2.5,
        hash = GetHashKey("weapon_compactrifle")
    },
    ["weapon_militaryrifle"] = {
        label = "[Vom Feuer] Military Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 2.5,
        hash = GetHashKey("weapon_militaryrifle")
    },
    ["weapon_sniperrifle"] = {
        label = "[Shrewsbury] Hunting Rifle",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_HUNTING"),
        weight = 4.5,
        hash = GetHashKey("weapon_sniperrifle")
    },
    -- Light Machine Guns
    ["weapon_mg"] = {
        label = "[Shrewsbury] MG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 10.8,
        hash = GetHashKey("weapon_mg")
    },
    ["weapon_combatmg"] = {
        label = "[Hawk & Little] Combat MG",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 13.2,
        hash = GetHashKey("weapon_combatmg")
    },
    ["weapon_combatmg_mk2"] = {
        label = "[Hawk & Little] Combat MG Mk II",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 12.5,
        hash = GetHashKey("weapon_combatmg_mk2")
    },
    ["weapon_gusenberg"] = {
        label = "[D.D.P] Gusenberg Sweeper",
        hasAmmo = true,
        hasClip = true,
        isGun = true,
        ammoType = GetHashKey("AMMO_RIFLE"),
        weight = 7.5,
        hash = GetHashKey("weapon_gusenberg")
    },
    --HeavyWeapons
    ["weapon_firework"] = {
        label = "Pyrotechnický Raketomet",
        hasAmmo = true,
        hasClip = false,
        isThrowable = false,
        ammoType = GetHashKey("AMMO_FIREWORK"),
        weight = 2.0,
        hash = GetHashKey("weapon_firework")
    },
    -- Other
    ["gadget_parachute"] = {
        label = "Padák",
        hasAmmo = false,
        hasClip = false,
        isThrowable = false,
        ammoType = "Padák",
        weight = 10.0,
        hash = GetHashKey("gadget_parachute")
    },
    ["weapon_digiscanner"] = {
        label = "Digitální Skenr",
        hasAmmo = false,
        hasClip = false,
        isThrowable = false,
        ammoType = "Digitální Skenr",
        weight = 3.0,
        hash = GetHashKey("weapon_digiscanner")
    },
    ["weapon_flaregun"] = {
        label = "Signální Pistole",
        hasAmmo = true,
        hasClip = false,
        isThrowable = false,
        ammoType = GetHashKey("AMMO_FLAREGUN"),
        weight = 1.2,
        hash = GetHashKey("weapon_flaregun")
    },
    -- Throwables
    ["weapon_flare"] = {
        label = "Světlice",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = "flare",
        weight = 1.2,
        hash = GetHashKey("weapon_flare")
    },
    ["weapon_ball"] = {
        label = "Míček",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = "ball",
        weight = 0.2,
        hash = GetHashKey("weapon_ball")
    },
    ["weapon_snowball"] = {
        label = "Sněhová koule",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = "snowball",
        weight = 0.2,
        hash = GetHashKey("weapon_snowball")
    },
    ["weapon_molotov"] = {
        label = "Molotov",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = "molotov",
        weight = 0.2,
        hash = GetHashKey("weapon_molotov")
    },
    ["weapon_flashbang"] = {
        label = "Flashbang",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = "flashbang",
        weight = 0.2,
        hash = GetHashKey("weapon_flashbang")
    },
    ["weapon_smokegrenade"] = {
        label = "Kouřový granát",
        hasAmmo = false,
        hasClip = false,
        isThrowable = true,
        ammoType = GetHashKey("weapon_smokegrenade"),
        weight = 0.2,
        hash = GetHashKey("weapon_smokegrenade")
    },
    -- Miscellaneous
    ["weapon_petrolcan"] = {
        label = "Kanystr",
        hasAmmo = true,
        hasClip = false,
        isTank = true,
        ammoType = "Kanystr",
        maxAmmo = 5000,
        weight = 10.2,
        hash = GetHashKey("weapon_petrolcan")
    },
    ["weapon_fireextinguisher"] = {
        label = "Hasičák",
        hasAmmo = true,
        hasClip = false,
        isTank = true,
        ammoType = "Hasičák",
        maxAmmo = 5000,
        weight = 15.0,
        hash = GetHashKey("weapon_fireextinguisher")
    }
}

Config.Magazines = {
    -- Pistols
    ["magazine_pistol_default"] = {
        ammo = 12,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_pistol_extended"] = {
        ammo = 16,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_combatpistol_default"] = {
        ammo = 17,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_combatpistol_extended"] = {
        ammo = 33,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_appistol_default"] = {
        ammo = 18,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_appistol_extended"] = {
        ammo = 36,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_pistol50_default"] = {
        ammo = 7,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_pistol50_extended"] = {
        ammo = 12,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_snspistol_default"] = {
        ammo = 6,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_snspistol_extended"] = {
        ammo = 12,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_snspistol_mk2_default"] = {
        ammo = 6,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_snspistol_mk2_extended"] = {
        ammo = 12,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_heavypistol_default"] = {
        ammo = 7,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_heavypistol_extended"] = {
        ammo = 15,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_pistol_mk2_default"] = {
        ammo = 12,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_pistol_mk2_extended"] = {
        ammo = 30,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_ceramicpistol_default"] = {
        ammo = 12,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_ceramicpistol_extended"] = {
        ammo = 17,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_vintagepistol_default"] = {
        ammo = 7,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_vintagepistol_extended"] = {
        ammo = 12,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_PISTOL")
    },
    ["magazine_machinepistol_default"] = {
        ammo = 10,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_machinepistol_extended"] = {
        ammo = 20,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_machinepistol_box"] = {
        ammo = 30,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_paintballgun_default"] = {
        ammo = 50,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_PAINTBALLS")
    },
    -- SMGs
    ["magazine_minismg_default"] = {
        ammo = 10,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_minismg_extended"] = {
        ammo = 20,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_smg_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_smg_extended"] = {
        ammo = 60,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_smg_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_smg_mk2_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_smg_mk2_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_microsmg_default"] = {
        ammo = 20,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_microsmg_extended"] = {
        ammo = 32,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_assaultsmg_default"] = {
        ammo = 20,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_assaultsmg_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_combatpdw_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_combatpdw_extended"] = {
        ammo = 40,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SMG")
    },
    ["magazine_combatpdw_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_SMG")
    },
    -- Rifles
    ["magazine_assaultrifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_assaultrifle_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_assaultrifle_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_carbinerifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_carbinerifle_extended"] = {
        ammo = 40,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_carbinerifle_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_advancedrifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_advancedrifle_extended"] = {
        ammo = 40,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_specialcarbine_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_specialcarbine_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_specialcarbine_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_specialcarbine_mk2_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_specialcarbine_mk2_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_bullpuprifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_bullpuprifle_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_bullpuprifle_mk2_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_bullpuprifle_mk2_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_assaultrifle_mk2_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_assaultrifle_mk2_extended"] = {
        ammo = 40,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_carbinerifle_mk2_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_carbinerifle_mk2_extended"] = {
        ammo = 40,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_militaryrifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_militaryrifle_extended"] = {
        ammo = 45,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_compactrifle_default"] = {
        ammo = 30,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_compactrifle_extended"] = {
        ammo = 60,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_compactrifle_box"] = {
        ammo = 100,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    -- Machine Guns
    ["magazine_mg_default"] = {
        ammo = 75,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_mg_extended"] = {
        ammo = 100,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_combatmg_default"] = {
        ammo = 100,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_combatmg_extended"] = {
        ammo = 200,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_combatmg_mk2_default"] = {
        ammo = 100,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_combatmg_mk2_extended"] = {
        ammo = 200,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_gusenberg_default"] = {
        ammo = 50,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_gusenberg_extended"] = {
        ammo = 100,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    -- Shotguns
    ["magazine_assaultshotgun_default"] = {
        ammo = 8,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SHOTGUN")
    },
    ["magazine_assaultshotgun_extended"] = {
        ammo = 32,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SHOTGUN")
    },
    ["magazine_heavyshotgun_default"] = {
        ammo = 8,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_SHOTGUN")
    },
    ["magazine_heavyshotgun_extended"] = {
        ammo = 12,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_SHOTGUN")
    },
    ["magazine_heavyshotgun_box"] = {
        ammo = 30,
        type = "clip_box",
        ammoType = GetHashKey("AMMO_SHOTGUN")
    },
    -- Sniper Rifles
    ["magazine_sniperrifle_default"] = {
        ammo = 5,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_HUNTING")
    },
    ["magazine_heavysniper_default"] = {
        ammo = 6,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_heavysniper_mk2_default"] = {
        ammo = 6,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_heavysniper_mk2_extended"] = {
        ammo = 8,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_marksmanrifle_default"] = {
        ammo = 8,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_marksmanrifle_extended"] = {
        ammo = 16,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_marksmanrifle_mk2_default"] = {
        ammo = 8,
        type = "clip_default",
        ammoType = GetHashKey("AMMO_RIFLE")
    },
    ["magazine_marksmanrifle_mk2_extended"] = {
        ammo = 16,
        type = "clip_extended",
        ammoType = GetHashKey("AMMO_RIFLE")
    }
}

Config.Ammo = {
    ["ammo_pistol"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_PISTOL"),
        animDict = "weapons@pistol@ap_pistol_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_rifle"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_RIFLE"),
        animDict = "weapons@submg@advanced_rifle_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_smg"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_SMG"),
        animDict = "weapons@submg@assault_smg_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_shotgun"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_SHOTGUN"),
        animDict = "weapons@rifle@lo@sawnoff_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_flaregun"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_FLAREGUN"),
        animDict = "weapons@rifle@lo@sawnoff_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_paintballs"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_PAINTBALLS"),
        animDict = "weapons@pistol@ap_pistol_str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_hunting"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_HUNTING"),
        animDict = "weapons@first_person@aim_rng@generic@sniper_rifle@musket@str",
        anim = "reload_aim",
        reloadTime = 1000
    },
    ["ammo_firework"] = {
        ammo = 1,
        ammoType = GetHashKey("AMMO_FIREWORK"),
        animDict = "weapons@heavy@rpg_str",
        anim = "reload_aim",
        reloadTime = 1000
    }
}

Config.WeaponAddons = {
    ["clip_default"] = {
        ["weapon_pistol"] = GetHashKey("COMPONENT_PISTOL_CLIP_01"),
        ["weapon_appistol"] = GetHashKey("COMPONENT_APPISTOL_CLIP_01"),
        ["weapon_pistol50"] = GetHashKey("COMPONENT_PISTOL50_CLIP_01"),
        ["weapon_snspistol"] = GetHashKey("COMPONENT_SNSPISTOL_CLIP_01"),
        ["weapon_heavypistol"] = GetHashKey("COMPONENT_HEAVYPISTOL_CLIP_01"),
        ["weapon_vintagepistol"] = GetHashKey("COMPONENT_VINTAGEPISTOL_CLIP_01"),
        ["weapon_machinepistol"] = GetHashKey("COMPONENT_MACHINEPISTOL_CLIP_01"),
        ["weapon_combatpistol"] = GetHashKey("COMPONENT_COMBATPISTOL_CLIP_01"),
        ["weapon_pistol_mk2"] = GetHashKey("COMPONENT_PISTOL_MK2_CLIP_01"),
        ["weapon_ceramicpistol"] = GetHashKey("COMPONENT_CERAMICPISTOL_CLIP_01"),
        ["weapon_snspistol_mk2"] = GetHashKey("COMPONENT_SNSPISTOL_MK2_CLIP_01"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_CARBINERIFLE_CLIP_01"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_CARBINERIFLE_MK2_CLIP_01"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_ASSAULTRIFLE_CLIP_01"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_ASSAULTRIFLE_MK2_CLIP_01"),
        ["weapon_advancedrifle"] = GetHashKey("COMPONENT_ADVANCEDRIFLE_CLIP_01"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_SPECIALCARBINE_CLIP_01"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_SPECIALCARBINE_MK2_CLIP_01"),
        ["weapon_smg"] = GetHashKey("COMPONENT_SMG_CLIP_01"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_SMG_MK2_CLIP_01"),
        ["weapon_microsmg"] = GetHashKey("COMPONENT_MICROSMG_CLIP_01"),
        ["weapon_assaultsmg"] = GetHashKey("COMPONENT_ASSAULTSMG_CLIP_01"),
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_COMBATPDW_CLIP_01"),
        ["weapon_minismg"] = GetHashKey("COMPONENT_MINISMG_CLIP_01"),
        ["weapon_assaultshotgun"] = GetHashKey("COMPONENT_ASSAULTSHOTGUN_CLIP_01"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_HEAVYSHOTGUN_CLIP_01"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_BULLPUPRIFLE_CLIP_01"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_BULLPUPRIFLE_MK2_CLIP_01"),
        ["weapon_compactrifle"] = GetHashKey("COMPONENT_COMPACTRIFLE_CLIP_01"),
        ["weapon_militaryrifle"] = GetHashKey("COMPONENT_MILITARYRIFLE_CLIP_01")
    },
    ["clip_extended"] = {
        ["weapon_pistol"] = GetHashKey("COMPONENT_PISTOL_CLIP_02"),
        ["weapon_appistol"] = GetHashKey("COMPONENT_APPISTOL_CLIP_02"),
        ["weapon_pistol50"] = GetHashKey("COMPONENT_PISTOL50_CLIP_02"),
        ["weapon_snspistol"] = GetHashKey("COMPONENT_SNSPISTOL_CLIP_02"),
        ["weapon_heavypistol"] = GetHashKey("COMPONENT_HEAVYPISTOL_CLIP_02"),
        ["weapon_vintagepistol"] = GetHashKey("COMPONENT_VINTAGEPISTOL_CLIP_02"),
        ["weapon_machinepistol"] = GetHashKey("COMPONENT_MACHINEPISTOL_CLIP_02"),
        ["weapon_combatpistol"] = GetHashKey("COMPONENT_COMBATPISTOL_CLIP_02"),
        ["weapon_pistol_mk2"] = GetHashKey("COMPONENT_PISTOL_MK2_CLIP_02"),
        ["weapon_ceramicpistol"] = GetHashKey("COMPONENT_CERAMICPISTOL_CLIP_02"),
        ["weapon_snspistol_mk2"] = GetHashKey("COMPONENT_SNSPISTOL_MK2_CLIP_02"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_CARBINERIFLE_CLIP_02"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_CARBINERIFLE_MK2_CLIP_02"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_ASSAULTRIFLE_CLIP_02"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_ASSAULTRIFLE_MK2_CLIP_02"),
        ["weapon_advancedrifle"] = GetHashKey("COMPONENT_ADVANCEDRIFLE_CLIP_02"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_SPECIALCARBINE_CLIP_02"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_SPECIALCARBINE_MK2_CLIP_02"),
        ["weapon_smg"] = GetHashKey("COMPONENT_SMG_CLIP_02"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_SMG_MK2_CLIP_02"),
        ["weapon_microsmg"] = GetHashKey("COMPONENT_MICROSMG_CLIP_02"),
        ["weapon_assaultsmg"] = GetHashKey("COMPONENT_ASSAULTSMG_CLIP_02"),
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_COMBATPDW_CLIP_02"),
        ["weapon_minismg"] = GetHashKey("COMPONENT_MINISMG_CLIP_02"),
        ["weapon_assaultshotgun"] = GetHashKey("COMPONENT_ASSAULTSHOTGUN_CLIP_02"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_HEAVYSHOTGUN_CLIP_02"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_BULLPUPRIFLE_CLIP_02"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_BULLPUPRIFLE_MK2_CLIP_02"),
        ["weapon_compactrifle"] = GetHashKey("COMPONENT_COMPACTRIFLE_CLIP_02"),
        ["weapon_militaryrifle"] = GetHashKey("COMPONENT_MILITARYRIFLE_CLIP_02")
    },
    ["clip_box"] = {
        ["weapon_machinepistol"] = GetHashKey("COMPONENT_MACHINEPISTOL_CLIP_03"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_CARBINERIFLE_CLIP_03"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_ASSAULTRIFLE_CLIP_03"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_SPECIALCARBINE_CLIP_03"),
        ["weapon_smg"] = GetHashKey("COMPONENT_SMG_CLIP_03"),
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_COMBATPDW_CLIP_03"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_HEAVYSHOTGUN_CLIP_03"),
        ["weapon_compactrifle"] = GetHashKey("COMPONENT_COMPACTRIFLE_CLIP_03")
    },
    ["flashlight"] = {
        ["weapon_pistol"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_appistol"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_pistol50"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_heavypistol"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_combatpistol"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_pistol_mk2"] = GetHashKey("COMPONENT_AT_PI_FLSH_02"),
        ["weapon_snspistol_mk2"] = GetHashKey("COMPONENT_AT_PI_FLSH_03"),
        ["weapon_revolver_mk2"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_advancedrifle"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_pumpshotgun"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_microsmg"] = GetHashKey("COMPONENT_AT_PI_FLSH"),
        ["weapon_smg"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_assaultsmg"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_pumpshotgun_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_assaultshotgun"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_bullpupshotgun"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_combatshotgun"] = GetHashKey("COMPONENT_AT_AR_FLSH"),
        ["weapon_militaryrifle"] = GetHashKey("COMPONENT_AT_AR_FLSH")
    },
    ["small_scope"] = {
        ["weapon_revolver_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_MK2"),
        ["weapon_snspistol_mk2"] = GetHashKey("COMPONENT_AT_PI_RAIL_02"),
        ["weapon_pistol_mk2"] = GetHashKey("COMPONENT_AT_PI_RAIL"),
        ["weapon_microsmg"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO"),
        ["weapon_smg"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_02"),
        ["weapon_assaultsmg"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2"),
        ["weapon_pumpshotgun_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_MK2"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_02_MK2"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_MK2"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_MK2"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MACRO_MK2")
    },
    ["medium_scope"] = {
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL_SMG_MK2"),
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL"),
        ["weapon_pumpshotgun_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL_MK2"),
        ["weapon_advancedrifle"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL_MK2"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"),
        ["weapon_militaryrifle"] = GetHashKey("COMPONENT_AT_SCOPE_SMALL")
    },
    ["large_scope"] = {
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2")
    },
    ["holographic_sight"] = {
        ["weapon_revolver_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS_SMG"),
        ["weapon_pumpshotgun_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_SIGHTS")
    },
    ["suppressor"] = {
        ["weapon_pistol"] = GetHashKey("COMPONENT_AT_PI_SUPP_02"),
        ["weapon_appistol"] = GetHashKey("COMPONENT_AT_PI_SUPP"),
        ["weapon_pistol50"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_heavypistol"] = GetHashKey("COMPONENT_AT_PI_SUPP"),
        ["weapon_machinepistol"] = GetHashKey("COMPONENT_AT_PI_SUPP"),
        ["weapon_combatpistol"] = GetHashKey("COMPONENT_AT_PI_SUPP"),
        ["weapon_pistol_mk2"] = GetHashKey("COMPONENT_AT_PI_SUPP_02"),
        ["weapon_ceramicpistol"] = GetHashKey("COMPONENT_CERAMICPISTOL_SUPP"),
        ["weapon_snspistol_mk2"] = GetHashKey("COMPONENT_AT_PI_SUPP_02"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_pumpshotgun"] = GetHashKey("COMPONENT_AT_SR_SUPP"),
        ["weapon_microsmg"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_smg_mk2"] = GetHashKey("COMPONENT_AT_PI_SUPP"),
        ["weapon_assaultsmg"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_pumpshotgun_mk2"] = GetHashKey("COMPONENT_AT_SR_SUPP_03"),
        ["weapon_assaultshotgun"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_combatshotgun"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_bullpupshotgun"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_advancedrifle"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_AR_SUPP"),
        ["weapon_militaryrifle"] = GetHashKey("COMPONENT_AT_AR_SUPP")
    },
    ["grip"] = {
        ["weapon_combatpdw"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_assaultshotgun"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_bullpupshotgun"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_heavyshotgun"] = GetHashKey("COMPONENT_AT_AR_SUPP_02"),
        ["weapon_assaultrifle_mk2"] = GetHashKey("COMPONENT_AT_AR_AFGRIP_02"),
        ["weapon_carbinerifle"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_carbinerifle_mk2"] = GetHashKey("COMPONENT_AT_AR_AFGRIP_02"),
        ["weapon_specialcarbine"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_specialcarbine_mk2"] = GetHashKey("COMPONENT_AT_AR_AFGRIP_02"),
        ["weapon_assaultrifle"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_bullpuprifle"] = GetHashKey("COMPONENT_AT_AR_AFGRIP"),
        ["weapon_bullpuprifle_mk2"] = GetHashKey("COMPONENT_AT_AR_AFGRIP_02")
    }
}

Config.SameWeaponAddons = {
    ["clip_default"] = {
        "clip_extended",
        "clip_box"
    },
    ["clip_extended"] = {
        "clip_default",
        "clip_box"
    },
    ["clip_box"] = {
        "clip_default",
        "clip_extended"
    }
}

Config.AllWeapons = {
    --Melee
    "WEAPON_DAGGER",
    "WEAPON_BAT",
    "WEAPON_BOTTLE",
    "WEAPON_CROWBAR",
    --"WEAPON_UNARMED", pozor at to zustane zakomentovane pičuskovia
    "WEAPON_FLASHLIGHT",
    "WEAPON_GOLFCLUB",
    "WEAPON_HAMMER",
    "WEAPON_HATCHET",
    "WEAPON_KNUCKLE",
    "WEAPON_KNIFE",
    "WEAPON_KATANA",
    "WEAPON_MACHETE",
    "WEAPON_SWITCHBLADE",
    "WEAPON_NIGHTSTICK",
    "WEAPON_WRENCH",
    "WEAPON_BATTLEAXE",
    "WEAPON_POOLCUE",
    "WEAPON_STONE_HATCHET",
    --HandGuns
    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_REVOLVER",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_RAYPISTOL",
    "WEAPON_CERAMICPISTOL",
    "WEAPON_NAVYREVOLVER",
    "WEAPON_GADGETPISTOL",
    "WEAPON_PAINTBALLGUN",
    --Submachine GUNS
    "WEAPON_MICROSMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_COMBATPDW",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_MINISMG",
    --Shotguns
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_MUSKET",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    "WEAPON_AUTOSHOTGUN",
    "WEAPON_COMBATSHOTGUN",
    --Assaut Rifles
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_COMPACTRIFLE",
    "WEAPON_MILITARYRIFLE",
    -- Light Machine Guns
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_GUSENBERG",
    --Sniper Rifle
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2",
    --Heavy Weapons
    "WEAPON_RPG",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_RAYMINIGUN",
    --Throwables
    "WEAPON_GRENADE",
    "WEAPON_BZGAS",
    "WEAPON_FLASHBANG",
    "WEAPON_MOLOTOV",
    "WEAPON_STICKYBOMB",
    "WEAPON_PROXMINE",
    "WEAPON_SNOWBALL",
    "WEAPON_PIPEBOMB",
    "WEAPON_BALL",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_FLARE",
    --Miscellaneous
    "WEAPON_PETROLCAN",
    "GADGET_PARACHUTE",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_HAZARDCAN"
}

Config.WeaponColors = {
    {
        weaponspray_defaultblack = 0,
        weaponspray_green = 1,
        weaponspray_gold = 2,
        weaponspray_pink = 3,
        weaponspray_army = 4,
        weaponspray_lspd = 5,
        weaponspray_orange = 6,
        weaponspray_platinum = 7
    },
    {
        weaponspray_mk2classicblack = 0,
        weaponspray_mk2classicgray = 1,
        weaponspray_mk2classictwotone = 2,
        weaponspray_mk2classicwhite = 3,
        weaponspray_mk2classicbeige = 4,
        weaponspray_mk2classicgreen = 5,
        weaponspray_mk2classicblue = 6,
        weaponspray_mk2classicearth = 7,
        weaponspray_mk2classicbrownblack = 8,
        weaponspray_mk2redcontrast = 9,
        weaponspray_mk2bluecontrast = 10,
        weaponspray_mk2yellowcontrast = 11,
        weaponspray_mk2orangecontrast = 12,
        weaponspray_mk2boldpink = 13,
        weaponspray_mk2boldpurpleyellow = 14,
        weaponspray_mk2boldorange = 15,
        weaponspray_mk2boldgreenpurple = 16,
        weaponspray_mk2boldredfeatures = 17,
        weaponspray_mk2boldgreenfeatures = 18,
        weaponspray_mk2boldcyanfeatures = 19,
        weaponspray_mk2boldyellowfeatures = 20,
        weaponspray_mk2boldredwhite = 21,
        weaponspray_mk2boldbluewhite = 22,
        weaponspray_mk2metallicgold = 23,
        weaponspray_mk2metallicplatinum = 24,
        weaponspray_mk2metallicgraylilac = 25,
        weaponspray_mk2metallicpurplelime = 26,
        weaponspray_mk2metallicred = 27,
        weaponspray_mk2metallicgreen = 28,
        weaponspray_mk2metallicblue = 29,
        weaponspray_mk2metallicwhiteaqua = 30,
        weaponspray_mk2metallicredyellow = 31
    }
}


Config.WeaponCamos = {
    ["WEAPON_KNUCKLE"] = {
        ["Default"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_BASE"
            },
            Price = 0
        },
        ["The Pimp"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_PIMP"
            },
            Price = 60
        },
        ["The Ballas"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_BALLAS"
            },
            Price = 60
        },
        ["The Hustler"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_DOLLAR"
            },
            Price = 60
        },
        ["The Rock"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_DIAMOND"
            },
            Price = 60
        },
        ["The Hater"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_HATE"
            },
            Price = 60
        },
        ["The Lover"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_LOVE"
            },
            Price = 60
        },
        ["The Player"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_PLAYER"
            },
            Price = 60
        },
        ["The King"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_KING"
            },
            Price = 60
        },
        ["The Vagos"] = {
            Components = {
                "COMPONENT_KNUCKLE_VARMOD_VAGOS"
            },
            Price = 60
        }
    },
    ["WEAPON_SWITCHBLADE"] = {
        ["Default"] = {
            Components = {
                "COMPONENT_SWITCHBLADE_VARMOD_BASE"
            },
            Price = 0
        },
        ["VIP Variant"] = {
            Components = {
                "COMPONENT_SWITCHBLADE_VARMOD_VAR1"
            },
            Price = 60
        },
        ["Bodyguard Variant"] = {
            Components = {
                "COMPONENT_SWITCHBLADE_VARMOD_VAR2"
            },
            Price = 60
        }
    },
    ["WEAPON_PISTOl"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_PISTOL_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_COMBATPISTOl"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER"
            },
            Price = 60
        }
    },
    ["WEAPON_APPISTOl"] = {
        ["Gilded Gun Metal Finish"] = {
            Components = {
                "COMPONENT_APPISTOL_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_PISTOl50"] = {
        ["Platinum Pearl Deluxe Finish"] = {
            Components = {
                "COMPONENT_PISTOL50_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_REVOLVER"] = {
        ["Default"] = {
            Components = {
                "COMPONENT_REVOLVER_CLIP_01"
            },
            Price = 60
        },
        ["VIP Variant"] = {
            Components = {
                "COMPONENT_REVOLVER_VARMOD_BOSS"
            },
            Price = 60
        },
        ["Bodyguard Variant"] = {
            Components = {
                "COMPONENT_REVOLVER_VARMOD_GOON"
            },
            Price = 60
        }
    },
    ["WEAPON_SNSPISTOl"] = {
        ["Etched Wood Grip Finish"] = {
            Components = {
                "COMPONENT_SNSPISTOL_VARMOD_LOWRIDER"
            },
            Price = 60
        }
    },
    ["WEAPON_SNIPERRIFLE"] = {
        ["Etched Wood Grip Finish"] = {
            Components = {
                "COMPONENT_SNIPERRIFLE_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_HEAVYPISTOL"] = {
        ["Etched Wood Grip Finish"] = {
            Components = {
                "COMPONENT_HEAVYPISTOL_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_REVOLVER_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_REVOLVER_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_SNSPISTOl_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO",
                "COMPONENT_SNSPISTOL_MK2_CAMO_SLIDE"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_02",
                "COMPONENT_SNSPISTOL_MK2_CAMO_02_SLIDE"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_03",
                "COMPONENT_SNSPISTOL_MK2_CAMO_03_SLIDE"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_04",
                "COMPONENT_SNSPISTOL_MK2_CAMO_04_SLIDE"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_05",
                "COMPONENT_SNSPISTOL_MK2_CAMO_05_SLIDE"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_06",
                "COMPONENT_SNSPISTOL_MK2_CAMO_06_SLIDE"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_07",
                "COMPONENT_SNSPISTOL_MK2_CAMO_07_SLIDE"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_08",
                "COMPONENT_SNSPISTOL_MK2_CAMO_08_SLIDE"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_09",
                "COMPONENT_SNSPISTOL_MK2_CAMO_09_SLIDE"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_10",
                "COMPONENT_SNSPISTOL_MK2_CAMO_10_SLIDE"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01",
                "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01_SLIDE"
            },
            Price = 60
        }
    },
    ["WEAPON_PISTOl_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO",
                "COMPONENT_PISTOL_MK2_CAMO_SLIDE"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_02",
                "COMPONENT_PISTOL_MK2_CAMO_02_SLIDE"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_03",
                "COMPONENT_PISTOL_MK2_CAMO_03_SLIDE"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_04",
                "COMPONENT_PISTOL_MK2_CAMO_04_SLIDE"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_05",
                "COMPONENT_PISTOL_MK2_CAMO_05_SLIDE"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_06",
                "COMPONENT_PISTOL_MK2_CAMO_06_SLIDE"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_07",
                "COMPONENT_PISTOL_MK2_CAMO_07_SLIDE"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_08",
                "COMPONENT_PISTOL_MK2_CAMO_08_SLIDE"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_09",
                "COMPONENT_PISTOL_MK2_CAMO_09_SLIDE"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_10",
                "COMPONENT_PISTOL_MK2_CAMO_10_SLIDE"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_PISTOL_MK2_CAMO_IND_01",
                "COMPONENT_PISTOL_MK2_CAMO_IND_01_SLIDE"
            },
            Price = 60
        }
    },
    ["WEAPON_MICROSMG"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_MICROSMG_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_SMG"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_SMG_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_ASSAULTSMG"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER"
            },
            Price = 60
        }
    },
    ["WEAPON_SMG_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_SMG_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_PUMPSHOTGUN"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER"
            },
            Price = 60
        }
    },
    ["WEAPON_SAWNOFFSHOTGUN"] = {
        ["Gilded Gun Metal Finish"] = {
            Components = {
                "COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_PUMPSHOTGUN_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_ASSAULTRIFLE"] = {
        ["Yusuf Amir Luxury Finish"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_ADVANCEDRIFLE"] = {
        ["Gilded Gun Metal Finish"] = {
            Components = {
                "COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE"
            },
            Price = 60
        }
    },
    ["WEAPON_SPECIALCARBINE"] = {
        ["cs"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_VARMOD_BASE"
            },
            Price = 60
        },
        ["Etched Gun Metal Finish"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER"
            },
            Price = 60
        }
    },
    ["WEAPON_BULLPUPRIFLE"] = {
        ["Gilded Gun Metal Finish"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_VARMOD_LOW"
            },
            Price = 60
        }
    },
    ["WEAPON_BULLPUPRIFLE_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_SPECIALCARBINE_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_ASSAULTRIFLE_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    },
    ["WEAPON_CARBINERIFLE_MK2"] = {
        ["Digital Camo"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO"
            },
            Price = 60
        },
        ["Brushstroke Camo"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_02"
            },
            Price = 60
        },
        ["Woodland Camo"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_03"
            },
            Price = 60
        },
        ["Skull"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_04"
            },
            Price = 60
        },
        ["Sessanta Nove"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_05"
            },
            Price = 60
        },
        ["Perseus"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_06"
            },
            Price = 60
        },
        ["Leopard"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_07"
            },
            Price = 60
        },
        ["Zebra"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_08"
            },
            Price = 60
        },
        ["Geometric"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_09"
            },
            Price = 60
        },
        ["Boom!"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_10"
            },
            Price = 60
        },
        ["Patriotic"] = {
            Components = {
                "COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01"
            },
            Price = 60
        }
    }
}
