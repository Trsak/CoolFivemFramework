Config = {}
Config.IgnoreInCover = true

Config.CanUse = {
    ["police"] = true
}

Config.Weapons = {
    -- Z/DO STŘEDU OPASKU           AnimDict = "anim@melee@switchblade@holster", sAnim = "w_unholster", eAnim = "w_holster" }
    -- MELEE                        AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster" }
    -- ZE ZADU                      AnimDict = "reaction@intimidation@1h", sAnim = "outro", eAnim = "intro"
    -- HOLSTER                      AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro"
    -- PREJ TAKY HOLSTER            AnimDict = "rcmjosh", sAnim = "josh_leadout_cop2", eAnim = "josh_leadout_cop2"
    { Name = "WEAPON_PISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_PISTOL_MK2", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_COMBATPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_APPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_PISTOL50", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_REVOLVER", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_REVOLVER_MK2", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_SNSPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_SNSPISTOL_MK2", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_HEAVYPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_VINTAGEPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_MARKSMANPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_DOUBLEACTION", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_CERAMICPISTOL", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_NAVYREVOLVER", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },
    { Name = "WEAPON_GADGETPISTOL", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = true },
    { Name = "WEAPON_STUNGUN", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = true },
    { Name = "WEAPON_FLAREGUN", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = true },
    { Name = "WEAPON_GRENADE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_STICKYBOMB", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_SMOKEGRENADE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_BZGAS", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_FLASHBANG", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_MOLOTOV", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_PROXMINE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },
    { Name = "WEAPON_PIPEBOMB", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 800, QuickCop = true },

    { Name = "WEAPON_KNIFE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_NIGHTSTICK", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = true },
    { Name = "WEAPON_HAMMER", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_BAT", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 800, QuickCop = false },
    { Name = "WEAPON_CROWBAR", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_GOLFCLUB", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_BOTTLE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_DAGGER", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_KNUCKLE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_MACHETE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_FLASHLIGHT", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = true },
    { Name = "WEAPON_SWITCHBLADE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_POOLCUE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_WRENCH", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_BATTLEAXE", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    -- ADDON
    { Name = "WEAPON_KATANA", AnimDict = "melee@holster", sAnim = "unholster", eAnim = "holster", AnimDuration = 500, QuickCop = false },
    { Name = "WEAPON_DILDOBAT", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 800, QuickCop = false },
    { Name = "WEAPON_PAINTBALLGUN", AnimDict = "reaction@intimidation@cop@unarmed", sAnim = "outro", eAnim = "intro", AnimDuration = 805, QuickCop = true },

    { Name = "WEAPON_DIGISCANNER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MICROSMG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SMG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SMG_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_ASSAULTSMG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_PUMPSHOTGUN_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MINISMG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MACHINEPISTOL", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_COMBATPDW", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_PUMPSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SAWNOFFSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_ASSAULTSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_BULLPUPSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_HEAVYSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_ASSAULTRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_ASSAULTRIFLE_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_CARBINERIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_CARBINERIFLE_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_ADVANCEDRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SPECIALCARBINE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SPECIALCARBINE_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_BULLPUPRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_BULLPUPRIFLE_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_COMPACTRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_COMBATMG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_GUSENBERG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_SNIPERRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_HEAVYSNIPER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_HEAVYSNIPER_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MARKSMANRIFLE", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MARKSMANRIFLE_MK2", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_GRENADELAUNCHER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_RPG", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_STINGER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MINIGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_DIGISCANNER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_FIREWORK", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_MUSKET", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_HOMINGLAUNCHER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_RAILGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_DBSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_AUTOSHOTGUN", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
    { Name = "WEAPON_COMPACTLAUNCHER", AnimDict = "anim@heists@ornate_bank@grab_cash", sAnim = "intro", eAnim = "exit", AnimDuration = 850, QuickCop = false },
}