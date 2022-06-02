CRAFTING_RECIPES = {
    -- WEED
    {
        item = "weedbag",
        count = 1,
        actionText = "Balíš trávu..",
        duration = 650,
        ingredients = {
            cannabis = {
                count = 5
            },
            drugbag = {
                count = 1
            }
        },
        requirements = {
            scale = {
                count = 1
            }
        }
    },
    {
        item = "joint",
        count = 1,
        actionText = "Balíš joint..",
        duration = 650,
        ingredients = {
            cannabis = {
                count = 1
            },
            joint_paper = {
                count = 1,
                data = {
                    amount = 1
                }
            }
        }
    },
    {
        item = "cannabis",
        count = 5,
        actionText = "Rozbaluješ sáček..",
        duration = 500,
        ingredients = {
            weedbag = {
                count = 1
            }
        },
        additions = {
            drugbag = {
                count = 1
            }
        }
    },
    -- METH
    {
        item = "meth",
        count = {30, 45},
        actionText = "Drtíš břečku..",
        duration = 5000,
        ingredients = {
            tray_smashed = {
                count = 1
            }
        },
        requirements = {
            mortal = {
                count = 1
            }
        }
    },
    {
        item = "meth",
        count = 1,
        actionText = "Rozbaluješ meth..",
        duration = 5000,
        ingredients = {
            methsmallbag = {
                count = 1
            }
        }
    },
    {
        item = "meth",
        count = 100,
        actionText = "Rozbaluješ meth..",
        duration = 500,
        ingredients = {
            methbag = {
                count = 1
            }
        }
    },
    {
        item = "methsmallbag",
        count = 1,
        actionText = "Balíš meth..",
        duration = 1000,
        ingredients = {
            meth = {
                count = 1
            },
            drugbag = {
                count = 1
            }
        },
        requirements = {
            scale = {
                count = 1
            }
        }
    },
    {
        item = "methbag",
        count = 1,
        actionText = "Balíš meth..",
        duration = 5000,
        ingredients = {
            meth = {
                count = 100
            },
            drugbag = {
                count = 1
            }
        },
        requirements = {
            scale = {
                count = 1
            }
        }
    },
    -- COKE
    {
        item = "cokebag",
        count = 1,
        actionText = "Balíš kokain..",
        duration = 1000,
        ingredients = {
            coke = {
                count = 1
            },
            drugbag = {
                count = 1
            }
        },
        requirements = {
            scale = {
                count = 1
            }
        }
    },
    {
        item = "coke",
        count = 1,
        actionText = "Rozbaluješ kokain..",
        duration = 1000,
        ingredients = {
            cokebag = {
                count = 1
            }
        },
        additions = {
            drugbag = {
                count = 1
            }
        }
    },
    {
        item = "cokepack",
        count = 1,
        actionText = "Balíš kokain..",
        duration = 5000,
        ingredients = {
            coke = {
                count = 100
            },
            cokepack_empty = {
                count = 1
            }
        },
        requirements = {
            scale = {
                count = 1
            }
        }
    },
    {
        item = "coke",
        count = 100,
        actionText = "Rozbaluješ kokain..",
        duration = 5000,
        ingredients = {
            cokepack = {
                count = 1
            }
        },
        additions = {
            cokepack_empty = {
                count = 1
            }
        }
    },
    -- Drug crafting
    { -- Míchání pasty
        item = "cokepaste",
        count = 1,
        actionText = "Děláš kokainovou pastu..",
        duration = 30000,
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
    { -- Pasta na tác
        item = "tray_paste",
        count = 1,
        actionText = "Dáváš kokainovou pastu na tác..",
        duration = 30000,
        ingredients = {
            tray = {
                count = 1
            },
            cokepaste = {
                count = 6
            }
        }
    },
    { -- Drcení pasty
        item = "coke",
        count = 90,
        actionText = "Drtíš kokainovou pastu..",
        duration = 10000,
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
    }
}
