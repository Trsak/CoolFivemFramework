Config = {}

Config.Jobs = {
    -- State Jobs
    ["gov"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-546.72, -202.84, 47.41), vec3(2510.46, -421.85, 106.91)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(-552.29, -191.65, 38.22)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-527.887574, -192.679580, 38.222416), vec3(2511.95, -428.57, 94.58),
                          vec3(-538.517334, -174.422562, 38.22241)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Úřad města"] = {
                Sprite = 419,
                Coords = vec3(-547.64, -199.74, 38.22)
            }
        }
    },
    ["ems"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(361.933289, -588.402588, 47.322296), vec3(-267.048950, 6321.170410, 32.427296)},
                Duty = true,
                Grade = 21
            },
            Fridge = {
                Coords = {vec3(341.6, -596.33, 43.28), vec3(335.571320, -593.933654, 43.301926)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(364.150391, -589.998230, 47.322262)},
                Duty = true,
                Grade = 21
            },
            Duty = {
                Coords = {vec3(309.497192, -596.557434, 43.293716), vec3(343.582855, -582.769958, 28.898821),
                          vec3(-255.509949, 6329.955566, 32.427238), vec3(-1405.490234, -437.001800, 36.558724)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(340.790649, -582.309692, 28.898819), vec3(314.877838, -601.700806, 43.293678),
                          vec3(-256.480682, 6327.890137, 32.427296)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(314.203674, -603.273987, 43.293686)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(303.824371, -595.427612, 48.224182), vec3(-258.911835, 6326.414063, 32.427273)},
                Duty = true,
                Grade = 2
            },
            Armory = {
                Coords = {vec3(305.818573, -580.359375, 43.281731)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Pillbox Hill Medical Center"] = {
                Sprite = 61,
                Coords = vec3(317.55, -591.01, 43.28)
            },
            ["Paleto Bay Medical Center"] = {
                Sprite = 61,
                Coords = vec3(-258.911652, 6326.414063, 32.427273)
            }
        }
    },
    ["lspd"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(462.161316, -985.554504, 30.728078)},
                Duty = true,
                Grade = 11
            },
            Duty = {
                Coords = {vec3(443.382782, -980.025086, 30.193094), vec3(1848.10, 3686.66, 34.27)},
                Duty = false,
                Grade = 1
            },
            WeaponRegister = {
                Coords = {vec3(442.996734, -983.180604, 30.689580)},
                Duty = true,
                Grade = 2
            },
            Fridge = {
                Coords = {vec3(462.998260, -980.174744, 30.689872)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(474.982422, -996.065612, 26.273436), vec3(472.684722, -995.029480, 26.273440),
                          vec3(449.661286, -997.606384, 30.689580), vec3(444.402558, -984.346496, 30.689582)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(462.538818, -996.267396, 30.689566), vec3(475.169434, -996.267150, 30.689802),
                          vec3(1846.08, 3694.41, 34.27), vec3(463.219848, -987.712708, 30.728074)},
                Duty = false,
                Grade = 1
            },
            Armory = {
                Coords = {vec3(479.157624, -996.623108, 30.691990), vec3(1858.93, 3690.97, 34.27)},
                Duty = true,
                Grade = 1
            },
            MechanicMenu = {
                Coords = {vec3(463.498168, -1019.138978, 28.102456)},
                Duty = true,
                Grade = 11
            }
        },
        Blips = {
            ["Los Santos Police Department"] = {
                Sprite = 526,
                Coords = vec3(463.784882, -999.190674, 25.624704)
            }
        }
    },
    ["lssd"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1857.30, 3690.12, 38.07)},
                Duty = true,
                Grade = 7
            },
            Duty = {
                Coords = {vec3(1848.10, 3686.66, 34.27), vec3(443.382782, -980.025086, 30.193094)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(1855.84, 3692.87, 38.07)},
                Duty = true,
                Grade = 1
            },
            WeaponRegister = {
                Coords = {vec3(1851.86, 3687.71, 34.27)},
                Duty = true,
                Grade = 2
            },
            Storage = {
                Coords = {vec3(1853.54, 3685.02, 30.27), vec3(1851.62, 3690.72, 30.27)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(1846.08, 3694.41, 34.27), vec3(475.169434, -996.267150, 30.689802)},
                Duty = false,
                Grade = 1
            },
            Armory = {
                Coords = {vec3(1858.93, 3690.97, 34.27)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Los Santos Sheriff Department "] = {
                Sprite = 526,
                Coords = vec3(1854.56, 3684.87, 34.27)
            }
        }
    },
    ["sahp"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-447.02505493164, 6014.1606445312, 36.507022857666)},
                Duty = true,
                Grade = 7
            },
            Duty = {
                Coords = {vec3(-449.73614501954, 6012.23828125, 31.716428756714)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-439.85144042968, 6012.9975585938, 31.716711044312)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-439.10662841796, 6010.44140625, 27.985610961914)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(-455.36517333984, 6014.8139648438, 31.716432571412),
                          vec3(475.169434, -996.267150, 30.689802)},
                Duty = false,
                Grade = 1
            },
            Armory = {
                Coords = {vec3(-1098.749878, -826.040222, 14.282884),
                          vec3(-437.1618347168, 6001.1435546875, 31.716093063354)},
                Duty = true,
                Grade = 1
            },
            WeaponRegister = {
                Coords = {vec3(-447.88162231446, 6012.3774414062, 31.716432571412)},
                Duty = true,
                Grade = 1
            },
            MechanicMenu = {
                Coords = {vec3(-450.72, 5998.34, 31.34)},
                Duty = true,
                Grade = 7
            }
        },
        Blips = {
            ["San Andreas Highway Patrol"] = {
                Sprite = 526,
                Coords = vec3(-448.38, 6009.64, 31.72)
            }
        },
        ClearArea = {
            Coords = {vec3(-429.88314819336, 6003.3266601562, 27.985626220704),
                      vec3(-440.61892700196, 6012.71875, 27.985626220704),
                      vec3(-435.96502685546, 5999.8208007812, 31.716083526612),
                      vec3(-439.22720336914, 6005.1059570312, 36.50703048706),
                      vec3(-449.08715820312, 6007.0600585938, 36.50987625122)},
            radius = 5.0
        }
    },
    ["lsfd"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1166.28, -1482.70, 35.07)},
                Duty = true,
                Grade = 20
            },
            Duty = {
                Coords = {vec3(1185.15, -1470.55, 35.07)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(1174.15, -1468.77, 35.07), vec3(1208.356079, -1474.396606, 34.859486)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(1181.54, -1484.11, 35.07)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(1167.74, -1466.12, 35.07)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(1172.06, -1467.46, 35.07)},
                Duty = false,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(1169.408569, -1483.066040, 35.078686)},
                Duty = true,
                Grade = 20
            },
            Armory = {
                Coords = {vec3(1209.203125, -1480.810303, 34.859539)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Los Santos Fire Department"] = {
                Sprite = 436,
                Coords = vec3(1193.70, -1472.54, 34.69)
            }
        }
    },
    -- Private Jobs
    ["weazel"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-568.317016, -913.301452, 23.875734)},
                Duty = true,
                Grade = 10
            },
            Duty = {
                Coords = {vec3(-586.841248, -921.482666, 23.869084)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-577.859680, -924.274108, 32.520520)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-594.559082, -926.405090, 32.524726), vec3(-596.469726, -930.591918, 32.524666)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-564.289246, -935.593444, 23.864934)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Weazel News"] = {
                Sprite = 135,
                Coords = vec3(-592.308960, -929.965149, 23.870003)
            }
        }
    },
    ["g6"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-237.814102, -832.574402, 30.678790)},
                Duty = false,
                Grade = 8
            },
            Duty = {
                Coords = {vec3(-229.492630, -842.895508, 30.683862)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-215.540558, -822.555358, 30.683332)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-218.414062, -821.587586, 30.683332)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-224.817382, -820.305114, 30.683366)},
                Duty = false,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(-219.960174, -824.002198, 30.683334)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Gruppe 6"] = {
                Sprite = 507,
                Coords = vec3(-229.492630, -842.895508, 30.683862)
            }
        }
    },
    ["lost"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(989.48, -136.12, 74.06), vec3(-1114.19, -832.41, 30.75)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(992.415710, -136.391372, 74.061386)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(1992.16, 3047.62, 50.50), vec3(992.11, -135.22, 74.06), vec3(986.95, -92.95, 74.84)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(972.348877, -98.022919, 74.870094), vec3(996.421386, -122.415596, 73.901802)},
                Duty = true,
                Grade = 2
            },
            Vault = {
                Coords = {vec3(977.21, -104.03, 74.84)},
                Duty = true,
                Grade = 1
            },
            MechanicMenu = {
                Coords = {vec3(982.458436, -135.820664, 73.426200), vec3(997.901916, -127.113320, 73.307266)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Dílna The Lost"] = {
                Sprite = 446,
                Coords = vec3(997.22, -130.1, 83.88)
            }
        }
    },
    ["lsc"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-319.54, -127.05, 38.9)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(-347.48, -129.48, 38.9)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-349.73, -122.69, 38.9)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-314.36, -119.88, 38.9), vec3(-322.24, -141.04, 38.9), vec3(1189.15, 2638.28, 38.44)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-323.04, -127.28, 38.9)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(-315.97, -122.3, 38.9)},
                Duty = true,
                Grade = 1
            },
            MechanicMenu = {
                Coords = {vec3(-337.83, -134.99, 38.9), vec3(-334.17, -126.83, 38.9)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Dílna LS Customs"] = {
                Sprite = 72,
                Coords = vec3(-345.44, -138.84, 38.9)
            }
        }
    },
    ["airseal"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-950.34, -2944.48, 14.52)},
                Duty = true,
                Grade = 8
            },
            PersonalCloset = {
                Coords = {vec3(-925.911744, -2939.194824, 13.945078)},
                Duty = false,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(-923.07, -2937.83, 13.95)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-925.95, -2936.49, 13.95)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-932.07, -2936.2, 13.94), vec3(-924.6, -2984.66, 14.2)},
                Duty = false,
                Grade = 1
            },
            Licenses = {
                Coords = {vec3(-951.51, -2941.2, 13.95)},
                Duty = true,
                Grade = 6
            }
        },
        Blips = {
            ["Air Seal"] = {
                Sprite = 251,
                Coords = vec3(-1007.64, -2976.15, 13.95)
            }
        }
    },
    ["cran"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1073.562378, -311.999756, 37.807708)},
                Duty = true,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(-1074.614258, -306.944794, 37.807826)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1075.121460, -315.143860, 37.807824)},
                Duty = true,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1075.353516, -321.387390, 37.807708)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1066.643188, -311.706970, 37.807708)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Cranberry Bar"] = {
                Sprite = 93,
                Coords = vec3(-1080.583252, -315.653778, 37.807876)
            }
        }
    },
    ["konran"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(832.533325, -1061.275512, 28.367977)},
                Duty = false,
                Grade = 2
            },
            Fridge = {
                Coords = {vec3(840.857177, -1066.572875, 28.367979)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(837.835205, -1064.447387, 28.412012)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(830.857177, -1064.594848, 28.367977)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["queencrown"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(738.944580, -813.803650, 24.267462)},
                Duty = true,
                Grade = 6
            },
            Duty = {
                Coords = {vec3(741.822266, -810.721740, 24.267462)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(735.658692, -826.038086, 22.667430)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(706.331848, -808.576416, 16.880084)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(732.773132, -795.199218, 18.074216)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Garrison Bar"] = {
                Sprite = 541,
                Coords = vec3(755.511048, -816.501526, 26.507066)
            }
        }
    },
    ["nmcomp"] = {
        Places = {
            Duty = {
                Coords = {vec3(-781.470214, -211.886918, 37.152736)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(-809.889770, -207.995286, 37.122098)},
                Duty = true,
                Grade = 6
            },
            Storage = {
                Coords = {vec3(-780.407470, -231.181060, 37.147618), vec3(-772.987426, -230.076248, 37.147618)},
                Duty = false,
                Grade = 3
            },
            Cloakroom = {
                Coords = {vec3(-809.721374, -204.227432, 37.133472)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-802.416016, -200.068680, 37.150138)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["NM Cars"] = {
                Sprite = 596,
                Coords = vec3(-772.987426, -230.076248, 37.147618)
            }
        }
    },
    ["ngmc"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1382.377564, -627.027344, 36.940452)},
                Duty = true,
                Grade = 9
            },
            Duty = {
                Coords = {vec3(-1371.95, -625.85, 30.82)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1390.97, -606.73, 30.32), vec3(-1373.92, -627.8, 30.82), vec3(-1378.38, -630.75, 30.82)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1386.77, -606.64, 30.32), vec3(943.480224, -1486.281250, 23.047092)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1384.002808, -628.590210, 36.940442)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Bahama Mamas Bar"] = {
                Sprite = 93,
                Coords = vec3(-1391.767090, -611.674622, 31.880452)
            }
        },
        ClearArea = {
            Coords = {vec3(-1385.336060, -617.688782, 31.000000), vec3(-1394.961670, -606.756896, 31.000000),
                      vec3(1416.711548, 1155.256958, 114.497986)},
            radius = 20.0
        }
    },
    ["sawmill"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-841.72, 5401, 34.62)},
                Duty = true,
                Grade = 5
            },
            Duty = {
                Coords = {vec3(-567.04, 5243.43, 70.47)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-567.45, 5252.97, 70.49)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-486.75, 5373.67, 78.57), vec3(-508.4, 5257.82, 80.62), vec3(-580.12, 5277.56, 70.34)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["casino"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(957.37, 55.75, 75.44)},
                Duty = true,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(959.29, 34.29, 71.84)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(939.9, 25.09, 71.83), vec3(937.167420, 26.878266, 71.833626),
                          vec3(939.976014, 27.662290, 71.833626), vec3(960.370788, 72.421464, 112.554542)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(987.01, 31.81, 70.24)},
                Duty = true,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(954.92, 1.43, 71.84)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["flametires"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1187.04, 2637.31, 38.04)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(1187.51, 2635.88, 38.4)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(1189.49, 2643.47, 38.4)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(1189.15, 2638.28, 38.44)},
                Duty = true,
                Grade = 1
            },
            MechanicMenu = {
                Coords = {vec3(1174.91, 2640.51, 37.17)},
                Duty = true,
                Grade = 1
            }
        }
        -- Blips = {
        --    ["Flame Tires"] = {
        --        Sprite = 446,
        --        Coords = vec3(1180.48, 2639.97, 48.66)
        --    }
        -- }
    },
    ["downtowncab"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(897.31, -170.88, 74.67)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(893.09, -170.34, 74.67)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(900.3, -166.74, 74.17)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(888.11, -154.28, 76.89)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Taxislužba Downtown Cab Co."] = {
                Sprite = 198,
                Coords = vec3(897.47, -160.72, 95.48)
            }
        },
        ClearArea = {
            Coords = {vec3(906.19, -159.65, 74.17)},
            radius = 20.0
        }
    },
    ["yellowjack"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1998, 3047.52, 50.51)},
                Duty = true,
                Grade = 6
            },
            Duty = {
                Coords = {vec3(1988.56, 3051.06, 50.51)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(1982.14, 3052.91, 47.22), vec3(1986.48, 3048.8, 50.5), vec3(1965.0510253906, 3029.7961425782,47.383434295654)},
                Duty = true,
                Grade = 2
            },
            Cloakroom = {
                Coords = {vec3(1992.23, 3047.64, 50.5)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(1994.36, 3043.05, 47.21), vec3(2001.16, 3044.75, 46.99)},
                Duty = true,
                Grade = 3
            },
            Vault = {
                Coords = {vec3(1987.98, 3047.66, 50.5)},
                Duty = true,
                Grade = 3
            }
        },
        Blips = {
            ["Yellow Jack"] = {
                Sprite = 93,
                Coords = vec3(1994.31, 3050.59, 47.21)
            }
        },
        ClearArea = {
            Coords = {vec3(1994.31, 3050.59, 47.21)},
            radius = 20.0
        }
    },
    ["night"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(126.19, -3007.91, 7.04), vec3(-1206.602172, -1170.698242, 2.352042)},
                Duty = true,
                Grade = 5   
            },
            Duty = {
                Coords = {vec3(124.6, -3011.53, 7.04)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(153.9, -3011.16, 7.04), vec3(-1210.326538, -1164.093750, 2.352044)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(128.6, -3013.57, 7.04), vec3(583.01861572266, -428.14419555664, 17.62378501892),
                          vec3(-1181.769166, -1155.252808, 2.353052),
                          vec3(1094.8354492188, -3097.9438476562, -38.99995803833),
                          vec3(1101.41796875, -3098.0764160156, -38.99995803833)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(145.69, -3011.29, 7.04), vec3(-1181.805786, -1160.091308, 2.353048),
                          vec3(-1182.530030, -1152.301026, 2.353130)},
                Duty = true,
                Grade = 2
            },
            PersonalCloset = {
                Coords = {vec3(152.29699707032, -3014.4970703125, 7.040888786316)},
                Duty = false,
                Grade = 2
            },
            MechanicMenu = {
                Coords = {vec3(144.98, -3030.08, 7.04), vec3(135.67, -3029.95, 7.04), vec3(125.5, -3041.21, 7.04),
                          vec3(126.4, -3034.73, 7.04), vec3(125.32, -3047.28, 7.04), vec3(124.75, -3022.78, 7.04)},
                Duty = true,
                Grade = 2
            }
        },
        Blips = {
            ["Midnight"] = {
                Sprite = 124,
                Coords = vec3(139.47, -3032.4, 7.06)
            },
            ["Relas Club"] = {
                Sprite = 739,
                Coords = vec3(-1194.9243164062, -1162.4451904296, -0.6478585600853)
            }

        }
    },
    ["tequila"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-572.82, 286.45, 79.18)},
                Duty = false,
                Grade = 4
            },
            Fridge = {
                Coords = {vec3(-562.05, 289.77, 82.18), vec3(-562.42, 285.2, 82.18), vec3(-565.5, 286.27, 85.38)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-566.98, 279.79, 82.98)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-568.56, 291.13, 79.18)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Tequi-la-la"] = {
                Sprite = 93,
                Coords = vec3(-573.03, 285.99, 83.14)
            }
        },
        ClearArea = {
            Coords = {vec3(-572.667542, 289.882660, 79.176674), vec3(-555.952454, 288.288056, 82.176292),
                      vec3(-556.059326, 281.465332, 82.176292)},
            radius = 10.0
        }
    },
    ["midas"] = {
        Places = {
            Duty = {
                Coords = {vec3(-63.507690, -2518.404296, 7.391968)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(-59.525276, -2518.562744, 7.391968)},
                Duty = false,
                Grade = 6
            },
            Fridge = {
                Coords = {vec3(131.99, -1285.67, 29.27), vec3(129.47, -1281.18, 29.27)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-52.813186, -2525.195556, 7.391968)},
                Duty = false,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(-61.978020, -2516.268066, 7.391968)},
                Duty = false,
                Grade = 6
            },
            Storage = {
                Coords = {vec3(-57.309890, -2519.472412, 7.391968), vec3(-54.778022, -2521.199952, 7.391968)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["mesa"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(371.06, -332.73, 48.11)},
                Duty = true,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(364.03, -336.89, 46.78)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(361.49, -343.32, 46.78), vec3(367.01, -344.93, 46.78)},
                Duty = true,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(367.31, -335.55, 46.78)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(374.06, -333.29, 48.11)},
                Duty = true,
                Grade = 5
            },
            Storage = {
                Coords = {vec3(364.91, -335.84, 46.78)},
                Duty = true,
                Grade = 3
            }
        },
        Blips = {
            ["La Mesa"] = {
                Sprite = 77,
                Coords = vec3(369.67, -342.54, 52.57)
            }
        }
    },
    ["marlowe"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1876.76, 2059.31, 145.57)},
                Duty = true,
                Grade = 8
            },
            Duty = {
                Coords = {vec3(-1876.46, 2057.98, 135.97)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1890.27, 2064.38, 145.57), vec3(-1869.03, 2066.07, 140.98)},
                Duty = true,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1887.27, 2070.19, 145.57), vec3(-1874.52, 2062.74, 135.92)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1896.21, 2069.85, 144.86)},
                Duty = true,
                Grade = 5
            }
        },
        Blips = {
            ["Vinice Marlowe"] = {
                Sprite = 93,
                Coords = vec3(-1890.95, 2046.64, 135.97)
            }
        },
        ClearArea = {
            Coords = {vec3(-1890.95, 2046.64, 135.97)},
            radius = 100.0
        }
    },
    ["walker"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-4.024620, 522.947388, 170.623566), vec3(-628.237304, 225.132720, 81.881462)},
                Duty = false,
                Grade = 3
            },
            Fridge = {
                Coords = {vec3(-635.41, 233.64, 81.88), vec3(-631.88, 228.06, 81.88)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-634.55, 225.9, 81.88)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-631.43, 223.74, 81.88)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Kavárna Bean Machine"] = {
                Sprite = 93,
                Coords = vec3(-623.59, 234.86, 81.88)
            }
        }
    },
    ["fordw"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(2403.55, 3127.79, 48.15)},
                Duty = false,
                Grade = 6
            },
            Duty = {
                Coords = {vec3(2369.01, 3155.55, 49.05)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(2399.96, 3124.44, 48.15)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(2347.81, 3128.38, 48.21), vec3(2351.779542, 3137.201660, 48.208702)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Vrakoviště Ford's Recyclation"] = {
                Sprite = 779,
                Coords = vec3(2386.53, 3091.68, 48.15)
            }
        },
        ClearArea = {
            Coords = {vec3(2386.53, 3091.68, 48.15)},
            radius = 60.0
        }
    },
    ["reapers"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-119.89, 6374.62, 32.11)},
                Duty = false,
                Grade = 9
            },
            Fridge = {
                Coords = {vec3(-116.84, 6385.7, 32.1), vec3(-125.07, 6374.11, 32.1)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-116.74, 6371.26, 31.5)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-103.99, 6384.48, 31.43), vec3(-126.532288, 6365.200684, 28.495286)},
                Duty = false,
                Grade = 3
            },
            Vault = {
                Coords = {vec3(-114.925674, 6377.180176, 32.099826)},
                Duty = false,
                Grade = 5
            },
            Duty = {
                Coords = {vec3(-113.055122, 6387.573730, 32.459450)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Mojito Inn"] = {
                Sprite = 93,
                Coords = vec3(-116.42, 6382.11, 32.1)
            }
        },
        ClearArea = {
            Coords = {vec3(-116.42, 6382.11, 32.1), vec3(-127.564698, 6374.540040, 32.200000), vec3(-109.481010, 6373.254394, 32.200000)},
            radius = 15.0
        }
    },
    ["catcafe"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-577.569396, -1067.565552, 26.614074)},
                Duty = false,
                Grade = 4
            },
            Fridge = {
                Coords = {vec3(-590.285034, -1058.833984, 22.344214), vec3(-588.55, -1066.49, 22.34)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-586.582154, -1050.196534, 22.344202)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-597.790222, -1064.079712, 22.344190)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["UwU Cat Cafe"] = {
                Sprite = 463,
                Coords = vec3(-583.320434, -1060.735230, 22.344204)
            }
        }
    },
    ["gsf"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-12.49, -1435.15, 31.1)},
                Duty = false,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(-12.362986, -1426.133300, 30.672704)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["vagos"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(350.520844, -2027.380004, 22.184214)},
                Duty = false,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(332.504638, -2018.539916, 22.354146)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["ballas"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(117.99, -2008.98, 18.5)},
                Duty = false,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(114.99, -1989.32, 18.4)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(117.06, -2004.07, 15.1)},
                Duty = false,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(114.16, -2002.83, 18.5)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(119.09, -2002.83, 18.5)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["fm"] = {
        Places = {
            Duty = {
                Coords = {vec3(-1123.567750, 4888.712402, 218.476578)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1153.023804, 4900.646972, 220.978180), vec3(-1112.363404, 4943.854980, 218.449646)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1142.561524, 4907.437012, 220.973542)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1126.167358, 4884.018554, 218.476578)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(-1120.057374, 4885.851074, 218.486710)},
                Duty = false,
                Grade = 2
            }
        }
    },
    ["arasaka"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-981.510070, 1317.747192, 199.246018)},
                Duty = true,
                Grade = 7
            },
            Duty = {
                Coords = {vec3(-988.756958, 1329.146118, 199.245956)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-993.175416, 1336.052368, 199.246110)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-967.696716, 1338.741944, 197.066268)},
                Duty = true,
                Grade = 1
            }
        }
    },
    ["mirrorllc"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-82.461204528808, -796.6196899414, 44.227348327636)},
                Duty = false,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(-78.77643585205, -796.46875, 44.227325439454)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["herrkutz"] = {
        Blips = {
            ["Herr Kutz Barber"] = {
                Sprite = 106,
                Coords = vec3(142.821274, -1712.906738, 35.699996)
            }
        }
    },
    ["bennys"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-240.487916, -1318.905518, 30.880616), vec3(-233.907684, -1317.560424, 30.880616)},
                Duty = true,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(-223.661530, -1336.786866, 30.880616)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-237.797806, -1336.984620, 30.880616)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-223.992234, -1319.967652, 30.890236), vec3(-228.039550, -1340.584594, 30.880616)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(-227.169236, -1315.015380, 30.880616)},
                Duty = true,
                Grade = 6
            },
            MechanicMenu = {
                Coords = {vec3(-221.657136, -1330.074708, 30.594116), vec3(-221.815384, -1324.114258, 30.594116), vec3(-196.404388, -1332.210938, 30.594116), vec3(-196.905488, -1338.870362, 30.594116)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-233.156036, -1338.923096, 30.880616)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Benny's"] = {
                Sprite = 669,
                Coords = vec3(-218.537536, -1327.639160, 31.000000)
            }
        }
    },
    ["bec"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(90.261750, 6352.027344, 40.397030)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(92.509400, 6347.346192, 40.397030)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(95.024200, 6348.312988, 31.350280)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(115.237144, 6367.360352, 31.350280), vec3(106.749588, 6345.087890, 31.350280)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(97.273400, 6354.068360, 40.397034)},
                Duty = true,
                Grade = 4
            }
        }
    },
    ["pizza"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(798.560608, -750.680726, 31.265892)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(803.897584, -761.290162, 31.265890)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(809.879150, -759.097534, 31.265884)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(806.197388, -764.836854, 26.780848), vec3(808.478028, -761.079956, 22.295840),
                          vec3(809.819030, -756.330628, 22.295836)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(796.390564, -749.417846, 31.265884)},
                Duty = true,
                Grade = 4
            },
            Fridge = {
                Coords = {vec3(813.412110, -749.034606, 26.780834), vec3(799.725036, -759.416932, 31.265874),
                          vec3(806.317566, -761.655518, 26.780848)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(810.862244, -764.275696, 31.265884)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Pizza This"] = {
                Sprite = 273,
                Coords = vec3(800.698182, -748.118836, 360.000000)
            }
        }
    },
    ["animclin"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1400.980712, -442.908692, 36.558758)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(-1408.012208, -438.484436, 36.557656)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1400.225586, -438.699920, 36.558742)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1398.774170, -441.620788, 36.558738)},
                Duty = true,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(-1403.115478, -444.411988, 36.558738)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Zvířecí klinika Los Santos"] = {
                Sprite = 442,
                Coords = vec3(-1404.813720, -438.762756, 38.058738)
            }
        }
    },
    ["sushi"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-146.575806, 295.799530, 98.872330)},
                Duty = true,
                Grade = 6
            },
            Duty = {
                Coords = {vec3(-174.005966, 301.672272, 100.923202)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-173.048478, 305.993500, 100.923202)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-176.589538, 309.406250, 97.990982)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-172.654418, 291.961640, 93.763154), vec3(-177.632920, 305.847840, 97.459960),
                          vec3(-172.345200, 307.976990, 97.990998)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Sakura Sushi Bar"] = {
                Sprite = 120,
                Coords = vec3(-162.037078, 302.185760, 94.000000)
            }
        },
        ClearArea = {
            Coords = {vec3(-176.089798, 303.223510, 100.923150)},
            radius = 10.0
        }
    },
    ["nauticw"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-771.208618, -1324.882690, 9.599990)},
                Duty = true,
                Grade = 4
            },
            Duty = {
                Coords = {vec3(-762.825928, -1310.431030, 9.600000)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-760.661438, -1328.281250, 9.600002)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Lodní doprava Nautic Wolf"] = {
                Sprite = 455,
                Coords = vec3(-764.756896, -1328.944214, 6.000000)
            }
        }
    },
    ["raven"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(990.566894, -2149.550782, 30.205342)},
                Duty = false,
                Grade = 6
            },
            Storage = {
                Coords = {vec3(976.827820, -2129.552002, 30.475466)},
                Duty = false,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(987.788636, -2126.806396, 30.475578)},
                Duty = false,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(966.281616, -2187.081298, 30.131264)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["comedy"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-431.110352, 279.167846, 83.015922)},
                Duty = true,
                Grade = 4
            },
            Storage = {
                Coords = {vec3(-448.662232, 269.593048, 83.015922)},
                Duty = true,
                Grade = 2
            },
            Fridge = {
                Coords = {vec3(-444.553680, 266.714904, 83.015922)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(-428.569458, 275.290192, 83.015922)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Comedy Club"] = {
                Sprite = 362,
                Coords = vec3(-438.016082, 270.996124, 84.000000)
            }
        }
    },
    ["bigjam"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(171.203156, -1722.767456, 29.391704)},
                Duty = true,
                Grade = 2
            },
            Storage = {
                Coords = {vec3(162.504150, -1715.985596, 29.291882)},
                Duty = true,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(167.147460, -1709.819702, 29.291822)},
                Duty = false,
                Grade = 1
            }
        },
        Blips = {
            ["Myčka BigJam"] = {
                Sprite = 100,
                Coords = vec3(174.009674, -1731.405884, 29.288282)
            }
        }
    },
    ["sbcs"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1366.076050, -479.356476, 31.595738)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(-1367.847900, -466.198944, 31.595728)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["JFC"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1056.328002, -2375.921875, 25.899632)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(1073.039550, -2398.702392, 25.894412)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(1066.445190, -2386.697022, 25.899658)},
                Duty = true,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(1048.953614, -2383.158936, 25.899626)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(1049.334228, -2393.562500, 25.899614)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(1058.157836, -2376.109130, 25.899556)},
                Duty = true,
                Grade = 2
            }
        },
        Blips = {
            ["JFC Fight Club"] = {
                Sprite = 88,
                Coords = vec3(1073.941528, -2407.345458, 31.000000)
            }
        }
    },
    ["burger"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1178.386840, -895.812562, 13.974190)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(-1188.500976, -900.893738, 13.974178)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1182.672242, -898.380188, 13.974188)},
                Duty = false,
                Grade = 1
            },
            PersonalCloset = {
                Coords = {vec3(-1181.122558, -900.813904, 13.974188)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1198.747802, -903.637756, 13.974190), vec3(-1194.799682, -896.747070, 13.974184),
                          vec3(-1196.438476, -894.333008, 13.974182), vec3(-1179.153076, -894.685120, 13.974188)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1200.814332, -901.218934, 13.974186)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Burger Shot"] = {
                Sprite = 106,
                Coords = vec3(-1188.864136, -891.212768, 14.730670)
            }
        }
    },
    ["galaxy"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(390.776886, 269.782074, 94.991096)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(389.422028, 272.730866, 94.991082)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(393.592988, 279.213012, 94.991096)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(379.212188, 258.586274, 92.190002)},
                Duty = true,
                Grade = 2
            },
            Fridge = {
                Coords = {vec3(352.201600, 288.331420, 91.190354), vec3(356.059296, 282.043824, 94.190934),
                          vec3(384.162902, 280.092316, 94.991074)},
                Duty = true,
                Grade = 2
            },
            Vault = {
                Coords = {vec3(1058.157836, -2376.109130, 25.899556)},
                Duty = true,
                Grade = 3
            }
        },
        Blips = {
            ["Galaxy Club"] = {
                Sprite = 93,
                Coords = vec3(351.672822, 288.773560, 92.000000)
            }
        }
    },
    ["esposito"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-1180.597046, -1408.419190, 10.524068)},
                Duty = true,
                Grade = 5
            },
            Duty = {
                Coords = {vec3(-1186.177612, -1397.792602, 4.472944)},
                Duty = false,
                Grade = 1
            },
            Cloakroom = {
                Coords = {vec3(-1189.344238, -1387.194824, 4.642858)},
                Duty = false,
                Grade = 1
            },
            Storage = {
                Coords = {vec3(-1196.268188, -1404.035156, 4.472946), vec3(-1194.265870, -1396.195800, 4.472948),
                          vec3(-1198.638672, -1399.526856, 4.472946), vec3(-1195.314698, -1397.222534, 10.524064),
                          vec3(-1191.048218, -1410.416382, 10.524072), vec3(-1182.688842, -1403.237426, 10.524074)},
                Duty = true,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(-1198.401490, -1401.960694, 4.472948)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(-1180.869140, -1406.212280, 13.834844)},
                Duty = true,
                Grade = 5
            }
        },
        Blips = {
            ["Ristorante Esposito"] = {
                Sprite = 93,
                Coords = vec3(-1191.506958, -1395.227172, 4.472950)
            }
        }
    },
    ["dailyglobe"] = {
        Places = {
            Duty = {
                Coords = {vec3(-1049.9, -241.68, 44.3)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(-1056.21, -234.21, 44.3)},
                Duty = true,
                Grade = 2
            },
            Storage = {
                Coords = {vec3(-1052.0466308594, -232.67431640625, 44.376895904542)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Daily Globe"] = {
                Sprite = 590,
                Coords = vec3(-1051.798828125, -233.16902160644, 58.056861877442)
            }
        }
    },
    ["pawnshop"] = {
        Places = {
            Duty = {
                Coords = {vec3(552.298768, 2671.580566, 35.639588)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(551.601258, 2668.818848, 35.639584)},
                Duty = true,
                Grade = 2
            }
           
        },
        Blips = {
            ["Pawn Shop"] = {
                Sprite = 267,
                Coords = vec3(559.945374, 2674.313720, 36.000000)
            }
        }
    },
    ["faa"] = {
        Places = {
            Duty = {
                Coords = {vec3(-1034.878784, -2856.445556, 37.976730)},
                Duty = false,
                Grade = 1
            },
            Bossmenu = {
                Coords = {vec3(-1044.291016, -2864.448730, 34.476586)},
                Duty = true,
                Grade = 2
            }
        },
        Blips = {
            ["Státní letecký úřad"] = {
                Sprite = 564,
                Coords = vec3(-1034.881104, -2856.444092, 37.976730)
            }
        }
    },
    ["santosmc"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(2518.62, 4098.09, 35.59)},
                Duty = true,
                Grade = 11
            },
            Duty = {
                Coords = {vec3(2513.92, 4100.06, 35.59)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(2511.88, 4097.39, 38.58)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(2517.62, 4106.6, 35.59)},
                Duty = true,
                Grade = 10
            },
            Storage = {
                Coords = {vec3(2526.8, 4109.48, 38.58)},
                Duty = true,
                Grade = 1
            },
            Cloakroom ={
                Coords = {vec3(2521.13, 4102.69, 35.59)},
                Duty = true,
                Grade = 1
            }
        },
        Blips = {
            ["Santa Madre"] = {
                Sprite = 93,
                Coords = vec3(2521.13, 4102.69, 35.59)
            }
        }
    },
    ["wannabe"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(839.934020, -1060.273438, 27.940676)},
                Duty = true,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(843.460938, -1062.406372, 27.940676)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["church"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(-768.606018, -17.274546, 44.775128)},
                Duty = true,
                Grade = 1
            },
            Duty = {
                Coords = {vec3(-771.247864, -18.469032, 44.778630)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["oneill"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(2438.719238, 4962.271972, 46.810588)},
                Duty = true,
                Grade = 3
            },
            Duty = {
                Coords = {vec3(2440.885498, 4970.973632, 46.810600)},
                Duty = false,
                Grade = 1
            },
            Fridge = {
                Coords = {vec3(2441.677978, 4979.715820, 46.810588)},
                Duty = true,
                Grade = 1
            },
            Vault = {
                Coords = {vec3(2444.355958, 4966.744628, 46.810588)},
                Duty = true,
                Grade = 3
            },
            Storage = {
                Coords = {vec3(2455.846680, 4993.491700, 46.810338)},
                Duty = true,
                Grade = 1
            },
            Cloakroom ={
                Coords = {vec3(2455.269288, 4972.286132, 46.810230)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["marabunte"] = {
        Places = {
            Bossmenu = {
                Coords = {vec3(1282.496704, -1615.516480, 58.345826)},
                Duty = true,
                Grade = 2
            },
            Duty = {
                Coords = {vec3(1292.426392, -1615.978028, 58.345826)},
                Duty = false,
                Grade = 1
            }
        }
    },
    ["ihatenpcs"] = {
        ClearArea = {
            Coords = {vec3(-719.910766, 618.036376, 154.960098), vec3(-702.727906, 650.718078, 155.139862),
                      vec3(-1510.456666, 138.321732, 56.540000), vec3(-1543.283448, 105.912522, 57.919998),
                      vec3(-1543.144898, 129.595444, 57.919998), vec3(-1484.949708, 197.543076, 56.080002),
                      vec3(-1440.234498, 201.568420, 57.919998), vec3(-678.355042, 903.544616, 231.282226), 
                      vec3(-204.636764, -1331.902100, 34.899444), vec3(713.683532, 4182.395508, 41.445434),
                      vec3(727.978028, 4172.848144, 41.445434), vec3(-449.578034, 5994.000000, 33.896728)},
            radius = 10.0
        }
    },
    ["merryweather"] = {
        ClearArea = {
            Coords = {vec3(525.956848, -3131.761962, 2.000000)},
            radius = 70.0
        }
    }
}

Config.Texts = {
    Bossmenu = "Boss menu",
    Duty = "Služba",
    Cloakroom = "Šatna",
    Fridge = "Lednice",
    Storage = "Sklad",
    Vault = "Trezor",
    Licenses = "Vydávání licencí",
    WeaponRegister = "Registr zbraní",
    PersonalCloset = "Skříňka",
    Armory = "Výdej věcí",
    MechanicMenu = "Mechanik menu",
    ClearArea = "maže NPC"
}

Config.Licenses = {{
    Name = "PPL-A",
    Label = "Soukromý pilot letounu"
}, {
    Name = "CPL-A",
    Label = "Obchodní pilot letounu"
}, {
    Name = "ATPL-A",
    Label = "Dopravní pilot letounu"
}, {
    Name = "PPL-H",
    Label = "Soukromý pilot helikoptéry"
}, {
    Name = "CPL-H",
    Label = "Obchodní pilot helikoptéry"
}, {
    Name = "ATPL-H",
    Label = "Dopravní pilot helikoptéry"
}, {
    Name = "MEP",
    Label = "Přeškolení pro vícemotorové letouny"
}, {
    Name = "ACR",
    Label = "Přeškolení pro akrobacii"
}, {
    Name = "NIGHT",
    Label = "Přeškolení pro noční lety"
}, {
    Name = "PARA",
    Label = "Přeškolení pro skákání padákem"
}}

