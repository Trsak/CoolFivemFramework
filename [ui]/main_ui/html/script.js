var wasDead = false;

var uiStatuses = {
    uiStatusMicrophone: true,
    uiStatusHealth: 100,
    uiStatusArmour: 0,
    uiStatusHunger: 100,
    uiStatusThirst: 100,
    uiStatusStamina: 100,
    uiStatusOxygen: 90,
    uiStatusStress: 0,
    uiStatusDrunk: 0
};

var lastData = null;
var lastNeeds = {};

function addClassToElement(element, className) {
    if (!element.classList.contains(className)) {
        element.classList.add(className);
    }
}

function removeClassFromElement(element, className) {
    if (element.classList.contains(className)) {
        element.classList.remove(className);
    }
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function checkNeedsValue(bar, value) {
    let element = document.querySelector('.' + bar);

    if (bar !== "voice") {
        if (value.toFixed(2) <= uiStatuses['uiStatus' + capitalizeFirstLetter(bar)]) {
            element.style.display = 'block';
        } else {
            element.style.display = 'none';
        }
    }
}

function checkNeedsBiggerValue(bar, value) {
    let element = document.querySelector('.' + bar);
    if (value.toFixed(2) >= uiStatuses['uiStatus' + capitalizeFirstLetter(bar)]) {
        element.style.display = 'block';
    } else {
        element.style.display = 'none';
    }
}

function widthHeightSplit(value, ele) {
    let height = 25.5;
    let eleHeight = (value / 100) * height;
    let leftOverHeight = height - eleHeight;

    ele.style.height = eleHeight + "px";
    ele.style.top = leftOverHeight + "px";
}

function changeIsDead(isDead) {
    let element = document.querySelector('.health .status-inside');

    if (isDead && !wasDead) {
        wasDead = true;
        element.innerHTML = '<i class="fas fa-skull-crossbones"></i>';
    } else if (!isDead && wasDead) {
        wasDead = false;
        element.innerHTML = '<i class="fas fa-heart"></i>';
    }
}

function setStatusBarValue(bar, value) {
    let element = document.querySelector('.' + bar);
    element.style.backgroundSize = value + "% 100%";

    if (bar === "stress" || bar === "armour" || bar === "drunk") {
        checkNeedsBiggerValue(bar, value);
    } else {
        checkNeedsValue(bar, value);
    }
}

function setVoiceRange(range) {
    let element = document.querySelector('.voice');
    let percent = (range / 15.0) * 100.0;

    element.style.backgroundSize = percent.toFixed(0) + "% 100%";
}

var enabledUI = false;

window.onload = function () {
    setVoiceRange(1.5);

    var eventCallback = {
        enableUi: function (data) {
            enabledUI = true;
        },
        toggleUi: function (data) {
            var uiID = document.querySelector('.ui');
            if (data.value == true && enabledUI) {
                uiID.style.display = 'block';
            } else {
                uiID.style.display = 'none';
            }
        },
        toggleUiStatus: function (data) {
            uiStatuses = data.uiStatuses;

            var voiceBar = document.querySelector('.voice');
            if (!uiStatuses.uiStatusMicrophone) {
                voiceBar.style.display = 'none';
            } else {
                voiceBar.style.display = 'block';
            }

            for (const [need, data] of Object.entries(lastNeeds)) {
                eventCallback.setNeeds(data);
            }

            if (lastData != null) {
                eventCallback.setData(lastData);
            }
        },
        setNeeds: function (data) {
            lastNeeds[data.need] = data;
            var statusValue;
            if (data.need === "hunger") {
                statusValue = Math.floor(data.value);
                setStatusBarValue("hunger", statusValue);
            } else if (data.need === "thirst") {
                statusValue = Math.floor(data.value);
                setStatusBarValue("thirst", statusValue);
            } else if (data.need === "stress") {
                statusValue = Math.floor(data.value);
                setStatusBarValue("stress", statusValue);
            } else if (data.need === "drunk") {
                statusValue = Math.floor(data.value);
                setStatusBarValue("drunk", statusValue);
            }
        },
        setData: function (data) {
            lastData = data;
            var statusValue;

            if ("health" in data) {
                changeIsDead(data.dead);

                if (data.dead) {
                    setStatusBarValue("health", 0);
                } else {
                    statusValue = Math.floor(data.health);
                    setStatusBarValue("health", statusValue);
                }
            }

            if ("armor" in data) {
                statusValue = Math.floor(data.armor);
                setStatusBarValue("armour", statusValue);
            }

            if ("stamina" in data) {
                statusValue = Math.floor(data.stamina);
                setStatusBarValue("stamina", statusValue);
            }

            if ("oxygen" in data) {
                statusValue = Math.floor(data.oxygen);
                if (statusValue < 0.0) {
                    statusValue = 0.0;
                } else if (statusValue > 100.0) {
                    statusValue = 100.0;
                }

                setStatusBarValue("oxygen", statusValue);
            }

            if ("voiceRange" in data) {
                statusValue = Math.floor(data.voiceRange);
                setVoiceRange(statusValue);
            }

            if ("talking" in data) {
                let element = document.querySelector('.voice .fas');

                if (data.talking && !element.classList.contains("active")) {
                    element.classList.add("active");
                } else if (!data.talking && element.classList.contains("active")) {
                    element.classList.remove("active");
                }
            }

            if ("minimapWidth" in data) {
                statusValue = data.minimapWidth * 100;
                document.querySelector('#hud').style.width = statusValue + 'vw';
            }
        }
    };

    window.addEventListener('message', function (event) {
        eventCallback[event.data.action](event.data);
    });
}