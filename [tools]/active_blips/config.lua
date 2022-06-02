Config = {}
Config.refreshTime = 1
Config.newIncomersDelay = 1
Config.flashTimeout = 60000 * 1
Config.defaultBlipSettings = {
    sprite = {
        ["foot"] = 57,
        ["automobile"] = 225,
        ["bike"] = 226,
        ["plane"] = 584,
        ["heli"] = 64,
        ["boat"] = 755
    },
    display = 4,
    scale = 0.6,
    isShortRange = true,
    colour = 4,
    category = 7
}

Config.defaultFloatingBlipSettings = {
    sprite = 755,
    display = 4,
    scale = 0.9,
    isShortRange = true,
    colour = 40,
    category = 7,
    text = "PLAVIDLO"
}

Config.defaultFlyingBlipSettings = {
    sprite = 584,
    display = 4,
    scale = 0.9,
    isShortRange = true,
    colour = 40,
    category = 7
}

Config.jobSettings = {
    ["lspd"] = {
        blipSettings = {
            colour = {
                default = 26,
                adminColour = 26
            },
            sprite = {
                ["automobile"] = {
                    default = 56
                }
            },
            scale = 0.9
        },
        specificallySee = {
            ["lspd"] = true,
            ["lssd"] = true,
            ["lsfd"] = true,
            ["sahp"] = true,
            ["ems"] = true
        },
        secretAvailable = {
            grade = 11
        },
        tagAvailable = {
            grade = 1
        }
    },
    ["sahp"] = {
        blipSettings = {
            colour = {
                default = 47,
                adminColour = 47
            },
            sprite = {
                ["automobile"] = {
                    default = 56
                }
            },
            scale = 0.9
        },
        specificallySee = {
            ["lspd"] = true,
            ["lssd"] = true,
            ["lsfd"] = true,
            ["sahp"] = true,
            ["ems"] = true
        },
        secretAvailable = {
            grade = 7
        },
        tagAvailable = {
            grade = 1
        }
    },
    ["lssd"] = {
        blipSettings = {
            colour = {
                default = 25,
                adminColour = 25
            },
            sprite = {
                ["automobile"] = {
                    default = 56
                }
            },
            scale = 0.9
        },
        specificallySee = {
            ["lspd"] = true,
            ["lssd"] = true,
            ["lsfd"] = true,
            ["sahp"] = true,
            ["ems"] = true
        },
        secretAvailable = {
            grade = 6
        },
        tagAvailable = {
            grade = 1
        }
    },
    ["lsfd"] = {
        blipSettings = {
            colour = {
                default = 75,
                adminColour = 75
            },
            sprite = {
                ["automobile"] = {
                    default = 635
                }
            },
            scale = 0.9
        },
        specificallySee = {
            ["lspd"] = true,
            ["lssd"] = true,
            ["lsfd"] = true,
            ["sahp"] = true,
            ["ems"] = true
        },
        tagAvailable = {
            grade = 1
        },
        secretAvailable = {
            grade = 20
        }
    },
    ["ems"] = {
        blipSettings = {
            colour = {
                default = 55,
                adminColour = 8,
                grade = {
                    ["10"] = 8
                }
            },
            sprite = {
                ["foot"] = {
                    default = 57,
                    grade = {
                        ["10"] = 621
                    }
                },
                ["automobile"] = {
                    default = 659
                }
            },
            scale = 0.9
        },
        specificallySee = {
            ["lspd"] = true,
            ["lssd"] = true,
            ["lsfd"] = true,
            ["sahp"] = true,
            ["ems"] = true
        },
        tagAvailable = {
            grade = 1
        },
        secretAvailable = {
            grade = 25
        }
    },
    ["airseal"] = {
        blipSettings = {
            colour = {
                default = 24
            },
        },
        specificallySee = nil,
        seeAir = true
    }
}

Config.specificVehicle = {
    ["-1520196593"] = "heli",
    ["1664225903"] = "bike",
    ["1392424197"] = "bike"
}

Config.floatingBlip = {
    ["boat"] = true
}

Config.flyingBlip = {
    ["heli"] = true,
    ["plane"] = true
}
