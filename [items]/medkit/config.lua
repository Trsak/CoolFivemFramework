Config = {}

Config.Items = {
    -- REVIVE
    ["defibrilator"] = {
        Type = "revive",
        Anim = {
            animDict = "mini@cpr@char_a@cpr_str",
            anim = "cpr_pumpchest"
        },
        Allowed = {
            ["ems"] = true
        }
    },
    ["medkit"] = {
        Type = "revive",
        Anim = {
            animDict = "rcmextreme3",
            anim = "idle"
        },
        Allowed = {
            ["ems"] = true,
            ["police"] = true,
            ["lsfd"] = true
        }
    },
    -- HEAL
    ["firstaidkit"] = {
        Type = "heal",
        Anim = {
            animDict = "rcmextreme3",
            anim = "idle"
        },
        Heal = 200,
        Allowed = {
            ["ems"] = true
        }
    },
    ["plaster"] = {
        Type = "heal",
        Anim = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a"
        },
        Heal = 10
    },
    ["infusion"] = {
        Type = "food",
        Anim = {
            animDict = "mp_arresting",
            anim = "a_uncuff"
        },
        Allowed = {
            ["ems"] = true
        }
    }
}
