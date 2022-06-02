let isOpen = false;
let modalOpen = false;
let openedData;
let active;
let store;
let basket = [];
let sync = [];
let pref = "https://phone_shop/"

$(document).ready(function () {
    var eventCallback = {
        open: function (data) {
            open(data);
        },

        refresh: function(data) {
            refresh(data);
        },

        close: function(data) {
            close(data);
        },

        hide: function(data) {
            open(data);
        }
    }

    window.addEventListener('message', function (event) {
        eventCallback[event.data.action](event.data);
    });
});

function open(data) {
    openedData = data
    store = data.shop
    create_items(data.mobile)
    $(".frame").css({'background-color':"rgba("+data.shop.color+")"})
    $(".header-store-name").html(data.shop.name)
    $(".header-store-description").html(data.shop.description)
    $("body").show();
    isOpen = true;
    basket_count()
}

function close() {
    window.location.reload();
    $.post(pref + 'Close', JSON.stringify({}));
    isOpen = false
}

function create_items(items) {
    $(".content").html("")
    $.each(items, function(id, item) {
        item.model = id
        let itemModel = item.phoneModel || item.simModel
        let itemElement = "<div class=\"item\">\n" +
            "   <img class=\"item-img\" src=\"./img/"+itemModel+".png\" alt=\""+itemModel+"\">\n" +
            "   <div class=\"item-buttons\">\n" +
            "       <div class=\"item-name\" id='"+id+"'>\n" +
            "           "+item.label+"\n" +
            "       </div>\n" +
            "       <i class=\"fas fa-shopping-basket basket\" id=\"item-"+id+"\"> $ "+item.price+"</i>\n" +
            "   </div>\n" +
            "</div>"
        $(".content").append(itemElement);
        $("#"+id+"").data('tagData', item);
        $("#item-"+id+"").data('tagData', item);
    })
}

function open_item_info(itemData) {
    modalOpen = true;
    $(".modal-item-description").html("");
    $(".item-info-name").html(""+ itemData.label +"")
    let itemModel = itemData.phoneModel || itemData.simModel
    document.getElementById("item-info-img").src="./img/"+itemModel+".png";
    $.each(itemData, function(id, item) {
        if (id !== "label" && id !== "item" && id !== "phoneModel" && id !== "internet") {
            if (typeof item === "boolean") {
                if (item) {
                    item = "<div style='color:green'>Nemá</div>"
                } else {
                    item = "<div style='color:red'>Nemá</div>"
                }
            }
            if (typeof item !== "object") {
                let itemElement = "<div class=\"info\">\n" +
                    "  <div style='font-weight: bolder;'>"+id+":</div> "+item+" \n" +
                    "</div>"
                $(".modal-item-description").append(itemElement);
                console.log(id, item)
            }
        }
    })
    $(".modal-item-info").css({'display': "grid"})
}

function create_recovery_items(recovery) {
    $(".content").html("")
    var id = 0;
    $.each(recovery, function(model, items) {
        $.each(items, function(i, item) {
            item.model = model
            id += 1
            let label = item.phoneid ||item.simid
            let itemElement = "<div class=\"item\">\n" +
                "   <img class=\"item-img\" src=\"./img/"+model+".png\" alt=\""+model+"\">\n" +
                "   <div class=\"item-buttons\">\n" +
                "       <div class=\"item-name\" id='"+id+"'>\n" +
                "           "+label+"\n" +
                "       </div>\n" +
                "       <i class=\"fas fa-sync sync\" id=\"item-"+id+"\"> $ "+item.price+"</i>\n" +
                "   </div>\n" +
                "</div>"
            $(".content").append(itemElement);
            $("#"+id+"").data('tagData', item);
            $("#item-"+id+"").data('tagData', item);
        })
    })
}

function basket_count() {
    if (basket.length >= 1) {
        $(".basket-count").css({'display': "block"})
    }
    $(".basket-count").html(""+basket.length +"")
}

function create_basket() {
    $(".basket-items").html("")
    $(".payment").html("");
    var totalPrice = 0;
    if (basket.length >= 1) {
        $.each(basket, function (id, item) {
            totalPrice += item.price
            let itemElement = "<div class=\"basket-item\">\n" +
                "   <span class=\"basket-item-id\">"+(id+1)+".</span>\n" +
                "   <span class=\"basket-item-name\">"+item.label+"</span>\n" +
                "   <span class=\"basket-item-price\">$ "+item.price+"</span>\n" +
                "   <span class='cross' id="+id+"><i class=\"far fa-times-circle\" style=\"color:red; font-size:1rem;\"></i></span>\n" +
                "</div>"
            $(".basket-items").append(itemElement);
            $("#" + id + "").data('tagData', item);
        })
    } else {
        let itemElement = "<div class='basket-item' style='padding-left:4vw;padding-top:2vw;'>No products!</div>"
        $(".basket-items").append(itemElement);
    }

    $(".sync-items").html("")
    if (sync.length >= 1) {
        $.each(sync, function (id, item) {
            totalPrice += item.price
            var label = ""
            console.log(id, item)
            if (item.model === "phone") {
                label = "Mobile recovery"
            } else {
                label = "Sim recovery"
            }
            let itemElement = "<div class=\"sync-item\">\n" +
                "   <span class=\"sync-item-id\">"+(id+1)+".</span>\n" +
                "   <span class=\"sync-item-name\">"+label+"</span>\n" +
                "   <span class=\"sync-item-price\">$ "+item.price+"</span>\n" +
                "   <span class='crossSync' id="+id+"><i class=\"far fa-times-circle\" style=\"color:red; font-size:1rem;\"></i></span>\n" +
                "</div>"
            $(".sync-items").append(itemElement);
            $("#" + id + "").data('tagData', item);
        })
    } else {
        let itemElement = "<div class='basket-item'>No recovery!</div>"
        $(".sync-items").append(itemElement);
    }

    $(".total-count").html("$"+totalPrice+"")
    let paymentElements = "<i id='byCash-"+totalPrice+"' class=\"fas fa-wallet pay\"></i>\n" +
        "<i id='byCard-"+totalPrice+"' class=\"fas fa-credit-card pay\"></i>" +
        "<input type='text' id='account-id' placeholder=\"Account ID\" class='pay'>"
    $(".payment").append(paymentElements);
}

function setActive(i) {
    $('#'+i).addClass("active");
    if (active){
        $('#'+active).removeClass("active");
    }
    active = i
}

$(document).on('click', '.item-name', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    var itemData = $("#"+itemId).data('tagData');
    open_item_info(itemData)
});

$(document).on('click', '.basket', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    var itemData = $("#"+itemId).data('tagData');
    basket.push(itemData)
    basket_count()
});

$(document).on('click', '.sync', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    var itemData = $("#"+itemId).data('tagData');
    if (sync.length === 1) {
        sync = []
        sync.push(itemData)
    } else {
        sync.push(itemData)
    }
});

$(document).on('click', '.pay', function(event){
    event.preventDefault();
    var itemId = $(this).attr('id');
    if (basket.length >= 1) {
        $.post(pref+'BuyPhone', JSON.stringify({
            payment: itemId,
            account: $('#account-id').val(),
            basket: basket
        }), function(status){
           if (status === "done") {
               basket = []
               basket_count()
               create_basket()
           }
        })
    }
    if (sync.length >= 1) {
        $.post(pref+'Recover', JSON.stringify({
            payment: itemId,
            account: $('#account-id').val(),
            sync: sync
        }), function(status){
            if (status === "done") {
                sync = []
                create_basket()
            }
        })
    }
});


$(document).on('click', '.cross', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    basket.indexOf(itemId);
    if (itemId > -1) {
        basket.splice(itemId, 1);
    }
    basket_count()
    create_basket()
});

$(document).on('click', '.crossSync', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    sync.indexOf(itemId);
    if (itemId > -1) {
        sync.splice(itemId, 1);
    }
    create_basket()
});

$(document).on('click', '#basket-cashout', function(event){
    event.preventDefault();
    modalOpen = true
    $(".modal-basket").css({'display': "block"})
    create_basket()
});

$(document).on('click', '.header-buttons', function(event){
    event.preventDefault();

    var itemId = $(this).attr('id');
    if (itemId !== "recovery") {
        create_items(openedData[itemId])
    } else {
        create_recovery_items(openedData[itemId])
    }
    setActive(itemId)
});

$(document).keyup(function (e) {
    if (isOpen) {
        if (e.keyCode === 27) {
            if (modalOpen === false) {
                close();
            } else {
                modalOpen = false
                $(".modal-item-info").css({'display': "none"})
                $(".modal-basket").css({'display': "none"})
            }
        }
    }
});

$(document).ready(function(){
    setActive("mobile");
});