$(function () {
	window.addEventListener('message', function (event) {
		switch (event.data.action) {
			case 'show':
				$('#box').html(event.data.list);
				$('#box').show();
				break;
			case 'hide':
				$('#box').hide();
				break;
			case 'refresh':
				$('#box').html(event.data.list);
				break;
			default:
				console.log('ui_ids: unknown action!');
				break;
		}
	}, false);
});