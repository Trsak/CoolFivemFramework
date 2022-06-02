var isOpen = false;
var craftingPossibilities = {};
var itemsData = [];
var currentItemCounts = {};
var weaponComponents = [];
var disabled = false;
var dragging = false;
var draggingElement = null;
var leftShiftPressed = false;
var modalType = null;
var currentData = null;
var dropping = false;
var inventoryType = "none";
var dragFromMain = true;
var canScroll = true;
var firstRun = true;
var currentCrafting = null;
let itemsToCraft = [];

var formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0
});

var debug = false;

$(document).ready(function () {
    var eventCallback = {
        openInventory: function (data) {
            inventoryType = "none";
            openInventory(data.inventory);
        },
        setMainInventory: function (data) {
            resetInventory(data.inventory.maxSpace, -1);
            setInventoryItems(data.inventory, false);
            setupEvents();
            disabled = false;
        },
        setSecondInventory: function (data) {
            resetInventory(-1, data.inventory.maxSpace);
            setInventoryItems(data.inventory, true);

            $("#secondInventory .currentStorage").html(data.inventory.data.length);
            $("#secondInventory .maxStorage").html(data.inventory.maxSpace);
            $("#secondInventory .currentWeight").html(data.inventory.currentWeight.toFixed(1));
            $("#secondInventory .maxWeight").html(data.inventory.maxWeight.toFixed(1));

            setupEvents();
            setupPlayerEvents();

            disabled = false;
        },
        setStorageInventory: function (data) {
            resetInventory(-1, data.storage.maxSpace);
            setInventoryItems(data.storage, true);

            $("#secondInventory .currentStorage").html(data.storage.data.length);
            $("#secondInventory .maxStorage").html(data.storage.maxSpace);
            $("#secondInventory .currentWeight").html(data.storage.currentWeight.toFixed(1));
            $("#secondInventory .maxWeight").html(data.storage.maxWeight.toFixed(1));

            setupEvents();
            setupStorageEvents();

            disabled = false;
        },
        openDrop: function (data) {
            inventoryType = "drop";
            openDropInventory(data.inventory, data.drop);
            disabled = false;
        },
        openPlayer: function (data) {
            inventoryType = "player";
            openPlayerInventory(data.inventory, data.otherPlayer);
            disabled = false;
        },
        openStorage: function (data) {
            inventoryType = "storage";
            openStorageInventory(data.inventory, data.storage);
            disabled = false;
        },
        openShop: function (data) {
            inventoryType = "shop";
            openShopInventory(data.inventory, data.shop, data.shopData);
            disabled = false;
        },
        closeInventory: function () {
            closeInventory();
        },
        setItemsData: function (data) {
            itemsData = data.items;
            craftingPossibilities = data.crafting;
            weaponComponents = data.weaponComponents;
        },
        enable: function () {
            disabled = false;
        }
    };

    window.addEventListener('message', function (event) {
        eventCallback[event.data.action](event.data);
    });
});

$(document).keydown(function (e) {
    if (e.keyCode == 16) {
        leftShiftPressed = true;
    }
});

$(document).keyup(function (e) {
    if (e.keyCode == 16) {
        leftShiftPressed = false;
    }

    if (isOpen) {
        if (e.keyCode === 27 || e.keyCode === 113) {
            closeInventory();
        }
    }
});

function resetInventory(spaces, spacesSecond) {
    if (spaces >= 0) {
        $("#mainInventory .inventoryGrid").html(" ");
    }

    if (spacesSecond >= 0) {
        $("#secondInventory .inventoryGrid").html(" ");
    }

    var slot = 1;
    while (slot <= spaces) {
        $("#mainInventory .inventoryGrid").append("<div id='main-slot-" + slot + "' class='inventorySlot noitem slot-" + slot + "' data-slot='" + slot + "'><div class='itemLabel'><div class='itemLabelText'></div></div></div>");
        ++slot;
    }

    slot = 1;

    while (slot <= spacesSecond) {
        $("#secondInventory .inventoryGrid").append("<div id='main-slot-" + slot + "' class='inventorySlot noitem slot-" + slot + "' data-slot='" + slot + "'><div class='itemLabel'><div class='itemLabelText'></div></div></div>");
        ++slot;
    }
}

function openStorageInventory(inventory, storageInventory) {
    isOpen = true;
    $("#mainModal").modal("hide");

    $("#secondInventory .inventoryData .storage").show();
    $("#secondInventory .inventoryData .weight").show();
    $("#secondInventory .inventoryData .info").html(storageInventory.label)
    $("#secondInventory .inventoryData .info").show();

    var items = inventory.data;
    var storageItems = storageInventory.data;

    resetInventory(inventory.maxSpace, storageInventory.maxSpace);
    setInventoryItems(inventory, false);
    setInventoryItems(storageInventory, true);

    $("#mainInventory .currentStorage").html(items.length);
    $("#mainInventory .maxStorage").html(inventory.maxSpace);
    $("#mainInventory .currentWeight").html(inventory.currentWeight.toFixed(1));
    $("#mainInventory .maxWeight").html(inventory.maxWeight.toFixed(1));

    $("#secondInventory .currentStorage").html(storageItems.length);
    $("#secondInventory .maxStorage").html(storageInventory.maxSpace);
    $("#secondInventory .currentWeight").html(storageInventory.currentWeight.toFixed(1));
    $("#secondInventory .maxWeight").html(storageInventory.maxWeight.toFixed(1));

    setupEvents();
    setupStorageEvents();

    $("body").show();

    disabled = false;
}

function openPlayerInventory(inventory, otherPlayerInventory) {
    isOpen = true;
    $("#mainModal").modal("hide");

    $("#secondInventory .inventoryData .storage").show();
    $("#secondInventory .inventoryData .weight").show();
    $("#secondInventory .inventoryData .info").hide();

    var items = inventory.data;
    var otherPlayerItems = otherPlayerInventory.data;

    resetInventory(inventory.maxSpace, otherPlayerInventory.maxSpace);
    setInventoryItems(inventory, false);
    setInventoryItems(otherPlayerInventory, true);

    $("#mainInventory .currentStorage").html(items.length);
    $("#mainInventory .maxStorage").html(inventory.maxSpace);
    $("#mainInventory .currentWeight").html(inventory.currentWeight.toFixed(1));
    $("#mainInventory .maxWeight").html(inventory.maxWeight.toFixed(1));

    $("#secondInventory .currentStorage").html(otherPlayerItems.length);
    $("#secondInventory .maxStorage").html(otherPlayerInventory.maxSpace);
    $("#secondInventory .currentWeight").html(otherPlayerInventory.currentWeight.toFixed(1));
    $("#secondInventory .maxWeight").html(otherPlayerInventory.maxWeight.toFixed(1));

    setupEvents();
    setupPlayerEvents();

    $("body").show();

    disabled = false;
}

function openShopInventory(inventory, shopItems, shopData) {
    isOpen = true;
    $("#mainModal").modal("hide");

    $("#secondInventory .inventoryData .storage").hide();
    $("#secondInventory .inventoryData .weight").hide();
    $("#secondInventory .inventoryData .info").html(shopData.name)
    $("#secondInventory .inventoryData .info").show();

    var items = inventory.data;

    for (i = 0; i < shopItems.length; ++i) {
        shopItems[i].slot = i + 1;
        shopItems[i].data = [];
    }

    var shopItemdsData = [];
    shopItemdsData.data = shopItems;

    resetInventory(inventory.maxSpace, shopItems.length);
    setInventoryItems(inventory, false);
    setInventoryItems(shopItemdsData, true);

    $("#mainInventory .currentStorage").html(items.length);
    $("#mainInventory .maxStorage").html(inventory.maxSpace);
    $("#mainInventory .currentWeight").html(inventory.currentWeight.toFixed(1));
    $("#mainInventory .maxWeight").html(inventory.maxWeight.toFixed(1));

    setupEvents();

    $("body").show();

    disabled = false;
}

function openDropInventory(inventory, drop) {
    isOpen = true;
    $("#mainModal").modal("hide");

    $("#secondInventory .inventoryData .storage").show();
    $("#secondInventory .inventoryData .weight").hide();
    $("#secondInventory .inventoryData .info").html("Podlaha")
    $("#secondInventory .inventoryData .info").show();

    var items = inventory.data;
    var dropItems = drop.data;
    var dropMaxStorage = getBiggestSlot(dropItems) + 20;

    resetInventory(inventory.maxSpace, dropMaxStorage);
    setInventoryItems(inventory, false);
    setInventoryItems(drop, true);

    $("#secondInventory .currentStorage").html(dropItems.length);
    $("#secondInventory .maxStorage").html(dropMaxStorage);
    $("#mainInventory .currentStorage").html(items.length);
    $("#mainInventory .maxStorage").html(inventory.maxSpace);
    $("#mainInventory .currentWeight").html(inventory.currentWeight.toFixed(1));
    $("#mainInventory .maxWeight").html(inventory.maxWeight.toFixed(1));

    setupEvents();
    setupDropEvents();

    $("body").show();

    disabled = false;
}

function setInventoryItems(info, isSecondInventory) {
    var invId = "#mainInventory";

    if (isSecondInventory) {
        invId = "#secondInventory";
        $("#secondInventory .inventoryGrid").css("overflow-y", "visible");
    } else {
        currentItemCounts = {};
    }

    var items = info.data;
    $(invId + " .currentStorage").html(items.length);

    if (info.maxSpace) {
        $(invId + " .maxStorage").html(info.maxSpace);
    }

    if (info.currentWeight) {
        $(invId + " .currentWeight").html(info.currentWeight.toFixed(1));
    }

    if (info.maxWeight) {
        $(invId + " .maxWeight").html(info.maxWeight.toFixed(1));
    }

    for (i = 0; i < items.length; ++i) {
        var slot = $(invId + " .slot-" + items[i].slot);
        var item = itemsData[items[i].name];
        slot.html("");
        slot.data("item", items[i].name);
        slot.data("type", item.type);
        slot.data("data", JSON.stringify(items[i].data));
        slot.data("count", items[i].count);

        if (!isSecondInventory) {
            if (currentItemCounts[items[i].name] === undefined) {
                currentItemCounts[items[i].name] = {
                    count: items[i].count
                }
            } else {
                currentItemCounts[items[i].name].count += items[i].count;
            }
        }

        var itemLabel = item.label;
        var itemIcon = getItemIcon(item.class);
        if (items[i].data.activeMobile || items[i].data.activeWeapon) {
            itemLabel = "<i class='fas fa-circle activeItem'></i> " + itemLabel;
        } else if (itemIcon && itemIcon != undefined) {
            itemLabel = "<i class='" + itemIcon + " activeItem'></i> " + itemLabel;
        }

        if ((item.name.includes("_glass") || item.name == "shot") && items[i].data.drink) {
            if (item.name == "shot") {
                itemLabel = itemLabel + " " + getDrinkLabel(items[i].data.drink)
            } else if (item.name != "beer_glass" && item.name != "tall_glass") {
                itemLabel = "Sklenička " + getDrinkLabel(items[i].data.drink)

            } else {
                itemLabel = "Sklenice " + getDrinkLabel(items[i].data.drink)
            }
        }

        slot.removeClass("noitem");
        slot.addClass("item");

        if (items[i].name === "plate") {
            let plateClass = "plate_blue";
            if (items[i].data.plateIndex == 1 || items[i].data.plateIndex == 2) {
                plateClass = "plate_yellow";
            }

            slot.append(`<div class="itemContent plateText">
                <div class="itemImage" style="background-image: url(./items/plates/${items[i].data.plateIndex}.png);">
                <span class="plateSpanText ${plateClass}">${items[i].data.plateText}</span>
            </div>`);
        } else if (items[i].name === "bankcard") {
            slot.append(`<div class="itemContent cardText">
                <div class="itemImage" style="background-image: url(\'./items/bankcard.png\');">
                <span class="cardSpanText">${items[i].data.id}</span>
            </div>`);
        } else if ((item.name.includes("_glass") || item.name == "shot") && items[i].data.drink) {
            itemImageName = item.name + "_drink"
            slot.append('<div class="itemContent"><div class="itemImage" style="background-image: url(\'./items/' + itemImageName + '.png\');-webkit-filter:hue-rotate(3.142rad);filter:hue-rotate(3.142rad);"></div>');
        } else {
            let itemImageName = items[i].name;
            if (items[i].name.startsWith("chip_") && items[i].count > 5) {
                itemImageName = itemImageName + "_pile";
            } else if (items[i].name === "evidencebag" && !items[i].data.items) {
                itemImageName = "evidencebag_empty";
            }

            slot.append('<div class="itemContent"><div class="itemImage" style="background-image: url(\'./items/' + itemImageName + '.png\');"></div>');
        }

        let rarity = 0;
        if (item.rarity) {
            rarity = item.rarity;
        }
        slot.append('<div class="itemLabel rarity-' + rarity + '"><div class="itemLabelText">' + itemLabel + '</div></div>');

        if (isSecondInventory) {
            slot.addClass("second");
        }

        var itemCounts = '<div class="itemCounts"><div class="itemCountsData">';

        if (item.type == "weapon") {
            if (items[i].data.hasAmmo && items[i].data.ammoType) {
                itemCounts += '<div class="itemCount"><img src="img/bullet.png" class="bulletImg"> ' + items[i].data.ammo + '</div>';
            } else if (isSecondInventory && inventoryType == "shop") {
                itemCounts += '<div class="itemCount">' + items[i].count + '</div>';
            } else {
                itemCounts += '<div class="itemCount">1</div>';
            }
        } else if (item.type == "item") {
            let itemCount = items[i].count;
            if (item.name == "cash") {
                itemCount = formatter.format(items[i].count);
            } else if (items[i].data.amount) {
                itemCount += " (" + items[i].data.amount + ")";
            }

            itemCounts += '<div class="itemCount">' + itemCount + '</div>';
        }


        if (!isSecondInventory || inventoryType === "player") {
            if (items[i].slot <= 5) {
                itemCounts += '<div class="itemBind">' + (items[i].slot) + '</div>';
            }
        }

        if (isSecondInventory && inventoryType == "shop") {
            itemCounts += '<div class="itemWeight">' + formatter.format(items[i].price) + '</div>';
        } else {
            itemCounts += '<div class="itemWeight">' + (items[i].count * item.weight).toFixed(1) + '</div>';
        }

        itemCounts += '</div></div></div>';
        slot.append(itemCounts);

        var specialTooltip = "";
        if (item.type == "weapon" && items[i].data && items[i].data.components && items[i].data.components.length > 0) {
            specialTooltip = "<div class='special-tooltip-header'>Rozšíření</div><div class='special-tooltip-content'>";

            for (var x = 0; x < items[i].data.components.length; x++) {
                var componentName = getWeaponComponentNameByHash(items[i].data.components[x], items[i].name);
                if (componentName !== null && (itemsData[componentName] || getMagazine(componentName) != undefined)) {
                    var componentLabel = (itemsData[componentName] != undefined && itemsData[componentName].label || getMagazine(componentName))
                    specialTooltip = specialTooltip + (componentLabel);

                    if (x < items[i].data.components.length - 1) {
                        specialTooltip = specialTooltip + " | ";
                    }
                }
            }
            if (specialTooltip != "") {
                specialTooltip = specialTooltip + "</div>";
                
            } 
        } else if (item.type == "item" && items[i].data && items[i].data.components) {
            var sexText = "muže";
            if (items[i].data.sex == 1) {
                sexText = "ženu";
            }

            specialTooltip = "<div class='special-tooltip-header'>Oblečení pro " + sexText + "</div><div class='special-tooltip-content'>";

            var length = Object.keys(items[i].data.components).length;
            var index = 0;

            $.each(items[i].data.components, function (component, value) {
                var componentName = getClothesLabel(component);

                if (componentName !== null) {
                    specialTooltip = specialTooltip + "<strong>" + componentName + ":</strong> " + value;

                    if (index < length - 1) {
                        specialTooltip = specialTooltip + " | ";
                    }
                }

                index = index + 1;
            });

            $.each(items[i].data.props, function (prop, value) {
                var propName = getPropsLabel(prop);

                if (componentName !== null) {
                    specialTooltip = specialTooltip + "<strong>" + propName + ":</strong> " + value;

                    if (index < length - 1) {
                        specialTooltip = specialTooltip + " | ";
                    }
                }

                index = index + 1;
            });

            specialTooltip = specialTooltip + "</div>";
        }

        if (items[i].data && items[i].data.label) {
            var title = "Údaje o předmětu";

            if (item.name == "car_keys") {
                title = "SPZ Vozidla";
            }

            let tooltipText = items[i].data.label;
            if (items[i].data.nametag) {
                tooltipText += "<br><strong>Jmenovka:</strong> " + items[i].data.nametag;
            }

            if (items[i].name === "evidencebag") {
                if (items[i].data.items) {
                    tooltipText += "<br><strong>Předmětů:</strong> " + items[i].data.items
                }

                if (items[i].data.weight) {
                    tooltipText += "<br><strong>Váha:</strong> " + items[i].data.weight.toFixed(1)
                }
            }

            specialTooltip += "<div class='special-tooltip-header'>" + title + "</div><div class='special-tooltip-content'>" + tooltipText + "</div>";
        }

        if (specialTooltip !== "") {
            slot.attr("data-tippy-content", specialTooltip);
        }
    }

    tippy('[data-tippy-content]', {
        allowHTML: true,
        placement: 'right'
    });
}

function openInventory(inventory) {
    isOpen = true;
    $("#mainModal").modal("hide");

    $("#secondInventory .inventoryData .storage").hide();
    $("#secondInventory .inventoryData .weight").hide();
    $("#secondInventory .inventoryData .info").html("Crafting")
    $("#secondInventory .inventoryData .info").show();

    var items = inventory.data;

    resetInventory(inventory.maxSpace, 0);
    setInventoryItems(inventory, false);

    setupCrafting(items);

    $("#mainInventory .currentStorage").html(items.length);
    $("#mainInventory .maxStorage").html(inventory.maxSpace);
    $("#mainInventory .currentWeight").html(inventory.currentWeight.toFixed(1));
    $("#mainInventory .maxWeight").html(inventory.maxWeight.toFixed(1));

    setupEvents();

    $("body").show();

    disabled = false;
}

function setupCrafting(items) {
    itemsToCraft = [];
    for (const [itemId, data] of Object.entries(craftingPossibilities)) {
        let canBeCrafted = true;
        let maxCount = 10000;

        for (const [ingredient, ingredientData] of Object.entries(data.ingredients)) {
            if (currentItemCounts[ingredient] && currentItemCounts[ingredient].count >= ingredientData.count) {
                if (ingredientData.data) {
                    var hasAmount = false
                    for (i = 0; i < items.length; ++i) {
                        var itemName = items[i].name
                        if (itemName == ingredient && items[i].data.amount && ingredientData.data.amount <= items[i].data.amount) {
                            hasAmount = true
                        }
                    }
                    if (!hasAmount) {
                        canBeCrafted = false;
                        break;
                    }
                }
                else {
                    let maxCountIngredient = Math.floor(currentItemCounts[ingredient].count / ingredientData.count);
                    if (maxCountIngredient < maxCount || maxCount == 10000) {
                        maxCount = maxCountIngredient;
                        if (maxCount == 10000){
                            canBeCrafted = false;
                            break

                        }
                    }

                }
            } else {
                canBeCrafted = false;
                break;
            }
        }

        if (data.requirements) {
            for (const [requirement, reqirementData] of Object.entries(data.requirements)) {
                if (!currentItemCounts[requirement] || currentItemCounts[requirement].count < reqirementData.count) {
                    canBeCrafted = false;
                    break;
                }
            }
        }

        if (canBeCrafted && maxCount > 0 && maxCount != 10000) {
            itemsToCraft.push({
                id: itemId,
                item: data.item,
                maxCount: maxCount,
                baseCount: data.count,
                ingredients: data.ingredients,
                requirements: data.requirements,
                additions: data.additions
            });
        }
    }

    if (itemsToCraft.length === 0) {
        $("#secondInventory .inventoryGrid").html("<div id='craftingGrid'><div id='craftingText'>Nemáš u sebe nic na crafting</div></div>");
    } else {
        let craftingItemsHtml = "";
        itemsToCraft.forEach(itemToCraft => {
            let item = itemsData[itemToCraft.item];
            
            let rewardCount = (typeof(itemToCraft.baseCount) == "number" && itemToCraft.baseCount || itemToCraft.baseCount[0] + " - " + itemToCraft.baseCount[1])
            craftingItemsHtml += `<div class='craftingRow' onclick='craftItem("` + itemToCraft.item + `","` + itemToCraft.id + `")'>` + rewardCount + `<span style='text-transform: none'>x</span> <img src='./items/` + itemToCraft.item + `.png' style='max-height: 25px;'> ` + item.label;

            if (itemToCraft.additions) {
                var count = Object.entries(itemToCraft.additions).length;
                craftingItemsHtml += ` + (`;
                for (const [addition, additionData] of Object.entries(itemToCraft.additions)) {
                    let itemIngredient = itemsData[addition];
                    craftingItemsHtml += additionData.count + "<span style='text-transform: none'>x</span> <img src='./items/" + addition + ".png' style='max-height: 25px;'> " + itemIngredient.label;

                    count -= 1;
                    if (count > 0) {
                        craftingItemsHtml += " + ";
                    } else {
                        craftingItemsHtml += `) => `;
                    }
                }
            } else {
                craftingItemsHtml += ` => `;
            }

            var count = Object.entries(itemToCraft.ingredients).length;
            for (const [ingredient, ingredientData] of Object.entries(itemToCraft.ingredients)) {
                let itemIngredient = itemsData[ingredient];
                let ingredientAmount = ((ingredientData.data && ingredientData.data.amount) && " (" + ingredientData.data.amount + ") " || "")
                craftingItemsHtml += ingredientData.count + "<span style='text-transform: none'>x</span> <img src='./items/" + ingredient + ".png' style='max-height: 25px;'> " + itemIngredient.label + ingredientAmount;

                count -= 1;
                if (count > 0 || itemToCraft.requirements) {
                    craftingItemsHtml += " + ";
                }
            }

            if (itemToCraft.requirements) {
                var count = Object.entries(itemToCraft.requirements).length;
                for (const [requirement, reqirementData] of Object.entries(itemToCraft.requirements)) {
                    let itemRequirement = itemsData[requirement];
                    craftingItemsHtml += reqirementData.count + "<span style='text-transform: none'>x</span> <img src='./items/" + requirement + ".png' style='max-height: 25px;'> " + itemRequirement.label;

                    count -= 1;
                    if (count > 0) {
                        craftingItemsHtml += " + ";
                    }
                }


            }
            craftingItemsHtml += "</div>";
        });

        $("#secondInventory .inventoryGrid").html("<div id='craftingGrid'>" + craftingItemsHtml + "</div>");
    }
}

function setupStorageEvents() {
    $('#secondInventory .noitem').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            disabled = true;

            var from = ui.draggable.data("slot");
            var to = $(this).data("slot");
            var count = ui.draggable.data("count");

            if (dragFromMain) {
                if (inventoryType == "storage") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("putIntoStorageCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("putIntoStorage");
                        $.post("https://inventory/putIntoStorage", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    }
                }
            } else {
                if (inventoryType == "storage") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("splitStorageCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("sortStorageItems");
                        $.post("https://inventory/sortStorageItems", JSON.stringify({
                            from: from,
                            to: to
                        }));
                    }
                }
            }
        }
    });

    $('#secondInventory .item').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            var from = ui.draggable;
            var to = $(this);
            var fromData = JSON.parse(from.data("data"));
            var toData = JSON.parse(to.data("data"));

            if (from.data("item") == to.data("item") && from.data("type") == "item") {
                if (dragFromMain) {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;

                        if (debug) console.log("putIntoStorage");
                        $.post("https://inventory/putIntoStorage", JSON.stringify({
                            from: from.data("slot"),
                            to: to.data("slot"),
                            count: from.data("count")
                        }));
                    }
                } else {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;
                        if (inventoryType == "storage") {
                            if (debug) console.log("joinStorageItem");
                            $.post("https://inventory/joinStorageItem", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count"),
                                data: JSON.parse(from.data("data"))
                            }));
                        }
                    }
                }
            } else {
                if (!dragFromMain) {
                    disabled = true;

                    if (debug) console.log("swapStorageItem");
                    $.post("https://inventory/swapStorageItem", JSON.stringify({
                        from: from.data("slot"),
                        to: to.data("slot")
                    }));
                }
            }
        }
    });
}

function setupPlayerEvents() {
    $('#secondInventory .noitem').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            disabled = true;

            var from = ui.draggable.data("slot");
            var to = $(this).data("slot");
            var count = ui.draggable.data("count");

            if (dragFromMain) {
                if (inventoryType == "player") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("giveToPlayerCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("giveToPlayer");
                        $.post("https://inventory/giveToPlayer", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    }
                }
            } else {
                if (inventoryType == "player") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("splitPlayerCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("sortPlayerItems");
                        $.post("https://inventory/sortPlayerItems", JSON.stringify({
                            from: from,
                            to: to
                        }));
                    }
                }
            }
        }
    });

    $('#secondInventory .item').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            var from = ui.draggable;
            var to = $(this);
            var fromData = JSON.parse(from.data("data"));
            var toData = JSON.parse(to.data("data"));

            if (from.data("item") == to.data("item") && from.data("type") == "item") {
                if (dragFromMain) {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;

                        if (debug) console.log("giveToPlayer");
                        $.post("https://inventory/giveToPlayer", JSON.stringify({
                            from: from.data("slot"),
                            to: to.data("slot"),
                            count: from.data("count")
                        }));
                    }
                } else {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;
                        if (inventoryType == "player") {
                            if (debug) console.log("joinPlayerItem");
                            $.post("https://inventory/joinPlayerItem", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count")
                            }));
                        }
                    }
                }
            } else {
                if (!dragFromMain) {
                    disabled = true;

                    if (debug) console.log("swapPlayerItem");
                    $.post("https://inventory/swapPlayerItem", JSON.stringify({
                        from: from.data("slot"),
                        to: to.data("slot")
                    }));
                }
            }
        }
    });
}

function setupDropEvents() {
    $('#secondInventory .noitem').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            disabled = true;

            var from = ui.draggable.data("slot");
            var to = $(this).data("slot");
            var count = ui.draggable.data("count");

            if (dragFromMain) {
                if (inventoryType == "drop") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("dropItemToGroundCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("dropItemToGround");
                        $.post("https://inventory/dropItemToGround", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    }
                }

            } else {
                if (inventoryType == "drop") {
                    if (leftShiftPressed && count > 1) {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("splitDropCount");
                        disabled = false;
                    } else {
                        if (debug) console.log("sortDropItems");
                        $.post("https://inventory/sortDropItems", JSON.stringify({
                            from: from,
                            to: to
                        }));
                    }
                }
            }
        }
    });

    $('#secondInventory .item').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            var from = ui.draggable;
            var to = $(this);
            var fromData = JSON.parse(from.data("data"));
            var toData = JSON.parse(to.data("data"));

            if (from.data("item") == to.data("item") && from.data("type") == "item") {
                if (dragFromMain) {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;

                        if (debug) console.log("dropItemToGround");
                        $.post("https://inventory/dropItemToGround", JSON.stringify({
                            from: from.data("slot"),
                            to: to.data("slot"),
                            count: from.data("count")
                        }));
                    }
                } else {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;
                        if (inventoryType == "drop") {
                            if (debug) console.log("joinDropItem");
                            $.post("https://inventory/joinDropItem", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count"),
                                data: JSON.parse(from.data("data"))
                            }));
                        }
                    }
                }
            } else {
                if (!dragFromMain) {
                    disabled = true;

                    if (debug) console.log("swapDropItem");
                    $.post("https://inventory/swapDropItem", JSON.stringify({
                        from: from.data("slot"),
                        to: to.data("slot")
                    }));
                }
            }
        }
    });
}

function setupEvents() {
    $('.item').draggable({
        cursor: "move",
        helper: 'clone',
        scroll: false,
        appendTo: 'body',
        zIndex: 99999,
        revert: 'invalid',
        tolerance: "fit",
        start: function (event, ui) {
            if (disabled) {
                return false;
            }

            if (window.screen.availWidth >= 2500) {
                $(this).draggable('instance').offset.click = {
                    left: Math.floor(ui.helper.width() / 2),
                    top: Math.floor(ui.helper.height() / 2)
                };
            } else {
                $(this).draggable('instance').offset.click = {
                    left: Math.floor(ui.helper.width() / 4),
                    top: Math.floor(ui.helper.height() / 4)
                };
            }

            dragFromMain = !($(this).hasClass("second"));

            ui.helper.find(".itemCounts").hide();
            ui.helper.find(".itemLabel").hide();
            ui.helper.css("background-color", "transparent");
            ui.helper.css("border", "none");
            ui.helper.css("box-shadow", "none");
            ui.helper.width($(this).width()).height($(this).height());

            ui.helper.removeClass("hasLabel");
            ui.helper.find('.itemDataLabel').hide();
            $(this).find('.itemContent').hide();

            dragging = true;
            draggingElement = ui.helper;
        },
        stop: function () {
            $(this).find('.itemContent').show();
            dragging = false;
            draggingElement = null;

            if (dropping && dragFromMain) {
                var from = $(this).data("slot");
                var count = $(this).data("count");

                if (leftShiftPressed && count > 1) {
                    currentData = {
                        from: from,
                        count: count
                    };

                    openModal("dropItemToGroundCount");
                    disabled = false;
                } else {
                    if (debug) console.log("dropItemToGround");
                    $.post("https://inventory/dropItemToGround", JSON.stringify({
                        from: from,
                        count: count
                    }));
                }

                dropping = false;
            }
        }
    });


    $('body').droppable({
        drop: function (event, ui) {
            if (!draggingElement) {
                return false;
            }

            dropping = false;
            if (dragFromMain) {
                var coordsMain = $('#mainInventory')[0].getBoundingClientRect();
                var coordsSecond = $('#secondInventory')[0].getBoundingClientRect();

                var xStart = coordsMain.x
                var xStop = coordsSecond.x + coordsSecond.width

                var yStart = coordsMain.y
                var yStop = coordsMain.y + coordsMain.height

                if (!(yStart <= event.clientY && yStop >= event.clientY && xStart <= event.clientX && xStop >= event.clientX)) {
                    dropping = true;
                }
            }
        }
    });

    $('#mainInventory .item').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            var from = ui.draggable;
            var to = $(this);
            var fromData = JSON.parse(from.data("data"));
            var toData = JSON.parse(to.data("data"));
            if (from.data("item") == to.data("item") && from.data("type") == "item") {
                if (dragFromMain) {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;
                        if (debug) console.log("joinItem");
                        $.post("https://inventory/joinItem", JSON.stringify({
                            from: from.data("slot"),
                            to: to.data("slot"),
                            count: from.data("count"),
                            data: JSON.parse(from.data("data"))
                        }));
                    }
                } else {
                    if ((typeof toData.id === 'undefined' && typeof fromData.id === 'undefined') || toData.id === fromData.id) {
                        disabled = true;
                        if (inventoryType == "drop") {
                            if (debug) console.log("takeFromDrop");
                            $.post("https://inventory/takeFromDrop", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count")
                            }));
                        } else if (inventoryType == "player") {
                            if (debug) console.log("takeFromPlayer");
                            $.post("https://inventory/takeFromPlayer", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count")
                            }));
                        } else if (inventoryType == "storage") {
                            if (debug) console.log("takeFromStorage");
                            $.post("https://inventory/takeFromStorage", JSON.stringify({
                                from: from.data("slot"),
                                to: to.data("slot"),
                                count: from.data("count")
                            }));
                        } else if (inventoryType == "shop") {
                            currentData = {
                                item: from.data("item"),
                                to: to.data("slot"),
                                count: from.data("count")
                            };

                            openModal("buyCount");
                            disabled = false;
                        }
                    }
                }
            } else {
                if (dragFromMain) {
                    disabled = true;

                    if (debug) console.log("swapItem");
                    $.post("https://inventory/swapItem", JSON.stringify({
                        from: from.data("slot"),
                        to: to.data("slot")
                    }));
                }
            }
        }
    });

    $('#mainInventory .noitem').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            if (!draggingElement || dropping) {
                return false;
            }
            if (disabled) return;

            disabled = true;

            var from = ui.draggable.data("slot");
            var to = $(this).data("slot");
            var count = ui.draggable.data("count");

            if (dragFromMain) {
                if (leftShiftPressed && count > 1) {
                    currentData = {
                        from: from,
                        to: to,
                        count: count
                    };

                    openModal("splitCount");
                    disabled = false;
                } else {
                    if (debug) console.log("sortItems");
                    $.post("https://inventory/sortItems", JSON.stringify({
                        from: from,
                        to: to
                    }));
                }
            } else {
                if (leftShiftPressed && count > 1) {
                    if (inventoryType == "drop") {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("takeFromDropCount");
                        disabled = false;
                    } else if (inventoryType == "player") {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("takeFromPlayerCount");
                        disabled = false;
                    } else if (inventoryType == "storage") {
                        currentData = {
                            from: from,
                            to: to,
                            count: count
                        };

                        openModal("takeFromStorageCount");
                        disabled = false;
                    }
                } else {
                    if (inventoryType == "drop") {
                        if (debug) console.log("takeFromDrop");
                        $.post("https://inventory/takeFromDrop", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    } else if (inventoryType == "player") {
                        if (debug) console.log("takeFromPlayer");
                        $.post("https://inventory/takeFromPlayer", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    } else if (inventoryType == "storage") {
                        if (debug) console.log("takeFromStorage");
                        $.post("https://inventory/takeFromStorage", JSON.stringify({
                            from: from,
                            to: to,
                            count: count
                        }));
                    }
                }

                if (inventoryType == "shop") {
                    currentData = {
                        item: ui.draggable.data("item"),
                        to: to,
                        count: count
                    };

                    openModal("buyCount");
                    disabled = false;
                }
            }
        }
    });

    $('#mainInventory .item').dblclick(function () {
        if (disabled) return;
        if (debug) console.log("Kliknutí");
        if (itemsData[$(this).data("item")].usable) {
            if (debug) console.log("useItem");
            $.post("https://inventory/useItem", JSON.stringify({
                item: $(this).data("item"),
                slot: $(this).data("slot"),
                data: JSON.parse($(this).data("data"))
            }));

            if (debug) console.log("useItem");
        }
    });

    $("#mainInventory .item").bind("contextmenu", function () {
        var count = $(this).data("count");
        if (disabled) return;

        if (leftShiftPressed && count > 1) {
            currentData = {
                from: $(this).data("slot"),
                count: count
            };

            openModal("selectItemActionCount");
            disabled = false;
        } else {
            closeInventory();

            if (debug) console.log("selectItemAction");
            $.post("https://inventory/selectItemAction", JSON.stringify({
                from: $(this).data("slot"),
                count: count
            }));
        }
    });
}

function startItemCrafting() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());
    if (count > max) {
        count = max
    }
    else if (count < min) {
        count = min
    }

    if (count >= min && count <= max) {
        closeInventory();

        if (debug) console.log("startItemCrafting");
        $.post("https://inventory/startItemCrafting", JSON.stringify({
            item: currentCrafting.item,
            count: count,
            id: currentCrafting.id
        }));
    }
}

function openModal(type) {
    modalType = type;

    if (modalType == "splitCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k rozdělení (1 - ' + (currentData.count - 1) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count - 1;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            splitItems();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "selectItemActionCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            itemAction();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "crafting") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet opakování craftingu (1 - ' + (currentCrafting.maxCount) + ')" type="number" min="1" max="' + (currentCrafting.maxCount) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentCrafting.maxCount;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            startItemCrafting();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "splitStorageCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k rozdělení (1 - ' + (currentData.count - 1) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count - 1;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            splitStorageItems();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "splitPlayerCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k rozdělení (1 - ' + (currentData.count - 1) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count - 1;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            splitPlayerItems();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "splitDropCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k rozdělení (1 - ' + (currentData.count - 1) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count - 1;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            splitDropItems();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "dropItemToGroundCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k zahození (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            dropItems();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "putIntoStorageCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            putIntoStorage();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "giveToPlayerCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            giveToPlayer();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "takeFromStorageCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            takeFromStorage();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "takeFromPlayerCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            takeFromPlayer();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "takeFromDropCount") {
        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet (1 - ' + (currentData.count) + ')" type="number" min="1" max="' + (currentData.count - 1) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        $("#modalInput").change(function () {
            var max = currentData.count;
            var min = 1;

            if ($(this).val() > max) {
                $(this).val(max);
            } else if ($(this).val() < min) {
                $(this).val(min);
            }
        });

        $("#modalConfirm").prop("onclick", null).off("click");
        $("#modalConfirm").click(function () {
            takeFromDrop();
        });

        $("#mainModal").modal("show");

        setTimeout(function () {
            $("#modalInput").focus();
        }, 600);
    } else if (modalType == "buyCount") {
        var maxCount = (currentData.count)
        if (currentData.item.includes("weapon_") || currentData.item.includes("magazine_")) {
            maxCount = 1
        }

        $(".modal-body").html('<form onsubmit="return dialogSubmit();"><div class="form-row"><div class="col-9"><input id="modalInput" placeholder="Zadejte počet k zakoupení (1 - ' + maxCount + ')" type="number" min="1" max="' + (currentData.count) + '" class="form-control"></div><div class="col-3"><button type="button" class="btn btn-primary" id="modalConfirm">Potvrdit</button></div></div></form>');

        if (maxCount == 1) {
            disabled = false;
            buyShopItem(1);
        } else {
            $("#modalInput").change(function () {
                var max = currentData.count;
                var min = 1;

                if ($(this).val() > max) {
                    $(this).val(max);
                } else if ($(this).val() < min) {
                    $(this).val(min);
                }
            });

            $("#modalConfirm").prop("onclick", null).off("click");
            $("#modalConfirm").click(function () {
                buyShopItem();
            });

            $("#mainModal").modal("show");

            setTimeout(function () {
                $("#modalInput").focus();
            }, 600);
        }
    }
}

function dialogSubmit() {
    $("#modalConfirm").trigger("click");
    return false
}

function buyShopItem(count = null) {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    if (count == null) {
        count = parseInt($("#modalInput").val());
    }

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("buyShopItem");
        $.post("https://inventory/buyShopItem", JSON.stringify({
            item: currentData.item,
            to: currentData.to,
            count: count
        }));
    }
}

function putIntoStorage() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("putIntoStorage");
        $.post("https://inventory/putIntoStorage", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function giveToPlayer() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("giveToPlayer");
        $.post("https://inventory/giveToPlayer", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function itemAction() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        closeInventory();

        if (debug) console.log("selectItemAction");
        $.post("https://inventory/selectItemAction", JSON.stringify({
            from: currentData.from,
            count: count
        }));
    }
}

function takeFromStorage() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("takeFromStorage");
        $.post("https://inventory/takeFromStorage", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function takeFromPlayer() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("takeFromPlayer");
        $.post("https://inventory/takeFromPlayer", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function takeFromDrop() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("takeFromDrop");
        $.post("https://inventory/takeFromDrop", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function dropItems() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        var to = null;
        if (currentData.to) {
            to = currentData.to;
        }

        if (debug) console.log("dropItemToGround");
        $.post("https://inventory/dropItemToGround", JSON.stringify({
            from: currentData.from,
            to: to,
            count: count
        }));
    }
}

function splitItems() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        if (disabled) return;

        if (debug) console.log("splitItem");
        $.post("https://inventory/splitItem", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function craftItem(item, id) {
    currentCrafting = null;

    itemsToCraft.forEach(itemToCraft => {
        if (itemToCraft.item == item && itemToCraft.id == id) {
            currentCrafting = itemToCraft;
        }
    });

    if (currentCrafting != null) {
        openModal("crafting");
    }
}

function splitStorageItems() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("splitStorageItems");
        $.post("https://inventory/splitStorageItems", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function splitPlayerItems() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("splitPlayerItems");
        $.post("https://inventory/splitPlayerItems", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function splitDropItems() {
    if (disabled) return;
    $("#mainModal").modal("hide");

    var max = parseInt($("#modalInput").attr('max'));
    var min = 1;
    var count = parseInt($("#modalInput").val());

    if (count >= min && count <= max) {
        disabled = true;

        if (debug) console.log("splitDropItem");
        $.post("https://inventory/splitDropItem", JSON.stringify({
            from: currentData.from,
            to: currentData.to,
            count: count
        }));
    }
}

function closeInventory() {
    isOpen = false;

    if (draggingElement) {
        draggingElement.remove();
        draggingElement = null;
    }

    $("[data-tippy-root]").remove();
    $(".tippy-box").remove();

    $.post("https://inventory/closeInventory", JSON.stringify({
        type: inventoryType
    }));
    $("body").hide();
}

function getBiggestSlot(data) {
    var biggest = 0;

    for (i = 0; i < data.length; ++i) {
        if (data[i].slot && data[i].slot > biggest) {
            biggest = data[i].slot;
        }
    }

    return biggest;
}

$(window).bind('mousewheel', function (event) {
    if (dragging && canScroll) {
        var overInventory = null;

        var coordsMain = $('#mainInventory .inventoryGrid')[0].getBoundingClientRect();
        var coordsSecond = $('#secondInventory .inventoryGrid')[0].getBoundingClientRect();

        var xStart = coordsMain.x
        var xStop = coordsMain.x + coordsMain.width

        var yStart = coordsMain.y
        var yStop = coordsMain.y + coordsMain.height

        if (yStart <= event.clientY && yStop >= event.clientY && xStart <= event.clientX && xStop >= event.clientX) {
            overInventory = "main";
        }


        if (overInventory == null) {
            xStart = coordsSecond.x
            xStop = coordsSecond.x + coordsSecond.width

            yStart = coordsSecond.y
            yStop = coordsSecond.y + coordsSecond.height

            if (yStart <= event.clientY && yStop >= event.clientY && xStart <= event.clientX && xStop >= event.clientX) {
                overInventory = "second";
            }
        }

        if (overInventory !== null) {
            canScroll = false
            var invId = "#mainInventory";

            if (overInventory == "second") {
                invId = "#secondInventory";
            }

            var currentScroll = $(invId + " .inventoryGrid").scrollTop();

            if (event.originalEvent.wheelDelta >= 0) {
                var newScroll = currentScroll - 250
                if (newScroll < 0) {
                    newScroll = 0;
                }

                $(invId + " .inventoryGrid").animate({
                    scrollTop: newScroll
                }, 200);
            } else {
                $(invId + " .inventoryGrid").animate({
                    scrollTop: (currentScroll + 250)
                }, 200);
            }

            setTimeout(enableScroll, 200);
        }
    }
});

function enableScroll() {
    canScroll = true;
}

function getWeaponComponentNameByHash(hash, weaponName) {
    var returnName = null;

    $.each(weaponComponents, function (componentName, weapons) {
        var component = weapons[weaponName];

        if (typeof(component) !== undefined && component === hash) {
            returnName = componentName;
        }
    });

    return returnName;
}

const clothes = [
    "Obličej",
    "👺",
    "Vlasy",
    "🧤",
    "👖",
    "🎒",
    "👞",
    "🧣",
    "👕",
    "🛡️",
    "🖼️",
    "🧥"
];

function getClothesLabel(component) {
    return clothes[component];
}

const props = [
    "🎩",
    "🕶️",
    "👂",
    "Nic",
    "Nic",
    "Nic",
    "⌚",
    "⛓️"
];

function getPropsLabel(prop) {
    return props[prop];
};

const drinks = {
    ["beer_am"]: "Piva A.M.",
    ["beer_cervezabarracho"]: "Piva Cerveza Barracho",
    ["beer_dusche"]: "Piva Dusche Gold",
    ["beer_jakeyslager"]: "Piva Jakey's Lager",
    ["beer_logger"]: "Piva Logger",
    ["beer_patriot"]: "Piva Patriot",
    ["beer_pisswasser"]: "Piva Pisswasser",
    ["beer_pridebrew"]: "Piva Pride Brew",
    ["beer_stoutblarneys"]: "Piva Blarney's Stout",
    ["beer_sakura"]: "Piva Sakura",
    ["beer_thelost"]: "Piva The Lost",
    ["beer_benedict"]: "Piva Benedict Light",
    ["beer_stronzo"]: "Piva Stronzo",
    ["beer_beereater0"]: "Piva Beereater ZERO",
    ["beer_beereater12"]: "Piva Beereater 12°",
    ["beer_beereater17"]: "Piva Beereater 17°",
    ["beer_barney"]: "Piva Barney",
    ["beer_yellowjack"]: "Piva Yellow Jack",
    ["beer_vanilla"]: "Piva Vanilla Unicorn 12°",
    ["beer_royalcompany"]: "Piva Royal Company",
    ["beer_corona"]: "Piva Corrona",
    ["beer_lamesa"]: "Piva La Mesa",
    ["beer_jfc"]: "Piva JFC",
    ["beer_santamadre"]: "Piva Santa Madre",
    ["brandy_cardiaque"]: "Cardiaque Brandy",
    ["brandy_sealovice"]: "Sealovice",
    ["can_ecola"]: "eColy",
    ["can_orangotang"]: "Orang-O-Tanga",
    ["can_sprunk"]: "Sprunku",
    ["canbeer_blarneysstout"]: "Piva Blarney's Stout",
    ["canbeer_hoplivion"]: "Piva Hoplivion",
    ["canbeer_logger"]: "Piva Logger",
    ["champ_bleuterdclassic"]: "Blêuter'd - Classic",
    ["champ_bleuterdsilver"]: "Blêuter'd - Silver",
    ["champ_bleuterdgold"]: "Blêuter'd - Gold",
    ["champ_bleuterdluxe"]: "Blêuter'd - Luxe",
    ["cognac_bourgeoix"]: "Bourgeoix Cognac",
    ["drink_beanmachinecoffee"]: "Bean Machine Kávy",
    ["drink_burgershotcoffee"]: "Burger Shot Kávy",
    ["drink_burgershotjuice"]: "Burger Shot Nápoje",
    ["drink_cluckingbellcoffee"]: "Clucking Bell Kávy",
    ["drink_cluckingbelljuice"]: "Clucking Bell Nápoje",
    ["drink_cocomotion"]: "Coco Motion",
    ["drink_cocomaxik"]: "Coco Maxíka",
    ["drink_coffe"]: "Kávy",
    ["drink_milk"]: "Mléka",
    ["drink_pq"]: "P's & Q's Drink",
    ["energydrink_junk"]: "Energiťáku Junk",
    ["rum_ragga"]: "Ragga Rum",
    ["tequila_cazafortunas"]: "Cazafortunas Teuqily",
    ["tequila_isabel"]: "Isabel's Dream Teuqily",
    ["tequila_sinsimitosilver"]: "Sinsimitor Silver Teuqily",
    ["tequila_sinsimitogold"]: "Sinsimitor Gold Teuqily",
    ["tequila_tequilya"]: "Tequiyla Teuqily",
    ["tequila_matt"]: "Matt Teuqily",
    ["tequila_demacho"]: "Matt De Macho",
    ["gin_premium"]: "Ginu Prémium",
    ["tonic_ecolatonic"]: "eCola Tonic",
    ["vodka_cherenkovblue"]: "Cherenkov - Blue",
    ["vodka_cherenkovgreen"]: "Cherenkov - Green",
    ["vodka_cherenkovpurple"]: "Cherenkov - Purple",
    ["vodka_cherenkovred"]: "Cherenkov - Red",
    ["vodka_nogo"]: "Nogo Vodky",
    ["vodka_pablo"]: "Pablo Vodky",
    ["water_flow"]: "Vody",
    ["water_raine"]: "Vody",
    ["whiskey_macbeth"]: "Macbeth' Whiskey",
    ["whiskey_richard"]: "Richard' Whiskey",
    ["whiskey_themount"]: "The Mount Whiskey",
    ["whiskey_ramon"]: "Ramon Whiskey",
    ["rum_thelost"]: "Rumu The Lost",
    ["wine_costadelperro"]: "Costa Del Perro Vína",
    ["wine_marlowe"]: "Marlowe Vína",
    ["wine_rockfordhill"]: "Rockford Hill Vína",
    ["wine_vinewoodred"]: "Vinewood Red Vína",
    ["wine_vinewoodwhite"]: "Vinewood White Vína",
    ["wine_barolo"]: "Marlowe Vína Barolo",
    ["wine_chardonnay"]: "Marlowe Vína Chardonnay",
    ["wine_vermentino"]: "Marlowe Vína Vermentino",
    ["wine_pinotgrigio"]: "Marlowe Vína Pinot Grigio",
    ["wine_chianti"]: "Marlowe Vína Chianti",
    ["wine_prosecco"]: "Marlowe Vína Prosecco",
};

function getDrinkLabel(drink) {
    return drinks[drink];
};

const icons = {
    ["food"]: "fas fa-drumstick-bite",
    ["drink"]: "fas fa-tint",
    ["clothes"]: "fas fa-tshirt",
    ["ammo"]: "fab fa-stack-overflow",
};
function getItemIcon(icon) {
    return icons[icon];
};

const magazines = {
    ["clip_extended"]: "Rozšířený zásobník",
    ["clip_box"]: "Boxový zásobník",
};

function getMagazine(icon) {
    return magazines[icon];
};