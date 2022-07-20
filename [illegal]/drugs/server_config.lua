ServerConfig = {}

ServerConfig.DrainSpeeds = {
    ["methtable"] = {
        Battery = 0.1,
        Mix = 0.35,
        Quality = 0.35
    }
}

ServerConfig.GainSpeeds = {
    ["methtable"] = {
        Percent = 1.5,
        Quality = 0.5
    },
    ["cokeseed"] = {
        Percent = 0.08271298593879239040529363110008
    },
    ["tray_meth"] = {
        Percent = 4
    }
}

ServerConfig.Crafting = {
    ["coke"] = {
        ["pasta"] = {
            item = "cokepaste",
            count = 1,
            ingredients = {
                cocaplant = {
                    count = 200
                },
                kerosene = {
                    count = 10
                },
                sulfuricacid = {
                    count = 8
                },
                technicalpetrol = {
                    count = 6
                }
            },
            requirements = {
                mixtube = {
                    count = 1
                }
            }
        },
        ["drying"] = {
            item = "tray_pastedryed",
            count = 1,
            ingredients = {
                tray_paste = {
                    count = 1
                }
            }
        },
        ["mixing"] = {
            item = "coke",
            count = 90,
            ingredients = {
                tray_pastedryed = {
                    count = 1
                }
            },
            requirements = {
                mortal = {
                    count = 1
                }
            },
            additions = {
                tray = {
                    count = 1
                }
            }
        },
        ["super_pills"] = {{ -- Balení bilých tabletek z krabičky
            item = "super_pills_packwhite",
            count = 1,
            data = {
                id = "super_pills_packwhite-10",
                amount = 10,
                label = "Zbývá: 10 pilulek"
            },
            ingredients = {
                super_pills_packorange = {
                    count = 1,
                    data = {
                        amount = 10
                    },
                    remove = true
                },
                coke = {
                    count = 5
                },
                bakingsoda = {
                    count = 2
                },
                citricacid = {
                    count = 2
                }
            },
            requirements = {
                super_pills_pillmould = {
                    count = 1
                },
                mortal = {
                    count = 1
                }
            }
        }, { -- Balení bílých super tabletek z pilulek
            item = "super_pills_packwhite",
            count = 1,
            data = {
                id = "super_pills_packwhite-10",
                amount = 10,
                label = "Zbývá: 10 pilulek"
            },
            ingredients = {
                super_pills_orange = {
                    count = 10
                },
                coke = {
                    count = 5
                },
                bakingsoda = {
                    count = 2
                },
                citricacid = {
                    count = 2
                }
            },
            requirements = {
                super_pills_pillmould = {
                    count = 1
                },
                mortal = {
                    count = 1
                }
            }
        }}
    },
    ["meth"] = {
        ["mixing"] = {
            item = "methmix",
            count = 1,
            ingredients = {
                acetone = {
                    count = 3
                },
                bismuth = {
                    count = 3
                },
                hydrogenperoxide = {
                    count = 5
                },
                sulfuricacid = {
                    count = 1
                },
                propyloneglycol = {
                    count = 4
                },
                toluene = {
                    count = 3
                }
            },
            requirements = {
                mixtube = {
                    count = 1
                }
            }
        },
        ["slushing"] = {
            item = "methslush",
            count = 1,
            ingredients = {
                methmix = {
                    count = 1
                }
            }
        },
        ["traying"] = {
            item = "tray_meth",
            count = 1,
            ingredients = {
                methslush = {
                    count = 1
                },
                tray = {
                    count = 1
                }
            }
        },
        ["smashing"] = {
            item = "meth",
            count = {30, 45},
            ingredients = {
                tray_methdryed = {
                    count = 1
                }
            },
            requirements = {
                mortal = {
                    count = 1
                }
            }
        }

    }
}
