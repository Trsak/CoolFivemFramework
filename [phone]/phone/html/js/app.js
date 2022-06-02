QB = {}
QB.Phone = {}
QB.Screen = {}
QB.Phone.Functions = {}
QB.Phone.Animations = {}
QB.Phone.Notifications = {}
QB.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

QB.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

QB.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && QB.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

QB.Phone.Functions.SetupApplications = function(data) {
    QB.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= QB.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, QB.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === QB.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

QB.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

QB.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (QB.Phone.Data.currentApplication == null) {
                QB.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                if (PressedApplication !== "camera") {
                    QB.Phone.Functions.ToggleApp(PressedApplication, "block");
                }
                
                if (QB.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    QB.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                QB.Phone.Data.currentApplication = PressedApplication;
    
                if (PressedApplication === "settings") {
                    $("#mySerialNumber").text("QB-" + QB.Phone.Data.MetaData.id);
                    QB.Phone.Functions.refreshSecurity()
                    if(QB.Phone.Data.MetaData.simActive.primary.active) {
                        var checkBoxes = $(".numberrec-box");
                        var checkIPBoxes = $(".ip-box");
                        checkBoxes.prop("checked", QB.Phone.Data.AnonymousCall);
                        if (!QB.Phone.Data.AnonymousCall) {
                            $("#numberrecognition > p").html('Off');
                        } else {
                            $("#numberrecognition > p").html('On');
                        }
                        checkIPBoxes.prop("checked", QB.Phone.Data.fakeIP);
                        if (!QB.Phone.Data.fakeIP) {
                            $("#iprecognition > p").html('Off');
                        } else {
                            $("#iprecognition > p").html('On');
                        }
                        $("#myPhoneNumber").text(QB.Phone.Data.MetaData.simActive.primary.telNumber);
                    } else {
                        $("#myPhoneNumber").text("No sim");
                    }
                } else if (PressedApplication === "twitter") {
                    if (QB.Phone.Data.MetaData.internet) {
                        if (QB.Phone.Data.IsOpen) {
                        $.post('https://phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                            QB.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                        })
                        $.post('https://phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                            QB.Phone.Notifications.LoadHashtags(Hashtags)
                        })
                        $.post('https://phone/GetTweets', JSON.stringify({}), function(Tweets){
                            QB.Phone.Notifications.LoadTweets(Tweets);
                            QB.Phone.Notifications.HotTweets(Tweets);
                        });
                        }
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "camera") {
                    $.post('https://phone/takePhoto', JSON.stringify({}), function(data){
                        var copyText = document.getElementById("camera-url");
                        if (data.url !== undefined) {
                            $("#camera-url").val(data.url);
                            copyText.select();
                            copyText.setSelectionRange(0, 99999);
                            document.execCommand("copy");

                            QB.Phone.Notifications.Add("fas fa-university", "Camera", "URL copied!", "#badc58", 1750);
                        }
                        $("#camera-url").css({"display": "none"});
                    });
                } else if (PressedApplication === "bank") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetBank', JSON.stringify({}), function(bank){
                            QB.Phone.Data.PlayerData.bank = bank
                            QB.Phone.Functions.DoBankOpen();
                        });
                        $.post('https://phone/GetBankContacts', JSON.stringify({}), function(contacts){
                            QB.Phone.Functions.LoadContactsWithNumber(contacts);
                        });
                        $.post('https://phone/GetInvoices', JSON.stringify({}), function(invoices){
                            QB.Phone.Functions.LoadBankInvoices(invoices);
                        });
                        $.post('https://phone/GetFines', JSON.stringify({}), function(fines){
                            QB.Phone.Functions.LoadBankFines(fines);
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "whatsapp") {
                    if (QB.Phone.Data.MetaData.simActive.primary.active || QB.Phone.Data.MetaData.simActive.secondary.active) {
                        $.post('https://phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                            QB.Phone.Functions.LoadWhatsappChats(chats);
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Není signál!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "phone") {
                    if (QB.Phone.Data.MetaData.simActive.primary.active || QB.Phone.Data.MetaData.simActive.secondary.active) {
                        $.post('https://phone/GetMissedCalls', JSON.stringify({}), function(recent){
                            QB.Phone.Functions.SetupRecentCalls(recent);
                        });
                        $.post('https://phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                            QB.Phone.Functions.SetupSuggestedContacts(suggested);
                        });
                        $.post('https://phone/ClearGeneralAlerts', JSON.stringify({
                            app: "phone"
                        }));
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Není signál!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "mail") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
                            QB.Phone.Functions.SetupMails(mails);
                        });
                        $.post('https://phone/ClearGeneralAlerts', JSON.stringify({
                            app: "mail"
                        }));
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "advert") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                            QB.Phone.Functions.RefreshAdverts(Adverts);
                        })
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "garage") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                            SetupGarageVehicles(Vehicles);
                        })
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "crypto") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetCryptoData', JSON.stringify({
                            crypto: "qbit",
                        }), function(CryptoData){
                            SetupCryptoData(CryptoData);
                        })

                        $.post('https://phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                            RefreshCryptoTransactions(data);
                        })
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "racing") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                            SetupRaces(Races);
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "houses") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                            SetupPlayerHouses(Houses);
                        });
                        $.post('https://phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                            $(".house-app-mykeys-container").html("");
                            if (Keys.length > 0) {
                                $.each(Keys, function(i, key){
                                    var elem = '<div class="mykeys-key" id="keyid-'+i+'"> <span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';

                                    $(".house-app-mykeys-container").append(elem);
                                    $("#keyid-"+i).data('KeyData', key);
                                });
                            }
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "meos") {
                    if (QB.Phone.Data.MetaData.internet) {
                        SetupMeosHome();
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "services") {
                        SetupServices();
                } else if (PressedApplication === "store") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/SetupStoreApps', JSON.stringify({}), function(data){
                            SetupAppstore(data);
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                } else if (PressedApplication === "trucker") {
                    if (QB.Phone.Data.MetaData.internet) {
                        $.post('https://phone/GetTruckerData', JSON.stringify({}), function(data){
                            SetupTruckerInfo(data);
                        });
                    } else {
                        QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                    }
                }
            }
        }
    } else {
        //QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", QB.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (QB.Phone.Data.currentApplication === null) {
        QB.Phone.Functions.Close();
    } else {
        QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        QB.Phone.Functions.HeaderTextColor("white", 300);

        if (QB.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (QB.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (QB.Phone.Data.currentApplication == "mail") {
            $(".mail-sign").css({"display":"none"})
            $(".mail-create").css({"display":"none"})
        } else if (QB.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        QB.Phone.Data.currentApplication = null;
    }
});

QB.Phone.Functions.Open = function(data) {
    if (QB.Phone.Settings.Security.lock) {
        QB.Phone.Functions.LockScreen()
    }
    QB.Phone.Animations.BottomSlideUp('.container', 300, 0);
    QB.Phone.Notifications.LoadTweets(data.Tweets);
    QB.Phone.Data.IsOpen = true;
}

QB.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

QB.Phone.Functions.Close = function() {
    if (QB.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            QB.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            QB.Phone.Data.currentApplication = null;
        }, 500)
    } else if (QB.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    QB.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('https://phone/Close');
    QB.Phone.Data.IsOpen = false;
}

QB.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

QB.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

QB.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

QB.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

QB.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

QB.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            $.post('https://phone/PlayNotification', JSON.stringify({}));
            if (QB.Phone.Notifications.Timeout == undefined || QB.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!QB.Phone.Data.IsOpen) {
                    QB.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                QB.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
                    clearTimeout(QB.Phone.Notifications.Timeout);
                }
                QB.Phone.Notifications.Timeout = setTimeout(function(){
                    QB.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!QB.Phone.Data.IsOpen) {
                        QB.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    QB.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!QB.Phone.Data.IsOpen) {
                    QB.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
                    clearTimeout(QB.Phone.Notifications.Timeout);
                }
                QB.Phone.Notifications.Timeout = setTimeout(function(){
                    QB.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!QB.Phone.Data.IsOpen) {
                        QB.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    QB.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

QB.Phone.Functions.LoadPhoneData = function(data) {
    QB.Phone.Data.PlayerData = data.PlayerData;
    QB.Phone.Data.PlayerJob = data.PlayerJob;
    QB.Phone.Data.MetaData = data.PhoneData.MetaData;
    $(".frame").html('<img alt='+QB.Phone.Data.MetaData.phoneModel+' src="/html/img/phones/'+QB.Phone.Data.MetaData.phoneModel+'.png" class="phone-frame">');
    if ( QB.Phone.Data.MetaData.simActive.primary.active || QB.Phone.Data.MetaData.simActive.secondary.active ) {
        $("#phone-icons").html('<i class="fas fa-signal" id="phone-signal" data-toggle="tooltip" data-placement="left" title="server 5GHZ"><i class="fas fa-battery-three-quarters" data-toggle="tooltip" data-placement="bottom" id="phone-battery" title="100%"></i>');
    } else {
        $("#phone-icons").html('<i class="fas fa-signal" id="phone-signal" data-toggle="tooltip" data-placement="left" title="No signal"></i><i class="fas fa-battery-three-quarters" data-toggle="tooltip" data-placement="bottom" id="phone-battery" title="100%"></i>');
    }
    QB.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    QB.Phone.Functions.LoadTwitterSettings(data.PhoneData.MetaData.settings.twitter);
    QB.Phone.Functions.LoadMailSettings(data.PhoneData.MetaData.settings.email);
    QB.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    QB.Phone.Functions.SetupApplications(data);
    QB.Phone.Functions.SetupAppWarnings(data.applications);
    if (QB.Phone.Data.MetaData.internet) {
        $.post('https://phone/LoadAdverts', JSON.stringify({}), function (Adverts) {
            QB.Phone.Functions.RefreshAdverts(Adverts);
        })
        $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
            QB.Phone.Functions.SetupMails(mails);
        });
        QB.Phone.Functions.loadTwAcc()
    }
    $.post('https://phone/dataDone');
    console.log("Phone succesfully loaded!");
}

QB.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var M = NewDate.getMonth();
    var D = NewDate.getUTCDate();
    var w = NewDate.getUTCDay();
    var week = ['Sunday', 'Moday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    var month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
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
    var MessageTime = data.InGameTime.hour + ":" + data.InGameTime.minute
    $("#phone-time").html(MessageTime);
    document.getElementById('lock-time').innerHTML = MessageTime;
    document.getElementById('lock-date').innerHTML = week[w] + ', ' + month[M] + ' ' + D;
}

QB.Phone.Functions.Battery = function(data) {

}

var NotificationTimeout = null;

QB.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);
        
            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }
        
            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

// QB.Screen.Notification("Nieuwe Tweet", "Dit is een test tweet like #YOLO", "fab fa-twitter", 4000);

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                QB.Phone.Functions.Open(event.data);
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
                QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
                QB.Phone.Data.IsOpen = true;
                QB.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            case "reload":
                console.log('reload')
                window.location.reload();
                break;
            case "close":
                QB.Phone.Functions.Close();
                QB.Phone.Data.IsOpen = false;
                break;
            // case "LoadPhoneApplications":
            //     QB.Phone.Functions.SetupApplications(event.data);
            //     break;
            case "LoadPhoneData":
                QB.Phone.Functions.LoadPhoneData(event.data);
                QB.Phone.Functions.loadTwAcc();
                break;
            case "UpdateTime":
                QB.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                QB.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                //console.log(event.data.PhoneNotify.icon, event.data.PhoneNotify.title)
                if (event.data.PhoneNotify.icon) {
                    QB.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                }
                break;
            case "RefreshAppAlerts":
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                QB.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (QB.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        console.log('Chat reloaded')
                        QB.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        console.log('Chats reloaded')
                        QB.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                QB.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "setupCall":
                QB.Phone.Functions.SetupCall(event.data.cData)
                break;
            case "UpdateTwitter":
                $.post('https://phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                    QB.Phone.Notifications.LoadMentionedTweets(MentionedTweets);
                })
                $.post('https://phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                    QB.Phone.Notifications.LoadHashtags(Hashtags);
                })
                $.post('https://phone/GetTweets', JSON.stringify({}), function(Tweets){
                    QB.Phone.Notifications.LoadTweets(Tweets);
                    QB.Phone.Notifications.HotTweets(Tweets);
                })
                break;
            case "RefreshWhatsappAlerts":
                QB.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                QB.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!QB.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    QB.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                QB.Phone.Functions.HeaderTextColor("white", 300);
    
                QB.Phone.Data.CallActive = false;
                QB.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                QB.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                QB.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (QB.Phone.Data.currentApplication === "advert") {
                    QB.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                QB.Phone.Data.PlayerJob = event.data.JobData;
                QB.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('https://phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
            case "RefreshData":
                QB.Phone.Data.MetaData = event.data.MetaData;
                QB.Phone.Functions.LoadMetaData(event.data.MetaData);
                QB.Phone.Functions.loadTwAcc();
                QB.Phone.Functions.LoadTwitterSettings(event.data.MetaData.settings.twitter);
                QB.Phone.Functions.LoadMailSettings(event.data.MetaData.settings.email);
                $.post('https://phone/GetMails', JSON.stringify({}), function(mails){
                    QB.Phone.Functions.SetupMails(mails);
                });
                break;
            case "QuickCall":
                if(QB.Phone.Data.MetaData.simActive.primary.active) {
                    if (event.data.call) {
                        QB.Phone.Functions.SetupCall(event.data.cData)
                    } else if (event.data.gps) {
                        QB.Phone.Functions.SendQuickGPS(event.data.cData)
                    }
                } else {
                    QB.Phone.Notifications.Add("fab fa-cog", "Error", "No signal!", "#ff0000", 1750);
                }
                break;
            case "DeleteCallNotification":
                $(".call-notifications").css({"display":"none"});
                break;
            case "ReloadRaces":
                if (QB.Phone.Data.MetaData.internet) {
                    $.post('https://phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else {
                    QB.Phone.Notifications.Add("fas fa-cog", "Error", "Nejsou internety!", "#ff0000", 1000);
                }
                break;
            case "RacingSetupNotification":
                $(".racing-notification").css({"display":"block"});
                break;
            case "DeleteRacingSetupNotification":
                $(".racing-notification").css({"display":"none"});
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            QB.Phone.Functions.Close();
            break;
        case 112: // F1
            $.post('https://phone/LockMobile');
            QB.Phone.Functions.Close();
            break;
    }
});

// QB.Phone.Functions.Open();
