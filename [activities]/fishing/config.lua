Config = {}

Config.FishingTime = 15000 --15000

    
Config.Fishes = {
    {
        ["minPrice"] = 1,
        ["maxPrice"] = 5,
        ["chance"] = 25,
        ["itemMin"] = 1,
        ["itemMax"] = 5,
        ["label"] = "Prodat bass",
        ["item"] = "fish_bass"
    },
    {
        ["minPrice"] = 1,
        ["maxPrice"] = 5,
        ["chance"] = 75,
        ["itemMin"] = 1,
        ["itemMax"] = 5,
        ["label"] = "Prodat halibuta",
        ["item"] = "fish_halibut"
    },
    {
        ["minPrice"] = 1,
        ["maxPrice"] = 5,
        ["chance"] = 50,
        ["itemMin"] = 1,
        ["itemMax"] = 5,
        ["label"] = "Prodat tuňáka",
        ["item"] = "fish_tuna"
    }
}


Config.Npc = {
    ["fisherman"] = {
        ["name"] = "fisherman",
        ["available"] = true,
        ["model"] = {
            type = 4,
            key = 0xED0CE4C6
        },
        ["pos"] = {
            ["x"] = -1594.28,
            ["y"] = 5193.03,
            ["z"] = 3.31,
            ["heading"] = 201.75
        },
        ["anim"] = {
            animDict = "amb@world_human_leaning@male@wall@back@legs_crossed@idle_a",
            anim = "idle_c"
        }
    }
}

