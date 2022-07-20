Config = {}

Config.Objects = {
    ["methtable"] = "tr_prop_meth_table01a",
    ["tray_meth"] = {
        [1] = "tr_prop_meth_tray_01a",
        [2] = "bkr_prop_meth_smashedtray_01"
    },
    ["cokeseed"] = "h4_prop_bush_cocaplant_01"
}

Config.Items = {
    ["methmix"] = {
        For = "methtable",
        Add = 20.0,
        Anim = {
            animDict = "weapons@misc@jerrycan@",
            anim = "fire",
            flags = 51
        }
    },
    ["lithiumbattery"] = {
        For = "methtable",
        Add = 50.0,
        Anim = {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 51
        }
    }
}

Config.Materials = {
    [-1595148316] = "SandLoose",
    [510490462] = "SandCompact",
    [909950165] = "SandWet",
    [-1907520769] = "SandTrack",
    [509508168] = "SandDryDeep",
    [1288448767] = "SandWetDeep",
    [951832588] = "GravelSmall",
    [2128369009] = "GravelLarge",
    [-356706482] = "GravelDeep",
    [-1942898710] = "MudHard",
    [312396330] = "MudPothole",
    [1635937914] = "MudSoft",
    [-273490167] = "MudUnderwater",
    [1109728704] = "MudDeep",
    [223086562] = "Marsh",
    [1584636462] = "MarshDeep",
    [-700658213] = "Soil",
    [1144315879] = "ClayHard",
    [560985072] = "ClaySoft",
    [-461750719] = "GrassLong",
    [1333033863] = "Grass",
    [-1286696947] = "GrassShort",
    [-309121453] = "Woodchips"
}


Config.Labs = {
    -- 4965.745118 -5297.907714 6.279908 
    {
        Coords = vec3(4974.830566, -5300.136230, -0.830810),
        Drug = "coke",
        Type = "pasta"
    },
    {
        Coords = vec3(4976.096680, -5303.802246, -0.830810),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4978.562500, -5303.934082, -0.830810),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4977.982422, -5301.244140, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4981.780274, -5301.520996, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4985.103516, -5301.679200, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4988.584472, -5299.147460, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4988.834960, -5295.257324, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4985.485840, -5295.059570, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4982.136230, -5295.006836, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4978.522950, -5291.907714, -0.830810),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4976.281250, -5289.296875, -0.830810),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4984.773438, -5289.705566, -0.830810),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4987.648438, -5289.876954, -0.830810),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    -- 4928.769042 -5278.087890 5.723754
    {
        Coords = vec3(4919.472656, -5276.175782, -1.386840),
        Drug = "coke",
        Type = "pasta"
    },
    {
        Coords = vec3(4918.021972, -5272.681152, -1.386840),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4915.687988, -5272.681152, -1.386840),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4916.373536, -5275.345214, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4912.602050, -5275.213378, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4909.200196, -5275.226562, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4905.784668, -5278.193360, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4905.771484, -5281.833008, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4909.200196, -5281.951660, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4912.536132, -5281.885742, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4916.320800, -5284.575684, -1.386840),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4918.641602, -5287.200196, -1.386840),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, 0.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4910.109864, -5287.239746, -1.386840),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, 0.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4907.116700, -5287.134278, -1.386840),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, 0.0),
        Drug = "coke",
        Type = "super_pills"
    },
    -- 4982.544922 -5118.777832 2.606568
    {
        Coords = vec3(4981.094726, -5125.740722, -4.487182),
        Drug = "coke",
        Type = "pasta"
    },
    {
        Coords = vec3(4977.560546, -5127.178222, -4.487182),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4977.718750, -5129.538574, -4.487182),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(4980.263672, -5128.931640, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4980.355958, -5132.650390, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4980.593262, -5136.013184, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4983.217774, -5139.389160, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4987.121094, -5139.191406, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4987.041992, -5135.815430, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4989.547364, -5128.615234, -4.487182),
        Offset = vec3(-1.9, -0.3, 0.6),
        Rot = vec3(0.0, 0.0, 180.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(4992.026368, -5126.175782, -4.487182),
        Offset = vec3(0.31, -1.71, -0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4992.382324, -5134.667968, -4.487182),
        Offset = vec3(0.31, -1.71, -0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(4992.408692, -5137.516602, -4.487182),
        Offset = vec3(0.31, -1.71, -0.6),
        Rot = vec3(0.0, 0.0, 90.0),
        Drug = "coke",
        Type = "super_pills"
    },
    -- 5119.806640 -5190.566894 2.421264
    {
        Coords = vec3(5126.597656, -5192.426270, -4.672486),
        Drug = "coke",
        Type = "pasta"
    },
    {
        Coords = vec3(5127.863770, -5196.013184, -4.672486),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(5130.448242, -5195.973632, -4.672486),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(5129.696778, -5193.323242, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5133.468262, -5193.336426, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5136.870118, -5193.362792, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5140.285644, -5190.580078, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5140.193360, -5186.808594, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5136.764648, -5186.782226, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5133.520996, -5186.887696, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5129.657226, -5184.065918, -4.672486),
        Offset = vec3(0.31, -1.71, 0.6),
        Rot = vec3(0.0, 0.0, -90.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5127.494628, -5181.481446, -4.672486),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(5135.789062, -5181.507812, -4.672486),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(5138.874512, -5181.520996, -4.672486),
        Offset = vec3(1.8, 0.3, -0.6),
        Rot = vec3(0.0, 0.0, -180.0),
        Drug = "coke",
        Type = "super_pills"
    },
    -- 5144.505372 -4614.474610 2.438110
    {
        Coords = vec3(5138.439454, -4611.178222, -4.672486),
        Drug = "coke",
        Type = "pasta"
    },
    {
        Coords = vec3(5137.951660, -4607.354004, -4.672486),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(5135.538574, -4606.681152, -4.672486),
        Drug = "coke",
        Type = "drying"
    },
    {
        Coords = vec3(5135.551758, -4609.648438, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5131.991210, -4608.435058, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5128.799804, -4607.670410, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5124.764648, -4609.279296, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5123.815430, -4613.063964, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5127.125488, -4613.973632, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5130.355958, -4614.764648, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5133.270508, -4618.522950, -4.672486),
        Offset = vec3(-0.31, 1.71, 0.6),
        Rot = vec3(0.0, 0.0, 86.0),
        Drug = "coke",
        Type = "mixing"
    },
    {
        Coords = vec3(5134.839356, -4621.608886, -4.672486),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, -2.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(5126.571290, -4619.288086, -4.672486),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, -2.0),
        Drug = "coke",
        Type = "super_pills"
    },
    {
        Coords = vec3(5123.670410, -4618.615234, -4.672486),
        Offset = vec3(-1.8, -0.3, -0.6),
        Rot = vec3(0.0, 0.0, -2.0),
        Drug = "coke",
        Type = "super_pills"
    },
}

Config.Dependencies = {
    ["coke"] = {
        ["mixing"] = {
            Length = 25000,
            Target = "Míchat kokain",
            Label = "Mícháš kokain",
            Anims = {
                AnimDict = "anim@amb@business@coc@coc_unpack_cut_left@",
                Player = "coke_cut_v5_coccutter",
                Props = {
                    Soda = "coke_cut_v5_bakingsoda",
                    FirstCard = "coke_cut_v5_creditcard",
                    SecCard = "coke_cut_v5_creditcard^1"
                }
            },
            Props = {
                Soda = "bkr_prop_coke_bakingsoda_o",
                FirstCard = "prop_cs_credit_card",
                SecCard = "prop_cs_credit_card"
            }
        },
        ["pasta"] = {
            Length = 25000,
            Target = "Udělat kokainovou pastu",
            Label = "Děláš kokainovou pastu",
            Anim = {
                emotes = "fuel"
            }
        },
        ["drying"] = {
            Length = 25000,
            Target = "Usušit kokainovou pastu",
            Label = "Sušíš kokainovou pastu",
            Anim = {
                emotes = "pull"
            }
        },
        ["super_pills"] = {
            Length = 25000,
            Target = "Vytvořit Super tabletky White pilulky",
            Label = "Vytváříš Super tabletky White pilulky..",
            Anims = {
                AnimDict = "anim@amb@business@coc@coc_unpack_cut_left@",
                Player = "coke_cut_v5_coccutter",
                Props = {
                    Soda = "coke_cut_v5_bakingsoda",
                    FirstCard = "coke_cut_v5_creditcard",
                    SecCard = "coke_cut_v5_creditcard^1"
                }
            },
            Props = {
                Soda = "citricacid",
                FirstCard = "prop_cs_credit_card",
                SecCard = "prop_cs_credit_card"
            }
        }
    }
}