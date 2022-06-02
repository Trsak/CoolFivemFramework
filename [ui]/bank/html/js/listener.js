let opened = false;
let blocked = false;
let wasBlocked = false
let accounts = [];
let cards = [];
let access = [];
let allAccesses = [];
let charNames = [];
let jobNames = [];
let finesList = [];
let invoicesList = [];
let removeAccount = 0;
let removeCard = 0;
let editCard = 0;
let editAccess = 0;
let usedAccount = 0;
let currentCard = 0;
let charId = 0
let accountsLeft = 0
let filter = "all";
let company = "";
let selectedIcon = 'fas fa-university';
let currentTransactions = [];
let balanceChart = null;

const months = [
    'LED',
    'ÚNO',
    'BŽE',
    'DUB',
    'KVĚ',
    'ČVN',
    'ČVC',
    'SRP',
    'ZÁŘ',
    'ŘÍJ',
    'LIS',
    'PRO'
]

const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0
});

document.onkeyup = function (data) {
    if (data.which === 27 && opened) {
        closepanel();
    }
};

new ClipboardJS('.copy');

$('.icp-dd').iconpicker({
    title: 'Zvolte ikonku účtu',
    hideOnSelect: true,
    templates: {
        search: '<input type="search" class="form-control iconpicker-search" placeholder="Hledat v ikonkách" />',
    }
});

$(function () {
    window.addEventListener('message', function (event) {
        blocked = false;

        switch (event.data.action) {
            case 'show':
                opened = true;

                if (event.data.accounts) {
                    accounts = event.data.accounts;
                }

                if (event.data.bankCompany) {
                    company = event.data.bankCompany;
                }

                if (event.data.numberOfAccountsLeft !== undefined) {
                    accountsLeft = event.data.numberOfAccountsLeft;
                }

                $('#logoImage').attr('src', 'img/' + company + '.png');

                showBank();
                break;
            case 'refreshATM':
                if (event.data.cardData.withdrawLimit === 0) {
                    $('#cardModalAccountWithdrawalLimit').html('Neomezený');
                } else {
                    $('#cardModalAccountWithdrawalLimit').html(formatter.format(event.data.cardsWithdrawLimit) + ' / ' + formatter.format(event.data.cardData.withdrawLimit));
                }

                $('#cardModalAccountBalance').html(formatter.format(event.data.accountData.balance));
                $('#cardModalAmount').val('');
                $('#cardModalAmount').focus();
                break;
            case 'showATM':
                opened = true;

                currentCard = event.data.cardNumber;

                $('#cardModalCardNumber').html(event.data.cardNumber);
                $('#cardModalAccountNumber').html(event.data.accountNumber);
                $('#cardModalAccountName').html(event.data.accountData.name);
                $('#cardModalAccountBalance').html(formatter.format(event.data.accountData.balance));

                if (event.data.cardData.withdrawLimit === 0) {
                    $('#cardModalAccountWithdrawalLimit').html('Neomezený');
                } else {
                    $('#cardModalAccountWithdrawalLimit').html(formatter.format(event.data.cardsWithdrawLimit) + ' / ' + formatter.format(event.data.cardData.withdrawLimit));
                }

                $('#cardModalAmount').val('');

                showATM();
                break;
            case 'hide':
                hideAllPanels();
                $('#box').hide();
                $('body').hide();
                opened = false;
                break;
            case 'openFines':
                if (event.data.fines) {
                    finesList = event.data.fines;
                }

                loadFinesList();

                showFines()

                break;
            case 'openInvoices':
                if (event.data.invoices) {
                    invoicesList = event.data.invoices;
                }

                loadInvoicesList();

                showInvoices()

                break;
            case 'refreshDetails':
                $('#sendAcountNumber').val('');
                $('#sendAmount').val('');
                $('#sendDescriptionReciever').val('');
                $('#sendDescriptionSender').val('');

                filter = "all";
                accounts[event.data.accountNumber] = event.data.accountDetails;

                if (event.data.accessData !== undefined) {
                    access = event.data.accessData;
                }

                if (event.data.charId !== undefined) {
                    charId = event.data.charId;
                }

                currentTransactions = event.data.logs;

                if (event.data.graphPage) {
                    loadTransactionsGraph();
                    useAccountGraph(event.data.accountNumber);
                } else {
                    loadTransactions();
                    useAccount(event.data.accountNumber);
                }
                break;
            case 'refreshDetailsCards':
                cards = event.data.accountCards;

                accounts[usedAccount] = event.data.accountData;

                loadCardsList();
                useAccountCards(event.data.accountNumber);
                break;
            case 'refreshDetailsAccesses':
                allAccesses = event.data.accessDetails;

                if (event.data.charNames) {
                    charNames = event.data.charNames;
                }

                if (event.data.jobNames) {
                    jobNames = event.data.jobNames;
                }

                loadAccessList();
                useAccountAccesses(event.data.accountNumber);

                if (!event.data.hasAccess) {
                    closepanel();
                }
                break;
            default:
                console.log('bank: unknown action!');
                break;
        }
    }, false);
});

function closepanel() {
    $.post('https://bank/closepanel', JSON.stringify({}));
}

function hideAllPanels() {
    $('#add-new-bank-account').modal('hide');
    $('#add-new-bank-card').modal('hide');
    $('#remove-bank-account').modal('hide');
    $('#remove-bank-card').modal('hide');
    $('#bank-account-deposit').modal('hide');
    $('#bank-account-withdraw').modal('hide');
    $('#credit-card-modal').modal('hide');
    $('#transaction-detail').modal('hide');
    $('#bank-account-send').modal('hide');
    $('#bank-account-edit').modal('hide');
    $('#edit-bank-card').modal('hide');
    $('#edit-bank-access').modal('hide');
    $('#subHeader').hide();
    $('#bankAccounts').hide();
    $('#finesListDetail').hide();
    $('#invoicesListDetail').hide();
    $('#bankAccountDetail').hide();
    $('#bankAccountDetailTransactions').hide();
    $('#bankAccountDetailTransactionsGraph').hide();
    $('#bankAccountDetailCards').hide();
    $('#bankAccountDetailAccesses').hide();
    $('#removeAccountButton').hide();
    $('#accountActions').hide();
    $('#accountActionsHr').hide();
    $('#accountActionsWithdraw').hide();
    $('#accountActionsDeposit').hide();
    $('#navSend').hide();
    $('#navEdit').hide();
    $('#navCards').hide();
    $('#navAccess').hide();

    $("[name=allFilters]").val(["all"]);
    $('.secondary-nav .nav-link').removeClass('active');
}

$('#bank-account-deposit').on('shown.bs.modal', function (e) {
    $('#depositAmount').focus();
})

$('#bank-account-withdraw').on('shown.bs.modal', function (e) {
    $('#withdrawAmount').focus();
})

$('#credit-card-modal').on('shown.bs.modal', function (e) {
    $('#cardModalAmount').focus();
})

$('#bank-account-edit').on('show.bs.modal', function (e) {
    const accountData = accounts[usedAccount];

    selectedIcon = accountData.icon;
    $('#accountIconEdit').data('selected', accountData.icon);

    $("#accountIconEditIcon").removeAttr('class');
    $("#accountIconEditIcon").attr('class', accountData.icon);
})

$('#add-new-bank-account').on('show.bs.modal', function (e) {
    selectedIcon = 'fas fa-university';
    $('#accountIcon').data('selected', selectedIcon);

    $("#accountIconIcon").removeAttr('class');
    $("#accountIconIcon").attr('class', selectedIcon);
})

$('#credit-card-modal').on('hide.bs.modal', function (e) {
    closepanel();
})

$('input[type=radio][name=allFilters]').change(function () {
    if (filter !== this.value) {
        filter = this.value;
        loadTransactions();
    }
});

$("#credit-card-modal-form").submit(function (event) {
    event.preventDefault();

    let action = $(this).find("button[type=submit]:focus").val();
    if (!blocked) {
        blocked = true;
        if (action === 'withdraw') {
            $.post('https://bank/cardWithdraw', JSON.stringify({
                amount: $('#cardModalAmount').val(),
                cardNumber: currentCard
            }));
        } else if (action === 'deposit') {
            $.post('https://bank/cardDeposit', JSON.stringify({
                amount: $('#cardModalAmount').val(),
                cardNumber: currentCard
            }));
        }
    }
});

$("#add-new-bank-card").submit(function (event) {
    event.preventDefault();

    if (hasAccess('cards')) {
        if (!blocked) {
            blocked = true;
            $.post('https://bank/createNewCard', JSON.stringify({
                pin: $('#cardPin').val(),
                name: $('#cardName').val(),
                withdrawLimit: $('#cardWithdrawLimit').val(),
                account: usedAccount
            }));

            $('#cardPin').val('');
            $('#cardName').val('');
            $('#cardWithdrawLimit').val(0);
        }
    }
});

$("#send").submit(function (event) {
    event.preventDefault();

    if (hasAccess('send')) {
        if (!blocked) {
            blocked = true;
            $.post('https://bank/sendMoney', JSON.stringify({
                accountTarget: $('#sendAcountNumber').val(),
                amount: $('#sendAmount').val(),
                descTo: $('#sendDescriptionReciever').val(),
                descFrom: $('#sendDescriptionSender').val(),
                account: usedAccount
            }));
        }
    }
});

$("#deposit").submit(function (event) {
    event.preventDefault();

    if (hasAccess('deposit')) {
        if (!blocked) {
            blocked = true;
            $('#bank-account-deposit').modal('hide');

            $.post('https://bank/depositAmount', JSON.stringify({
                amount: $('#depositAmount').val(),
                account: usedAccount
            }));

            $('#depositAmount').val('');
        }
    }
});

$("#withdraw").submit(function (event) {
    event.preventDefault();

    if (hasAccess('withdraw')) {
        if (!blocked) {
            blocked = true;
            $('#bank-account-withdraw').modal('hide');

            $.post('https://bank/withdrawAmount', JSON.stringify({
                amount: $('#withdrawAmount').val(),
                account: usedAccount
            }));

            $('#withdrawAmount').val('');
        }
    }
})

$("#editbankaccount").submit(function (event) {
    event.preventDefault();

    if (hasAccess('edit')) {
        if (!blocked) {
            blocked = true;
            $('#bank-account-edit').modal('hide');

            $.post('https://bank/editAccount', JSON.stringify({
                account: usedAccount,
                name: $('#accountNameEdit').val(),
                description: $('#accountDescriptionEdit').val(),
                icon: selectedIcon
            }));
        }
    }
});

$("#editbankcard").submit(function (event) {
    event.preventDefault();

    if (hasAccess('cards')) {
        if (!blocked) {
            blocked = true;
            $('#bank-account-edit').modal('hide');

            $.post('https://bank/editCard', JSON.stringify({
                pin: $('#cardPinEdit').val(),
                name: $('#cardNameEdit').val(),
                withdrawLimit: $('#cardWithdrawLimitEdit').val(),
                card: editCard
            }));
        }
    }
});

$("#editbankaccess").submit(function (event) {
    event.preventDefault();

    if (hasAccess('accesses')) {
        if (!blocked) {
            blocked = true;
            $('#edit-bank-access').modal('hide');

            $.post('https://bank/editAccess', JSON.stringify({
                priority: $('#accessEditPriority').val(),
                root: $('#accessEditRoot').is(":checked"),
                view: $('#accessEditView').is(":checked"),
                cards: $('#accessEditCards').is(":checked"),
                withdraw: $('#accessEditWithdraw').is(":checked"),
                deposit: $('#accessEditDeposit').is(":checked"),
                edit: $('#accessEditEdit').is(":checked"),
                send: $('#accessEditSend').is(":checked"),
                accesses: $('#accessEditAccesses').is(":checked"),
                accessId: editAccess,
                account: usedAccount
            }));
        }
    }
});

$("#addbankaccount").submit(function (event) {
    event.preventDefault();

    if (!blocked && accountsLeft > 0) {
        blocked = true;
        $('#add-new-bank-account').modal('hide');

        $.post('https://bank/createAccount', JSON.stringify({
            name: $('#accountName').val(),
            description: $('#accountDescription').val(),
            icon: selectedIcon
        }));

        $('#accountName').val('');
        $('#accountDescription').val('');
    }
});

function filterCheck(action) {
    if (filter === 'deposit' && action !== 'DEPOSIT_CASH') {
        return false;
    } else if (filter === 'withdraw' && action !== 'WITHDRAW_CASH') {
        return false;
    } else if (filter === 'in' && action !== 'RECEIVE_MONEY') {
        return false;
    } else if (filter === 'out' && action !== 'SEND_MONEY') {
        return false;
    }

    return true;
}

function loadFinesList() {
    $('#finesListUnpaid').html('');
    $.each(finesList, function (index, fineData) {
        if (fineData.Date < 10000000000) {
            fineData.Date *= 1000;
        }
        let date = new Date(fineData.Date);

        $('#finesListUnpaid').prepend(`<div class="notifications-item unread px-4 py-3" onclick="payFine(${fineData.Dbid})">
                                <div class="row align-items-center flex-row">
                                    <div class="col-2 col-sm-1 text-center text-8 icon-bell"><i class="fas fa-gavel"></i>
                                    </div>
                                    <div class="col col-sm-10">
                                        <h4 class="text-3 mb-1">${fineData.Label} (${formatter.format(fineData.Price)})</h4>
                                        <span class="text-muted">${("0" + date.getDate()).slice(-2)}.${("0" + date.getMonth() + 1).slice(-2)}.${date.getFullYear()} ${("0" + date.getHours()).slice(-2)}:${("0" + date.getMinutes()).slice(-2)}</span></div>
                                    <div class="col-1 text-right text-muted" style="white-space: nowrap">Zaplatit <i class="fas fa-chevron-right"></i></div>
                                </div>
                            </div>`);
    });

    if (finesList.length === 0) {
        $('#finesListUnpaid').html(`<div class="alert alert-success" style="margin: 5px;" role="alert">Nemáš žádné nezaplacené pokuty!</div>`);
    }
}

function loadInvoicesList() {
    $('#invoicesListUnpaid').html('');
    $.each(invoicesList, function (invoiceId, invoiceData) {
        if (invoiceData.Date < 10000000000) {
            invoiceData.Date *= 1000;
        }
        let date = new Date(invoiceData.Date);
        let items = ""
        $.each(invoiceData.Items, function (_, itemData) {
            items = items + " | " + itemData.label + " - $" + itemData.price
        });

        $('#invoicesListUnpaid').prepend(`<div class="notifications-item unread px-4 py-3" onclick="payInvoice('${invoiceData.Id}')">
                                <div class="row align-items-center flex-row">
                                    <div class="col-2 col-sm-1 text-center text-8 icon-bell"><i class="fas fa-receipt"></i>
                                    </div>
                                    <div class="col col-sm-10">
                                        <h4 class="text-3 mb-1">${items} - (${formatter.format(invoiceData.Price)})</h4>
                                        <span class="text-muted">${("0" + date.getDate()).slice(-2)}.${("0" + date.getMonth()).slice(-2)}.${date.getFullYear()} ${("0" + date.getHours()).slice(-2)}:${("0" + date.getMinutes()).slice(-2)} - vydáno ${invoiceData.SenderName}</span></div>
                                    <div class="col-1 text-right text-muted" style="white-space: nowrap">Zaplatit <i class="fas fa-chevron-right"></i></div>
                                </div>
                            </div>`);
    });

    if (invoicesList.length === 0) {
        $('#invoicesListUnpaid').html(`<div class="alert alert-success" style="margin: 5px;" role="alert">Nemáš žádné nezaplacené faktury!</div>`);
    }
}

function loadCardsList() {
    const accountData = accounts[usedAccount];
    if (accountData.freeCard) {
        $('#cardPriceText').text('první zdarma');
    } else {
        $('#cardPriceText').text('$100');
    }

    $('.cardSingle').remove();
    $.each(cards, function (cardNumber, cardData) {
        $('#cardsList').prepend(` <div class="col-12 col-sm-6 col-lg-6 cardSingle">
                <div class="account-card account-card-primary text-white rounded p-3 mb-4 mb-lg-0">
                  <p class="text-4" style="margin-bottom: 70px;">${cardNumber}</p>
                  <p class="d-flex align-items-center m-0"> <span class="text-uppercase font-weight-500">${cardData.name}</span> <img class="ml-auto" src="img/${company}.png"> </p>
                  <div class="account-card-overlay rounded"> 
                  <a href="#" onclick="editCardModal('${cardNumber}')" class="text-light btn-link mx-2"><span class="mr-1"><i class="fas fa-edit"></i></span>Upravit</a> 
                  <a href="#" onclick="removeCardModal('${cardNumber}')" class="text-light btn-link mx-2"><span class="mr-1"><i class="fas fa-minus-circle"></i></span>Smazat</a> 
                  </div>
                </div>
              </div>`);
    });
}

function loadAccessList() {
    $('#bankAccountDetailAccessesList').html('');
    $('#bankAccountDetailAccessesList').append(`<div class="bg-white shadow-sm rounded p-4 accessDetail">
        <h3 class="text-4 font-weight-200 d-flex align-items-center" style="padding-bottom: 0; margin-bottom: 0">Zakladatel ${charNames[accounts[usedAccount].founder]} (nejvyšší priorita)</h3>
        <hr class="mx-n1 mb-1">
            <p class="text-3" style="margin-bottom: 0; padding-bottom: 0">Plná práva</p>
        </div>`);

    $.each(allAccesses, function (index, accessInfo) {
        let label = '';
        if (accessInfo.type === 'char') {
            label = 'Osoba ' + charNames[accessInfo.who];
        } else if (accessInfo.type === 'job') {
            label = jobNames[accessInfo.who].label + ' od ' + jobNames[accessInfo.who].grades[accessInfo.grade - 1].label;
        }

        $('#bankAccountDetailAccessesList').append(`<div class="bg-white shadow-sm rounded p-4 accessDetail">
        <h3 class="text-4 font-weight-200 d-flex align-items-center" style="padding-bottom: 0; margin-bottom: 0">
            ${label} (priorita ${accessInfo.priority})
            <a href="#" onclick="editAccessModal(${accessInfo.id}, ${index})"  class="ml-auto text-2 text-uppercase btn-link"><span class="mr-1"><i class="fas fa-edit"></i></span>Změnit</a>
        </h3>
        <hr class="mx-n1 mb-1">
            <p class="text-3" style="margin-bottom: 0; padding-bottom: 0">${accessLabel(accessInfo)}</p>
        </div>`);
    });
}

function accessLabel(accessData) {
    if (accessData.root === true) {
        return "Plná práva";
    }

    let userAccesses = [];

    if (accessData.view === true) {
        userAccesses.push("Zobrazení zůstatku a transakcí");
    }

    if (accessData.cards === true) {
        userAccesses.push("Správa karet účtu");
    }

    if (accessData.withdraw === true) {
        userAccesses.push("Výběry v bance");
    }

    if (accessData.deposit === true) {
        userAccesses.push("Vklady v bance");
    }

    if (accessData.edit === true) {
        userAccesses.push("Úprava účtu");
    }

    if (accessData.send === true) {
        userAccesses.push("Vytvoření příkazu");
    }

    if (accessData.accesses === true) {
        userAccesses.push("Správa přístupů");
    }

    if (accessData.remove === true) {
        userAccesses.push("Odstranění účtu");
    }

    if (userAccesses.length === 0) {
        return "Žádná práva";
    } else {
        return userAccesses.join(' | ');
    }
}

function loadTransactionsGraph() {
    let balanceLabels = [];
    let balanceData = [];

    let dayData = [];

    if (currentTransactions === undefined) {
        currentTransactions = [];
    }

    const reversed = currentTransactions.reverse();
    $.each(reversed, function (index, transactionInfo) {
        if (transactionInfo.date < 10000000000) {
            transactionInfo.date *= 1000;
        }
        let date = new Date(transactionInfo.date);
        let dayMonth = date.getDate() + "." + (date.getMonth() + 1) + ".";
        dayData[dayMonth] = transactionInfo.balance;
    });

    let todayDate = new Date();
    let dayMonth = todayDate.getDate() + "." + (todayDate.getMonth() + 1) + ".";
    dayData[dayMonth] = accounts[usedAccount].balance;

    for (const [key, value] of Object.entries(dayData.reverse())) {
        balanceLabels.push(key);
        balanceData.push(value);
    }

    if (balanceChart !== null) {
        balanceChart.destroy();
    }

    const ctx = document.getElementById('balanceChart').getContext('2d');
    balanceChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: balanceLabels,
            datasets: [{
                data: balanceData,
                label: "Zůstatek",
                borderColor: "#3e95cd",
                fill: true
            }]
        },
        options: {
            interaction: {
                intersect: false,
                mode: 'index'
            },
            scales: {
                y: {
                    ticks: {
                        callback: function (value, index, ticks) {
                            return formatter.format(value);
                        }
                    }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function (context) {
                            let label = context.dataset.label || '';
                            return label + ': ' + formatter.format(context.parsed.y);
                        }
                    }
                }
            }
        }
    });
}

function loadTransactions() {
    $('#transactions').html('');
    $.each(currentTransactions, function (index, transactionInfo) {
        if (filterCheck(transactionInfo.action)) {
            let textTop;

            if (transactionInfo.action === 'WITHDRAW_CASH') {
                textTop = 'Výběr hotovosti';
            } else if (transactionInfo.action === 'DEPOSIT_CASH') {
                textTop = 'Vklad hotovosti';
            } else if (transactionInfo.action === 'SEND_MONEY') {
                textTop = 'Odchozí platba';
            } else if (transactionInfo.action === 'RECEIVE_MONEY') {
                textTop = 'Příchozí platba';
            }

            if (transactionInfo.date < 10000000000) {
                transactionInfo.date *= 1000;
            }
            let date = new Date(transactionInfo.date);

            let negativeSign = '';
            let negativeClass = '';
            if (transactionInfo.negative) {
                negativeSign = '-';
                negativeClass = 'negative';
            }

            $('#transactions').append(`<div class="transaction-item ${negativeClass} px-4 py-3" data-toggle="modal" data-target="#transaction-detail" onclick="transactionDetail(${index})">
                <div class="row align-items-center flex-row">
                  <div class="col-2 col-sm-1 text-center"> <span class="d-block text-4 font-weight-300">${date.getDate()}</span> <span class="d-block text-1 font-weight-300 text-uppercase">${months[date.getMonth()]}</span> </div>
                  <div class="col col-sm-9"> <span class="d-block text-4">${textTop}</span> <span class="text-muted">${transactionInfo.description}</span> </div>
                  <div class="col-2 col-sm-2 text-right text-4"> <span class="text-nowrap">${negativeSign}${formatter.format(transactionInfo.amount)}</span></div>
                </div>
              </div>`);
        }
    });
}

function useAccount(accountNumber) {
    usedAccount = accountNumber;
    const accountData = accounts[accountNumber];

    hideAllPanels();

    $('#navDetail .nav-link').addClass('active');
    $('#bankAccountDetailName').text(accountData.name);
    $('#bankAccountDetailDescription').text(accountData.description);
    $('#bankAccountDetailNumber').text(accountNumber);
    $('#bankAccountDetailBalance').text(formatter.format(accountData.balance));

    checkAccountSubmenu();

    $('#accountNameEdit').val(accountData.name);
    $('#accountDescriptionEdit').val(accountData.description);

    $('#subHeader').show();
    $('#bankAccountDetailTransactions').show();
    $('#bankAccountDetail').show();
}

function useAccountGraph(accountNumber) {
    usedAccount = accountNumber;
    const accountData = accounts[accountNumber];

    hideAllPanels();

    $('#navGraph .nav-link').addClass('active');
    $('#bankAccountDetailName').text(accountData.name);
    $('#bankAccountDetailDescription').text(accountData.description);
    $('#bankAccountDetailNumber').text(accountNumber);
    $('#bankAccountDetailBalance').text(formatter.format(accountData.balance));

    checkAccountSubmenu();

    $('#accountNameEdit').val(accountData.name);
    $('#accountDescriptionEdit').val(accountData.description);

    $('#subHeader').show();
    $('#bankAccountDetailTransactionsGraph').show();
    $('#bankAccountDetail').show();
}

function useAccountAccesses(accountNumber) {
    const accountData = accounts[accountNumber];
    hideAllPanels();

    $('#navAccess .nav-link').addClass('active');
    $('#bankAccountDetailName').text(accountData.name);
    $('#bankAccountDetailDescription').text(accountData.description);
    $('#bankAccountDetailNumber').text(accountNumber);
    $('#bankAccountDetailBalance').text(formatter.format(accountData.balance));

    checkAccountSubmenu();

    $('#subHeader').show();
    $('#bankAccountDetailAccesses').show();
    $('#bankAccountDetail').show();
}

function useAccountCards(accountNumber) {
    const accountData = accounts[accountNumber];
    hideAllPanels();

    $('#navCards .nav-link').addClass('active');
    $('#bankAccountDetailName').text(accountData.name);
    $('#bankAccountDetailDescription').text(accountData.description);
    $('#bankAccountDetailNumber').text(accountNumber);
    $('#bankAccountDetailBalance').text(formatter.format(accountData.balance));

    checkAccountSubmenu();

    $('#subHeader').show();
    $('#bankAccountDetailCards').show();
    $('#bankAccountDetail').show();
}

$("#navDetail").click(function () {
    loadAccount(usedAccount);
});

$("#navGraph").click(function () {
    loadAccountGraph(usedAccount);
});

$("#navCards").click(function () {
    loadCards(usedAccount);
});

$("#navAccess").click(function () {
    loadAccesses(usedAccount);
});

function showInvoices() {
    hideAllPanels();

    $('.navbar-nav li').removeClass('active');
    $('#navInvoicesList').addClass('active');
    $('#invoicesListDetail').show();
}

function showFines() {
    hideAllPanels();

    $('.navbar-nav li').removeClass('active');
    $('#navFinesList').addClass('active');
    $('#finesListDetail').show();
}

function showATM() {
    hideAllPanels();

    $('body').show();
    $('#credit-card-modal').modal('show');
}

function transactionDetail(transactionIndex) {
    let transactionInfo = currentTransactions[transactionIndex];
    if (transactionInfo.date < 10000000000) {
        transactionInfo.date *= 1000;
    }
    let date = new Date(transactionInfo.date);
    $("#transactionTargetBox").hide();

    $('#transactionDateTime').html(("0" + date.getDate()).slice(-2) + "." + ("0" + (date.getMonth() + 1)).slice(-2) + "." + date.getFullYear() + " " + ("0" + date.getHours()).slice(-2) + ":" + ("0" + date.getMinutes()).slice(-2) + ":" + ("0" + date.getSeconds()).slice(-2));
    $('#transactionDesccription').html(transactionInfo.description);
    if(transactionInfo.targetAccount != null && transactionInfo.targetAccount != ""){
        $("#transactionTargetBox").show();

        $("#transactionTargetLabel").html("Na účet:");
        if(transactionInfo.action == "RECEIVE_MONEY")
            $("#transactionTargetLabel").html("Z účtu:");

        $('#transactionTarget').html(transactionInfo.targetAccount);
    }
    $('#transactionAmount').html(formatter.format(transactionInfo.amount));
    $('#transactionBalance').html(formatter.format(transactionInfo.balance));
}

function showBank() {
    hideAllPanels();
    setupBankAccounts();

    $('.navbar-nav li').removeClass('active');
    $('#navAllList').addClass('active');

    if (accountsLeft <= 0) {
        $('#addNewBankAccountButton').hide();
    } else {
        $('.accountsLeft').text(accountsLeft);
        $('#addNewBankAccountButton').show();
    }

    $('#bankAccounts').show();
    $('#box').show();
    $('body').show();
}

function createNewAccess() {
    if (hasAccess('accesses')) {
        closepanel();
        $.post('https://bank/createNewAccess', JSON.stringify({
            account: usedAccount
        }));
    }
}

function checkAccountSubmenu() {
    if (hasAccess('remove')) {
        $('#removeAccountButton').show();
    }

    if (hasAccess('cards')) {
        $('#navCards').show();
    }

    if (hasAccess('edit')) {
        $('#navEdit').show();
    }

    if (hasAccess('send')) {
        $('#navSend').show();
    }

    if (hasAccess('accesses')) {
        $('#navAccess').show();
    }

    if (hasAccess('deposit')) {
        $('#accountActionsHr').show();
        $('#accountActions').show();
        $('#accountActionsDeposit').show();
    }

    if (hasAccess('withdraw')) {
        $('#accountActionsHr').show();
        $('#accountActions').show();
        $('#accountActionsWithdraw').show();
    }
}

function loadAccesses(accountNumber) {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadAccesses', JSON.stringify({
            account: accountNumber
        }));
    }
}

function loadCards(accountNumber) {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadCards', JSON.stringify({
            account: accountNumber
        }));
    }
}

function loadFines() {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadFines', JSON.stringify({}));
    }
}

function loadInvoices() {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadInvoices', JSON.stringify({}));
    }
}

function loadAccountGraph(accountNumber) {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadAccountGraph', JSON.stringify({
            account: accountNumber
        }));
    }
}

function loadAccount(accountNumber) {
    if (!blocked) {
        blocked = true;
        $.post('https://bank/loadAccount', JSON.stringify({
            account: accountNumber
        }));
    }
}

function payFine(fineId) {
    if (!blocked) {
        blocked = true;

        $.post('https://bank/payFine', JSON.stringify({
            fine: fineId
        }));
    }
}

function payInvoice(invoiceId) {
    if (!blocked) {
        blocked = true;

        $.post('https://bank/payInvoice', JSON.stringify({
            invoice: invoiceId
        }));
    }
}

function confirmRemoveAccount() {
    if (hasAccess('remove')) {
        if (!blocked) {
            blocked = true;
            $('#remove-bank-account').modal('hide');

            $.post('https://bank/removeAccount', JSON.stringify({
                account: removeAccount
            }));
        }
    }
}

function confirmRemoveAccess() {
    if (hasAccess('accesses')) {
        if (!blocked) {
            blocked = true;
            $('#edit-bank-access').modal('hide');

            $.post('https://bank/removeAccess', JSON.stringify({
                accessId: editAccess,
                account: usedAccount
            }));
        }
    }
}

function confirmRemoveCard() {
    if (!blocked) {
        blocked = true;
        $('#remove-bank-card').modal('hide');

        $.post('https://bank/removeCard', JSON.stringify({
            card: removeCard
        }));
    }
}

function editAccessModal(accessId, accessIndex) {
    editAccess = accessId;
    const accessData = allAccesses[accessIndex];

    $('#accessEditPriority').val(accessData.priority);
    $('#accessEditRoot').prop('checked', accessData.root);
    $('#accessEditView').prop('checked', accessData.view);
    $('#accessEditCards').prop('checked', accessData.cards);
    $('#accessEditWithdraw').prop('checked', accessData.withdraw);
    $('#accessEditDeposit').prop('checked', accessData.deposit);
    $('#accessEditEdit').prop('checked', accessData.edit);
    $('#accessEditSend').prop('checked', accessData.send);
    $('#accessEditAccesses').prop('checked', accessData.accesses);
    $('#accessEditRemove').prop('checked', accessData.remove);

    $('#edit-bank-access').modal('show');
}

function editCardModal(cardNumber) {
    editCard = cardNumber;
    const cardData = cards[cardNumber];

    $('#cardNameEdit').val(cardData.name);
    $('#cardPinEdit').val(cardData.pin);
    $('#cardWithdrawLimitEdit').val(cardData.withdrawLimit);

    $('#edit-bank-card').modal('show');
}

function removeCardModal(cardNumber) {
    removeCard = cardNumber;
    const cardData = cards[cardNumber];

    $('#removeCardNumber').text(cardNumber);
    $('#removeCardName').text(cardData.name);
    $('#remove-bank-card').modal('show');
}

function removeAccountModal() {
    removeAccount = usedAccount;
    const accountData = accounts[usedAccount];

    $('#removeAccountNumber').text(usedAccount);
    $('#removeAccountName').text(accountData.name);
    $('#remove-bank-account').modal('show');
}

function setupBankAccounts() {
    $(".bankAccountSingle").remove();

    $.each(accounts, function (accountNumber, accountData) {
        $('#bankAccountsListRows').prepend(`<div class="col-12 col-sm-6 bankAccountSingle">
                <div class="account-card account-card-primary text-white rounded mb-4 mb-lg-0">
                  <div class="row no-gutters">
                    <div class="col-3 d-flex justify-content-center p-3">
                      <div class="my-auto text-center"> <span class="text-13"><i class="${accountData.icon}"></i></span>
                      </div>
                    </div>
                    <div class="col-9 border-left">
                      <div class="py-4 my-2 pl-4">
                        <p class="text-4 font-weight-500 mb-1">${accountData.name}</p>
                        <p class="text-4 opacity-9 mb-1">${accountNumber}</p>
                        <p class="m-0">${accountData.description}</p>
                      </div>
                    </div>
                  </div>
                  <a href="#" onclick="loadAccount(${accountNumber})" class="text-light btn-link mx-2">
                  <div class="account-card-overlay rounded"> <span class="mr-1"><i class="fas fa-share"></i></span>Spravovat účet
                  </div>
                  </a> 
                </div>
              </div>`);
    });
}

function hasAccess(rule) {
    if (rule === 'remove') {
        return accounts[usedAccount].founder === charId;
    }

    if (access.root === true) {
        return true;
    } else if (access[rule] === true) {
        return true;
    }

    return false;
}

(function () {
    if (wasBlocked) {
        wasBlocked = false;
        if (blocked) {
            blocked = false;
        }
    } else {
        if (blocked) {
            wasBlocked = true;
        }
    }

    setTimeout(arguments.callee, 250);
})();

$('.icp-dd').on('iconpickerSelected', function (event) {
    selectedIcon = event.iconpickerValue;
});