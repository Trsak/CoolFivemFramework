'use strict';

var isMenuFocused = false;
var isMenuOpen = false;

var menuItems = [{
        id: 'clothes',
        title: 'Oblečení',
        icon: '#clothes'
    },
    {
        id: 'more',
        title: 'Lidé',
        icon: '#walk',
        items: [{
                id: 'cuff',
                title: 'Pouta',
                icon: '#cuffs'
            },
            {
                id: 'search',
                title: 'Prohledat',
                icon: '#search'
            },
            {
                id: 'inoutvehicle',
                title: 'Z/Do vozidla',
                icon: '#swap'
            },
            {
                id: 'shoulderwalk',
                icon: '#take',
                title: 'Vzít'
            },
            {
                id: 'sackoff',
                icon: '#sack',
                title: 'Sundat pytel'
            }
        ]
    },
    {
        id: 'more2',
        title: 'Vozidlo',
        icon: '#drive',
        items: [{
            id: 'trunk',
            title: 'Kufr',
            icon: '#trunk'
        }, {
            id: 'box',
            title: 'Přihrádka',
            icon: '#box'
        }, {
            id: 'engine',
            title: 'Motor',
            icon: '#engine'
        }, {
            id: 'doors',
            title: 'Dveře',
            icon: '#doors'
        }, {
            id: 'window',
            title: 'Okno',
            icon: '#doors'
        }, {
            id: 'hood',
            title: 'Kapota',
            icon: '#hood'
        }]
    }, {
        id: 'injuries',
        title: 'Zranění',
        icon: '#injury'
    },
    {
        id: 'more2',
        title: 'Nošení lidí',
        icon: '#walk',
        items: [
            {
                id: 'backride',
                icon: '#liftup',
                title: 'Na záda'
            },
            {
                id: 'carry',
                icon: '#carry',
                title: 'Na rameno'
            },
            {
                id: 'liftup',
                icon: '#liftup',
                title: 'Do náručí'
            }
        ]
    }
];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
window.onload = function() {
    var svgMenu = new RadialMenu({
        parent: document.body,
        size: 400,
        closeOnClick: true,
        menuItems: menuItems,
        onClick: function(item) {
            $.post('https://rp/openmenu', JSON.stringify({
                id: item.id
            }));
        }
    });

    window.addEventListener('message', function(event) {
        if (event.data.type == "init") {
            isMenuFocused = false;
            isMenuOpen = true;
            svgMenu.open();
        } else if (event.data.type == "destroy") {
            isMenuFocused = false;
            isMenuOpen = false;
            svgMenu.close();
        }
    });

    window.oncontextmenu = function() {
        if (isMenuOpen) {
            isMenuFocused = !isMenuFocused;
            $.post('https://rp/menufocus', JSON.stringify({
                isMenuFocused: isMenuFocused
            }));
        }
    }
};