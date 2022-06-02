document.onkeyup = function (data) {
    if (data.which == 27) { // ESC
        $.post('https://bossmenu/closepanel', JSON.stringify({}));
    }
};

const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0
});

var jobData = null;
var opennedPage = null;
$(function () {
    window.addEventListener('message', function (event) {
        switch (event.data.action) {
            case 'show':
                $('#user-details').html(event.data.user.firstname + " " + event.data.user.lastname);

                $('.box').show();
                if (event.data.data != null) {
                    jobData = event.data.data
                }
                if (event.data.page != null) {
                    openMenu(event.data.page)
                }
                break;
            case 'hide':
                $('.box').hide();
                break;
            case "update":
                jobData = event.data.data;
                if (opennedPage) {
                    openMenu(opennedPage);
                }
                break;
            default:
                console.log('rito: unknown action!');
                break;
        }
    }, false);
});


function openMenu(page) {
    if (page == "dashboard") {
        opennedPage = "dashboard";

        $('#description').html(`<label for=""><i class="fas fa-globe"></i></label> Přehled`);

        $('#main-place').html(`
        <div class="cards ">
            <div class="card-single ">
                <div>
                    <h1>${tableLength(jobData.employees)}</h1>
                    <span>Počet zaměstnanců</span>
                </div>
                <div>
                    <i class="fas fa-user"></i>
                </div>
            </div>
            <div class="card-single ">
                <div>
                    <h1>${jobData.Induty}</h1>
                    <span>Počet zaměstnanců ve službě</span>
                </div>
                <div>
                    <i class="fas fa-user-clock"></i>
                </div>
            </div>
            <div class="card-single ">
                <div>
                    <h1>${tableLength(jobData.applications)}</h1>
                    <span>Počet žádostí</span>
                </div>
                <div>
                    <i class="fas fa-envelope"></i>
                </div>
            </div>
            <div class="card-single">
                <div>
                    <h1 onclick="employeeAction('new')" >Nábor</h1>
                    <span onclick="employeeAction('new')">Přijmout nového zaměstance</span>
                </div>
                <div>
                <i class="fas fa-user-plus" onclick="employeeAction('new')"></i>
                </div>
            </div>
        </div>
        <div class="recent-flex ">
            <div class="projects ">
                <div class="card ">
                    <div class="card-header ">
                        <h2>Zaměstanci</h2>
                        <button onclick="openMenu('employes')">Zobrazit více  <i class="fas fa-search "></i></button>

                    </div>
                    <div class="card-body ">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>Jméno</td>
                                        <td>Pozice</td>
                                        <td>Stav</td>
                                    </tr>
                                </thead>
                                <tbody id="smallemployelist">
                                </tbody>

                            </table>
                        </div>

                    </div>
                </div>
            </div>
            <div class="customers ">
                <div class="card ">
                    <div class="card-header ">
                        <h2>Žádosti</h2>
                        <button onclick="openMenu('applications')">Zobrazit více  <i class="fas fa-search "></i></button>

                    </div>
                    <div class="card-body">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>Jméno</td>
                                        <td>Datum narození</td>
                                    </tr>
                                </thead>
                                <tbody id="smallapplicationlist">
                                </tbody>

                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `);

        var employeCount = 0
        $.each(jobData.employees, function (_, employe) {
            if (employeCount < 8) {
                let status = '<span class="status red "></span> Mimo službu'
                if (employe.Duty) {
                    status = '<span class="status green "></span> Ve službě'
                }
                employeCount = employeCount + 1

                $("#smallemployelist").append(`<tr>
                <td>${employe.Name}</td>
                <td>${employe.GradeLabel}</td>
                <td>
                    ${status}
                </td>
            </tr>`);
            }
        });

        var applicationCount = 0
        $.each(jobData.applications, function (_, application) {
            if (applicationCount < 8) {
                applicationCount = applicationCount + 1

                $("#smallapplicationlist").append(`<tr>
                <td>${application.name}</td>
                <td>${application.born}</td>
            </tr>`);
            }
        });


    } else if (page == "employes") {
        opennedPage = "employes";
        $('#description').html(`<label for=""><i class="fas fa-users"></i></label> Zaměstanci`);

        $('#main-place').html(`
        <div class="employe-list ">
            <div class="projects ">
                <div class="card ">
                    
                    <div class="card-body ">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>Jméno</td>
                                        <td>Pozice</td>
                                        <td>Stav</td>
                                        <td>Poznámky</td>
                                        <td>Volačka</td>
                                        <td>Bankovní účet</td>
                                        <td>Akce</td>
                                        <td> </td>
                                    </tr>
                                </thead>
                                <tbody id="employeslist">
                                </tbody>

                            </table>
                        </div>

                    </div>
                </div>
            </div>
        </div>`);

        let sortable = [];
        for (let charid in jobData.employees) {
            sortable.push([charid, jobData.employees[charid]]);
        }

        sortable.sort(function (a, b) {
            return b[1].Grade - a[1].Grade || a[1].Name - b[1].Name;
        });

        $.each(sortable, function (employeeId, employeeData) {
            let charid = employeeData[0];
            let employe = employeeData[1];

            let status = '<span class="status red "></span> Mimo službu'
            if (employe.Duty) {
                status = '<span class="status green "></span> Ve službě'
            }
            let notes = "placeholder='Žádné poznámky'"
            if (employe.BossData && employe.BossData.notes) {
                notes = `value="${employe.BossData.notes}"`
            }
            let customtag = "placeholder='Žádná volačka'"
            if (employe.BossData && employe.BossData.customtag) {
                customtag = `value="${employe.BossData.customtag}"`
            }
            let bank = "placeholder='Žádný účet'"
            if (employe.BossData && employe.BossData.bank) {
                bank = `value="${employe.BossData.bank}""`
            }

            $("#employeslist").append(`<tr>
                <td width="15%">${employe.Name}</td>
                <td width="1%">
                    <select id="grades-${charid}" class="form-select" aria-label="Ahoooj" onchange="submitForm(event, 'grade','${charid}')">
                        <option value='${employe.Grade}' selected>${employe.GradeLabel}</option>
                    </select>
                </td>
                <td width="10%">${status}</td>
                <td><input id="input-${charid}" type="text" name="input" ${notes}/></td>
                <td><input id="input-customtag-${charid}" type="text" name="input" ${customtag}/></td>
                <td><input id="input-bank-${charid}" type="number" name="input" min="1000000000" max="9999999999" ${bank}/></td>
                <td><button class="button red" onclick="employeeAction('fire', '${charid}')">Vyhodit</button></td>
                <td><button class="button blue" onclick="submitForm(event, 'employee', '${charid}')">Uložit změny</button></td>
            </tr>`);
            $.each(jobData.grades, function (id, grade) {
                if (grade.label != employe.GradeLabel) {
                    $(`#grades-${charid}`).append(`
                        <option value='${id + 1}'>${grade.label}</option>
                    `);
                }

            });

        });
    } else if (page == "grades") {
        opennedPage = "grades";
        $('#description').html(`<label for=""><i class="fas fa-id-badge"></i></label> Správa pozic`);

        $('#main-place').html(`
        <div class="employe-list ">
            <div class="projects ">
                <div class="card ">
                    
                    <div class="card-body ">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>Číslo pozice</td>
                                        <td>Název pozice</td>
                                        <td>Výplata</td>
                                        <td>Počet zaměstanců</td>
                                    </tr>
                                </thead>
                                <tbody id="gradelist">
                                </tbody>

                            </table>
                        </div>

                    </div>
                </div>
            </div>
        </div>`);

        $.each(jobData.grades, function (id, grade) {
            var count = 0
            $.each(jobData.employees, function (_, employe) {
                if (id + 1 == employe.Grade) {
                    count = count + 1
                }
            });
            $("#gradelist").append(`<tr>
                <td>${id + 1}.</td>
                <td>${grade.label}</td>
                <td>
                    <form class="grade-form" onsubmit="submitForm(event, 'salary', '${id + 1}')">
                        <input id="input-grade-${id + 1}" type="number" name="input" value="${grade.salary}">
                    </form>
                </td>
                <td>${count}</td>
            </tr>`);
        });
    } else if (page == "buy") {
        opennedPage = "buy";
        $('#description').html(`<label for=""><i class="fas fa-car"></i></label> Koupě vozidel`);

        $('#main-place').html(`
        <div class="buy">
            
        </div>`);

        var hasAccount = jobData.bank == null || jobData.bank == 0 || jobData.bank == "0" ? false : true

        $.each(jobData.Vehicles, function (_, data) {
            var buy = ""
            if (hasAccount) {
                buy = `<div><strong><i class="fas fa-shopping-basket" onclick="orderVehicle('${data.Model}', '${data.Price}', '${data.Type}', '${data.Livery}')"></i></strong></div>`
            }
            $(".buy").append(`
            <div class="vehicle-single" style="background: url('https://static.server.cz/img/vehicles/${data.Model}.png')">
        
                <div class='vehicleTextWrapper'>
                    <div class='vehicleText'>
                        <div>
                            <strong>${data.Label}</strong>
                        </div>
                        <div>
                            <strong>Cena činí: $${data.Price}</strong>
                        </div>
                        ${buy}
                    </div>
                </div>
            </div>`);
        });

    } else if (page == "vehicles") {
        opennedPage = "vehicles";
        $('#description').html(`<label for=""><i class="fas fa-car"></i></label> Firemní vozidla`);

        $('#main-place').html(`
        <div class="employe-list ">
            <div class="projects ">
                <div class="card ">
                    
                    <div class="card-body ">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>SPZ</td>
                                        <td>Model</td>
                                        <td>Garáž</td>
                                        <td>Poznámka</td>
                                        <td>Přístupné od pozice</td>
                                        <td>Přidělené pozici</td>
                                        <td>Přiděleno</td>
                                    </tr>
                                </thead>
                                <tbody id="vehicleslist">
                                </tbody>

                            </table>
                        </div>

                    </div>
                </div>
            </div>
        </div>`);
        $.each(jobData.OwnedVehs, function (vehId, vehicle) {

            let gradeLabel = "Nepřiřazeno"
            let grade = -1
            if (vehicle.Data && vehicle.Data.vehGrade) {
                grade = Number(vehicle.Data.vehGrade)
                gradeLabel = jobData.grades[Number(vehicle.Data.vehGrade) - 1].label
            }

            let charLabel = "Nepřiřazeno"
            let char = 0
            if (vehicle.Data && vehicle.Data.vehChar && jobData.employees[String(vehicle.Data.vehChar)]) {
                char = Number(vehicle.Data.vehChar)
                charLabel = jobData.employees[String(vehicle.Data.vehChar)].Name
            }


            let notes = "placeholder='Žádné poznámky'"
            if (vehicle.Data && vehicle.Data.vehNote) {
                notes = `value="${vehicle.Data.vehNote}"`
            }

            $("#vehicleslist").append(`<tr>
                <td width="10%">${vehicle.Plate}</td>
                <td width="20%">${vehicle.Label}</td>
                <td width="10%">${vehicle.Garage}</td>
                <td>
                    <form class="grade-form" onsubmit="submitForm(event, 'vehNote', '${vehicle.Plate}')">
                        <input id="vehicle-vehNote-${vehicle.Plate}" type="text" name="input" ${notes}>
                    </form>
                </td>
                <td width="1%">
                    <select id="vehicle-vehLowerGrade-${vehicle.Plate}" class="form-select" aria-label="Ahoooj" onchange="submitForm(event, 'vehLowerGrade','${vehicle.Plate}')">
                        <option value='${vehicle.Grade}' selected>${jobData.grades[Number(vehicle.Grade) - 1].label}</option>
                    </select>
                </td>
                <td width="1%">
                    <select id="vehicle-vehGrade-${vehicle.Plate}" class="form-select" aria-label="Ahoooj" onchange="submitForm(event, 'vehGrade','${vehicle.Plate}')">
                        <option value='${grade}' selected>${gradeLabel}</option>
                    </select>
                </td>
                <td width="1%">
                    <select id="vehicle-vehChar-${vehicle.Plate}" class="form-select" aria-label="Ahoooj" onchange="submitForm(event, 'vehChar','${vehicle.Plate}')">
                        <option value='${char}' selected>${charLabel}</option>
                    </select>
                </td>
            </tr>`);
            $.each(jobData.grades, function (id, grade) {
                if (gradeLabel != grade.label) {
                    $(`#vehicle-vehGrade-${vehicle.Plate}`).append(`
                    <option value='${id + 1}'>${grade.label}</option>
                `);
                }
                if (id + 1 != vehicle.Grade) {

                    $(`#vehicle-vehLowerGrade-${vehicle.Plate}`).append(`
                <option value='${id + 1}'>${grade.label}</option>
            `);
                }
            });
            if (grade != -1) {
                $(`#vehicle-vehGrade-${vehicle.Plate}`).append(`
                    <option value='Nepřiřazeno'>Nepřiřazeno</option>
                `);

            }
            $.each(jobData.employees, function (id, employe) {
                if (charLabel != employe.GradeLabel) {
                    $(`#vehicle-vehChar-${vehicle.Plate}`).append(`
                    <option value='${id}'>${employe.Name}</option>
                `);
                }

            });
            if (char != 0) {
                $(`#vehicle-vehChar-${vehicle.Plate}`).append(`
                    <option value='Nepřiřazeno'>Nepřiřazeno</option>
                `);

            }

        });
    } else if (page == "invoices"){
        opennedPage = "invoices";
        $('#description').html(`<label for=""><i class="fas fa-car"></i></label> Nezaplacené faktury`);

        $('#main-place').html(`
        <div class="employe-list ">
            <div class="projects ">
                <div class="card ">
                    
                    <div class="card-body ">
                        <div class="table-responsive ">
                            <table width="100% ">
                                <thead>
                                    <tr>
                                        <td>Číslo faktury</td>
                                        <td>Splátce</td>
                                        <td>Částka</td>
                                        <td>Datum</td>
                                    </tr>
                                </thead>
                                <tbody id="invoicesList">
                                </tbody>

                            </table>
                        </div>

                    </div>
                </div>
            </div>
        </div>`);

        $.each(jobData.invoices, function (invoiceId, invoiceData) {
            if (invoiceData.Date < 10000000000) {
                invoiceData.Date *= 1000;
            }
            let date = new Date(invoiceData.Date);
            let items = "";
            if(invoiceData.Items != null){
                let first = true;
                $.each(invoiceData.Items, function (_, itemData) {
                    items = items + (first ? "" : " | ") + itemData.label + " - $" + itemData.price
                    first = false;
                });
            }
            $("#invoicesList").append(`<tr>
                <td width="25%">${invoiceData.Id}</td>
                <td width="25%">${invoiceData.OwnerName}</td>
                <td width="25%">${items}  (<strong style='color: darkgreen;'>${formatter.format(invoiceData.Price)}</strong>)</td>
                <td width="25%">${("0" + date.getDate()).slice(-2)}.${("0" + date.getMonth()).slice(-2)}.${date.getFullYear()} ${("0" + date.getHours()).slice(-2)}:${("0" + date.getMinutes()).slice(-2)}</td>
            </tr>`);
        });
    }

    else if (page == "applications") {
        opennedPage = "applications";
        $('#description').html(`<label for=""><i class="fas fa-envelope"></i></label> Žádosti o práci`);


        if (tableLength(jobData.applications) > 0) {

            $('#main-place').html(`
            <div class="applications-list ">
                <div class="projects ">
                    <div class="card ">
                        
                        <div class="card-body ">
                            <div class="table-responsive ">
                                <table width="100% ">
                                    <thead>
                                        <tr>
                                            <td>Jméno</td>
                                            <td>Datum narození</td>
                                            <td>Telefonní číslo</td>
                                            <td>Bydliště</td>
                                            <td>Pracovní zkušenosti</td>
                                            <td>Vzdělání</td>
                                            <td>Status</td>
                                            <td>Akce</td>
                                            <td>Akce</td>
                                        </tr>
                                    </thead>
                                    <tbody id="applicationslist">
                                    </tbody>

                                </table>
                            </div>

                        </div>
                    </div>
                </div>
            </div>`);
            $.each(jobData.applications, function (id, application) {
                $("#applicationslist").append(`<tr>
                    <td>${application.name}</td>
                    <td>${application.born}</td>
                    <td>${application.phone}</td>
                    <td>${application.house}</td>
                    <td>${application.experiences}</td>
                    <td>${application.school}</td>
                    <td>${application.status}</td>
                    <td onclick="applicationAction(${id}, 'accept')">Příjmout</td>
                    <td onclick="applicationAction(${id}, 'delete')">Smazat</td>
                </tr>`);
            });
        } else {
            $('#main-place').html(`<h3>Nejsou nalezeny žádné žádosti o zaměstnání!</h3>`);
        }
    } else if (page == "logs") {
        opennedPage = "logs";
        $('#description').html(`<label for=""><i class="fas fa-user-clock"></i></label> Příchody a odchody`);

        if (tableLength(jobData.logs) > 0) {

            $('#main-place').html(`
            <div class="employe-list ">
                <div class="projects ">
                    <div class="card ">
                        
                        <div class="card-body ">
                            <div class="table-responsive ">
                                <table width="100% ">
                                    <thead>
                                        <tr>
                                            <td>Zaměstanec</td>
                                            <td>Pozice</td>
                                            <td>Čas</td>
                                            <td>Akce</td>
                                        </tr>
                                    </thead>
                                    <tbody id="loglist">
                                    </tbody>

                                </table>
                            </div>

                        </div>
                    </div>
                </div>
            </div>`);
            $.each(jobData.logs, function (id, log) {
                let action = '<span class="status green "></span> Příchod'
                if (log.action == "off") {
                    action = '<span class="status red "></span> Odchod'
                }
                $("#loglist").append(`<tr>
                    <td>${log.employe}</td>
                    <td>${log.grade}</td>
                    <td>${log.time}</td>
                    <td>${action}</td>
                </tr>`);
            });
        } else {
            $('#main-place').html(`<h3>Nejsou dostupné žádné záznamy!</h3>`);
        }

    } else if (page == "settings") {
        opennedPage = "settings";
        $('#description').html(`<label for=""><i class="fas fa-cogs"></i></label> Nastavení`);

        var checked = (jobData.requests == true ? "Checked" : "")
        if (!jobData.garages) {
            jobData.garages = {}
        }

        var jobGarages = {
            car: jobData.garages.car == null ? 0000 : jobData.garages.car,
            boat: jobData.garages.boat == null ? 0000 : jobData.garages.boat,
            plane: jobData.garages.plane == null ? 0000 : jobData.garages.plane
        }
        checkedStyle = (jobData.requests == true ? "flexSwitchCheckChecked" : "flexSwitchCheckDefault")
        $('#main-place').html(`
            <div class="settings">
                <div class="projects ">
                    <div class="card ">
                        
                        <div class="card-body ">
                            <div class="table-responsive ">
                                <table width="100% ">
                                    <thead>
                                        <tr>
                                            <td>Bankovní účet společnosti</td>
                                            <td>Povolené žádosti z úřadu</td>
                                            <td>Číslo garáže pro vozidla</td>
                                            <td>Číslo hangáru pro letadla</td>
                                            <td>Číslo přístavu pro lodě</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <td>
                                            <form class="bank-form" onsubmit="submitForm(event, 'bank')">
                                            <input id="input-account" type="number" name="input" min="1000000000" max="9999999999" value="${jobData.bank}"/>
                                            </form>
                                        </td>
                                        
                                        <td style="align-content: center">
                                            <div class="form-check form-switch">
                                                <label class="form-check-label" for="${checkedStyle}"></label>
                                                <input class="form-check-input" type="checkbox" id="${checkedStyle}" ${checked} onclick="checkEnabled()">
                                            </div>
                                        </td>
                                        
                                        <td>
                                            <form class="vehicle-form" onsubmit="submitForm(event, 'car')">
                                            <input id="input-car" type="number" name="input" min="1000" max="9999" value="${jobGarages.car}"/>
                                            </form>
                                        </td>
                                        
                                        <td>
                                            <form class="plane-form" onsubmit="submitForm(event, 'plane')">
                                            <input id="input-plane" type="number" name="input" min="1000" max="9999" value="${jobGarages.plane}"/>
                                            </form>
                                        </td>
                                        
                                        <td>
                                            <form class="boat-form" onsubmit="submitForm(event, 'boat')">
                                            <input id="input-boat" type="number" name="input" min="1000" max="9999" value="${jobGarages.boat}"/>
                                            </form>
                                        </td>
                                    </tbody>

                                </table>
                            </div>

                        </div>
                    </div>
                </div>
            </div>`);
    }
}

function tableLength(t) {
    var count = 0
    $.each(t, function (_, _) {
        count = count + 1
    });
    return count
}

function submitForm(e, type, id) {
    e.preventDefault();
    let dataToSend = {}
    if (type == "salary") {
        dataToSend = {
            job: jobData.name,
            type: type,
            grade: id,
            newData: $(`#input-grade-${id}`).val()
        }
    } else if (type == "grade") {
        dataToSend = {
            job: jobData.name,
            type: type,
            char: id,
            newData: e.target.value
        }
    } else if (type == "employee") {
        dataToSend = {
            job: jobData.name,
            type: type,
            char: id,
            notes: $(`#input-${id}`).val(),
            bank: $(`#input-bank-${id}`).val(),
            customtag: $(`#input-customtag-${id}`).val()
        }
    } else if (type == "bank") {
        dataToSend = {
            job: jobData.name,
            type: type,
            newData: $(`#input-account`).val()
        }
    } else if (type == "car" || type == "boat" || type == "plane") {
        dataToSend = {
            job: jobData.name,
            type: type,
            newData: $(`#input-${type}`).val()
        }
    } else if (type == "vehChar" || type == "vehGrade" || type == "vehNote" || type == "vehLowerGrade" ) {
        dataToSend = {
            job: jobData.name,
            type: type,
            plate: id,
            newData: $(`#vehicle-${type}-${id}`).val()
        }
    }
    $.post('https://bossmenu/changeData', JSON.stringify(dataToSend));
}

function employeeAction(action, char) {
    let dataToSend = {
        action: "new",
        job: jobData.name,
        jobLabel: jobData.label,
        grades: jobData.grades
    }
    if (action == "fire") {
        dataToSend = {
            action: "fire",
            job: jobData.name,
            char: char
        }
    }
    $.post('https://bossmenu/employeeAction', JSON.stringify(dataToSend));
}

function applicationAction(id, action) {
    data = {
        id: id + 1,
        job: jobData.name,
        status: action
    }
    $.post('https://bossmenu/applicationData', JSON.stringify(data));
}

function checkEnabled() {
    let cb = document.getElementById(checkedStyle)
    $.post('https://bossmenu/changeData', JSON.stringify({
        job: jobData.name,
        type: 'requests',
        newData: cb.checked
    }));
}

function orderVehicle(model, price, type, livery) {
    $.post('https://bossmenu/orderVehicle', JSON.stringify({
        job: jobData.name,
        model: model,
        price: price,
        type: type,
        livery: livery
    }));
}