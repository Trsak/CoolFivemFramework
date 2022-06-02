Config = {}
Config.WhitelistedJobTypes = {
	police = true,
	medic = true
}
Config.delayDuration = 10 * 60000 -- 10 minut
Config.copsAllowed = 6
Config.defenceChance = 2

Config.Anims = {
	["scared"] = {
		["dict"] = "random@domestic",
		["name"] = "f_distressed_loop"
	},
	["hidden"] = {
		["dict"] = "amb@code_human_cower@male@idle_b",
		["name"] = "idle_d"
	}
}
