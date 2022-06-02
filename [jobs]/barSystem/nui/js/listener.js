var isOpen = false;
var modalOpen = false;
var changed = false;
var pref = 'https://barSystem/';
var imgPath = 'nui://inventory/ui/items/';
var isBoss = false
var restaurant;
var restaurantData;
var translate;

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
    document.getElementsByClassName("close")[0].onclick = function() {
      document.getElementsByClassName("modal")[0].style.display = "none";
        changePrice()
    }
    window.addEventListener('message', function (event) {
            eventCallback[event.data.action](event.data);
    });
});

function open(data) {
    $("body").show();
    isOpen = true
    isBoss = data.isBoss
    restaurantData = data.data
    restaurant = data.restaurant
    translate = data.translate
    setupMenu(data)
}

function refresh(data) {
    isBoss = data.isBoss
    restaurantData = data.data
    restaurant = data.restaurant
    translate = data.translate
    for (k in restaurantData.alcohol) {
        name = k.toLowerCase();
        for (drink in restaurantData.alcohol[k]) {
            let prefix = restaurantData.alcohol[k][drink]
            if (changed) {
                if (prefix.unique === false) {
                    if (prefix.id === parseInt(changed)){
                        $('.dFooter'+prefix.id+'').empty();
                        createButtons(prefix, name, prefix.id);
                    }
                }
            }
        }
    }
}

$(document).keyup(function (e) {
    if (isOpen) {
        if (modalOpen === false){
            if (e.keyCode === 27 ) {
                close();
            }
        }
    }
});

function close() {
    window.location.reload();
    $.post(pref + 'close', JSON.stringify({}));
    isOpen = false
}

function setupMenu(data) {
    $('.flipbook').append('<div class="hard" style="background-image:url(' + restaurantData.menu.Img + ')"></div>');
    $('.flipbook').append('<div class="hard" style="background-image:url(img/background.png)" id="restaurant"><p>' + restaurantData.menu.Rest + '</p></div>');
    if (data.isMenu) {
        createMenuItems();
        $('.flipbook').append('<div class="hard" style="background-image:url(' + restaurantData.menu.Img + ')"></div>');
    } else {
        createCraftMenuItems();
        createLastPage();
    }
    loadApp();
}

function createMenuItems() {
    for (k in restaurantData.alcohol) {
       name = k.toLowerCase();
       $('.flipbook').append('<div class="hard"  style="background-image:url(img/background.png)" id="type"><img src="img/'+name+'.png" alt=""></div>');
       for (drink in restaurantData.alcohol[k]) {
            let prefix = restaurantData.alcohol[k][drink]
            if (prefix.restaurants) {
                 label = '<div class="drinks"> \
                            <div class="dHeader"> \
                                <img src="'+imgPath+prefix.img+'.png" alt='+drink+'> \
                            </div> \
                            <div class="'+prefix.id+'"></div> \
                        </div>'
                $('.flipbook').append('<div class="hard" style="background-image:url(img/background.png)">'+ label +'</div>');
                $('.'+prefix.id+'').append('<p class="name">'+drink+'</p>');
                $('.'+prefix.id+'').append('<p class="desc">'+prefix.description+'</p>');
                if (name != 'food'){
                    $('.'+prefix.id+'').append('<p class="volume">Obsah alkoholu: '+prefix.volume+'%</p>');
                }
                $('.'+prefix.id+'').append('<p class="volume">Cena: '+prefix.cost+'$</p>');
            }
       }
    }
}

function createCraftMenuItems() {
    for (k in restaurantData.alcohol) {
        name = k.toLowerCase();
        $('.flipbook').append('<div class="hard" id="type" style="background-image:url(img/background.png)"><img src="img/'+name+'.png" alt=""></div>');
        for (drink in restaurantData.alcohol[k]) {
            let prefix = restaurantData.alcohol[k][drink]
            if (prefix.unique === false) {
                label = '<div class="drinks"> \
                        <div class="dHeader"> \
                            <img src="'+imgPath+prefix.img+'.png" alt='+drink+'> \
                        </div> \
                        <div class="'+prefix.id+'" id ="dBody"></div> \
                       <div class="dFooter'+prefix.id+'" id ="dFooter"></div> \
                    </div>'

                $('.flipbook').append('<div class="hard" style="background-image:url(img/background.png)">'+ label +'</div>');

                $('.'+prefix.id+'').append('<p class="name">'+drink+'</p>');
                $('.'+prefix.id+'').append('<p class="desc">'+prefix.description+'</p>');
                if (prefix.production) {
                    $('.'+prefix.id+'').append('<ul class="ul'+prefix.id+'">Potřebuješ:</ul>');
                    for (item in prefix.production) {
                        productionName = translate[item]
                        if (translate[item] === undefined) {
                            productionName = item
                        }
                        $('.ul'+prefix.id+'').append('<li class="items">' + productionName + ' <span style="color:red;">' + prefix.production[item] + '</span></li>');
                    }
                }
                $('.'+prefix.id+'').append('<p class="volume">Cena: '+prefix.cost+'$</p>');
                createButtons(prefix, name, prefix.id);
            }
        }
    }
}

function createButtons(prefix, name, drink) {
    if (prefix.restaurants) {
        if (isBoss) {
            $('.dFooter' + drink + '').append('<button class="button" id="button" key="' + drink + '" onclick="removeFromMenu(this)">Odebrat z menu</button>');
            document.getElementById("button").onclick = function () {
                removeFromMenu(this)
            };
        }

        if (prefix.production) {
            $('.dFooter'+drink+'').append('<button class="button" id="button1" key="'+drink+'" onclick="craft(this)">Craft'+name+'</button>');
            document.getElementById("button1").onclick = function() {craft(this)};
        }

        if (isBoss) {
            $('.dFooter'+drink+'').append('<button class="button" id="button2" key="'+drink+'" onclick="popUp(this)">Změnit Cenu</button>');
            document.getElementById("button2").onclick = function() {popUp(this)};
        }

    } else {
        if (isBoss) {
            $('.dFooter'+drink+'').append('<button class="button" id="button3" key="'+drink+'" onclick="addToMenu(this)">Přidat do menu</button>');
            document.getElementById("button3").onclick = function() {addToMenu(this)};
        }
    }
}

function createLastPage(){
    label = '<div class="drinks"> \
            <div class="dHeaderNew"> \
                <img src="img/new.png" alt="new"> \
            </div> \
            <div class="dBodyNew" id ="dBodyNew"> \
                <form id="new"> \
                    <label for="name" id="move">Zadejte název</label><br> \
                    <input type="text" id="name" name="name" value="Hnus"><br> \
                    <label id="move">Bude to Drink/Jídlo?</label><br> \
                    <input type="radio" id="food" name="type" value="food"> \
                    <label for="food">Jídlo</label> \
                    <input type="radio" id="drink" name="type" value="drink"> \
                    <label for="drink">Drink</label><br> \
                    <label id="move">Bude to unique?</label><br> \
                    <input type="radio" id="y" name="unique" value="y"> \
                    <label for="y">Ano</label> \
                    <input type="radio" id="n" name="unique" value="n"> \
                    <label for="n">Ne</label><br> \
                    <label for="capacity" id="move">Velikost ML/G</label><br> \
                    <input type="text" id="capacity" name="capacity" value="100"><br> \
                    <label for="price" id="move">Cena $</label><br> \
                    <input type="text" id="price" name="price" value="100"><br> \
                    <label for="volume" id="move">Alkohol %</label><br> \
                    <input type="text" id="volume" name="volume" value="0"><br> \
                    <label for="desc" id="move">Zadejte Popis drinku.</label><br> \
                    <textarea name="description" id="desc" form="new" maxlength="100"></textarea> \
                </form> \
            </div> \
           <div class="dFooterNew" id ="dFooter"></div> \
        </div>'
    $('.flipbook').append('<div class="hard" id="lastPage" style="background-image:url(img/background.png)">'+label+'</div>');
    $('.dFooterNew').append('<button class="button" id="button20" onclick="createNew()">Vytvoři nový drink/jídlo</button>');
    document.getElementById("button20").onclick = function() {createNew()};
}

function addToMenu(drinkName) {
    drinkId = drinkName.getAttribute("key")
    price = document.getElementById("price").value
    if (drinkId !== undefined) {
        $.post(pref + 'addToMenu', JSON.stringify({drinkId}));
        popUp(drinkName)
    }
}

function removeFromMenu(drinkName) {
    console.log(drinkName)
    drinkId = drinkName.getAttribute("key")
    changed = drinkId
    if (drinkId !== undefined) {
        $.post(pref + 'removeFromMenu', JSON.stringify({drinkId}));
    }
}

function changePrice() {
    document.getElementsByClassName("modal")[0].style.display = "none";
    drinkId = document.getElementById("price").getAttribute('key')
    price = document.getElementById("price").value
    console.log(drinkId, price)
    if (price !== undefined) {
        $.post(pref + 'changePrice', JSON.stringify({drinkId, price}));
    }
    modalOpen = false
}

function craft(drinkName) {
    drinkId = drinkName.getAttribute("key")
    if (drinkId !== undefined) {
        $.post(pref + 'craft', JSON.stringify({drinkId}));
    }
}

function popUp(drinkName) {
    drinkId = drinkName.getAttribute("key")
    document.getElementById("price").setAttribute("key", drinkId);
    document.getElementsByClassName("modal")[0].style.display = "block";
    modalOpen = true
    changed = drinkId
}

function createNew(){
    let data = {}
    let nilValue = false
    const formData = new FormData(document.querySelector('form'))
    for (var pair of formData.entries()) {
        if (pair[1] == ''){
              nilValue = true
              break
        } else {
            data[pair[0]] = pair[1]
        }
    }

    if (nilValue){
        data = false
    }
    $.post(pref + 'newItem', JSON.stringify({data}));
}

function loadApp() {
    // Create the flipbook
    $('.flipbook').turn({
        // Elevation
        elevation: 50,
        // Enable gradients
        gradients: true,
        // Auto center this flipbook
        autoCenter: false
    });
}