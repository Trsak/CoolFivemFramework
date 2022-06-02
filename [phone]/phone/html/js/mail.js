var OpenedMail = null;
var MailSettings = null;
var InboxType = 'Inbox'
var MonthFormatting = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

$(document).on('click', '.mail-inbox', function(e){
    e.preventDefault();
    InboxType = 'Inbox'
    $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
        QB.Phone.Functions.SetupMails(mails);
    });
});

$(document).on('click', '.mail-sent', function(e){
    e.preventDefault();
    InboxType = 'Sent'
    $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
        QB.Phone.Functions.SetupMails(mails);
    });
});

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    QB.Phone.Functions.SetupMail(MailData);

    OpenedMail = $(this).attr('id');
});

$(document).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
});

$(document).on('click', '#accept-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    if (MailData.button.length !== 0) {
        $.post('https://phone/AcceptMailButton', JSON.stringify({
            buttonEvent: MailData.button.buttonEvent,
            buttonData: MailData.button.buttonData,
            Id: MailData.mailID,
        }));
    }
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '#remove-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    console.log(MailData.mailID)
    $.post('https://phone/RemoveMail', JSON.stringify({
        Id: MailData.mailID,
        sender: (MailData.sender === MailSettings.account.name)
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '#reply-mail', function(e){
    e.preventDefault();

    var MailData = $("#"+OpenedMail).data('MailData');
    var reciever;

    if (MailData.subject === undefined) {
        MailData.subject = ""
    }

    if (MailData.message === undefined) {
        MailData.message = ""
    }

    var subject = "RE:" + MailData.subject + "";
    var message = "RE:" + MailData.message + "\n----------\n";

    if (InboxType === 'Inbox') {
        reciever = MailData.sender;
    } else {
        reciever = MailData.reciever;
    }

    $(".new-mail-reciever").val(reciever);
    $(".new-mail-subject").val(subject);
    $(".new-mail-textarea").val(message);

    QB.Phone.Animations.TopSlideDown(".new-mail", 450, 0);

    OpenedMail = null;
});

QB.Phone.Functions.SetupMails = function(Mails) {
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss;
    $(".mail-header").html("");
    if (MailSettings.account.logged) {
        var icons = '<span id="mail-header-text">' + InboxType + '</span><span id="mail-header-mail">Email not logged</span><span id="mail-header-lastsync">Create new email</span><i class="fas fa-sign-out-alt" id="mail-header-signout"></i><i class="fas fa-cog" id="mail-header-settings"></i>'
        $(".mail-header").append(icons);
        $("#mail-header-mail").html(MailSettings.account.name);
        $("#mail-header-lastsync").html("Last synchronized "+MessageTime);
        if (Mails !== null && Mails !== undefined) {
            if (Mails.length > 0) {
                $(".mail-list").html("");
                $.each(Mails, function(i, mail){
                    var date = new Date(mail.date);
                    var hours = date.getHours();
                    var minutes = date.getMinutes();
                    if (hours < 10) {
                        hours = "0" + hours;
                    }
                    if (minutes < 10) {
                        minutes = "0" + minutes;
                    }
                    var DateString = date.getDay() + " " + MonthFormatting[date.getMonth()] + " " + date.getFullYear() + " " + hours + ":" + minutes;
                    var element;
                    if (InboxType === 'Inbox') {
                        if (mail.reciever === MailSettings.account.name && !mail.reciever_deleted) {
                            element = '<div class="mail" id="mail-' + i + '"><span class="mail-sender" style="font-weight: bold;">' + mail.sender + '</span> <div class="mail-text"><p>' + mail.message + '</p></div> <div class="mail-time">' + DateString + '</div></div>';
                            if (!mail.read) {
                                element = '<div class="mail" id="mail-' + i + '"><span class="mail-sender-new" style="font-weight: bold;">' + mail.sender + '</span> <div class="mail-text"><p>' + mail.message + '</p></div> <div class="mail-time">' + DateString + '</div></div>';
                            }
                            $(".mail-list").append(element);
                            $("#mail-" + i).data('MailData', mail);
                        }
                    } else {
                        if (mail.sender === MailSettings.account.name && !mail.sender_deleted) {
                            element = '<div class="mail" id="mail-' + i + '"><span class="mail-sender" style="font-weight: bold;">' + mail.reciever + '</span> <div class="mail-text"><p>' + mail.message + '</p></div> <div class="mail-time">' + DateString + '</div></div>';
                            if (!mail.read) {
                                element = '<div class="mail" id="mail-' + i + '"><span class="mail-sender-new" style="font-weight: bold;">' + mail.reciever + '</span> <div class="mail-text"><p>' + mail.message + '</p></div> <div class="mail-time">' + DateString + '</div></div>';
                            }
                            $(".mail-list").append(element);
                            $("#mail-" + i).data('MailData', mail);
                        }
                    }
                });
            } else {
                $(".mail-list").html('<p class="nomails">You don\'t have any mails..</p>');
            }
        }
    } else {
        var icon = '<span id="mail-header-text">Inbox</span><span id="mail-header-mail">Email not logged</span><span id="mail-header-lastsync">Create new email</span><i class="fas fa-user-plus" id="mail-header-create"></i><i class="fas fa-sign-in-alt" id="mail-header-login"></i>'
        $(".mail-header").append(icon);
        $("#mail-header-mail").html("Email not logged");
        $("#mail-header-lastsync").html("Last synchronized "+MessageTime);
        $(".mail-list").html('<p class="nomails">You are not logged in bastard..</p>');
    }
}

QB.Phone.Functions.SetupMail = function(MailData) {
    var date = new Date(MailData.date);
    var DateString = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    $(".mail-subject").html("<p><span style='font-weight: bold;'>"+MailData.sender+"</span><br>"+MailData.subject+"</p>");
    $(".mail-date").html("<p>"+DateString+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");
    if ( MailData.button !== undefined && MailData.button.length !== 0) {
        var AcceptElem = '<div class="opened-mail-footer-item" id="accept-mail"><i class="fas fa-check-circle mail-icon"></i></div>';
    }
    var RemoveElem = '<div class="opened-mail-footer-item" id="remove-mail"><i class="fas fa-trash-alt mail-icon"></i></div>';
    var ReplyElem = '<div class="opened-mail-footer-item" id="reply-mail"><i class="fas fa-reply mail-icon"></i></div>';

    $(".opened-mail-footer").html("");    

    if ( MailData.button !== undefined && MailData.button.length !== 0) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer").append(ReplyElem);
        $(".opened-mail-footer-item").css({"width":"30%"});
        $("#remove-mail").css({"width":"40%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer").append(ReplyElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    }
    if (!MailData.read){
        if (MailData.reciever === MailSettings.account.name) {
            $.post('https://phone/ReadMail', JSON.stringify({
                Id: MailData.mailID
            }));
        }
    }
}
QB.Phone.Functions.LoadMailSettings = function(Settings) {
    MailSettings = Settings
    QB.Phone.Data.MetaData.settings.email = Settings
    for (setting in MailSettings.notifications) {
        var checkBoxes = $(".settings-" + setting + "");
        checkBoxes.prop("checked", MailSettings.notifications[setting]);

        if (!MailSettings.notifications[setting]) {
            $("#" + setting + " > p").html('Off');
        } else {
            $("#" + setting + " > p").html('On');
        }
    }
}

function clear_create(){
    $(".mail-create-name").val("");
    $(".mail-create-pw").val("");
    $(".mail-create-repw").val("");
    $(".mail-create-phone").val("");
}

$(document).on('click', '#mail-header-login', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".mail-sign", 450, 0);
    //QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
});

$(document).on('click', '#mail-login', function(e){
    e.preventDefault();
    name = $("#mail-login-name").val();
    pw = $("#mail-login-pw").val();
    pref = $("#mail-login-prefix").val();
    name = name + pref
    $.post('https://phone/LogInMail', JSON.stringify({
        name: name,
        pw: pw
    }), function(cb){
        if (cb[0]) {
            //QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
            QB.Phone.Notifications.Add("fas fa-envelope", "Success", "You are logged!", "#11ff00", 1000);
            QB.Phone.Animations.TopSlideDown(".mail-sign", 450, -120);
            clear_create()
            $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
                QB.Phone.Functions.SetupMails(mails);
            });
        }else{
            if (cb[1] === "PW") {
                QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Wrong PW or name", "#ff0000", 1000);
            }else{
                QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Already logged", "#ff0000", 1000);
            }
        }
    });
    //QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
});

$(document).on('click', '#mail-login-cancel', function(e){
    e.preventDefault();
    clear_create()
    QB.Phone.Animations.TopSlideDown(".mail-sign", 450, -120);
    //QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
})

$(document).on('click', '#mail-header-create', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
    //QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
});

$(document).on('click', '#mail-header-signout', function(e){
    e.preventDefault();
    MailSettings.account.logged = false
    QB.Phone.Data.MetaData.settings.email = MailSettings
    data = QB.Phone.Data.MetaData.settings
    $.post('https://phone/SaveSettings', JSON.stringify({data}), function(cb){
        if (cb){
            $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
                QB.Phone.Functions.SetupMails(mails);
            });
            $.post('https://phone/SignOutMail', JSON.stringify({}));
        }
    });
});


$(document).on('click', '#mail-add-create', function(e){
    e.preventDefault();
    let proceed = true
    name = $("#mail-create-name").val();
    pw = $("#mail-create-pw").val();
    repw = $("#mail-create-repw").val();
    tel = $("#mail-create-phone").val();
    pref = $("#mail-create-prefix").val();
    var search = XRegExp('([^?<first>\\pL ]+)');
    var res = XRegExp.match(name, search, '',"all");

    if (name === "" || pw === "" || repw === "" || tel === "") {
        QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Nevyplněná pole", "#ff0000", 1000);
    } else {
        if (name.search(" ") !== -1 && res === null){
            proceed = false
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Neplatné znaky v emailu", "#ff0000", 1000);
        }

        if (pw !== repw ){
            proceed = false
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "PW se nezhoduje", "#ff0000", 1000);
        }
        if (pw !== repw ){
            proceed = false
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "PW se nezhoduje", "#ff0000", 1000);
        }

        if (pw.length <= 3 && pw.length >= 6 ){
            proceed = false
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Heslo s minimalně 3 znakama a maximalně 6", "#ff0000", 1000);
        }

        if (pw.search(" ") !== -1){
            proceed = false
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Máš v hesle mezeru!", "#ff0000", 1000);
        }

        if (proceed){
            name = name + pref
            $.post('https://phone/CreateMail', JSON.stringify({
                name: name,
                pw: pw,
                tel: tel
            }), function(cb){
                if (cb) {
                    //QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
                    QB.Phone.Notifications.Add("fas fa-envelope", "Success", "Account created!", "#11ff00", 1000);
                    QB.Phone.Animations.TopSlideDown(".mail-create", 450, -120);
                    clear_create()
                }else{
                    QB.Phone.Notifications.Add("fas fa-envelope", "Error", "SMTH bad happend", "#ff0000", 1000);
                }
                $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
                    QB.Phone.Functions.SetupMails(mails);
                });
            });

        }
    }
});

$(document).on('click', '#mail-cancel', function(e){
    e.preventDefault();
    //QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
    QB.Phone.Animations.TopSlideUp(".mail-create", 450, -120);
    clear_create()
});

$(document).on('click', '#mail-header-settings', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".mail-settings", 450, 0);
    //QB.Phone.Animations.TopSlideDown(".twitter-new-acc-tab", 450, -120);
});

$(document).on('click', '.mail-settings-secondTab', function(e){
    e.preventDefault();
    var PressedMailTab = $(this).data('mailsettings');
    if ($(".settings-"+PressedMailTab+"")) {
        var checkBoxes = $(".settings-"+PressedMailTab+"");
        MailSettings.notifications[PressedMailTab] = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", MailSettings.notifications[PressedMailTab] );

        if (!MailSettings.notifications[PressedMailTab] ) {
            $("#"+PressedMailTab+" > p").html('Off');
        } else {
            $("#"+PressedMailTab+" > p").html('On');
        }
    }
});

$(document).on('click', '#mail-save-settings', function(e){
    e.preventDefault();
    QB.Phone.Data.MetaData.settings.email = MailSettings
    data = QB.Phone.Data.MetaData.settings
    $.post('https://phone/SaveSettings', JSON.stringify({data}), function(cb){});
    //QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
    QB.Phone.Animations.TopSlideDown(".mail-settings", 450, -120);
});

$(document).on('click', '#mail-cancel-settings', function(e){
    e.preventDefault();
    QB.Phone.Functions.LoadMailSettings(MailSettings)
    //QB.Phone.Animations.TopSlideDown(".mail-create", 450, 0);
    QB.Phone.Animations.TopSlideUp(".mail-settings", 450, -120);
});

function clear_new(){
    $(".new-mail-reciever").val("");
    $(".new-mail-subject").val("");
    $(".new-mail-textarea").val("");
}

$(document).on('click', '.new-email', function(e){
    e.preventDefault();
    if (MailSettings.account.logged) {
        QB.Phone.Animations.TopSlideDown(".new-mail", 450, 0);
    } else {
        QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Založ si účet", "#ff0000", 1000);
    }
});

$(document).on('click', '#new-mail-submit', function(e){
    e.preventDefault();

    reciever = $(".new-mail-reciever").val();
    subject = $(".new-mail-subject").val();
    message = $(".new-mail-textarea").val().replace(/\r\n/g, '<br />').replace(/[\r\n]/g, '<br />');

    if(QB.Phone.Functions.validateEmail(reciever)) {
        $.post('https://phone/SendNewMail', JSON.stringify({
            emailID: MailSettings.account.emailID,
            sender: MailSettings.account.name,
            reciever: reciever,
            subject: subject,
            message: message
        }), function(cb){
            if (cb){
                QB.Phone.Animations.TopSlideDown(".new-mail", 450, -120);
                clear_new()
            }
        });
    } else {
        QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Špatný EMAIL", "#ff0000", 1000);
    }
});

$(document).on('click', '#new-mail-back', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".new-mail", 450, -120);
    clear_new()
});

// Advert JS
var advertMaxLetters = 150;
var alreadyPosted = false;


$(".new-advert-textarea").keyup(function(){
    $("#word_left").text("Characters left: " + (advertMaxLetters - $(this).val().length));
});

$(document).on('click', '.test-slet', function(e){
    e.preventDefault();
    if (MailSettings.account.logged) {
        if (MailSettings.account.telephone !== undefined) {
            if (!alreadyPosted) {
                var words = $(".new-advert-textarea").val().length;
                $('#word_left').text("Characters left: "+(advertMaxLetters - words)+"");
                $(".advert-home").animate({
                    left: 30 + "vh"
                });
                $(".new-advert").animate({
                    left: 0 + "vh"
                });
            } else {
                QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Už máš jeden advertisement.", "#ff0000", 1000);
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Tvůj email, nemá k sobě Tel.", "#ff0000", 1000);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-envelope", "Error", "Založ si email", "#ff0000", 1000);
    }
});

$(document).on('click', '#new-advert-back', function(e){
    e.preventDefault();

    $(".advert-home").animate({
        left: 0+"vh"
    });
    $(".new-advert").animate({
        left: -30+"vh"
    });
});

$(document).on('click', '#new-advert-submit', function(e){
    e.preventDefault();

    var Advert = $(".new-advert-textarea").val().replace(/\r\n/g, '<br />').replace(/[\r\n]/g, '<br />');

    if (Advert !== "") {
        if(Advert.length >= 0) {
            $(".advert-home").animate({
                left: 0 + "vh"
            });
            $(".new-advert").animate({
                left: -30 + "vh"
            });
            $.post('https://phone/PostAdvert', JSON.stringify({
                message: Advert,
                name: MailSettings.account.name,
                number: MailSettings.account.telephone
            }));
            alreadyPosted = true;
        } else {
            QB.Phone.Notifications.Add("fas fa-ad", "Advertisement", "Moc písmen lol.", "#ff8f1a", 2000);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-ad", "Advertisement", "You can\'t post an empty ad!", "#ff8f1a", 2000);
    }
});

QB.Phone.Functions.RefreshAdverts = function(Adverts) {
    var foundAdvert = false;
    var advertsCount = 0;
    if (MailSettings.account.logged) {
        tel = MailSettings.account.telephone
        if (tel === undefined) {
            tel = 'Nemáš tel.'
        }
        $("#advert-header-name").html(""+MailSettings.account.name+" | "+tel+"");
    } else {
        $("#advert-header-name").html("Create an Email "+'<i class="fas fa-envelope"></i>');
    }

    $.each(Adverts, function(i, advert){
        if (!advert.expired) {
            advertsCount += 1
        }
    });

    if (advertsCount > 0 || Adverts.length === undefined) {
        $(".advert-list").html("");
        $.each(Adverts, function(i, advert){
            if (!advert.expired) {
                var element = '<div class="advert" id="advert-'+i+'"><span class="advert-sender"><span id="advert-name">'+advert.name+'</span> | <span id="advert-tel">'+advert.number+'</span></span><p>'+advert.message+'</p></div>';
                $(".advert-list").append(element);
                $("#advert-" + i).data('AdvertData', advert);
                if (advert.name === MailSettings.account.name){
                    alreadyPosted = true
                    foundAdvert = true
                }
            }
        });
    } else {
        $(".advert-list").html("");
        var element = '<div class="advert"><span class="advert-sender">There are no advertisements yet!</span></div>';
        $(".advert-list").append(element);
    }
    if (!foundAdvert){
        alreadyPosted = false
    }
}


$(document).on('click', '.advert-sender', function(e){
    if (e.target.id !== '') {
        var copyText = document.getElementById(""+e.target.id+"");
        var textArea = document.createElement("textarea");
        textArea.value = copyText.textContent;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand("Copy");
        textArea.remove();

        QB.Phone.Notifications.Add("fas fa-ad", "Advertisement", "Text copied copied!", "#ff8f1a", 1750);
    }
});