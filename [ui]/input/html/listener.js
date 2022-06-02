$(function () {
	window.addEventListener('message', function (event) {
		if (event.data.action == "openInput") {
			if (event.data.type == "text") {
				$('#inputTextForm h5').html(event.data.data.title);
				$('#inputText').attr("placeholder", event.data.data.placeholder);
				$('#inputText').val(event.data.data.value);

				if (event.data.data.hidden) {
					$('#inputText').attr('type','password');
				} else {
					$('#inputText').attr('type','text');
				}

				$('#inputNumberForm').hide();
				$('#inputTextForm').show();
				$('body').show();

				$('#inputText').focus();
			} else if (event.data.type == "number") {
				$('#inputNumberForm h5').html(event.data.data.title);
				$('#inputNumber').attr("placeholder", event.data.data.placeholder);
				$('#inputNumber').val(event.data.data.value);

				$('#inputTextForm').hide();
				$('#inputNumberForm').show();
				$('body').show();

				$('#inputNumber').focus();
			}
		}
	});
});

function closeInput() {
	$('body').hide();
}

$('#inputNumberForm').submit(function (event) {
	event.preventDefault();
	closeInput();

	$.post("https://input/confirmed", JSON.stringify({
		value: $('#inputNumber').val()
	}));
})

$('#inputTextForm').submit(function (event) {
	event.preventDefault();
	closeInput();

	$.post("https://input/confirmed", JSON.stringify({
		value: $('#inputText').val()
	}));
})

document.onkeyup = function (data) {
	if (data.which == 27) {
		closeInput();
		$.post('https://input/closedmenu', JSON.stringify({}));
	}
};