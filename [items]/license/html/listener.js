var openedLicenseId = 0;
var config = null;
var licenses = null;
var confirmedCancel = false
var currentTest = {
    NextQuestion: null,
    AnsweredQuestions: {},
    Step: 0,
    Points: 0
};

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC 
        if (currentTest.Step <= 0 || confirmedCancel) {
            if (currentTest.Step > 0) {
                $.post('https://license/endTest', JSON.stringify({
                    type: "canceled"
                }));
                currentTest = {
                    NextQuestion: null,
                    AnsweredQuestions: {},
                    Step: 0,
                    Points: 0
                };
            } else {
                $.post('https://license/closepanel', JSON.stringify({}));
            }
        }
        if (currentTest.Step > 0) {
            if (!confirmedCancel) {
                $.post('https://license/warnExit', JSON.stringify({}));
                confirmedCancel = true
                setTimeout(function() { confirmedCancel = false }, 5000);

            }
        }
    }
};



$(function() {
    window.addEventListener('message', function(event) {
        switch (event.data.Action) {
            case 'show':
                $('.box').show();
                openedLicenseId = event.data.Opened;
                if (event.data.Config != null) {
                    config = event.data.Config
                    licenses = event.data.Licenses
                }
                openMenu(event.data.Type)
                break;
            case 'hide':
                $('.box').hide();
                break;
            case 'opencontent':
                $('.content').html(event.data.Content);
                $('#school-title').html(event.data.Title);
                break;
            case 'showasurebox':
                $('#asure-box').show();
                break;
            case 'hideasurebox':
                $('#asure-box').hide();
                break;
            default:
                console.log('license: unknown action!');
                break;
        }
    }, false);
});

function closePanel() {
    $.post('https://license/closepanel', JSON.stringify({}));
}

function endTest() {
    $.post('https://license/endTest', JSON.stringify({
        type: "canceled"
    }));
    currentTest = {
        NextQuestion: null,
        AnsweredQuestions: {},
        Step: 0,
        Points: 0
    };
}


function chooseTest(testname) {
    $.post('https://license/chooseTest', JSON.stringify({
        testname: testname
    }));
}

function openMenu(page) {
    if (page == "teoretic") {
        $('#school-title').html("Autoškola");
        var groupData = config.Licenses["TR"]

        $('.content').html(`<div class='license-point' onclick="chooseTest('TR')"><span class='license-title'>${groupData.Label}</span><br><span class='license-group-name'>${groupData.Group}</span><span class='license-price'>$${groupData.Price}</span></div>`);

    } else if (page == "teoretic-test") {
        $('#school-title').html("Teoretický test");
        nextQuestion()
    } else if (page == "practic") {
        $('.content').html(``);
        var counted = 0

        $.each(config.Licenses, function(name, licenseData) {
            if (licenseData.Requirements && licenseData.Requirements[0] == "TR" && licenses["TR"]) {
                if (!licenses[name]) {
                    counted = counted + 1
                    $(".content").append(`
                    <div class='license-point' onclick="chooseTest('${name}')"><span class='license-title'>${licenseData.Label}</span><br><span class='license-group-name'>${licenseData.Group}</span><span class='license-price'>$${licenseData.Price}</span></div>
                    `);
                } else if (licenses[name] && licenses[name].status == "unblocked") {
                    counted = counted + 1
                    $(".content").append(`
                    <div class='license-point' onclick="chooseTest('${name}')"><span class='license-title'>${licenseData.Label}</span><br><span class='license-group-name'>${licenseData.Group}  <strong class='license-blocked'>(po zákazu)</strong></span><span class='license-price'>$${licenseData.Price}</span></div>
                    `);
                } else if (licenses[name] && licenses[name].status == "blocked") {
                    counted = counted + 1
                    $(".content").append(`
                    <div class='license-point blocked'><span class='license-title'>${licenseData.Label}</span><br><span class='license-group-name'>${licenseData.Group}</span><span class='license-blocked'>${!licenses[name].blockedLabel ? "Blokováno" : licenses[name].blockedLabel}</span></div>
                    `);

                }
            }
        });
        if (counted == 0) {
            $.post('https://license/closepanel', JSON.stringify({
                notify: "nolicenses"
            }));

        }
    }
}


function nextQuestion(answered) {
    if (answered) {
        var selectedValue = $("input[name='flexRadioDefault']:checked").val();
        if (selectedValue) {
            if (selectedValue == "CORRECT") {
                currentTest.Points = currentTest.Points + 1
            }
        } else return;
        if (currentTest.Step >= config.Questions["TR"].Questions.length) {
            $.post('https://license/endTest', JSON.stringify({
                points: currentTest.Points,
                steps: currentTest.Step,
                test: "TR",
                type: "done"
            }));
            currentTest = {
                NextQuestion: null,
                AnsweredQuestions: {},
                Step: 0,
                Points: 0
            };
            return
        }
    }
    $('.content').html(``);
    var chooseRandom = null

    while (!chooseRandom) {
        var randomQuestion = getRandomInt(0, config.Questions["TR"].Questions.length)
        if (!currentTest.AnsweredQuestions[randomQuestion]) {
            currentTest.AnsweredQuestions[randomQuestion] = true
            chooseRandom = config.Questions["TR"].Questions[randomQuestion]
        }
    }

    currentTest.Step = currentTest.Step + 1
    currentTest.NextQuestion = chooseRandom
    $(".content").append(`
        <div class='license-point'><span class='license-title'>${currentTest.Step}. ${chooseRandom.Question}</span></div>
        `);

    var alphabet = [
        "A",
        "B",
        "C",
        "D",
    ]
    var randomQuestionaire = []
    var correctIndex = null
    $.each(chooseRandom.Answers, function(i, answerData) {
        randomQuestionaire.push(answerData)
        if (answerData.Correct) {
            correctIndex = i

        }
    });
    var correctPosition = getRandomInt(1, chooseRandom.Answers.length)
    var tempMoveAnswer = randomQuestionaire[correctPosition]

    randomQuestionaire[correctPosition] = chooseRandom.Answers[correctIndex]
    randomQuestionaire[correctIndex] = tempMoveAnswer

    $.each(randomQuestionaire, function(index, question) {
        $(".content").append(`
            <div class="form-check">
                <input class="form-check-input" type="radio" name="flexRadioDefault" value="${(index == correctPosition ? "CORRECT" : "INCORRECT")}" id="flexRadioDefault1">
                <label class="form-check-label" for="flexRadioDefault1">
                ${alphabet[index]}. ${question.Text}
                </label>
              </div>
            `);
    });
    $(".content").append(`
            <div class='next-button' onclick="nextQuestion(true)">Pokračovat</div>
            <div class='exit-button' onclick="endTest()">Ukončit test</div>
            `);
}




function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min) + min); //The maximum is exclusive and the minimum is inclusive
}