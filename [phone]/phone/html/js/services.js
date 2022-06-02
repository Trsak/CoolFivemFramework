var CurrentServicesTab = "services-list"
var ServicesSettings;
var reportMaxLetters = 150;
var ServiceData;
var ServiceType;
var jobsAllowed = {
    ["medic"]: "emergency",
    ["police"]: "emergency",
    ["usms"]: "emergency",
    ["emergency"]: "emgergency"
}

$(document).on('click', '.services-header-tab', function(e){
    e.preventDefault();
    var PressedServicesTab = $(this).data('servicestab');
    if (PressedServicesTab) {
        var PreviousServicesTabObject = $('.services-header-tab').find('[data-servicestab="'+CurrentServicesTab+'"]');
        if (PressedServicesTab !== CurrentServicesTab) {
            $(this).addClass('selected-services-header-tab');
            $(PreviousServicesTabObject).removeClass('selected-services-header-tab');
            if (PressedServicesTab !== "services-settings") {
                $("." + CurrentServicesTab + "-tab").css({"display": "none"});
                $("." + PressedServicesTab + "-tab").css({"display": "block"});

                if (PressedServicesTab === "services-list") {
                    $.post('https://phone/GetServices', JSON.stringify({}), function (Services) {
                        SetupServicesList(Services)
                    });
                }

                if (PressedServicesTab === "services-messages") {
                    $.post('https://phone/GetMessages', JSON.stringify({}), function (Messages) {
                        SetupMessagesList(Messages);
                    });
                }

                CurrentServicesTab = PressedServicesTab;
            } else {
                $.post('https://phone/AddNewService', JSON.stringify({Job:QB.Phone.Data.PlayerJob}));
            }
        }
    }
});

SetupServices = function() {
    var header = $(".services-header-tab")
    var job = QB.Phone.Data.PlayerJob
    $(header).html("");
    $(header).append("<div id=\"services-list\" data-servicestab=\"services-list\" class=\"services-header-tab selected-services-header-tab\"><i class=\"fas fa-landmark\"></i></div>");
    if (job) {
        $(header).append("<div id=\"services-messages\" data-servicestab=\"services-messages\" class=\"services-header-tab\"><i class=\"fas fa-inbox\"></i></div>");
/*        if (QB.Phone.Data.PlayerJob.isBoss) {
            $(header).append("<div id=\"services-settings\" data-servicestab=\"services-settings\" class=\"services-header-tab\"><i class=\"fas fa-cog\"></i></div>");
        }*/
    }
    $.post('https://phone/GetServices', JSON.stringify({}), function (Services) {
        SetupServicesList(Services)
    });
}

$(".new-services-message-textarea").keyup(function(){
    $("#word_left_services").text("Characters left: " + (reportMaxLetters - $(this).val().length));
});

$(document).on('click', '.service-list-report', function(e){
    e.preventDefault();
    var textArea = $(".new-services-message-textarea");
    ServiceData = $(this).parent().data('ServiceData');
    ServiceType = "single"
    var words = $(textArea).val().length;
    $('#word_left').text("Characters left: "+(reportMaxLetters - words)+"");
    $("."+CurrentServicesTab+"").animate({
        left: 30 + "vh"
    });
    $(".new-services-message").animate({
        left: 0 + "vh"
    });
});

$(document).on('click', '.service-list-reportAll', function(e){
    e.preventDefault();
    var textArea = $(".new-services-message-textarea");
    ServiceData = $(this).data('ServiceData');
    ServiceType = "all"
    var words = $(textArea).val().length;
    $('#word_left').text("Characters left: "+(reportMaxLetters - words)+"");
    $("."+CurrentServicesTab+"").animate({
        left: 30 + "vh"
    });
    $(".new-services-message").animate({
        left: 0 + "vh"
    });
});

$(document).on('click', '#new-services-message-back', function(e){
    e.preventDefault();

    $("."+CurrentServicesTab+"").animate({
        left: 0+"vh"
    });
    $(".new-services-message").animate({
        left: -30+"vh"
    });
});

$(document).on('click', '#new-services-message-submit', function(e){
    e.preventDefault();
    var service = $(".new-services-message-textarea");
    var Report = $(service).val().replace(/\r\n/g, '<br />').replace(/[\r\n]/g, '<br />');
    if (Report !== "") {
        if(Report.length >= 0) {
            $("."+CurrentServicesTab+"").animate({
                left: 0 + "vh"
            });
            $(".new-services-message").animate({
                left: -30 + "vh"
            });
            $.post('https://phone/PostNewReport', JSON.stringify({
                message: Report,
                data: {
                    name: ServiceData.name,
                    typejob: ServiceData.type,
                    type: ServiceType
                }
            }));
            $(service).val("")
        } else {
            QB.Phone.Notifications.Add("fas fa-user-tie", "Services", "Too many characters", "#1affca", 2000);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-user-tie", "Services", "You can\'t post an empty ad!", "#1afff7", 2000);
    }
});



SetupServicesList = function(data) {
    var servicesListTab = $(".services-list-tab")
    $(servicesListTab).html("");
    var lawyers = [];
    var realestate = [];
    var mechanic = [];
    var taxi = [];
    var emergency = [];
    if (data.length > 0) {

        $.each(data, function(i, service) {
            if (service.typejob === "emergency") {
                emergency.push(service);
            }
/*            if (service.typejob === "service") {
                lawyers.push(service);
            }
            if (service.typejob === "realestate") {
                realestate.push(service);
            }
            if (service.typejob === "mechanic") {
                mechanic.push(service);
            }
            if (service.typejob === "taxi") {
                taxi.push(service);
            }*/
        });
        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(0, 102, 255);">Emergency (' + emergency.length + ')</h1><div class="service-list-reportAll" id="emergency"><i class="fas fa-phone"></i></div>');
        $("#emergency").data('ServiceData', { name: "emergency", type: "emergency"});
        if (emergency.length > 0) {
            $.each(emergency, function(i, emergency) {
                var element = '<div class="service-list" id="emergency-' + i + '"> <div class="service-list-firstletter" style="background-color: rgb(0, 102, 255);">' + (emergency.name).charAt(0).toUpperCase() + '</div> <div class="service-list-fullname">' + emergency.label + '</div> <div class="service-list-report"><i class="fas fa-phone"></i></div> </div><hr>'
                $(servicesListTab).append(element);
                $("#emergency-" + i).data('ServiceData', { name: emergency.name, type: emergency.typejob});
            });
        } else {
            var element = '<div class="service-list"><div class="no-services">There are no emergencies a available.</div></div>'
            $(servicesListTab).append(element);
        }
/*
        $(servicesListTab).append('<h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; border-top-left-radius: .5vh; border-top-right-radius: .5vh; width:100%; display:block; background-color: rgb(42, 137, 214);">Lawyers (' + lawyers.length + ')</h1>');

        if (lawyers.length > 0) {
            $.each(lawyers, function(i, service) {
                var element = '<div class="service-list" id="lawyerid-' + i + '"> <div class="service-list-firstletter" style="background-color: rgb(42, 137, 214);">' + (service.name).charAt(0).toUpperCase() + '</div> <div class="service-list-fullname">' + service.name + '</div> <div class="service-list-call"><i class="fas fa-phone"></i></div> </div>'
                $(servicesListTab).append(element);
                $("#serviceid-" + i).data('ServiceData', service);
            });
        } else {
            var element = '<div class="service-list"><div class="no-services">There are no lawyers available.</div></div>'
            $(servicesListTab).append(element);
        }

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(155, 15, 120);">Real Estate (' + realestate.length + ')</h1>');

        if (realestate.length > 0) {
            $.each(realestate, function(i, lawyer1) {
                var element = '<div class="service-list" id="lawyerid1-' + i + '"> <div class="service-list-firstletter" style="background-color: rgb(155, 15, 120);">' + (lawyer1.name).charAt(0).toUpperCase() + '</div> <div class="service-list-fullname">' + lawyer1.name + '</div> <div class="service-list-call"><i class="fas fa-phone"></i></div> </div>'
                $(servicesListTab).append(element);
                $("#lawyerid1-" + i).data('LawyerData', lawyer1);
            });
        } else {
            var element = '<div class="service-list"><div class="no-lawyers">There are no real estate agents available.</div></div>'
            $(servicesListTab).append(element);
        }

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(0, 204, 102);">Mechanic (' + mechanic.length + ')</h1>');

        if (mechanic.length > 0) {
            $.each(mechanic, function(i, lawyer2) {
                var element = '<div class="service-list" id="lawyerid2-' + i + '"> <div class="service-list-firstletter" style="background-color: rgb(0, 204, 102);">' + (lawyer2.name).charAt(0).toUpperCase() + '</div> <div class="service-list-fullname">' + lawyer2.name + '</div> <div class="service-list-call"><i class="fas fa-phone"></i></div> </div>'
                $(servicesListTab).append(element);
                $("#lawyerid2-" + i).data('LawyerData', lawyer2);
            });
        } else {
            var element = '<div class="service-list"><div class="no-services">There are no mechanics available.</div></div>'
            $(servicesListTab).append(element);
        }

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(255, 190, 27);">Taxi (' + taxi.length + ')</h1>');

        if (taxi.length > 0) {
            $.each(taxi, function(i, lawyer3) {
                var element = '<div class="service-list" id="lawyerid3-' + i + '"> <div class="service-list-firstletter" style="background-color: rgb(255, 190, 27);">' + (lawyer3.name).charAt(0).toUpperCase() + '</div> <div class="service-list-fullname">' + lawyer3.name + '</div> <div class="service-list-call"><i class="fas fa-phone"></i></div> </div>'
                $(servicesListTab).append(element);
                $("#lawyerid3-" + i).data('LawyerData', lawyer3);
            });
        } else {
            var element = '<div class="service-list"><div class="no-lawyers">There are no taxis available.</div></div>'
            $(servicesListTab).append(element);
        }*/
    } else {
        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(0, 102, 255);">Emergency (' + emergency.length + ')</h1>');

        var element = '<div class="service-list"><div class="no-services">There are no emergency a available.</div></div>'
        $(servicesListTab).append(element);

        /*$(servicesListTab).append('<h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; border-top-left-radius: .5vh; border-top-right-radius: .5vh; width:100%; display:block; background-color: rgb(42, 137, 214);">Lawyers (' + lawyers.length + ')</h1>');

        var element = '<div class="service-list"><div class="no-services">There are no lawyers available.</div></div>'
        $(servicesListTab).append(element);

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(155, 15, 120);">Real Estate (' + realestate.length + ')</h1>');

        var element = '<div class="service-list"><div class="no-services">There are no real estate agents available.</div></div>'
        $(servicesListTab).append(element);

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(0, 204, 102);">Mechanic (' + mechanic.length + ')</h1>');

        var element = '<div class="service-list"><div class="no-services">There are no mechanics available.</div></div>'
        $(servicesListTab).append(element);

        $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(255, 190, 27);">Taxi (' + taxi.length + ')</h1>');

        var element = '<div class="service-list"><div class="no-services">There are no taxis available.</div></div>'
        $(servicesListTab).append(element);*/
    }
}

SetupMessagesList = function(Messages) {
    var servicesListTab = $(".services-messages-tab")
    $(servicesListTab).html("");
    Messages.reverse()
    $(servicesListTab).append('<br><h1 style="font-size:1.641025641025641vh; padding:1.0256410256410255vh; color:#fff; margin-top:0; width:100%; display:block; background-color: rgb(0, 102, 255);">Messages (' + Messages.length + ')</h1>');
    if (Messages.length >= 0) {
        $.each(Messages, function(i, message) {
            var date = new Date(message.time * 1000);
            var formattedTime = date.toLocaleString();

            var element = '<div class="service-message" id="message-' + i + '"><div id="call-'+ i +'" class="service-message-call"><i class="fas fa-phone"></i></div><div class="service-message-header">['+i+'] '+formattedTime+' </div><div class="service-message-message">'+message.message+'</div><div class="service-message-details">IP:'+message.userData.ip+' Number: '+message.userData.telNumber||'undefined'+' Phone: '+message.userData.phone+'</div></div>'

            /*var element = '<div class="service-message" id="message-' + i + '"><div class="service-message-message">'+message.message+'</div></div> <hr>'*/
            $(servicesListTab).append(element);
            console.log(message)
            $("#message-" + i).data('messageData', message);
            $("#call-" + i).data('messageData', message.userData);
        });
    } else {
        var element = '<div class="service-message"><div class="no-services">There are no reports.</div></div>'
        $(servicesListTab).append(element);
    }
}

$(document).on('click', '.service-message-call', function(e){
    e.preventDefault();
    var messageData = $(this).data('messageData');
    var telNumber = messageData.telNumber || null
    $.post('https://phone/ServiceCall', JSON.stringify({telNumber}));
});

$(document).on('click', '.service-message-message', function(e){
    e.preventDefault();
    var messageData = $(this).parent().data('messageData');
    var location = messageData.userData.location || null
    $.post('https://phone/SetWP', JSON.stringify({location}));
});