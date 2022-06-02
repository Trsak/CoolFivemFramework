var FoccusedBank = null;
var BankAccs = {};
var inputChecked = "transfer";

$(document).on('click', '.bank-app-account', function(e){
    var copyText = document.getElementById("number"+e.currentTarget.id+"");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    QB.Phone.Notifications.Add("fas fa-university", "QBank", "Account number. copied!", "#badc58", 1750);
});

var CurrentTab = "accounts";


$(document).on('click', '.bank-app-header-button', function(e){
    e.preventDefault();

    var PressedObject = this;
    var PressedTab = $(PressedObject).data('headertype');

    if (CurrentTab != PressedTab) {
        var PreviousObject = $(".bank-app-header").find('[data-headertype="'+CurrentTab+'"]');

        if (PressedTab == "invoices") {
            $(".bank-app-account-actions").css({"display":"none"})
            $(".bank-app-"+CurrentTab).animate({
                left: -30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);

        } else if (PressedTab == "accounts") {
            $(".bank-app-"+CurrentTab).animate({
                left: 30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
            $(".bank-app-account-actions").css({"display":"block"})
        } else if (PressedTab == "fines") {
            $(".bank-app-account-actions").css({"display":"none"})
            $(".bank-app-"+CurrentTab).animate({
                left: -30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        }

        $(PreviousObject).removeClass('bank-app-header-button-selected');
        $(PressedObject).addClass('bank-app-header-button-selected');
        setTimeout(function(){ CurrentTab = PressedTab; }, 300)
    }
})


QB.Phone.Functions.DoBankOpen = function() {
    $(".bank-app-accounts").html("");
    QB.Phone.Animations.TopSlideDown(".bank-app-invoice-details", 400, -100);
    $.each(QB.Phone.Data.PlayerData.bank, function(k, bankAcc) {
        $.each(bankAcc, function(id, data) {
            BankAccs[id] = data
            $('.bank-app-accounts').append("<div id='"+id+"' class=\"bank-app-account\">\n" +
                "<div class=\"bank-app-account-name\">"+data.name+"</div>\n" +
                "<div class=\"bank-app-account-desc\">"+data.description+"</div>\n" +
                "<input id='number"+id+"' type=\"text\" class=\"bank-app-account-number\" readonly spellcheck=\"false\">\n" +
                "<div id='balance"+id+"' class=\"bank-app-account-balance\">&#36; 5000,00</div>\n" +
                "<i  class=\""+data.icon+" bank-app-account-icon\"></i>\n" +
                "</div>")
            $("#number"+id+"").val(id);
            $("#balance"+id+"").html("&#36; " + data.balance);
            $("#balance"+id+"").data('balance', data.balance);
            //$(".bank-app-account-balance").html("&#36; "+QB.Phone.Data.PlayerData.money.bank);
            //$(".bank-app-account-balance").data('balance', QB.Phone.Data.PlayerData.money.bank);

            $(".bank-app-loaded").css({"display": "none", "padding-left": "30vh"});
            $(".bank-app-accounts").css({"left": "30vh"});
            $(".qbank-logo").css({"left": "0vh"});
            $("#qbank-text").css({"opacity": "0.0", "left": "9vh"});
            $(".bank-app-loading").css({
                "display": "block",
                "left": "0vh",
            });
            setTimeout(function () {
                CurrentTab = "accounts";
                $(".qbank-logo").animate({
                    left: -12 + "vh"
                }, 500);
                setTimeout(function () {
                    $("#qbank-text").animate({
                        opacity: 1.0,
                        left: 14 + "vh"
                    });
                }, 100);
                setTimeout(function () {
                    $(".bank-app-loaded").css({"display": "flex"}).animate({"padding-left": "0"}, 300);
                    $(".bank-app-accounts").animate({left: 0 + "vh"}, 300);
                    $(".bank-app-loading").animate({
                        left: -30 + "vh"
                    }, 300, function () {
                        $(".bank-app-loading").css({"display": "none"});
                    });
                }, 1500)
            }, 500)
        })
    })
}

$(document).on('click', '.bank-app-account-actions', function(e){
    e.preventDefault();
    var $select = $("<i class=\"fab fa-cc-visa bank-app-transfer-select-icon\"></i><select class=\"bank-app-transfer-select\" name=\"bankaccs\" id=\"bankaccs\" required></select>");
    $("#bank-select").html($select);
    $.each(BankAccs, function (id, data){
        $("#bankaccs").append("<option value="+id+">"+data.name+"</option>");
        //document.getElementById("bankaccs").append("<option value='+id+'>'+data.name+'</option>")
    })
    QB.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
});

$(document).on('click', '#cancel-transfer', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
});

$(document).on('click', '.bank-transfer-type', function(e){
    if (e.target.id !== '') {
        target = $("#"+e.target.id+"")
        data = target.val();
        $("#"+inputChecked+"").checked = false;
        $("#"+e.target.id+"").checked = true;
        inputChecked = e.target.id
        if (data !== 'transfer') {
            $(".bank-transfer-type2").css({"display":"block"})
        }else{
            $(".bank-transfer-type2").css({"display":"none"})
        }
    }
});

$(document).on('click', '#accept-transfer', function(e){
    e.preventDefault();
    $(".bank-transfer-type2").css({"display":"none"})
    var iban = $("#bankaccs").val();
    var targetIban = $("#bank-transfer-iban").val();
    var amount = $("#bank-transfer-amount").val();
    var description = $("#description").val();
    var fine = document.getElementById('fine').checked
    var invoice = document.getElementById('invoice').checked
    var id = $("#bank-transfer-id").val();
    if (iban != targetIban) {
        if (iban != "" && amount != "") {
                $.post('https://phone/CanTransferMoney', JSON.stringify({
                    from: iban,
                    sendTo: targetIban,
                    amountOf: amount,
                    description: description,
                    void: false,
                    fine: fine,
                    invoice: invoice,
                    id: id,
                }), function(data){
                    if (data.TransferedMoney === "done") {
                        $("#bank-transfer-iban").val("");
                        $("#bank-transfer-amount").val("");
                        $("#description").val("");

                        QB.Phone.Data.PlayerData.bank = data.Bank
                        QB.Phone.Functions.DoBankOpen()
                        QB.Phone.Notifications.Add("fas fa-university", "QBank", "You have transfered &#36; "+amount+"!", "#badc58", 1500);
                    } else {
                        if (data.TransferedMoney === "sourceAccountDoesNotExist"){
                            data.TransferedMoney = "Account Does not exist";
                        } else if(data.TransferedMoney === "destAccountDoesNotExist"){
                            data.TransferedMoney = "Account Does not exist";
                        } else if(data.TransferedMoney === "noAccess"){
                            data.TransferedMoney = "No Access";
                        } else if(data.TransferedMoney === "notEnoughBalance"){
                            data.TransferedMoney = "Not enough money";
                        } else {
                            data.TransferedMoney = "Just error.";
                        }
                        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Error occured!"+data.TransferedMoney+"", "#badc58", 1500);
                    }
                    QB.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
                });
        } else {
            QB.Phone.Notifications.Add("fas fa-university", "QBank", "Fill out all fields!", "#badc58", 1750);
        }
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Dont you dare perpetumobile!", "#badc58", 1750);
    }
});

GetInvoiceLabel = function(type) {
    retval = null;
    if (type == "request") {
        retval = "Payment Request";
    }

    return retval
}

$(document).on('click', '.bank-app-invoice', function(e){
    if (e.target.id !== '') {
        invoiceId = e.currentTarget.id
        data = $("#"+invoiceId).data('invoicedata');
        $("#SenderName").val(data.SenderName);
        $("#OwnerName").val(data.OwnerName);
        $("#idInvoice").val(data.Id);
        $("#bank").val(data.Bank);
        $("#date").val(data.Datelabel);
        $("#price").val(data.Price);

        QB.Phone.Animations.TopSlideDown(".bank-app-invoice-details", 400, 0);
        $(".bank-app-invoice-details").css({"display":"flex"})
    }
});


$(document).on('click', '.bank-app-invoice-details', function(e){
    if (e.target.id !== '') {
        var copyText = document.getElementById(""+e.target.id+"");
        copyText.select();
        copyText.setSelectionRange(0, 99999);
        document.execCommand("copy");

        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Text copied copied!", "#badc58", 1750);
    }
});

$(document).on('click', '.bank-app-invoice-details', function(e){
    if (e.target.id == '') {
        QB.Phone.Animations.TopSlideDown(".bank-app-invoice-details", 400, -100);
    }
});

$(document).on('click', '.pay-invoice', function(event){
    event.preventDefault();

    var InvoiceId = $(this).parent().parent().attr('id');
    var InvoiceData = $("#"+InvoiceId).data('invoicedata');
    $.post('https://phone/PayInvoice', JSON.stringify({
        sender: InvoiceData.SenderName,
        senderBank: InvoiceData.Bank,
        Price: InvoiceData.Price,
        invoiceId: InvoiceData.Id,
        void: false,
        fine: false,
        invoice: true,
    }), function(data){
        if (data.TransferedMoney === "done") {
            $("#"+InvoiceId).animate({
                left: 30+"vh",
            }, 300, function(){
                setTimeout(function(){
                    $("#"+InvoiceId).remove();
                }, 100);
            });
            QB.Phone.Notifications.Add("fas fa-university", "QBank", "You have paid &#36;"+InvoiceData.Price+"!", "#badc58", 1500);
        } else {
            if (data.TransferedMoney === "sourceAccountDoesNotExist"){
                data.TransferedMoney = "Account Does not exist";
            } else if(data.TransferedMoney === "destAccountDoesNotExist"){
                data.TransferedMoney = "Account Does not exist";
            } else if(data.TransferedMoney === "noAccess"){
                data.TransferedMoney = "No Access";
            } else if(data.TransferedMoney === "notEnoughBalance"){
                data.TransferedMoney = "Not enough money";
            } else {
                data.TransferedMoney = "Just error.";
            }
            QB.Phone.Notifications.Add("fas fa-university", "QBank", "Error occured!"+data.TransferedMoney+"", "#badc58", 1500);
        }
    });
});

$(document).on('click', '.pay-fine', function(event){
    event.preventDefault();

    var FineId = $(this).parent().parent().attr('id');
    var FineData = $("#"+FineId).data('finedata');
    $.post('https://phone/PayFine', JSON.stringify({
        sender: FineData.SenderName,
        senderBank: FineData.Bank,
        Price: FineData.Price,
        invoiceId: FineData.Id,
        void: false,
        fine: false,
        invoice: true,
    }), function(data){
        if (data.TransferedMoney === "done") {
            $("#"+FineId).animate({
                left: 30+"vh",
            }, 300, function(){
                setTimeout(function(){
                    $("#"+FineId).remove();
                }, 100);
            });
            QB.Phone.Notifications.Add("fas fa-university", "QBank", "You have paid &#36;"+FineData.Price+"!", "#badc58", 1500);
        } else {
            if (data.TransferedMoney === "sourceAccountDoesNotExist"){
                data.TransferedMoney = "Account Does not exist";
            } else if(data.TransferedMoney === "destAccountDoesNotExist"){
                data.TransferedMoney = "Account Does not exist";
            } else if(data.TransferedMoney === "noAccess"){
                data.TransferedMoney = "No Access";
            } else if(data.TransferedMoney === "notEnoughBalance"){
                data.TransferedMoney = "Not enough money";
            } else {
                data.TransferedMoney = "Just error.";
            }
            QB.Phone.Notifications.Add("fas fa-university", "QBank", "Error occured!"+data.TransferedMoney+"", "#badc58", 1500);
        }
    });
});

$(document).on('click', '.decline-invoice', function(event){
    event.preventDefault();
    var InvoiceId = $(this).parent().parent().attr('id');
    var InvoiceData = $("#"+InvoiceId).data('invoicedata');

    $.post('https://phone/DeclineInvoice', JSON.stringify({
        sender: InvoiceData.sender,
        amount: InvoiceData.amount,
        society: InvoiceData.society,
        invoiceId: InvoiceData.id,
    }));
    $("#"+InvoiceId).animate({
        left: 30+"vh",
    }, 300, function(){
        setTimeout(function(){
            $("#"+InvoiceId).remove();
        }, 100);
    });
});

QB.Phone.Functions.LoadBankInvoices = function(invoices) {
    if (invoices !== null) {
        $(".bank-app-invoices-list").html("");
        $.each(invoices, function(i, invoice){
            var Elem = '<div class="bank-app-invoice" id="invoiceid-'+i+'"> <div class="bank-app-invoice-title">'+invoice.Bank+' <span style="font-size: 1vh; color: gray;">(Sender: '+invoice.SenderName+')</span></div> <div class="bank-app-invoice-amount">&#36; '+invoice.Price+'</div> <div class="bank-app-invoice-buttons"> <i class="fas fa-check-circle pay-invoice"></i></div> </div>';

            $(".bank-app-invoices-list").append(Elem);
            $("#invoiceid-"+i).data('invoicedata', invoice);
        });
    }
}

QB.Phone.Functions.LoadBankFines = function(Fines) {
    if (Fines !== null) {
        $(".bank-app-Fines-list").html("");

        $.each(Fines, function(i, fine){
            var Elem = '<div class="bank-app-fine" id="fineid-'+i+'"> <div class="bank-app-fine-title">'+fine.society+' <span style="font-size: 1vh; color: gray;">(Sender: '+fine.sender+')</span></div> <div class="bank-app-fine-amount">&#36; '+fine.amount+'</div> <div class="bank-app-fine-buttons"> <i class="fas fa-check-circle pay-fine"></i></div> </div>';

            $(".bank-app-Fines-list").append(Elem);
            $("#fineid-"+i).data('finedata', fine);
        });
    }
}

QB.Phone.Functions.LoadContactsWithNumber = function(myContacts) {
    var ContactsObject = $(".bank-app-my-contacts-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $("#bank-app-my-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".bank-app-my-contacts-list .bank-app-my-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var RandomNumber = Math.floor(Math.random() * 6);
            var ContactColor = QB.Phone.ContactColors[RandomNumber];
            var ContactElement = '<div class="bank-app-my-contact" data-bankcontactid="'+i+'"> <div class="bank-app-my-contact-firstletter">'+((contact.name).charAt(0)).toUpperCase()+'</div> <div class="bank-app-my-contact-name">'+contact.name+'</div> </div>'
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-bankcontactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '.bank-app-my-contacts-list-back', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});

$(document).on('click', '.bank-transfer-mycontacts-icon', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".bank-app-my-contacts", 400, 0);
});

$(document).on('click', '.bank-app-my-contact', function(e){
    e.preventDefault();
    var PressedContactData = $(this).data('contactData');

    if (PressedContactData.iban !== "" && PressedContactData.iban !== undefined && PressedContactData.iban !== null) {
        $("#bank-transfer-iban").val(PressedContactData.iban);
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "There is no bank account attached to this number!", "#badc58", 2500);
    }
    QB.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});