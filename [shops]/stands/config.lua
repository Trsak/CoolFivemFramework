Config = {}

Config.DispenseDict = {
    "mp_common",
    "givetake1_a"
}
Config.PocketAnims = {"mp_common_miss", "put_away_coke"}

Config.TrackedEntities = {
    Icecream = {
        Models = {"prop_pier_kiosk_03"},
        Radius = 10.0,
        Selling = {
            ["food_icecreamchoc"] = {
                Label = "Koupit si čokoládovou zmrzlinu ($17)",
                Price = 17,
                Icon = "fas fa-ice-cream"
            },
            ["food_icecreampis"] = {
                Label = "Koupit si pistáciovou zmrzlinu ($17)",
                Price = 17,
                Icon = "fas fa-ice-cream"
            },
            ["food_icecreamvan"] = {
                Label = "Koupit si vanilkovou zmrzlinu ($17)",
                Price = 17,
                Icon = "fas fa-ice-cream"
            }
        }
    },
    Burger = {
        Models = {"prop_burgerstand_01"},
        Selling = {
            ["food_burger"] = {
                Label = "Koupit si burger ($18)",
                Price = 18,
                Icon = "fas fa-hamburger"
            }
        }
    },
    Hotdog = {
        Models = {"prop_hotdogstand_01"},
        Selling = {
            ["food_hotdog"] = {
                Label = "Koupit si hotdog ($15)",
                Price = 15,
                Icon = "fas fa-hotdog"
            },
            ["can_ecola"] = {
                Label = "Koupit si eCola ($10)",
                Price = 10,
                Icon = "fas fa-wine-bottle"
            },
            ["can_sprunk"] = {
                Label = "Koupit si sprunk ($10)",
                Price = 10,
                Icon = "fas fa-wine-bottle"
            }
        }
    }
}
