// Imgur CLIENT ID
const CLIENT_ID = '4af6243f5c03d71';
let callbacks = {};

function getMugshotUrl(ped, cb) {
	let id = Object.keys(callbacks).length++;
	let url;

	// Store the callback
	callbacks[id] = cb;

	// Register the ped headshot
	let mugshot = RegisterPedheadshotTransparent(ped);

	// Timeout needed to let the game register the mugshot..
	setTimeout(() => {
		// Assing the texture to a variable, unnecessary to call it twice in the DrawSprite function
		let txdString = GetPedheadshotTxdString(mugshot);

		const loop = setTick(() => {
			DrawSprite(txdString, txdString, 0.045, 0.085, 0.10, 0.18, 0.0, 255, 255, 255, 1000);
		});

		// Another timeout needed since the setTick function takes a few milliseconds to.. start(?)
		setTimeout(async () => {
			// Screenshot the screen using screenshot-basic
			let promise = new Promise((resolve) => {
				exports['screenshot-basic'].requestScreenshotUpload(`https://api.imgur.com/3/upload`, 'imgur', {
					headers: {
						'authorization': `Client-ID ${ CLIENT_ID }`,
						'content-type': 'multipart/form-data'
					},
					crop: {
						offsetX: 0,
						offsetY: 0,
						width: 160,
						height: 180
					}
				}, (data) => {
					clearTick(loop);
					resolve(JSON.parse(data).data.link);
				});
			});

			// Await the url
			url = await promise;

			// Use the callback function to send it back
			callbacks[id](url);

			// Delete the callback since it's no longer needed
			delete callbacks[id];

			// Unregister the ped headshot
			UnregisterPedheadshot(mugshot)
		}, 100);
	}, 300);
}