(function(){
	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="menu top-right"  style="position: absolute; top: 0; right: 0;">' +
			'<div class="head"><span>{{{title}}}</span><br><p>{{{description}}}</p></div>' +
				'<div class="menu-items">' +
					'{{#elements}}' +
						'<div class="menu-item {{#selected}}selected{{/selected}}">' +
							'{{{label}}}{{#isSlider}} : <span class="slider {{{infoType}}}">{{{sliderLabel}}}</span>{{/isSlider}} {{#isInfo}}<span class="infos {{{infoType}}}">{{{info}}}</span>{{/isInfo}} {{#isCheckbox}}{{{checkboxLabel}}}{{/isCheckbox}}' +
						'</div>' +
					'{{/elements}}' +
				'</div>'+
			'</div>' +
		'</div>'
	;

	window.menuNui       = {};
	menuNui.ResourceName = 'menuNui';
	menuNui.opened       = {};
	menuNui.focus        = [];
	menuNui.pos          = {};

	menuNui.open = function(namespace, name, data) {

		if (typeof menuNui.opened[namespace] == 'undefined') {
			menuNui.opened[namespace] = {};
		}

		if (typeof menuNui.opened[namespace][name] != 'undefined') {
			menuNui.close(namespace, name);
		}

		if (typeof menuNui.pos[namespace] == 'undefined') {
			menuNui.pos[namespace] = {};
		}

		for (let i=0; i<data.elements.length; i++) {
			if (typeof data.elements[i].type == 'undefined') {
				data.elements[i].type = 'default';
			}
		}

		data._index     = menuNui.focus.length;
		data._namespace = namespace;
		data._name      = name;

		for (let i=0; i<data.elements.length; i++) {
			data.elements[i]._namespace = namespace;
			data.elements[i]._name      = name;
		}

		menuNui.opened[namespace][name] = data;
		menuNui.pos   [namespace][name] = 0;

		for (let i=0; i<data.elements.length; i++) {
			if (data.elements[i].selected) {
				menuNui.pos[namespace][name] = i;
			} else {
				data.elements[i].selected = false;
			}
		}

		menuNui.focus.push({
			namespace: namespace,
			name     : name
		});

		menuNui.render();
		$('#menu_' + namespace + '_' + name).find('.menu-item.selected')[0].scrollIntoView();
	};

	menuNui.close = function(namespace, name) {

		delete menuNui.opened[namespace][name];

		for (let i=0; i<menuNui.focus.length; i++) {
			if (menuNui.focus[i].namespace == namespace && menuNui.focus[i].name == name) {
				menuNui.focus.splice(i, 1);
				break;
			}
		}

		menuNui.render();

	};

	menuNui.render = function() {

		let menuContainer       = document.getElementById('menus');
		let focused             = menuNui.getFocused();
		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in menuNui.opened) {
			for (let name in menuNui.opened[namespace]) {

				let menuData = menuNui.opened[namespace][name];
				let view     = JSON.parse(JSON.stringify(menuData));

				for (let i=0; i<menuData.elements.length; i++) {
					let element = view.elements[i];

					switch (element.type) {
						case 'default' :
							if (element.info) {
								element.isInfo = true;
							}

						break;

						case 'slider' : {
							element.isSlider    = true;
							element.sliderLabel = (typeof element.options == 'undefined') ? element.value : element.options[element.value];

							if (element.info) {
								element.isInfo = true;
							}

							break;
						}
						case 'checkbox' : {
							element.isCheckbox    = true;
							console.log(element.value)
							element.checkboxLabel = (element.value === true) ? "<i class='far fa-check-square' id='checkbox'></i>" : '<i class="far fa-square" id="checkbox" style="color:red;"></i>';
							if (element.info) {
								element.isInfo = true;
							}

							break;
						}
						default : break;
					}

					if (i == menuNui.pos[namespace][name]) {
						element.selected = true;
					}
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];
				$(menu).hide();
				menuContainer.appendChild(menu);
			}
		}

		if (typeof focused != 'undefined') {
			$('#menu_' + focused.namespace + '_' + focused.name).show();
		}

		$(menuContainer).show();

	};

	menuNui.submit = function(namespace, name, data) {
		$.post('https://' + menuNui.ResourceName + '/menu_submit', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : menuNui.opened[namespace][name].elements
		}));
	};

	menuNui.cancel = function(namespace, name) {
		$.post('https://' + menuNui.ResourceName + '/menu_cancel', JSON.stringify({
			_namespace: namespace,
			_name     : name
		}));
	};

	menuNui.change = function(namespace, name, data) {
		$.post('https://' + menuNui.ResourceName + '/menu_change', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : menuNui.opened[namespace][name].elements
		}));
	};

	menuNui.getFocused = function() {
		return menuNui.focus[menuNui.focus.length - 1];
	};

	window.onData = (data) => {

		switch (data.action) {

			case 'openMenu': {
				menuNui.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				menuNui.close(data.namespace, data.name);
				break;
			}

			case 'controlPressed': {

				switch (data.control) {

					case 'ENTER': {
						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {
							let menu    = menuNui.opened[focused.namespace][focused.name];
							let pos     = menuNui.pos[focused.namespace][focused.name];
							let elem    = menu.elements[pos];

							if (menu.elements.length > 0) {
								menuNui.submit(focused.namespace, focused.name, elem);
							}
						}

						break;
					}

					case 'BACKSPACE': {
						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {
							menuNui.cancel(focused.namespace, focused.name);
						}

						break;
					}

					case 'TOP': {

						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {

							let menu = menuNui.opened[focused.namespace][focused.name];
							let pos  = menuNui.pos[focused.namespace][focused.name];

							if (pos > 0) {
								menuNui.pos[focused.namespace][focused.name]--;
							} else {
								menuNui.pos[focused.namespace][focused.name] = menu.elements.length - 1;
							}

							let elem = menu.elements[menuNui.pos[focused.namespace][focused.name]];

							for (let i=0; i<menu.elements.length; i++) {
								if (i == menuNui.pos[focused.namespace][focused.name]) {
									menu.elements[i].selected = true;
								} else {
									menu.elements[i].selected = false;
								}
							}

							menuNui.change(focused.namespace, focused.name, elem);
							menuNui.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;

					}

					case 'DOWN' : {

						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {
							let menu   = menuNui.opened[focused.namespace][focused.name];
							let pos    = menuNui.pos[focused.namespace][focused.name];
							let length = menu.elements.length;

							if (pos < length - 1) {
								menuNui.pos[focused.namespace][focused.name]++;
							} else {
								menuNui.pos[focused.namespace][focused.name] = 0;
							}

							let elem = menu.elements[menuNui.pos[focused.namespace][focused.name]];

							for (let i=0; i<menu.elements.length; i++) {
								if (i == menuNui.pos[focused.namespace][focused.name]) {
									menu.elements[i].selected = true;
								} else {
									menu.elements[i].selected = false;
								}
							}

							menuNui.change(focused.namespace, focused.name, elem);
							menuNui.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					case 'LEFT' : {

						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {
							let menu = menuNui.opened[focused.namespace][focused.name];
							let pos  = menuNui.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									let min = (typeof elem.min == 'undefined') ? 0 : elem.min;

									if (elem.value > min) {
										elem.value--;
										menuNui.change(focused.namespace, focused.name, elem);
									}
									console.log(elem.value)
									menuNui.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					case 'RIGHT' : {

						let focused = menuNui.getFocused();

						if (typeof focused != 'undefined') {
							let menu = menuNui.opened[focused.namespace][focused.name];
							let pos  = menuNui.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {

									if (typeof elem.options != 'undefined' && elem.value < elem.options.length - 1) {
										elem.value++;
										menuNui.change(focused.namespace, focused.name, elem);
									} else {
										if (typeof elem.max != 'undefined' && elem.value < elem.max) {
											elem.value++;
											menuNui.change(focused.namespace, focused.name, elem);
										}
									}

									menuNui.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					default : break;

				}

				break;
			}

		}

	};

	window.onload = function(e){
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
