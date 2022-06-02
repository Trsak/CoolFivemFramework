var defBuytime = 5 * 60;

var allvehicles = null;
var currentvehicles = null;
var vehtypes = null;
var categories = null;

var currentvehicle = null;
var currentmenu = "catalog";
var currentshop = -1;
var buying = false;

var buyingcd = null;

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
		console.log("XD")
        closePanel()
	}
};

$(function () {
	window.addEventListener('message', function (event) {
		switch (event.data.action) {
			case 'show':

				$('#ui').show();	

				currentmenu = "catalog";
				currentshop = event.data.currentshop;


				allvehicles = event.data.allvehicles;

				currentvehicles = event.data.currentvehicles;
				
				vehtypes = event.data.vehtypes;

				categories = event.data.categories;

				if(buying)
					HideCurrentVehicle('test');
				else 
					ShowCatalog();
				break;
			case 'hide':
				currentmenu = "";
				$('#ui').hide();	
				break;	
			case 'catalog_refresh':
				currentvehicles = event.data.newcatalog;

				buying = false
				ShowCatalog();
		}
	}, false);
});

$(document).ready(function(){
    $('#filter').click(function(){  
        switchFilter();
    });
});

let filterReversed = false;
function switchFilter(){
	if(!filterReversed){ $("#filter").html(`<i class="fas fa-sort-numeric-down-alt"></i>`);}
	else { $("#filter").html(`<i class="fas fa-sort-numeric-down"></i>`);} 

	filterReversed = !filterReversed;
	buying = false
	
	ShowCatalog();
}

function HideCurrentVehicle(modelName) {
	console.log('TODO - Define hide vehicle in UI')
}

function RegisterVehicle(modelName) {
	if(allvehicles[modelName].model == modelName){

		$.post('https://vehicles_shop/buyVehicleAttempt', JSON.stringify({
			model: modelName,
			price: allvehicles[modelName].baseprice,
			shop: currentshop
		}));
	}else{
		console.log("Nastala chyba při nákupu vozidla - " + JSON.stringify(allvehicles[modelName].model))
	}
}

function StopShopping() {
	buying = false
	ShowCatalog();
}

$('#searchCar').on('input',function(e){
    ShowCatalog();
});

$(document).on('click','#categories-button', function(e){
	let currentIndex = $(this).attr("value")

	$('#defaultCategory').html(currentIndex)

	ShowCatalog(currentIndex.toLowerCase())
});

function ResetUI() {
	$('#vehicle_detail').hide();
	$('#vehicle_detail').html("");
	$('#vehicle-ui').html("");
	$('#categories').html("");
	$('#message').html("");
}

function LoadUI() {
	$('#categories').show()
	$('#vehicle-ui').show()
}

function closePanel(){
	$('#vehicle_detail').hide()

	buying = false

	$.post('https://vehicles_shop/closepanel', JSON.stringify({}));
}

function LoadCategories() {
	if(categories != null ){
		categories = Object.values(categories)

		let i = 0

		// Define reset button, to categories :-)

		$('#categories').append(`
			<a id='categories-button' class="banger block px-4 py-2 mt-2 text-sm font-semibold bg-transparent rounded-lg dark-mode:bg-transparent dark-mode:hover:bg-gray-600 dark-mode:focus:bg-gray-600 dark-mode:focus:text-white dark-mode:hover:text-white dark-mode:text-gray-200 md:mt-0 hover:text-gray-900 focus:text-gray-900 hover:bg-gray-200 focus:bg-gray-200 focus:outline-none focus:shadow-outline" href="#" value="Kategorie">Všechna vozidla</a>
		`);

		while(i < categories.length) {
			$('#categories').append(`
				<a id='categories-button' class="banger block px-4 py-2 mt-2 text-sm font-semibold bg-transparent rounded-lg dark-mode:bg-transparent dark-mode:hover:bg-gray-600 dark-mode:focus:bg-gray-600 dark-mode:focus:text-white dark-mode:hover:text-white dark-mode:text-gray-200 md:mt-0 hover:text-gray-900 focus:text-gray-900 hover:bg-gray-200 focus:bg-gray-200 focus:outline-none focus:shadow-outline" href="#" value="${categories[i]}">${categories[i]}</a>
			`);
			i++
		}
	}
}

function ShowCatalog(categoryName){

	if(buying) {
		console.log('[ERROR]' + 'You are in buy menu boy!')
		return
	}
	
	ResetUI();
	LoadUI();
	
	LoadCategories();

	var _lowModelname = "";
	var _lowDrivetrain = "";
	var _lowManafacturer = "";
	var _lowVehClass = "";

	var searchVal = "";
	var found = false;

	if (categoryName !== undefined && searchVal == "") {
		searchVal = categoryName
	} else {
		searchVal = $('#searchCar').val().toLowerCase();
	}

	if (searchVal == 'kategorie') {
		searchVal = ''
	}

	if(currentvehicles != null ){

		currentvehicles = Object.values(currentvehicles)
		if(!filterReversed) currentvehicles.sort(function(a, b){return a.baseprice-b.baseprice});
		else currentvehicles.sort(function(a, b){return b.baseprice-a.baseprice});
		let i = 0

		while(i < currentvehicles.length) {
			
			let key = currentvehicles[i].vehName

			if(allvehicles[key] != null){
				_lowModelname = allvehicles[key].label.toLowerCase();
				_lowDrivetrain = allvehicles[key].drivetrain.toLowerCase();
				_lowManafacturer = allvehicles[key].manufacturer.toLowerCase();
				_lowVehClass = allvehicles[key].class.toLowerCase();

				if(_lowModelname.includes(searchVal) || 
					_lowManafacturer.includes(searchVal) || 
					_lowVehClass.includes(searchVal) || 
					_lowDrivetrain == searchVal
				){
					RenderCatalogByParams(allvehicles, currentvehicles, key, i)
					found = true;
				}
			}

			i++
		};	
	}

	if (!found) {
		$('#notification').show()
		$('#message').show()
		$('#message').html('Bohužel v dané kategorii nemůžeme nalézt vozidlo.');
	} else {
		$('#notification').hide()
		$('#message').hide()
	}
}

function RenderVehicleMenu(modelName) {
	$('#vehicle-ui').hide()
	$('#vehicle_detail').show()

	buying = true

	let vehicleData = allvehicles[modelName]

	$('#vehicle_detail').append(`

		<div class="flex justify-between items-center border-b-2 bg-gray-100 border-radius-left-25 border-radius-right-25 border-gray-100 md:pl-6 md:pr-5 py-6 md:justify-center ">
			<div class="hidden md:flex items-center justify-center md:flex-1 lg:w-0">
				<div class="whitespace-nowrap inline-flex items-center justify-center px-4 py-2">
					<h3 class="pt-2 text-2xl text-center">Registrace vozidla</h3>
				</div>
			</div>
		</div>



		<div class="relative rounded-lg block md:flex items-center bg-gray-100 shadow-xl border-radius-left-clear border-radius-right-clear" style="min-height: 19rem; border-top-left-radius: 0px !important; border-top-right-radius: 0px !important;">
			<div class="relative w-full md:w-2/5 h-full overflow-hidden rounded-t-lg md:rounded-t-none md:rounded-l-lg" style="min-height: 19rem;">	
			<img class="absolute inset-0 w-full h-full object-cover object-center" src="https://static.server.cz/img/vehicles/${modelName}.png" alt="${modelName}">
			<div class="absolute bottom-4 right-0 mt-4 mr-4 bg-server-light text-white rounded-full pt-1 pb-1 pl-4 pr-4 text-xs uppercase">
				<span>${vehicleData.manufacturer}</span>
			</div>

			<div class="absolute inset-0 w-full h-full bg-indigo-900 opacity-30"></div>
				<div class="absolute inset-0 w-full h-full flex items-center justify-center fill-current text-white">
				</div>
			</div>
	
			<div class="w-full md:w-3/5 h-full bg-gray-100 rounded-lg">
				<div class="h-4/5 p-12 md:pr-5 md:pl-6 md:py-2">
					<div class="text-right">
						<p class="uppercase tracking-wide text-sm font-bold text-gray-700">Manafacturer • ${vehicleData.manufacturer}</p>
						<p class="text-3xl text-gray-900">${vehicleData.label}</p>
						<p class="text-gray-700">$${vehicleData.baseprice}</p>
					</div>

					<div class="flex flex-wrap justify-center">
						<div class="w-full px-4 text-center">
							<div class="flex justify-center py-1 lg:pt-1 pt-8">
								<div class="mr-0 p-4 text-center">
									<span class="text-xl font-bold block tracking-wide text-blueGray-600">
									${vehicleData.trunk}
									</span>
									<span class="text-sm text-blueGray-400">Kapacita kufru</span>
								</div>
								<div class="mr-0 p-4 text-center">
									<span class="text-xl font-bold block tracking-wide text-blueGray-600">
									${vehicleData.seats}
									</span>
									<span class="text-sm text-blueGray-400">Počet míst</span>
								</div>
								<div class="lg:mr-0 p-4 text-center">
									<span class="text-xl font-bold block tracking-wide text-blueGray-600">
									${vehicleData.maxspeed}
									</span>
									<span class="text-sm text-blueGray-400">Maximální rychlost</span>
								</div>
								<div class="lg:mr-0 p-4 text-center">
									<span class="text-xl font-bold block tracking-wide text-blueGray-600">
									${vehicleData.drivetrain}
									</span>
									<span class="text-sm text-blueGray-400">Pohon</span>
								</div>
								<div class="lg:mr-0 p-4 text-center">
									<span class="text-xl font-bold block tracking-wide text-blueGray-600">
									${vehicleData.class}
									</span>
									<span class="text-sm text-blueGray-400">Typ vozidla</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		<div class="flex justify-between items-center md:pl-6 md:pr-5 py-6 md:justify-start ">

			<div class="hidden md:flex items-center justify-center md:flex-1 lg:w-0">
				<div class="whitespace-nowrap inline-flex items-center justify-center px-4 py-2">
					<a onclick="StopShopping()" class="whitespace-nowrap inline-flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700">
						Zpět do katalogu
					</a>
				</div>
			</div>


			<div class="hidden md:flex items-center justify-end md:flex-1 lg:w-0">
				<a onclick="RegisterVehicle('${modelName}')"class="whitespace-nowrap inline-flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700">
					Přejít k platbě
				</a>
			</div>
		</div>
	`)
}

function RenderCatalogByParams(allvehicles, currentvehicles, key, i) {
	$('#vehicle-ui').append(`
		<div class="vehicle-card bg-white rounded-md overflow-hidden relative shadow-md" id='${key}'>
			<div class="bg-white rounded-md overflow-hidden relative shadow-md">
				<div class="image rounded-md overflow-hidden relative shadow-md">
					<img class="w-full" src="https://static.server.cz/img/vehicles/${allvehicles[key].model}.png" alt="${key}">
					<div class="absolute bottom-4 right-0 mt-4 mr-4 bg-server-light text-white rounded-full pt-1 pb-1 pl-4 pr-4 text-xs uppercase">
						<span>${allvehicles[key].manufacturer}</span>
					</div>
				</div>
		
				<div class="p-4">
					<h2 class="text-2xl text-server-dark">${allvehicles[key].label}</h2>
					
					<div class="flex justify-between mt-4 mb-4 text-gray-500">
						<div class="flex items-center">
							<svg xmlns="https://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
							</svg>
							<span class="ml-1 lg:text-xl">${allvehicles[key].class}</span>
						</div>

						<div class="flex items-center">
							<svg xmlns="https://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
								<path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
							</svg>
							<span class="ml-1 lg:text-xl">${allvehicles[key].seats}</span>
						</div>
					</div>

					<div class="vehicle-details mb-4">
						<button onclick="RenderVehicleMenu('${key}')" class="text-white bg-server-light p-4 rounded-md w-full uppercase">${(currentvehicle == null ? "DETAIL NÁKUPU $" + allvehicles[key].baseprice : "ZAKOUPIT POLOŽKU $" + allvehicles[key].baseprice )}</button>
					</div>

				</div>
			</div>
		</div>
	`);
}

