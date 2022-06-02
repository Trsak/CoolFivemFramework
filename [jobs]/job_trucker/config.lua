Config = {}
Config.licenseNeeded = "C"
Config.baseReward = 80

Config.BlipSettings = {
    ["destination"] = {
        Sprite = 309,
        Colour = 71,
        Label = "Vykládání zboží"
    },
    ["returning"] = {
        Sprite = 309,
        Colour = 71,
        Label = "Vrácení tahače"
    }
}

Config.Central = {
    ["LS_depo"] = {
        Coords = vec4(-769.43, -2638.43, 13.04, 57.74),
        ReturnLocation = vec3(-809.22, -2631.52, 13.81),
        Model = GetHashKey("a_m_m_farmer_01"),
        SpawnLocations = {
            Truck = {
                vec4(-788.43, -2657.85, 13.81, 59.29),
                vec4(-791.39, -2662.99, 13.81, 59.29),
                vec4(-794.36, -2668.35, 13.81, 59.29),
                vec4(-797.25, -2673.47, 13.81, 59.29),
                vec4(-800.00, -2678.38, 13.81, 59.29),
                vec4(-802.95, -2683.57, 13.81, 59.29),
                vec4(-806.14, -2689.17, 13.81, 59.29),
                vec4(-808.99, -2694.24, 13.81, 59.29),
                vec4(-812.06, -2699.81, 13.81, 59.29),
                vec4(-814.75, -2704.76, 13.81, 59.29),
                vec4(-817.75, -2709.94, 13.81, 59.29)
            },
            Trailer = {
                vec4(-780.88, -2662.27, 13.81, 59.29),
                vec4(-784.08, -2667.64, 13.81, 59.29),
                vec4(-786.96, -2672.70, 13.81, 59.29),
                vec4(-790.02, -2677.71, 13.81, 59.29),
                vec4(-792.97, -2682.99, 13.81, 59.29),
                vec4(-796.12, -2688.19, 13.81, 59.29),
                vec4(-799.26, -2693.34, 13.81, 59.29),
                vec4(-802.19, -2698.45, 13.81, 59.29),
                vec4(-805.20, -2703.56, 13.81, 59.29),
                vec4(-808.28, -2708.79, 13.81, 59.29),
                vec4(-811.22, -2713.80, 13.81, 59.29)
            }
        }
    },
    ["Sandy_depo"] = {
        Coords = vec4(173.6755065918, 2778.9523925782, 46.077243804932, 186.9242401123),
        ReturnLocation = vec3(193.526276, 2745.989990, 43.426266),
        Model = GetHashKey("a_m_m_hillbilly_01"),
        SpawnLocations = {
            Truck = {
                vec4(202.3162689209, 2788.0251464844, 46.38469696045, 96.811378479004)
            },
            Trailer = {
                vec4(209.25053405762, 2788.8442382812, 47.384941101074, 96.848518371582)
            }
        }
    }
}

Config.Contracts = {
    ["Clucking Bell Farms"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("hauler"),
        Trailer = GetHashKey("trailers2"),
        Destination = vec3(-125.1482, 6215.826, 31.20206),
        Wage = {
            ['LS_depo'] = 2.5 * 220,
            ['Sandy_depo'] = 2.5 * 180
        }
        --BlockedFor = {
        --  ['DEPONAME'] = true
        --}
        --
    },
    ["Daisy-Lee loď"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("trailers4"),
        Destination = vec3(1208.58, -3022.174, 5.867384),
        Wage = {
            ['LS_depo'] = 2.5 * 95,
            ['Sandy_depo'] = 2.5 * 160
        }
    },
    ["Flywheels Garage"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker2"),
        Destination = vec3(1775.068, 3342.38, 40.96846),
        Wage = {
            ['LS_depo'] = 2.5 * 150,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Ropné vrty El Burro Heights"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(1720.57, -1570.904, 112.62),
        Wage = {
            ['LS_depo'] = 2.5 * 100,
            ['Sandy_depo'] = 2.5 * 150
        }
    },
    ["You Tool 1"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("trailers3"),
        Destination = vec3(2686.094, 3456.154, 55.76976),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 80
        }
    },
    ["Up-n-Atom"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("hauler"),
        Trailer = GetHashKey("trailers2"),
        Destination = vec3(98.61388, 302.7002, 110.0192),
        Wage = {
            ['LS_depo'] = 2.5 * 103,
            ['Sandy_depo'] = 2.5 * 90
        }
    },
    ["The Paint Shop"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(-1137.932, 2677.456, 18.0939),
        Wage = {
            ['LS_depo'] = 2.5 * 150,
            ['Sandy_depo'] = 2.5 * 40
        }
    },
    ["Wonderama Arcade"] = {
        LocationLabel = "Grapeseed",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("tvtrailer"),
        Destination = vec3(1708.82, 4801.77, 41.78328),
        Wage = {
            ['LS_depo'] = 2.5 * 172,
            ['Sandy_depo'] = 2.5 * 100
        }
    },
    ["Union Grain Seed Inc."] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(2933.738, 4313.53, 51.01526),
        Wage = {
            ['LS_depo'] = 2.5 * 160,
            ['Sandy_depo'] = 2.5 * 95
        }
    },
    ["Palomino Fwy Benzínka"] = {
        LocationLabel = "Palomino Highlands",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(2587.5, 415.89, 109.31),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 120
        }
    },
    ["Route 68 Benzínka"] = {
        LocationLabel = "Tongva Hills",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(-2526.14, 2341.04, 32.84),
        Wage = {
            ['LS_depo'] = 2.5 * 150,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Palmer-Taylor Power Plant 1"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(2775.34, 1437.98, 24.98),
        Wage = {
            ['LS_depo'] = 2.5 * 170,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["Palmer-Taylor Power Plant 2"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(2708.49, 1711.07, 24.98),
        Wage = {
            ['LS_depo'] = 2.5 * 170,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["Palmer-Taylor Power Plant 3"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(2782.33, 1710.64, 24.98),
        Wage = {
            ['LS_depo'] = 2.5 * 170,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["Palmer-Taylor Power Plant 4"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(2673.36, 1428.66, 24.98),
        Wage = {
            ['LS_depo'] = 2.5 * 160,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["Lumber Yard 1"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailerlogs"),
        Destination = vec3(-570.16, 5355.97, 70.14),
        Wage = {
            ['LS_depo'] = 2.5 * 200,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["Great Ocean Hway Benzínka"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(1685.83, 6439.52, 32.36),
        Wage = {
            ['LS_depo'] = 2.5 * 240,
            ['Sandy_depo'] = 2.5 * 120
        }
    },
    ["Steel Works"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(1076.79, -1952.2, 30.9),
        Wage = {
            ['LS_depo'] = 2.5 * 100,
            ['Sandy_depo'] = 2.5 * 120
        }
    },
    ["Industrial Zone"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(523.34, -2107.69, 6.29),
        Wage = {
            ['LS_depo'] = 2.5 * 90,
            ['Sandy_depo'] = 2.5 * 130
        }
    },
    ["Paleto Bay Benzínka"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(198.66, 6609.28, 31.72),
        Wage = {
            ['LS_depo'] = 2.5 * 250,
            ['Sandy_depo'] = 2.5 * 130
        }
    },
    ["Sandy Shores Benzínka"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(1981.11, 3782.81, 32.18),
        Wage = {
            ['LS_depo'] = 2.5 * 180,
            ['Sandy_depo'] = 2.5 * 60
        }
    },
    ["Senora Fwy Benzínka"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(2686.82, 3268.97, 55.24),
        Wage = {
            ['LS_depo'] = 2.5 * 120,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Davis Quartz Quarry 1"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers4"),
        Destination = vec3(2689.93, 2761.35, 37.88),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Davis Quartz Quarry 2"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers4"),
        Destination = vec3(2732.4, 2779.89, 36.01),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Davis Quartz Quarry 3"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailers4"),
        Destination = vec3(2768.11, 2803.76, 41.4),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 70
        }
    },
    ["Lumber Yard 2"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailerlogs"),
        Destination = vec3(-578.55, 5249.02, 70.47),
        Wage = {
            ['LS_depo'] = 2.5 * 200,
            ['Sandy_depo'] = 2.5 * 160
        }
    },
    ["Lumber Yard 3"] = {
        LocationLabel = "Paleto Bay",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("trailerlogs"),
        Destination = vec3(-601.97, 5302.31, 70.21),
        Wage = {
            ['LS_depo'] = 2.5 * 200,
            ['Sandy_depo'] = 2.5 * 160
        }
    },
    ["You Tool 2"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("trailers3"),
        Destination = vec3(2673.41, 3518.63, 52.71),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 80
        }
    },
    ["You Tool 3"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("trailers3"),
        Destination = vec3(2686.094, 3456.154, 55.76976),
        Wage = {
            ['LS_depo'] = 2.5 * 130,
            ['Sandy_depo'] = 2.5 * 80
        }
    },
    ["PDM"] = {
        LocationLabel = "Los Santos",
        Truck = GetHashKey("phantom3"),
        Trailer = GetHashKey("trailers"),
        Destination = vec3(-44.31, -1082.25, 26.68),
        Wage = {
            ['LS_depo'] = 2.5 * 60,
            ['Sandy_depo'] = 2.5 * 120
        }
    },
    ["Wind Farm"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("phantom"),
        Trailer = GetHashKey("armytrailer"),
        Destination = vec3(2498.49, 1588.65, 33.36),
        Wage = {
            ['LS_depo'] = 2.5 * 170,
            ['Sandy_depo'] = 2.5 * 75
        }
    },
    ["North Vinewood Benzínka"] = {
        LocationLabel = "Sandy Shores",
        Truck = GetHashKey("packer"),
        Trailer = GetHashKey("tanker"),
        Destination = vec3(-1791.06, 814.08, 138.5),
        Wage = {
            ['LS_depo'] = 2.5 * 110,
            ['Sandy_depo'] = 2.5 * 90
        }
    }
}