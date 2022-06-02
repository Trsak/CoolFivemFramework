QB.Phone.Settings = {};
QB.Phone.Settings.Background = "default-qbus";
QB.Phone.Settings.LockScreen = "default-qbus";
QB.Phone.Settings.OpenedTab = null;
QB.Phone.Settings.Backgrounds = {
    'default-qbus': {
        label: "Standard Qbus"
    },
    'background-1': {
        label: "Standard Qbus"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");
    var simActiv = QB.Phone.Data.MetaData.simActive.primary

    if (PressedTab === "background") {
        QB.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        QB.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab === "lockscreen") {
        QB.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        QB.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab === "security") {
        if (QB.Phone.Settings.Security) {
            Security = QB.Phone.Settings.Security
            QB.Phone.Functions.refreshSecurity()
            QB.Phone.Animations.TopSlideDown(".settings-" + PressedTab + "-tab", 200, 0);
            QB.Phone.Settings.OpenedTab = PressedTab;
        } else {
            QB.Phone.Notifications.Add("fa fa-cog", "Error", "Error 404", "#ff0000", 1000);
        }
    } else if (PressedTab === "numberrecognition") {
        if (simActiv.ghostChip) {
            var checkBoxes = $(".numberrec-box");
            QB.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
            checkBoxes.prop("checked", QB.Phone.Data.AnonymousCall);

            if (!QB.Phone.Data.AnonymousCall) {
                $("#numberrecognition > p").html('Off');
            } else {
                $("#numberrecognition > p").html('On');
            }
            $.post('https://phone/Incognito', JSON.stringify({Incognito: QB.Phone.Data.AnonymousCall}));
        }
    } else if (PressedTab === "iprecognition") {
        if (simActiv.ghostChip) {
            var checkIPBoxes = $(".ip-box");
            QB.Phone.Data.fakeIP = !checkIPBoxes.prop("checked");
            checkIPBoxes.prop("checked", QB.Phone.Data.fakeIP);

            if (!QB.Phone.Data.fakeIP) {
                $("#iprecognition > p").html('Off');
            } else {
                $("#iprecognition > p").html('On');
            }
            $.post('https://phone/IPShow', JSON.stringify({IPshow: QB.Phone.Data.fakeIP}));
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", QB.Phone.Settings.Backgrounds[QB.Phone.Settings.Background].label+" is ingesteld!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"})
    } else {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+"')"});
    }

    $.post('https://phone/SetBackground', JSON.stringify({
        background: QB.Phone.Settings.Background,
    }))
});

QB.Phone.Functions.refreshSecurity = function(){
    let primary = false
    if (QB.Phone.Settings.Security.type !== "none") {
        $.each(QB.Phone.Settings.Security.type, function (name, data) {
            if (QB.Phone.Settings.Security.primary === name) {
                $("#primary-security").html(name);
                primary = true
                $("#security-primary-" + name + "")[0].checked = true;
            } else {
                $("#security-primary-"+name+"")[0].checked = false;
            }
            let ss = $("#current-"+name+"");
            $(ss).html('<i class="fas fa-check-circle"></i>');
        })
        if (primary) {
            $("#security-tab-icon").html("<i class=\"fas fa-lock\" style=\"color: green;\">");
        }
    }
}

QB.Phone.Functions.LoadMetaData = function(MetaData) {
    QB.Phone.Settings.Security = QB.Phone.Data.MetaData.settings.password;
    QB.Phone.Data.AnonymousCall = false
    QB.Phone.Data.fakeIP = false

    if(QB.Phone.Data.MetaData.simActive.primary.active) {
        QB.Phone.Data.AnonymousCall = QB.Phone.Data.MetaData.simActive.primary.anonymousCall
        QB.Phone.Data.fakeIP = QB.Phone.Data.MetaData.simActive.primary.fakeIP
    }

    if (MetaData.settings.background !== null && MetaData.settings.background !== undefined && MetaData.settings.background !== '') {
        QB.Phone.Settings.Background = MetaData.settings.background;
    } else {
        QB.Phone.Settings.Background = "default-qbus";
    }

    if (MetaData.settings.lockscreen !== null && MetaData.settings.lockscreen !== undefined && MetaData.settings.lockscreen !== '') {
        QB.Phone.Settings.LockScreen = MetaData.settings.lockscreen;
    } else {
        QB.Phone.Settings.LockScreen = "background-1";
    }

    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();
    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"})
    } else {
        QB.Phone.Functions.testImage(QB.Phone.Settings.Background).then(value => {
            if (value === "success") {
                $(".phone-background").css({"background-image": "url('" + QB.Phone.Settings.Background + "')"});
            } else {
                QB.Phone.Settings.Background = "default-qbus"
                $(".phone-background").css({"background-image": "url('/html/img/backgrounds/" + QB.Phone.Settings.Background + ".png')"})
                $.post('https://phone/SetBackground', JSON.stringify({
                    background: QB.Phone.Settings.Background,
                }))
            }
        })
    }

    var hasCustomLockBackground = QB.Phone.Functions.IsLockBackgroundCustom();
    if (!hasCustomLockBackground) {
        $(".phone-lockBackground").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.LockScreen+".png')"})
    } else {
        QB.Phone.Functions.testImage(QB.Phone.Settings.LockScreen).then(value => {
            if (value === "success") {
                $(".phone-lockBackground").css({"background-image": "url('" + QB.Phone.Settings.LockScreen + "')"});
            } else {
                QB.Phone.Settings.LockScreen = "background-1"
                $(".phone-lockBackground").css({"background-image": "url('/html/img/backgrounds/" + QB.Phone.Settings.LockScreen + ".png')"})
                $.post('https://phone/SetLockBackground', JSON.stringify({
                    lockscreen: QB.Phone.Settings.LockScreen,
                }))
            }
        })
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

QB.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(QB.Phone.Settings.Backgrounds, function(i, background){
        if (QB.Phone.Settings.Background === i) {
            retval = false;
        }
    });
    return retval
}

QB.Phone.Functions.IsLockBackgroundCustom = function() {
    var retval = true;
    $.each(QB.Phone.Settings.Backgrounds, function(i, background){
        if (QB.Phone.Settings.LockScreen === i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (PressedBackground !== "custom-background") {
        QB.Phone.Settings.Background = PressedBackground;
        $(OldBackground).fadeOut(50, function(){
            $(OldBackground).remove();
        });
        $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    } else {
        QB.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
    }

});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();
    var custom = $(".custom-background-input").val()
    if (custom !== "" && custom !== undefined) {
        QB.Phone.Functions.testImage(custom).then(value => {
            if (value === "success") {
                QB.Phone.Settings.Background = custom;
                $(OldBackground).fadeOut(50, function () {
                    $(OldBackground).remove();
                });
                $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
                QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
            } else {
                QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Image not found!")
            }
        })
    }
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedLockScreen = null;
var PressedLockScreenObject = null;
var OldLockScreen = null;
var LockScreenIsChecked = null;

$(document).on('click', '#accept-lockscreen', function(e){
    e.preventDefault();
    var LockScreen = QB.Phone.Data.MetaData.settings.lockscreen;
    if (LockScreen === "background-1") {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard Lockscreen background set!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='lockscreen']").find('.settings-tab-icon').html('<img src="./img/backgrounds/background-1.png">');
    } else {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal Lockscreen background set!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='lockscreen']").find('.settings-tab-icon').html('<img src="'+LockScreen+'">');
    }
    $.post('https://phone/SetLockBackground', JSON.stringify({
        lockscreen: QB.Phone.Settings.LockScreen,
    }))
});

$(document).on('click', '#accept-custom-lockscreen', function(e){
    e.preventDefault();
    var custom = $(".custom-lockscreen-input").val();
    if (custom !== "" && custom !== undefined) {
        QB.Phone.Functions.testImage(custom).then(value => {
            if (value === "success") {
                QB.Phone.Settings.LockScreen = custom;
                QB.Phone.Data.MetaData.settings.lockscreen = custom;
                $(OldLockScreen).fadeOut(50, function () {
                    $(OldLockScreen).remove();
                });
                $(PressedLockScreenObject).append('<div class="lockscreen-option-current"><i class="fas fa-check-circle"></i></div>');
                QB.Phone.Animations.TopSlideUp(".lockscreen-custom", 200, -23);
            } else {
                QB.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Image not found!")
            }
        })
    }
});

$(document).on('click', '.lockscreen-option', function(e){
    e.preventDefault();
    PressedLockScreen = $(this).data('lockscreen');
    PressedLockScreenObject = this;
    OldLockScreen = $(this).parent().find('.lockscreen-option-current');
    LockScreenIsChecked = $(this).find('.lockscreen-option-current');
    if (PressedLockScreen !== "custom-lockscreen") {
        QB.Phone.Settings.LockScreen = PressedLockScreen;
        QB.Phone.Data.MetaData.settings.lockscreen = PressedLockScreen;
        $(OldLockScreen).fadeOut(50, function(){
            $(OldLockScreen).remove();
        });
        $(PressedLockScreenObject).append('<div class="lockscreen-option-current"><i class="fas fa-check-circle"></i></div>');
    } else {
        QB.Phone.Animations.TopSlideDown(".lockscreen-custom", 200, 13);
    }
});

$(document).on('click', '#cancel-lockscreen', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-lockscreen', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".lockscreen-custom", 200, -23);
});

// Security

var PressedSecurity = null;
var PressedSecurityObject = null;
var ProfileSecurityIsChecked = null;
var Security = {};

$(document).on('click', '.security-option', function(e){
    e.preventDefault();
    if (!PressedSecurity) {
        $(".security-custom-description").html("")
        PressedSecurity = $(this).data('security');
        PressedSecurityObject = this;
        ProfileSecurityIsChecked = $(PressedSecurityObject).find('.security-option-current');
        if (QB.Phone.Settings.Security.type !== "none" ) {
            if (QB.Phone.Settings.Security.type[PressedSecurity]) {
                if (PressedSecurity !== "GESTURE" && PressedSecurity !== "FINGERPRINT" && PressedSecurity !== "FACEID") {
                    $(".security-" + PressedSecurity + "-input").val("" + QB.Phone.Settings.Security.type[PressedSecurity] + "")
                }
            }
        }
        if (PressedSecurity === "GESTURE") {
            $(".security-primary-class").css({"top": "75%"})
            $(".security-primary-input").css({"top": "75%"})
            if (QB.Phone.Settings.Security.type === "none" || QB.Phone.Settings.Security.type[PressedSecurity]) {
                $("#gesturepwd").on("passwdClear");
            }
            $("#gesturepwd").GesturePasswd({
                backgroundColor: "transparent",  //背景色
                color: "black",   //主要的控件颜色
                roundRadii: 15,    //大圆点的半径
                pointRadii: 12, //大圆点被选中时显示的圆心的半径
                space: 35,  //大圆点之间的间隙
                width: 250,   //整个组件的宽度
                height: 250,  //整个组件的高度
                lineColor: "grey",   //用户划出线条的颜色
                zindex: 100  //整个组件的css z-index属性
            });
            QB.Phone.Animations.TopSlideDown(".security-" + PressedSecurity + "", 200, 20);
        } else if (PressedSecurity === "FINGERPRINT") {
            $(".security-primary-class").css({"top": "75%"})
            $(".security-primary-input").css({"top": "75%"})
            QB.Phone.Animations.TopSlideDown(".security-" + PressedSecurity + "", 200, 20);
        } else if (PressedSecurity === "FACEID") {
            $(".security-primary-class").css({"top": "75%"})
            $(".security-primary-input").css({"top": "75%"})
            QB.Phone.Animations.TopSlideDown(".security-" + PressedSecurity + "", 200, 20);
        } else {
            $(".security-primary-class").css({"top": "60%"})
            $(".security-primary-input").css({"top": "60%"})
            QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, 23);
        }
    }
});

// PIN

$(document).on('click', '#accept-PIN', function(e){
    e.preventDefault();
    PIN = $(".security-"+PressedSecurity+"-input").val();
    REPIN = $(".security-RE"+PressedSecurity+"-input").val();
    Primary = $("#security-primary-"+PressedSecurity+"")[0].checked;
    if (PIN !== "" && PIN !== undefined) {
        if (4 <= PIN.length && PIN.length <= 6) {
            if (Number.isInteger(parseInt(PIN))) {
                if (PIN === REPIN) {
                    if (Primary) {
                        Security.primary = PressedSecurity;
                    } else {
                        Security.primary = null;
                    }
                    if (Security.type === "none") {
                        Security.type = {}
                    }
                    Security.type[PressedSecurity] = PIN
                    $(".security-" + PressedSecurity + "-input").val("")
                    $(".security-RE" + PressedSecurity + "-input").val("")
                    QB.Phone.Animations.TopSlideDown(".security-" + PressedSecurity + "", 200, -100);
                    PressedSecurity = null;
                } else {
                    QB.Phone.Notifications.Add("fas fa-lock", "Error", "Not Match!", "#ff0000", 1000);
                }
            } else {
                QB.Phone.Notifications.Add("fas fa-lock", "Error", "Only Digits", "#ff0000", 1000);
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-lock", "Error", "PIN length 4-6", "#ff0000", 1000);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-lock", "Error", "PIN undefined", "#ff0000", 1000);
    }
});

$(document).on('click', '#cancel-PIN', function(e){
    e.preventDefault();
    $(".security-"+PressedSecurity+"-input").val("")
    QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -100);
    PressedSecurity = null;
});

// PW

$(document).on('click', '#accept-PW', function(e){
    e.preventDefault();
    PW = $(".security-"+PressedSecurity+"-input").val();
    REPW = $(".security-RE"+PressedSecurity+"-input").val();
    Primary = $("#security-primary-"+PressedSecurity+"")[0].checked;
    if (PW !== "" && PW !== undefined) {
        if (6 <= PW.length && PW.length <= 12) {
            if (PW === REPW) {
                if (Primary) {
                    Security.primary = PressedSecurity;
                }
                if (Security.type === "none") {
                    Security.type = {}
                }
                Security.type[PressedSecurity] = PW
                $(".security-" + PressedSecurity + "-input").val("")
                $(".security-RE" + PressedSecurity + "-input").val("")
                QB.Phone.Animations.TopSlideDown(".security-" + PressedSecurity + "", 200, -100);
                PressedSecurity = null;
            } else {
                QB.Phone.Notifications.Add("fas fa-key", "Error", "Password do not match!", "#ff0000", 1000);
            }
        } else {
            QB.Phone.Notifications.Add("fas fa-key", "Error", "Password length 6-12", "#ff0000", 1000);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-key", "Error", "Password undefined", "#ff0000", 1000);
    }
});

$(document).on('click', '#cancel-PW', function(e){
    e.preventDefault();
    $(".security-"+PressedSecurity+"-input").val("")
    QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -100);
    PressedSecurity = null;
});

// Gesture
var GestureDone = false;

$("#gesturepwd").on("hasPasswd",function(e,passwd){
    var setup = false;
    var pswd = $(".security-GESTURE-input").val();

    if (pswd === "") {
        setup = true
        $(".security-custom-description").html("Repeat password")
        $(".security-GESTURE-input").val(passwd)
    }

    if (!setup) {
        console.log(passwd, pswd)
        if (passwd === pswd) {
            $(".security-custom-description").html("DONE!")
            $("#gesturepwd").trigger("passwdRight");
            GestureDone = true
        } else {
            $("#gesturepwd").trigger("passwdWrong");
            GestureDone = false
        }
    } else {
        $("#gesturepwd").trigger("passwdRight");
    }
});

$(document).on('click', '#accept-GESTURE', function(e){
    e.preventDefault();
    GESTURE = $(".security-"+PressedSecurity+"-input").val();
    Primary = $("#security-primary-"+PressedSecurity+"")[0].checked;
    if (GestureDone && GESTURE) {
        if (Primary) {
            Security.primary = PressedSecurity;
        }
        if (Security.type === "none") {
            Security.type = {}
        }
        Security.type[PressedSecurity] = GESTURE
        $(".security-"+PressedSecurity+"-input").val("")
        QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"", 200, -120);
        PressedSecurity = null;
    } else {
        QB.Phone.Notifications.Add("fas fa-circle", "Error", "Gesture doesnt match", "#ff0000", 1000);
    }
});

$(document).on('click', '#cancel-GESTURE', function(e){
    e.preventDefault();
    $(".security-"+PressedSecurity+"-input").val("")
    QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -120);
    PressedSecurity = null;
});

$(document).on('click', '#accept-FINGERPRINT', function(e){
    e.preventDefault();
    if (QB.Phone.Functions.getFingerSetup) {
        FINGERPRINT = QB.Phone.Data.PlayerData.charid;
        Primary = $("#security-primary-"+PressedSecurity+"")[0].checked;
            if (Primary) {
                Security.primary = PressedSecurity;
            }
            if (Security.type === "none") {
                Security.type = {}
            }
            Security.type[PressedSecurity] = FINGERPRINT
            $(".security-"+PressedSecurity+"-input").val("")
            QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"", 200, -120);
            PressedSecurity = null;
            QB.Phone.Functions.resetFingerSetup()
    } else {
        QB.Phone.Notifications.Add("fas fa-circle", "Error", "Gesture doesnt match", "#ff0000", 1000);
    }
});

$(document).on('click', '#cancel-FINGERPRINT', function(e){
    e.preventDefault();
    $(".security-"+PressedSecurity+"-input").val("")
    QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -120);
    PressedSecurity = null;
});

$(document).on('click', '#accept-FACEID', function(e){
    e.preventDefault();
    if (QB.Phone.Functions.FaceIDStatus) {
        FACEID = QB.Phone.Data.PlayerData.charid;
        Primary = $("#security-primary-"+PressedSecurity+"")[0].checked;
        if (Primary) {
            Security.primary = PressedSecurity;
        }
        if (Security.type === "none") {
            Security.type = {}
        }
        Security.type[PressedSecurity] = FACEID
        $(".security-"+PressedSecurity+"-input").val("")
        QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"", 200, -120);
        PressedSecurity = null;
        QB.Phone.Functions.FaceIDReset()
    } else {
        QB.Phone.Notifications.Add("fas fa-circle", "Error", "FaceID smth!", "#ff0000", 1000);
    }
});

$(document).on('click', '#cancel-FACEID', function(e){
    e.preventDefault();
    $(".security-"+PressedSecurity+"-input").val("")
    QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -120);
    PressedSecurity = null;
});

$(document).on('click', '#accept-security', function(e){
    e.preventDefault();
    QB.Phone.Settings.Security = Security
    QB.Phone.Functions.refreshSecurity()
    $.post('https://phone/SaveSecurity', JSON.stringify({Security}))
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

$(document).on('click', '#cancel-security', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
    if (PressedSecurity) {
        QB.Phone.Animations.TopSlideDown(".security-"+PressedSecurity+"" , 200, -100);
        PressedSecurity = null;
        Security = {};
    }
});
