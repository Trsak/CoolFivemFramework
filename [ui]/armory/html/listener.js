var selectedItems = [];
var isShowed = false;
var job = null;

$(function () {
	window.addEventListener('message', function (event) {
		switch (event.data.action) {
			case 'show':
				job = event.data.job
				isShowed = true;
				$('#wrap').fadeIn();
				$('#box').html(event.data.items);
				$('#box').fadeIn();
				if (job == "lspd" || job == "lspd" || job == "sahp") {
					$("#box").css("top", "60%");
					$("#box").css("height", "60%");
				}
				else if (event.data.job == "ems") {
					$("#box").css("top", "75%");
					$("#box").css("height", "24%");

				}
				else if (event.data.job == "lsfd") {
					$("#box").css("top", "75%");
					$("#box").css("height", "24%");

				}
				break;
			case 'hide':
				isShowed = false;
				$('#wrap').fadeOut();
				$('#box').fadeOut();
				selectedItems = [];
				break;
			default:
				console.log('ui_armory: unknown action!');
				break;
		}
	}, false);
});

document.onkeyup = function (data) {
	if (data.which === 27 && isShowed) {
		$.post("https://armory/close", {});
	}
};


function activateWeapon(model) {
	if (!selectedItems.includes(model)) {
		selectedItems.push(model)
		$('#' + model).css("background-color", "rgba(236, 228, 228, 0.753)");
		$('#' + model).css("color", "rgba(26, 26, 26, 0.753)");
	} else {
		var itemtoRemove = model;
		selectedItems.splice($.inArray(itemtoRemove, selectedItems), 1);
		$('#' + model).css("background-color", "rgba(34, 33, 33, 0.904)");
		$('#' + model).css("color", "white");
	}
}

function takeLoadout() {
	$.post("https://armory/takeLoadout", JSON.stringify({
		selectedItems: selectedItems,
		job: job
	}));
	selectedItems = [];
}