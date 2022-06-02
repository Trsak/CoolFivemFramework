var currentInstance = "";
var audioPlayers = [];
var currentPlayerPos = {
    x: 0.0,
    y: 0.0,
    z: 0.0
}
var circle = Math.PI * 2;

var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

const handlers = {
    playSound(data) {
        var audioData = null;

        if (data.id) {
            audioData = getAudioDataById(data.id);

            if (audioData != null) {
                audioData.audioPlayer.stop();
            }
        }

        var audioPlayer = new Howl({
            src: ["https://static.server.cz/sounds/" + data.sound + ".ogg"]
        });

        audioPlayer.on('play', function () {
            audioPlayer.pos(data.coords.x, data.coords.y, data.coords.z);
            audioPlayer.volume(calculateVolume(data.coords, data.maxDistance, data.instance) * 100);
            audioPlayer.pannerAttr({
                panningModel: 'HRTF',
                refDistance: data.maxDistance,
                rolloffFactor: 10.0,
                distanceModel: 'exponential'
            });
            refreshVolumes();
        });

        audioPlayer.on('end', function () {
            audioPlayer.paused = true;
            audioPlayer.stop();
            audioPlayer.unload();
        });

        audioPlayer.on('stop', function () {
            audioPlayer.paused = true;
            audioPlayer.unload();
        });

        audioPlayer.play();

        audioData = {
            id: data.id,
            sound: data.sound,
            audioPlayer: audioPlayer,
            coords: data.coords,
            maxDistance: data.maxDistance,
            instance: data.instance,
            type: "sound",
            shouldStop: false
        };

        audioPlayers.push(audioData);
    },
    playYoutubeSound(data) {
        var elementId = uuidv4();

        if (data.id) {
            audioData = getAudioDataById(data.id);

            if (audioData !== null) {
                audioData.audioPlayer.stopVideo();
            }

            elementId = data.id;
        }

        $("#youtubeVideos").append('<div id="' + elementId + '"></div>');

        new YT.Player(elementId, {
            playerVars: {
                'autoplay': 1,
                'loop': 0,
                'controls': 0
            },
            height: '1',
            origin: 'nui://sound',
            width: '1',
            videoId: data.video,
            events: {
                'onReady': function (event) {
                    event.target.mute();
                    event.target.setVolume(calculateVolume(data.coords, data.maxDistance, data.instance) * 100);
                    event.target.unMute();
                    event.target.playVideo();

                    audioData = {
                        id: elementId,
                        sound: data.sound,
                        audioPlayer: event.target,
                        coords: data.coords,
                        maxDistance: data.maxDistance,
                        instance: data.instance,
                        type: "youtube"
                    }

                    audioPlayers.push(audioData);
                    refreshVolumes();
                }
            }
        });
    },
    playRadio(data) {
        var audioData = null;

        if (data.id) {
            audioData = getAudioDataById(data.id);

            if (audioData != null) {
                audioData.audioPlayer.stop();
            }
        }

        var audioPlayer = new Howl({
            src: ["http://gtatime.duckdns.org:8000/airtime_256"],
            ext: ['mp3'],
            html5: true,
            autoplay: false
        });

        audioPlayer.on('play', function () {
            audioPlayer.pos(data.coords.x, data.coords.y, data.coords.z);
            audioPlayer.volume(calculateVolume(data.coords, data.maxDistance, data.instance));
            audioPlayer.pannerAttr({
                panningModel: 'HRTF',
                refDistance: data.maxDistance,
                rolloffFactor: 10.0,
                distanceModel: 'exponential'
            });
            refreshVolumes();
        });

        audioPlayer.on('end', function () {
            audioPlayer.paused = true;
            audioPlayer.stop();
            audioPlayer.unload();
        });

        audioPlayer.on('stop', function () {
            audioPlayer.paused = true;
            audioPlayer.unload();
        });

        let volume = calculateVolume(data.coords, data.maxDistance, data.instance)
        audioPlayer.volume(volume);
        if (volume >= 0.0025) {
            audioPlayer.play();
        }

        audioData = {
            id: data.id,
            sound: data.sound,
            audioPlayer: audioPlayer,
            coords: data.coords,
            maxDistance: data.maxDistance,
            instance: data.instance,
            type: "sound",
            shouldStop: false,
            radio: true
        };

        audioPlayers.push(audioData);
    },
    stopSound(data) {
        var audioData = getAudioDataById(data.id);

        if (audioData != null) {
            if (audioData.type == "sound") {
                audioData.audioPlayer.stop();
                audioData.shouldStop = true;
            } else if (audioData.type == "youtube") {
                audioData.audioPlayer.stopVideo();
            }
        }
    },
    updateAudioCoords(data) {
        for (var i = audioPlayers.length - 1; i >= 0; i--) {
            if (audioPlayers[i].id == data.id) {
                audioPlayers[i].coords = data.coords;
                refreshVolumes();
                break;
            }
        }
    },
    updatePlayerInstance(data) {
        currentInstance = data.instance;
    },
    updatePlayerCoords(data) {
        currentPlayerPos = data.coords;

        Howler.pos(currentPlayerPos.x, currentPlayerPos.y, currentPlayerPos.z);

        if (data.heading) {
            var radians = data.heading * (Math.PI / 180);
            var direction = (radians + circle) % circle;
            var x = Math.cos(direction);
            var y = 0;
            var z = Math.sin(direction);

            Howler.orientation(x, y, z, 0, 1, 0);
        }

        refreshVolumes();
    }
};

window.addEventListener('message', function (e) {
    (handlers[e.data.action] || function () {
    })(e.data);
});

function calculateVolume(coords, maxDistance, instance) {
    if (instance != currentInstance) {
        return 0.0;
    }

    var distance = calculateDistance(coords);
    if (distance > maxDistance) {
        return 0.0;
    }

    var volume = 0.2 - (Math.pow(Math.E, Math.log(distance / maxDistance)) / 4);
    if (volume < 0) {
        volume = 0.0;
    }

    return volume;
}

function calculateDistance(coords) {
    return Math.sqrt(
        Math.pow(coords.x - currentPlayerPos.x, 2) +
        Math.pow(coords.y - currentPlayerPos.y, 2) +
        Math.pow(coords.z - currentPlayerPos.z, 2)
    );
}

function refreshVolumes() {
    for (var i = audioPlayers.length - 1; i >= 0; i--) {
        if (audioPlayers[i].type == "sound") {
            if (audioPlayers[i].audioPlayer.paused && !audioPlayers[i].radio) {
                audioPlayers.splice(i, 1);
            } else if (audioPlayers[i].radio) {
                if (audioPlayers[i].shouldStop) {
                    audioPlayers.splice(i, 1);
                } else {
                    let volume = calculateVolume(audioPlayers[i].coords, audioPlayers[i].maxDistance, audioPlayers[i].instance)
                    audioPlayers[i].audioPlayer.volume(volume);
                    if (volume < 0.025 && audioPlayers[i].audioPlayer.playing()) {
                        audioPlayers[i].audioPlayer.stop();
                    } else if (volume >= 0.0025 && !audioPlayers[i].audioPlayer.playing()) {
                        audioPlayers[i].audioPlayer.play();
                    }
                }
            }
        } else if (audioPlayers[i].type == "youtube") {
            if (!audioPlayers[i].audioPlayer || audioPlayers[i].audioPlayer.getPlayerState() == 0 || audioPlayers[i].audioPlayer.getPlayerState() == 5) {
                if (audioPlayers[i].audioPlayer) {
                    audioPlayers[i].audioPlayer.destroy();
                }

                audioPlayers.splice(i, 1);
            } else {
                audioPlayers[i].audioPlayer.setVolume(calculateVolume(audioPlayers[i].coords, audioPlayers[i].maxDistance, audioPlayers[i].instance) * 100);
            }
        }
    }
}

function getAudioDataById(id) {
    for (var i = audioPlayers.length - 1; i >= 0; i--) {
        if (audioPlayers[i].id == id) {
            return audioPlayers[i];
        }
    }

    return null;
}

function uuidv4() {
    return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
}