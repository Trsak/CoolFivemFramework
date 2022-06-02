Config = {}

Config.ComponentsMenuPosition = {"helmet", "mask", "glasses", "top", "belt", "pants", "shoes", "bag", "bproof", "ears", "chain", "bracelet", "watches", "clothes", "bra", "panties"}

Config.IgnoreComponentsTakeOff = {
    [0] = {
        ["1"] = {{0, 0}},
        ["3"] = {{15, 0}},
        ["4"] = {{64, 1}},
        ["5"] = {{0, 0}},
        ["6"] = {{34, 0}},
        ["7"] = {{0, 0}},
        ["8"] = {{15, 0}},
        ["9"] = {{0, 0}},
        ["10"] = {{0, 0}},
        ["11"] = {{15, 0}}
    },
    [1] = {
        ["1"] = {{0, 0}},
        ["3"] = {{15, 0}},
        ["4"] = {{202, 0}},
        ["5"] = {{0, 0}},
        ["6"] = {{35, 0}},
        ["7"] = {{0, 0}},
        ["8"] = {{34, 0}},
        ["9"] = {{0, 0}},
        ["10"] = {{0, 0}},
        ["11"] = {{260, 0}}
    }
}

Config.IgnorePropsTakeOff = {
    [0] = {
        ["0"] = {{-1, 0}},
        ["1"] = {{-1, 0}},
        ["2"] = {{-1, 0}},
        ["6"] = {{-1, 0}},
        ["7"] = {{-1, 0}}
    },
    [1] = {
        ["0"] = {{-1, 0}},
        ["1"] = {{-1, 0}},
        ["2"] = {{-1, 0}},
        ["6"] = {{-1, 0}},
        ["7"] = {{-1, 0}}
    }
}

Config.NakedComponents = {
    mask = {
        label = "Sundat masku",
        name = "Maska",
        commands = {"mask", "maska"},
        progress = {
            text = "Nasazuješ si masku",
            animDict = "missfbi4",
            anim = "takeoff_mask"
        },
        takeoff = {
            animDict = "missfbi4",
            anim = "takeoff_mask"
        },
        components = {
            ["1"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            }
        }
    },
    helmet = {
        label = "Sundat helmu / čepici",
        name = "Helma / Čepice",
        commands = {"helmet", "helm", "helma", "cap", "čepice", "hat"},
        progress = {
            text = "Nasazuješ si helmu / čepici",
            animDict = "mp_masks@standard_car@ds@",
            anim = "put_on_mask"
        },
        takeoff = {
            animDict = "missheist_agency2ahelmet",
            anim = "take_off_helmet_stand"
        },
        props = {
            ["0"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        }
    },
    glasses = {
        label = "Sundat brýle",
        name = "Brýle",
        commands = {"glasses", "bryle"},
        progress = {
            text = "Nasazuješ si brýle",
            animDict = "clothingspecs",
            anim = "try_glasses_positive_a"
        },
        takeoff = {
            animDict = "clothingspecs",
            anim = "take_off"
        },
        props = {
            ["1"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        }
    },
    top = {
        label = "Sundat si vršek oblečení",
        name = "Vršek oblečení",
        commands = {"top", "tricko", "triko", "vrsek", "tshirt", "torso", "arms"},
        progress = {
            text = "Nasazuješ si vršek oblečení",
            animDict = "clothingtie",
            anim = "try_tie_neutral_a"
        },
        takeoff = {
            animDict = "clothingtie",
            anim = "try_tie_neutral_a"
        },
        components = {
            ["8"] = {
                [0] = {15, 0},
                [1] = {34, 0}
            },
            ["11"] = {
                [0] = {15, 0},
                [1] = {546, 2}
            },
            ["10"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["3"] = {
                [0] = {15, 0},
                [1] = {15, 0}
            }
        }
    },
    belt = {
        label = "Sundat si opasek, tričko nebo doplňek",
        name = "Opasek, tričko nebo doplňek",
        commands = {"belt", "opasek", "doplnek", "accessory", "acesory", "acessory", "acsesory", "tricko2", "tshirt2"},
        progress = {
            text = "Nasazuješ si opasek, tričko nebo doplněk",
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        takeoff = {
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        components = {
            ["8"] = {
                [0] = {15, 0},
                [1] = {15, 0}
            }
        }
    },
    bra = {
        label = "Sundat si vršek a podprsenku",
        name = "Podprsenka",
        restricted = 1,
        commands = {"top2", "tricko2", "triko2", "vrsek2", "tshirt2", "torso2", "arms2", "bra", "podprsenka", "podprda"},
        progress = {
            text = "Nasazuješ si podprsenku a vršek",
            animDict = "clothingtie",
            anim = "try_tie_neutral_a"
        },
        takeoff = {
            animDict = "clothingtie",
            anim = "try_tie_neutral_a"
        },
        components = {
            ["8"] = {
                [0] = {15, 0},
                [1] = {34, 0}
            },
            ["11"] = {
                [0] = {15, 0},
                [1] = {260, 0}
            },
            ["10"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["3"] = {
                [0] = {15, 0},
                [1] = {274, 0}
            }
        }
    },
    pants = {
        label = "Sundat si kalhoty",
        name = "Kalhoty",
        commands = {"pants", "kalhoty"},
        progress = {
            text = "Nasazuješ si kalhoty",
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        takeoff = {
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        components = {
            ["4"] = {
                [0] = {64, 1},
                [1] = {15, 0}
            }
        }
    },
    panties = {
        label = "Sundat si kalhoty a kalhotky",
        name = "Kalhotky",
        restricted = 1,
        commands = {"pants2", "kalhoty2", "kalhotky", "panties", "undies", "underwear", "bombardaky"},
        progress = {
            text = "Nasazuješ si kalhotky a kalhoty",
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        takeoff = {
            animDict = "re@construction",
            anim = "out_of_breath"
        },
        components = {
            ["4"] = {
                [0] = {64, 1},
                [1] = {202, 0}
            }
        }
    },
    shoes = {
        label = "Sundat si boty",
        name = "Boty",
        commands = {"shoes", "boty"},
        progress = {
            text = "Nasazuješ si boty",
            animDict = "random@domestic",
            anim = "pickup_low"
        },
        takeoff = {
            animDict = "random@domestic",
            anim = "pickup_low"
        },
        components = {
            ["6"] = {
                [0] = {34, 0},
                [1] = {35, 0}
            }
        }
    },
    clothes = {
        label = "Sundat si všechno oblečení",
        name = "Oblečení",
        commands = {"outfit", "clothes", "set", "vsechno", "all", "vsechno", "obleceni"},
        progress = {
            text = "Nasazuješ si oblečení",
            animDict = "missmic4",
            anim = "michael_tux_fidget"
        },
        takeoff = {
            animDict = "clothingtie",
            anim = "try_tie_neutral_a"
        },
        props = {
            ["0"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            },
            ["1"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            },
            ["2"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            },
            ["6"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            },
            ["7"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        },
        components = {
            ["1"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["3"] = {
                [0] = {15, 0},
                [1] = {15, 0}
            },
            ["4"] = {
                [0] = {64, 1},
                [1] = {15, 0}
            },
            ["5"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["6"] = {
                [0] = {34, 0},
                [1] = {35, 0}
            },
            ["7"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["8"] = {
                [0] = {15, 0},
                [1] = {34, 0}
            },
            ["9"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["10"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            },
            ["11"] = {
                [0] = {15, 0},
                [1] = {546, 2}
            }
        }
    },
    bag = {
        label = "Sundat si batoh",
        name = "Batoh",
        commands = {"bag", "batoh"},
        progress = {
            text = "Nasazuješ si batoh",
            animDict = "anim@heists@ornate_bank@grab_cash",
            anim = "intro"
        },
        takeoff = {
            animDict = "anim@heists@ornate_bank@grab_cash",
            anim = "intro"
        },
        components = {
            ["5"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            }
        }
    },
    bproof = {
        label = "Sundat si vestu",
        name = "Vesta",
        commands = {"bproof", "vest", "vesta"},
        progress = {
            text = "Nasazuješ si vestu",
            animDict = "clothingtie",
            anim = "try_tie_negative_a"
        },
        takeoff = {
            animDict = "clothingtie",
            anim = "try_tie_negative_a"
        },
        components = {
            ["9"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            }
        }
    },
    ears = {
        label = "Sundat si doplňky do uší",
        name = "Doplňky do uší",
        commands = {"ears", "usi", "doplnky", "nausnice"},
        progress = {
            text = "Nasazuješ si doplňky do uší",
            animDict = "mini@ears_defenders",
            anim = "takeoff_earsdefenders_idle"
        },
        takeoff = {
            animDict = "mini@ears_defenders",
            anim = "takeoff_earsdefenders_idle"
        },
        props = {
            ["2"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        }
    },
    chain = {
        label = "Sundat si řetízek",
        name = "Řetízek",
        commands = {"chain", "retizek", "řetízek"},
        progress = {
            text = "Nasazuješ si řetízek",
            animDict = "clothingtie",
            anim = "try_tie_negative_a"
        },
        takeoff = {
            animDict = "clothingtie",
            anim = "try_tie_negative_a"
        },
        components = {
            ["7"] = {
                [0] = {0, 0},
                [1] = {0, 0}
            }
        }
    },
    bracelet = {
        label = "Sundat si náramek",
        name = "Náramek",
        commands = {"bracelet", "naramek", "náramek"},
        progress = {
            text = "Nasazuješ si náramek",
            animDict = "nmt_3_rcm-10",
            anim = "cs_nigel_dual-10"
        },
        takeoff = {
            animDict = "nmt_3_rcm-10",
            anim = "cs_nigel_dual-10"
        },
        props = {
            ["7"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        }
    },
    watches = {
        label = "Sundat si hodinky",
        name = "Hodinky",
        commands = {"watches", "hodinky"},
        progress = {
            text = "Nasazuješ si hodinky",
            animDict = "nmt_3_rcm-10",
            anim = "cs_nigel_dual-10"
        },
        takeoff = {
            animDict = "nmt_3_rcm-10",
            anim = "cs_nigel_dual-10"
        },
        props = {
            ["6"] = {
                [0] = {-1, 0},
                [1] = {-1, 0}
            }
        }
    }
}
