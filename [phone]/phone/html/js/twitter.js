var CurrentTwitterTab = "twitter-home"
var HashtagOpen = false;
var HashTagOpenHandle;
var TwitterSettings;
var MinimumTrending = 100;

$(document).on('click', '.twitter-header-tab', function(e){
    if (QB.Phone.Data.MetaData.internet) {
        e.preventDefault();
        var PressedTwitterTab = $(this).data('twittertab');
        var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');
        if (TwitterSettings.account.logged) {
            $(".twitter-new-tweet").css({"display": "block"});
        }

        if (PressedTwitterTab !== CurrentTwitterTab) {
            $(this).addClass('selected-twitter-header-tab');
            $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');

            $("." + CurrentTwitterTab + "-tab").css({"display": "none"});
            $("." + PressedTwitterTab + "-tab").css({"display": "block"});

            if (PressedTwitterTab === "twitter-mentions") {
                $.post('https://phone/ClearMentions');
            }

            if (PressedTwitterTab == "twitter-home") {
                $.post('https://phone/GetTweets', JSON.stringify({}), function (Tweets) {
                    QB.Phone.Notifications.LoadTweets(Tweets);
                });
            }

            if (PressedTwitterTab == "twitter-hotTweets") {
                $.post('https://phone/GetTweets', JSON.stringify({}), function (HotTweets) {
                    QB.Phone.Notifications.HotTweets(HotTweets);
                });
            }

            if (PressedTwitterTab === "twitter-settings") {
                $(".twitter-new-tweet").css({"display": "none"});
                QB.Phone.Functions.LoadTwitterSettings(TwitterSettings)
            }

            if (PressedTwitterTab === "twitter-acc") {
                QB.Phone.Functions.loadTwAcc()
            }

            CurrentTwitterTab = PressedTwitterTab;

            if (HashtagOpen) {
                event.preventDefault();

                $(".twitter-hashtag-tweets").css({"left": "30vh"});
                $(".twitter-hashtags").css({"left": "0vh"});
                if (TwitterSettings.account.logged) {
                    $(".twitter-new-tweet").css({"display": "block"});
                }
                $(".twitter-hashtags").css({"display": "block"});
                HashtagOpen = false;
            }else{
                HashTagOpenHandle = null;
            }
        } else if (CurrentTwitterTab == "twitter-hashtags" && PressedTwitterTab == "twitter-hashtags") {
            if (HashtagOpen) {
                event.preventDefault();

                $(".twitter-hashtags").css({"display": "block"});
                $(".twitter-hashtag-tweets").animate({
                    left: 30 + "vh"
                }, 150);
                $(".twitter-hashtags").animate({
                    left: 0 + "vh"
                }, 150);
                HashtagOpen = false;
            }
        } else if (CurrentTwitterTab == "twitter-home" && PressedTwitterTab == "twitter-home") {
            event.preventDefault();

            $.post('https://phone/GetTweets', JSON.stringify({}), function (Tweets) {
                QB.Phone.Notifications.LoadTweets(Tweets);
            });
        } else if (CurrentTwitterTab == "twitter-hotTweets" && PressedTwitterTab == "twitter-hotTweets") {
            event.preventDefault();

            $.post('https://phone/GetTweets', JSON.stringify({}), function (Tweets) {
                QB.Phone.Notifications.HotTweets(Tweets);
            });
        } else if (CurrentTwitterTab == "twitter-mentions" && PressedTwitterTab == "twitter-mentions") {
            event.preventDefault();

            $.post('https://phone/GetMentionedTweets', JSON.stringify({}), function (MentionedTweets) {
                QB.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
            })
        } else if (CurrentTwitterTab == "twitter-acc" && PressedTwitterTab == "twitter-acc") {
            event.preventDefault();
            $(".twitter-new-tweet").css({"display": "none"});
            QB.Phone.Functions.loadTwAcc()
        } else if (CurrentTwitterTab == "twitter-settings" && PressedTwitterTab == "twitter-settings") {
            event.preventDefault();
            $(".twitter-new-tweet").css({"display": "none"});
            QB.Phone.Functions.LoadTwitterSettings(TwitterSettings)
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
    }
});

QB.Phone.Functions.loadTwAcc = function(){
    $(".twitter-new-tweet").css({"display": "none;"});
    var buttons = $(".twitter-acc-buttons")
    buttons.html("");
    var elemAdd = '<div class="twitter-acc-button" id="twitter-login"><p>Log In</p></div><div class="twitter-acc-button" id="twitter-sign"><p>Create</p></div>';
    var name;
    var profilepicture = '<img src="./img/default.png" alt="profilepicture">';
    var query = $('[data-twitteracctab="default"]')
    if (TwitterSettings.account.logged) {
        elemAdd = '<div class="twitter-acc-button" id="twitter-acc-settings"><p>Settings</p></div><div class="twitter-acc-button" id="twitter-logout"><p>Log Out</p></div>';
        if (TwitterSettings.account.profilepicture !== "default") {
            profilepicture = '<img src="' + TwitterSettings.account.profilepicture + '" alt="profilepicture">';
        }
        $(".twitter-new-tweet").css({"display": "block;"})
        name = TwitterSettings.account.name;
    } else {
        name = 'Not Registered';
    }
    query.find('.twitter-acc-icon').html(profilepicture);
    query.find('.twitter-acc-username').html(name);
    buttons.append(elemAdd);
}

$(document).on('click', '.twitter-new-tweet', function(e){
    e.preventDefault();
    if (TwitterSettings.account.logged) {
        QB.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
    }
});

$(document).on('click', '#twitter-sign', function(e){
    e.preventDefault();
    $('#twitter-new-acc-header').html('<p>New Account</p>');
    var buttons = $(".twitter-new-acc-buttons").html('');
    var elemAdd = '<div class="twitter-new-acc-button" id="create-twitter-acc">\n' +
        '<p>Create</p>\n' +
        '</div>\n' +
        '<div class="twitter-new-acc-button" id="cancel-twitter-acc">\n' +
        '<p>Cancel</p>\n' +
        '</div>';
    buttons.append(elemAdd);
    QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, 0);
});

$(document).on('click', '#twitter-acc-settings', function(e){
    e.preventDefault();
    $('#twitter-new-acc-header').html('<p>Account Settings</p>');
    var buttons = $(".twitter-new-acc-buttons").html("");
    var elemAdd = '<div class="twitter-new-acc-button" id="save-twitter-acc">\n' +
        '<p>Save</p>\n' +
        '</div>\n' +
        '<div class="twitter-new-acc-button" id="cancel-twitter-acc">\n' +
        '<p>Cancel</p>\n' +
        '</div>';
    buttons.append(elemAdd);
    for (let input of document.querySelector('#new')){
        if (input.name === 'name') {
            $("#"+input.id+"").val(TwitterSettings.account.name);
        }
        if (input.name === 'password') {
            $("#"+input.id+"").val(TwitterSettings.account.password);
        }
        if (input.name === 'profilepicture') {
            $("#"+input.id+"").val(TwitterSettings.account.profilepicture);
        }
        if (input.name === 'email') {
            $("#"+input.id+"").val(TwitterSettings.account.email);
        }
    }
    QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, 0);
});

$(document).on('click', '#save-twitter-acc', function(e){
    e.preventDefault();
    var validate = validateNewForm()
    var data = validate[0]
    var nilValue = validate[1]
    console.log(nilValue)
    if (!nilValue){
        $.post('https://phone/EditTwitterAcc', JSON.stringify({data}), function(callback){
            console.log(callback)
            if (callback) {
                clearForm('new')
                QB.Phone.Functions.loadTwAcc()
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Úspěch", "Změna úspěšná!", "#25D366", 1000);
                QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
            } else {
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Nic si nezměnil!", "#ff0000", 1000);
            }
        })
    }
});

$(document).on('click', '#twitter-login', function(e){
    e.preventDefault();
    if (TwitterSettings.account.name !== undefined && TwitterSettings.account.password !== undefined) {
        for (let input of document.querySelector('#login')){
            if (input.name === 'name') {
                $("#"+input.id+"").val(TwitterSettings.account.name);
            }
            if (input.name === 'password') {
                $("#"+input.id+"").val(TwitterSettings.account.password);
            }
        }
    }

   QB.Phone.Animations.TopSlideDown(".twitter-login-tab", 450, 0);
});

$(document).on('click', '#twitter-logout', function(e){
    e.preventDefault();
    let data = TwitterSettings.account
    $.post('https://phone/SignOutTwitter', JSON.stringify({data}), function (callback) {
        if (callback) {
            QB.Phone.Functions.loadTwAcc()
            QB.Phone.Notifications.Add("fas fa-feather-alt", "Úspěch", "Odhlásil ses z Twitteru!", "#25D366", 1000);
        }
    })
});


QB.Phone.Functions.testImage = async function(url) {
    var img = new Image();
    var status = "error"
    var loading = false
    img.onload = function() {status = "success"; loading = true };
    img.onerror = function() {status = "erorr"; loading = true };
    img.src = url
    await until(_ => loading === true);
    return status
}
function until(conditionFunction) {

    const poll = resolve => {
        if(conditionFunction()) resolve();
        else setTimeout(_ => poll(resolve), 400);
    }

    return new Promise(poll);
}

QB.Phone.Functions.validateEmail = function (email) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

$(document).on('click', '#create-twitter-acc', function(e){
    e.preventDefault();
    var buttons = $(".twitter-new-acc-buttons").html("");
    var elemAdd = '<div class="twitter-new-acc-button" id="create-twitter-acc">\n' +
        '<p>Create</p>\n' +
        '</div>\n' +
        '<div class="twitter-new-acc-button" id="cancel-twitter-acc">\n' +
        '<p>Cancel</p>\n' +
        '</div>';
    buttons.append(elemAdd);
    var validate = validateNewForm()
    var data = validate[0]
    var nilValue = validate[1]

    if (!nilValue){
        $.post('https://phone/CreateTwitterAcc', JSON.stringify({data}), function(callback){
            if (callback) {
                clearForm('new')
                QB.Phone.Functions.loadTwAcc()
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Úspěch", "Hesla Twitter založen!", "#25D366", 1000);
                QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
            } else {
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Jméno nebo email už se používá!", "#ff0000", 1000);
            }
        })
    }
});

function validateNewForm(){
    var data = {}
    var nilValue = false
    const formData = new FormData(document.querySelector('#new'))

    for (var pair of formData.entries()) {
        if (pair[0] === "profilepicture"){
            if (pair[1] !== "default") {
                var img = new Image();
                var status = "success"
                img.onload = function() { console.log('23'); status = "success"; };
                img.onerror = function() { console.log('24'); status = "error"; };
                img.src = pair[1]
                if (status !== "success") {
                    nilValue = true
                    QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Špatný URL", "#ff0000", 1000);
                    break
                }
            }
        }
        if(pair[0] === "email") {
            if(!QB.Phone.Functions.validateEmail(pair[1])) {
                nilValue = true
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Špatný EMAIL", "#ff0000", 1000);
                break
            }
        }
        if(pair[0] === "password") {
            if(pair[1].length <= 3 && pair[1].length >= 6 ) {
                nilValue = true
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Heslo s minimalně 3 znakama a maximalně 6", "#ff0000", 1000);
                break
            }
            if(pair[1].search(" ") !== -1 ) {
                nilValue = true
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Máš v hesle mezeru!", "#ff0000", 1000);
                break
            }
        }
        if (pair[1] === ''){
            nilValue = true
            QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Něco Nevyplněný", "#ff0000", 1000);
            break
        } else {
            data[pair[0]] = pair[1]
        }
    }
    if (data["password"] !== data["repassword"]){
        nilValue = true
        QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Hesla nesouhlasí!", "#ff0000", 1000);
    }

    return [data, nilValue];
}

function clearForm(name){
    for (let input of document.querySelector('#'+name+'')){
        val = ""
        if (input.name === 'profilepicture') {
            //val = "default"
        }
        $("#"+input.id+"").val(val);
    }
}

$(document).on('click', '#login-twitter', function(e){
    e.preventDefault();
    var data = {}
    var nilValue = false
    const formData = new FormData(document.querySelector('#login'))
    for (var pair of formData.entries()) {
        if (pair[1] === ''){
              nilValue = true
              QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Něco Nevyplněný", "#ff0000", 1000);
              break
        } else {
            data[pair[0]] = pair[1]
        }
    }

    if (nilValue){
        QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "ERRROROROOROO", "#ff0000", 1000);
    } else {
        $.post('https://phone/LogInTwitter', JSON.stringify({data}), function(callback){
            if (callback[0]) {
                clearForm('login')
                QB.Phone.Functions.loadTwAcc()
                QB.Phone.Notifications.Add("fas fa-feather-alt", "Úspěch", "Úspěšně si se přihlásil na twitter!", "#25D366", 1000);
                QB.Phone.Animations.TopSlideDown(".twitter-login-tab", 450, -120);
            } else {
                if (callback[1] === "PW") {
                    QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Špatné heslo troubo!", "#ff0000", 1000);
                } else {
                    QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Někdo už je na účtě přihlášený.", "#ff0000", 1000);
                }
            }
        })
    }
});

$(document).on('click', '#cancel-twitter-acc', function(e){
    e.preventDefault();
    clearForm('new')
   QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
});


$(document).on('click', '#cancel-twitter', function(e){
    e.preventDefault();
    clearForm('login')
   QB.Phone.Animations.TopSlideDown(".twitter-login-tab", 450, -120);
});

QB.Phone.Functions.LoadTwitterSettings = function(Settings) {
    TwitterSettings = Settings
    for (setting in TwitterSettings.notifications) {
        var checkBoxes = $(".settings-" + setting + "");
        checkBoxes.prop("checked", TwitterSettings.notifications[setting]);

        if (!TwitterSettings.notifications[setting]) {
            $("#" + setting + " > p").html('Off');
        } else {
            $("#" + setting + " > p").html('On');
        }
    }
}

$(document).on('click', '.twitter-settings-secondTab', function(e){
    e.preventDefault();
    var PressedTwitterTab = $(this).data('twittersettingstab');
    if ($(".settings-"+PressedTwitterTab+"")) {
        var checkBoxes = $(".settings-"+PressedTwitterTab+"");
        TwitterSettings.notifications[PressedTwitterTab] = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", TwitterSettings.notifications[PressedTwitterTab] );

        if (!TwitterSettings.notifications[PressedTwitterTab] ) {
            $("#"+PressedTwitterTab+" > p").html('Off');
        } else {
            $("#"+PressedTwitterTab+" > p").html('On');
        }
    }
});

$(document).on('click', '#save-settings', function(e){
    e.preventDefault();
    $.post('https://phone/SetTwitterSettings', JSON.stringify({TwitterSettings}), function(Settings){
        QB.Phone.Functions.LoadTwitterSettings(Settings)
    })
});

$(document).on('click', '#reset-settings', function(e){
    e.preventDefault();
    $.post('https://phone/SetTwitterSettings', JSON.stringify({TwitterSettings}), function(Settings){
        Settings.notifications = {
            ["all-notification"] : true,
            ["mention-notification"] : true,
            ["email-notification"] : false
        }
        QB.Phone.Functions.LoadTwitterSettings(Settings)
    })
});

QB.Phone.Notifications.HotTweets = function(Tweets) {
    var HotTweets;
    var isTweet = false;
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        HotTweets = Tweets.sort(function(a, b){
            return(b.likes.length - a.likes.length)
        });
        $.each(Tweets, function(i, Tweet){
            if (!Tweet.deleted && Tweet.likes.length > 10){
                isTweet = true
            }
        })
        if (HotTweets !== null && HotTweets !== undefined && HotTweets !== "" && HotTweets.length > 0 && isTweet) {
            $(".twitter-hotTweets-tab").html("");
            $.each(Tweets, function(i, Tweet){
                if (!Tweet.deleted && Tweet.likes.length > 10){
                    var clean = DOMPurify.sanitize(Tweet.message , {
                        ALLOWED_TAGS: [],
                        ALLOWED_ATTR: []
                    });
                    if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
                    var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
                    var today = new Date();
                    var TweetTime = new Date(Tweet.time);
                    var diffMs = (today - TweetTime);
                    var diffDays = Math.floor(diffMs / 86400000);
                    var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
                    var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
                    var diffSeconds = Math.round(diffMs / 1000);
                    var TimeAgo = diffSeconds + ' s';

                    if (diffMins > 0) {
                        TimeAgo = diffMins + ' m';
                    } else if (diffHrs > 0) {
                        TimeAgo = diffHrs + ' h';
                    } else if (diffDays > 0) {
                        TimeAgo = diffDays + ' d';
                    }

                    var TwitterHandle = Tweet.name
                    var PictureUrl = "./img/default.png"
                    if (Tweet.picture !== "default") {
                        PictureUrl = Tweet.picture
                    }

                    var likes = Tweet.likes.length
                    if (likes === undefined) {
                        likes = 0
                    }

                    var heart = "far"
                    $.each(Tweet.likes, function(i, user){
                        if (user === TwitterSettings.account.twitterID) {
                            heart = "fas"
                            return false;
                        }
                    })

                    var TweetElement = '<div class="twitter-tweet" data-twtid="'+Tweet.tweetID+'">' +
                        '<div class="tweet-tweeter">'+TwitterHandle+' &nbsp;<span>@'+TwitterHandle+' &middot; '+TimeAgo+'</span></div>'+
                        '<div class="tweet-message">'+TwtMessage+'</div>'+
                        '<div class="tweet-bottom" data-twthandler="@'+TwitterHandle+'" data-twtid="'+Tweet.tweetID+'"><div class="tweet-likes"><i id="tweet-heart" class="'+heart+' fa-heart"></i><span style="margin-left: .6vh;font-weight: bolder;">'+likes+'</span></div></div>' +
                        '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image" alt="picture"></div>' +
                        '</div>';


                    $(".twitter-hotTweets-tab").append(TweetElement);
                }
            });
        }
    }
}

QB.Phone.Notifications.LoadTweets = function(Tweets) {
    if (!TwitterSettings) {
        QB.Phone.Notifications.LoadTweets(Tweets)
    }
    $(".twitter-home-tab").html("<div class=\"twitter-no-tweets\">\n" +
        "<p>No Tweets have been posted yet.. :(</p>\n" +
        "</div>");
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-home-tab").html("");
        $.each(Tweets, function(i, Tweet){
            if (!Tweet.deleted){
                var clean = DOMPurify.sanitize(Tweet.message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
                var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
                var today = new Date();
                var TweetTime = new Date(Tweet.time);
                var diffMs = (today - TweetTime);
                var diffDays = Math.floor(diffMs / 86400000);
                var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
                var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
                var diffSeconds = Math.round(diffMs / 1000);
                var TimeAgo = diffSeconds + ' s';

                if (diffMins > 0) {
                    TimeAgo = diffMins + ' m';
                } else if (diffHrs > 0) {
                    TimeAgo = diffHrs + ' h';
                } else if (diffDays > 0) {
                    TimeAgo = diffDays + ' d';
                }

                var TwitterHandle = Tweet.name
                var PictureUrl = "./img/default.png"
                if (Tweet.picture !== "default") {
                    PictureUrl = Tweet.picture
                }

                var likes = Tweet.likes.length
                if (likes === undefined) {
                    likes = 0
                }

                var heart = "far"
                $.each(Tweet.likes, function(i, user){
                    if (user === TwitterSettings.account.twitterID) {
                        heart = "fas"
                        return false;
                    }
                })

                var style = "display:none;"
                if (TwitterSettings.account) {
                    if (Tweet.twitterID === TwitterSettings.account.twitterID) {
                        style = "display:block;"
                    }
                }

                var TweetElement = '<div class="twitter-tweet" data-twtid="'+Tweet.tweetID+'">' +
                    '<div class="tweet-tweeter">'+TwitterHandle+' &nbsp;<span>@'+TwitterHandle+' &middot; '+TimeAgo+'</span></div>'+
                    '<div class="tweet-message">'+TwtMessage+'</div>'+
                    '<div class="tweet-bottom" data-twthandler="@'+TwitterHandle+'" data-twtid="'+Tweet.tweetID+'"><div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                    '<div class="tweet-likes"><i id="tweet-heart" class="'+heart+' fa-heart"></i><span style="margin-left: .6vh;font-weight: bolder;">'+likes+'</span></div>'+
                    '<div class="tweet-delete" style="'+ style +'"><i class="fas fa-trash-alt"></i></div></div>' +
                    '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image" alt="picture"></div>' +
                    '</div>';


                $(".twitter-home-tab").append(TweetElement);
            }
        });
    }
}

$(document).on('click', '.tweet-reply', function(e){
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    $("#tweet-new-message").val(TwtName + " ");
    QB.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
});

$(document).on('click', '.tweet-likes', function(e){
    e.preventDefault();
    var TwtID = $(this).parent().data('twtid');

    $.post('https://phone/EditTweet', JSON.stringify({
        tweetID: TwtID,
        action: "like"
    }));
    QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
});

$(document).on('click', '.tweet-delete', function(e){
    e.preventDefault();
    var TwtID = $(this).parent().data('twtid');
    $.post('https://phone/EditTweet', JSON.stringify({
        tweetID: TwtID,
        action: "delete"
    }));
});

QB.Phone.Notifications.LoadMentionedTweets = function(Tweets) {
    $(".twitter-mentions-tab").html("                        <div class=\"twitter-no-tweets\">\n" +
        "                            <p>You haven't been mentioned yet.. :(</p>\n" +
        "                        </div>");
    Tweets = Tweets.reverse();
    if (Tweets.length > 0) {
        $(".twitter-mentions-tab").html("");
        $.each(Tweets, function(i, Tweet){
            if (!Tweet.deleted) {
                var clean = DOMPurify.sanitize(Tweet.message , {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
                var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
                var today = new Date();
                var TweetTime = new Date(Tweet.time);
                var diffMs = (today - TweetTime);
                var diffDays = Math.floor(diffMs / 86400000);
                var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
                var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
                var diffSeconds = Math.round(diffMs / 1000);
                var TimeAgo = diffSeconds + ' s';

                if (diffSeconds > 60) {
                    TimeAgo = diffMins + ' m';
                } else if (diffMins > 60) {
                    TimeAgo = diffHrs + ' h';
                } else if (diffHrs > 24) {
                    TimeAgo = diffDays + ' d';
                }

                var TwitterHandle = Tweet.name
                var PictureUrl = "./img/default.png";
                if (Tweet.picture !== "default") {
                    PictureUrl = Tweet.picture
                }

                var likes = Tweet.likes.length
                if (likes === undefined) {
                    likes = 0
                }

                var heart = "far"
                $.each(Tweet.likes, function(i, user){
                    if (user === TwitterSettings.account.twitterID) {
                        heart = "fas"
                        return false;
                    }
                })

                var TweetElement = '<div class="twitter-tweet" data-twtid="'+Tweet.tweetID+'">' +
                    '<div class="tweet-tweeter">'+TwitterHandle+' &nbsp;<span>@'+TwitterHandle+' &middot; '+TimeAgo+'</span></div>'+
                    '<div class="tweet-message">'+TwtMessage+'</div>'+
                    '<div class="tweet-bottom" data-twthandler="@'+TwitterHandle+'" data-twtid="'+Tweet.tweetID+'"><div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                    '<div class="tweet-likes"><i id="tweet-heart" class="'+heart+' fa-heart"></i><span style="margin-left: .6vh;font-weight: bolder;">'+likes+'</span></div>'+
                    '</div>' +
                    '<div class="twt-img" style="top: 1vh;"><img src="'+PictureUrl+'" class="tweeter-image" alt="picture"></div>' +
                    '</div>';

                $(".twitter-mentioned-tweet").css({"background-color":"#F5F8FA"});
                $(".twitter-mentions-tab").append(TweetElement);
            }
        });
    }
}

QB.Phone.Functions.FormatTwitterMessage = function(TwitterMessage) {
    var TwtMessage = TwitterMessage;
    var res = TwtMessage.split("@");
    var tags = TwtMessage.split("#");
    var InvalidSymbols = [
        "[",
        "?",
        "!",
        "@",
        "#",
        "]",
    ]

    for(i = 1; i < res.length; i++) {
        var MentionTag = res[i].split(" ")[0];
        if (MentionTag !== null && MentionTag !== undefined && MentionTag !== "") {
            TwtMessage = TwtMessage.replace("@"+MentionTag, "<span class='mentioned-tag' data-mentiontag='@"+MentionTag+"' style='color: rgb(27, 149, 224);'>@"+MentionTag+"</span>");
        }
    }

    for(i = 1; i < tags.length; i++) {
        var Hashtag = tags[i].split(" ")[0].replaceAll(' ','');

/*
        for(i = 1; i < InvalidSymbols.length; i++){
            var symbol = InvalidSymbols[i];
            var res = Hashtag.indexOf(symbol);
            if (res > -1) {
                Hashtag = Hashtag.replace(symbol, "");
            }
        }
*/

        if (Hashtag !== null && Hashtag !== undefined && Hashtag !== "") {
            TwtMessage = TwtMessage.replace("#"+Hashtag, "<span class='hashtag-tag-text' data-hashtag='"+Hashtag+"' style='color: rgb(27, 149, 224);'>#"+Hashtag+"</span>");
        }
    }

    return TwtMessage
}

$(document).on('click', '#send-tweet', function(e){
    e.preventDefault();

    var TweetMessage = $("#tweet-new-message").val().replace(/\r\n/g, '<br />').replace(/[\r\n]/g, '<br />');
    if (TweetMessage !== "") {
        var CurrentDate = new Date();
        $.post('https://phone/PostNewTweet', JSON.stringify({
            twitterID: TwitterSettings.account.twitterID,
            name:TwitterSettings.account.name,
            Message: TweetMessage,
            Time: CurrentDate,
            Picture: TwitterSettings.account.profilepicture,
            Image: "null"
        }));
        QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
    } else {
        QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Fill a message!", "#1DA1F2");
    }
});

$(document).on('click', '#cancel-tweet', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
});

$(document).on('click', '.mentioned-tag', function(e){
    e.preventDefault();
    CopyMentionTag(this);
});

$(document).on('click', '.hashtag-tag-text', function(e){
    e.preventDefault();
    if (!HashtagOpen) {
        var Hashtag = $(this).data('hashtag');
        var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="'+CurrentTwitterTab+'"]');
    
        $("#twitter-hashtags").addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');
    
        $("."+CurrentTwitterTab+"-tab").css({"display":"none"});
        $(".twitter-hashtags-tab").css({"display":"block"});
    
        $.post('https://phone/GetHashtagMessages', JSON.stringify({hashtag: Hashtag}), function(HashtagData){
            QB.Phone.Notifications.LoadHashtagMessages(HashtagData.messages);
        });
    
        $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
        $(".twitter-hashtag-tweets").css({"left": "0vh"});
        $(".twitter-hashtags").css({"left": "-30vh"});
        $(".twitter-hashtags").css({"display":"none"});
        HashtagOpen = true;
    
        CurrentTwitterTab = "twitter-hashtags";
    }
});

function CopyMentionTag(elem) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(elem).data('mentiontag')).select();
    QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", $(elem).data('mentiontag')+ " copied!", "rgb(27, 149, 224)", 1250);
    document.execCommand("copy");
    $temp.remove();
}

QB.Phone.Notifications.LoadHashtags = function(hashtags) {
    var Hashtags = {};
    let test = [];
    $(".twitter-hashtags").html("<div class=\"twitter-no-tweets\">\n" +
        "<p>There are no hashtags yet #SAD.. :(</p>\n" +
        "</div>");


    $.each(hashtags, function(i, hashtag){
        $.each(hashtag.messages, function(msgI, msg){
          if (msg.deleted) {
              hashtags[i].messages.indexOf(msgI);
              if (msgI > -1) {
                  hashtags[i].messages.splice(msgI, 1);
              }
          }
        })
        test.push(hashtag.messages)
        test.sort(function(a, b){
            return b.length - a.length
        });
    })

    $.each(test, function(i, hashtag){
        if (hashtag[0]) {
            if (hashtag[0].hashtag_handle){
                handle = hashtag[0].hashtag_handle
                Hashtags[handle] = {}
                Hashtags[handle] = hashtags[handle]
            }
        }
    })

    if (Hashtags) {
        var id = 0;
        $(".twitter-hashtags").html("");
        $.each(Hashtags, function(i, hashtag){
            if (hashtag.messages.length !== 0 ) {
                var Elem = '';
                id += 1;
                var TweetHandle = "Tweet";

                var HashTags = hashtag.hashtag[0];
                if (hashtag.hashtag.length > 1) {
                    HashTags = hashtag.hashtag.toString();
                }

                if (hashtag.messages.length > 1) {
                    TweetHandle = "Tweets";
                }

                if (hashtag.messages.length >= MinimumTrending) {
                    Elem = '<div class="twitter-hashtag" id="tag-' + id + '"><div class="twitter-hashtag-status">Trending</div> <div class="twitter-hashtag-tag">#' + HashTags + '</div> <div class="twitter-hashtag-messages">' + hashtag.messages.length + ' ' + TweetHandle + '</div> </div>';
                } else {
                    Elem = '<div class="twitter-hashtag" id="tag-' + id + '"><div class="twitter-hashtag-status">Not trending</div> <div class="twitter-hashtag-tag">#' + HashTags + '</div> <div class="twitter-hashtag-messages">' + hashtag.messages.length + ' ' + TweetHandle + '</div> </div>';
                }


                $(".twitter-hashtags").append(Elem);
                $("#tag-" + id).data('tagData', hashtag);
                if (HashtagOpen) {
                    setTimeout(function () {
                        if (HashTagOpenHandle && HashTags === HashTagOpenHandle) {
                            QB.Phone.Notifications.LoadHashtagMessages(hashtag.messages);
                        }
                    }, 100);
                }
            }
        });
    }
}

QB.Phone.Notifications.LoadHashtagMessages = function(Tweets) {
    Tweets = Tweets.reverse();
    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        $(".twitter-hashtag-tweets").html("");
        $.each(Tweets, function(i, Tweet){
            if (!Tweet.deleted) {
                var clean = DOMPurify.sanitize(Tweet.message, {
                    ALLOWED_TAGS: [],
                    ALLOWED_ATTR: []
                });
                if (clean == '') clean = 'Hmm, I shouldn\'t be able to do this...'
                var TwtMessage = QB.Phone.Functions.FormatTwitterMessage(clean);
                var today = new Date();
                var TweetTime = new Date(Tweet.time);
                var diffMs = (today - TweetTime);
                var diffDays = Math.floor(diffMs / 86400000);
                var diffHrs = Math.floor((diffMs % 86400000) / 3600000);
                var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000);
                var diffSeconds = Math.round(diffMs / 1000);
                var TimeAgo = diffSeconds + ' s';

                if (diffSeconds > 60) {
                    TimeAgo = diffMins + ' m';
                } else if (diffMins > 60) {
                    TimeAgo = diffHrs + ' h';
                } else if (diffHrs > 24) {
                    TimeAgo = diffDays + ' d';
                }

                var TwitterHandle = Tweet.name
                var PictureUrl = "./img/default.png";
                if (Tweet.picture !== "default") {
                    PictureUrl = Tweet.picture
                }

                var likes = Tweet.likes.length
                if (likes === undefined) {
                    likes = 0
                }

                var heart = "far"
                $.each(Tweet.likes, function (i, user) {
                    if (user === TwitterSettings.account.twitterID) {
                        heart = "fas"
                        return false;
                    }
                })

                var TweetElement = '<div class="twitter-tweet" data-twtid="' + Tweet.tweetID + '">' +
                    '<div class="tweet-tweeter">' + TwitterHandle + ' &nbsp;<span>@' + TwitterHandle + ' &middot; ' + TimeAgo + '</span></div>' +
                    '<div class="tweet-message">' + TwtMessage + '</div>' +
                    '<div class="tweet-bottom" data-twthandler="@' + TwitterHandle + '" data-twtid="' + Tweet.tweetID + '"><div class="tweet-reply"><i class="fas fa-reply"></i></div>' +
                    '<div class="tweet-likes"><i id="tweet-heart" class="' + heart + ' fa-heart"></i><span style="margin-left: .6vh;font-weight: bolder;">' + likes + '</span></div>' +
                    '</div>' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image" alt="picture"></div>' +
                    '</div>';

                $(".twitter-hashtag-tweets").append(TweetElement);
            }
        });
    }
}


$(document).on('click', '.twitter-hashtag', function(event){
    event.preventDefault();

    var TweetId = $(this).attr('id');
    var TweetData = $("#"+TweetId).data('tagData');

    QB.Phone.Notifications.LoadHashtagMessages(TweetData.messages);

    $(".twitter-hashtag-tweets").css({"display":"block", "left":"30vh"});
    $(".twitter-hashtag-tweets").animate({
        left: 0+"vh"
    }, 150);
    $(".twitter-hashtags").animate({
        left: -30+"vh"
    }, 150, function(){
        $(".twitter-hashtags").css({"display":"none"});
    });
    HashtagOpen = true;
    HashTagOpenHandle = TweetData.hashtag;
});