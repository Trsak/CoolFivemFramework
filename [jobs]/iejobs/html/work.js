function createCards(){
    $.each(work.data, function(key, value){

        for (i = 0; i < work.data[key].length; i++) {
            dataStore  = work.data[key][i]
            if (work.data[key][i].WorkTaken == false && work.data[key][i].WorkDone == false){
                if (alreadyInWork == false){
                    $('.content').prepend('<div class="cards"> \
                                               <div class="cHeader"> \
                                                   <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                                   <img class="box" src="../html/img/box.png" alt="box"> \
                                                   <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                               </div> \
                                               <div class="cBody"> \
                                                   <h1>'+cfg['PV']+':</h1> \
                                                   <p>'+cfg['CC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+count(key, i)+'</span>  '+' $</p> \
                                                   <ul class='+i+key+'></ul> \
                                               </div> \
                                               <div class="cFooter"> \
                                                   <button key='+key+' uuid='+i+' workR='+work.data[key][i].WorkRoute+' id="button" cost='+count(key, i)+' class="button button1" onclick="submit()" >'+cfg["S"]+'</button> \
                                               </div> \
                                           </div>');
                    document.getElementById("button").onclick = function() {submit(this.getAttribute('key'), this.getAttribute('uuid'), this.getAttribute('cost'), this.getAttribute('workR'))};
                    itemList(key, i)
                } else {
                    $('.content').prepend('<div class="cards"> \
                                           <div class="cHeader"> \
                                               <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                               <img class="box" src="../html/img/box.png" alt="box"> \
                                               <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                           </div> \
                                           <div class="cBody"> \
                                               <h1>'+cfg["PV"]+':</h1> \
                                               <p>'+cfg["CC"]+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+count(key, i)+'</span>  '+' $</p> \
                                               <ul class='+i+key+'></ul> \
                                           </div> \
                                           <div class="cFooter"> \
                                               <h2 style="color:red;font-size:28px;">'+cfg["YHVIP"]+'</h2> \
                                           </div> \
                                       </div>');
                    itemList(key, i)
                }
            } else if (work.data[key][i].WorkTaken == true && work.data[key][i].WorkDone == false) {

                if (work.data[key][i].WorkTaken == true && work.data[key][i].WorkRDone == false) {
                    $('.content').prepend('<div class="cards"><div class="cardsT"> \
                                               <div class="cHeader"> \
                                                   <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                                   <img class="box" src="../html/img/box.png" alt="box"> \
                                                   <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                               </div> \
                                               <div class="cBody"> \
                                                   <h1>'+cfg['PV']+':</h1> \
                                                   <p>'+cfg['CC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+count(key, i)+'</span>  '+' $</p> \
                                                   <ul class='+i+key+'></ul> \
                                               </div> \
                                               <div class="cFooter"> \
                                               <h2>'+cfg['WIP']+'</h2> \
                                               </div> \
                                               </div> \
                                           </div>');
                    itemList(key, i)

                } else {
                    if (work.data[key][i].Steam == identifier){
                        $('.content').prepend('<div class="cards"><div class="cardsD"> \
                                               <div class="cHeader"> \
                                                   <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                                   <img class="box" src="../html/img/box.png" alt="box"> \
                                                   <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                               </div> \
                                               <div class="cBody"> \
                                                   <h1>'+cfg['PV']+':</h1> \
                                                   <p>'+cfg['CC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+count(key, i)+'</span>  '+' $</p> \
                                                   <ul class='+i+key+'></ul> \
                                               </div> \
                                               <div class="cFooter"> \
                                                <button key='+key+' uuid='+i+' workR='+work.data[key][i].WorkRoute+' id="button" cost='+count(key, i)+' class="button button1" onclick="submit()" >'+cfg['P']+'</button> \
                                               </div> \
                                               </div> \
                                           </div>');
                        itemList(key, i)
                        document.getElementById("button").onclick = function() {submit(this.getAttribute('key'), this.getAttribute('uuid'), this.getAttribute('cost'), this.getAttribute('workR'))};
                    } else {
                        $('.content').prepend('<div class="cards"><div class="cardsT"> \
                                                   <div class="cHeader"> \
                                                       <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                                       <img class="box" src="../html/img/box.png" alt="box"> \
                                                       <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                                   </div> \
                                                   <div class="cBody"> \
                                                       <h1>'+cfg['PV']+':</h1> \
                                                       <p>'+cfg['CC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+count(key, i)+'</span>  '+' $</p> \
                                                       <ul class='+i+key+'></ul> \
                                                   </div> \
                                                   <div class="cFooter"> \
                                                   <h2>'+cfg['WIP']+'</h2> \
                                                   </div> \
                                                   </div> \
                                               </div>');
                        itemList(key, i)
                    }
                }

            } else if (work.data[key][i].WorkTaken == true && work.data[key][i].WorkDone == true && work.data[key][i].WorkRDone == true) {
                $('.content').prepend('<div class="cards"><div class="cardsD"> \
                                               <div class="cHeader"> \
                                                   <img class='+key+' src="../html/img/'+key+'.png" alt='+key+'> \
                                                   <img class="box" src="../html/img/box.png" alt="box"> \
                                                   <img class='+work.data[key][i].WorkType+' src="../html/img/'+work.data[key][i].WorkType+'.png" alt='+work.data[key][i].WorkType+'> \
                                               </div> \
                                               <div class="cBody"> \
                                                   <h1>'+cfg['PV']+':</h1> \
                                                   <p>'+cfg['VC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+work.data[key][i].Payout+'</span>  '+' $ a '+work.data[key][i].companyTake+' $</p> \
                                                   <ul class='+i+key+'></ul> \
                                               </div> \
                                               <div class="cFooter"> \
                                               <h2>'+cfg['WC']+'</h2> \
                                               </div> \
                                               </div> \
                                           </div>');
                itemList(key, i)
            }
        }
    });
}


function payout (){
    var pref2 = work.data[work.currentWork.key][work.currentWork.uuid]
    fuelCost = cfg['fuelCost']
    companyTakeNumber = cfg['companyTakeNumber']

    if (pref2.startFuel < pref2.endFuel){
        fuel = ( pref2.startFuel - pref2.endFuel * -1 )
    } else {
        fuel = pref2.startFuel - pref2.endFuel
    }

    companyTake = (work.currentWork.cost - (fuel * fuelCost)) / 100 * companyTakeNumber
    countPayout = (work.currentWork.cost - (fuel * fuelCost)  -  companyTake)
    payout = countPayout.toFixed(0)
    if (pref2.Steam == identifier){
        document.getElementById("content").innerHTML = '<div class="basket"> \
                                       <div class="Header"> \
                                           <img class='+work.currentWork.key+' src="../html/img/'+work.currentWork.key+'.png" alt='+work.currentWork.key+'> \
                                           <img class="box" src="../html/img/box.png" alt="box"> \
                                           <img class='+pref2.WorkType+' src="../html/img/'+pref2.WorkType+'.png" alt='+pref2.WorkType+'> \
                                       </div> \
                                       <div class="Body"> \
                                           <h1>'+cfg['PV']+':</h1> \
                                           <p>'+cfg['CC']+':'+' '+'<span style="color:red;font-size:15px;font-weight: bold;">'+payout+'</span>  '+' $</p> \
                                           <ul class='+work.currentWork.uuid+work.currentWork.key+'></ul> \
                                       </div> \
                                       <div class="Footer"> \
                                           <button key='+work.currentWork.key+' uuid='+work.currentWork.uuid+' workR='+pref2.WorkRoute+' id="button" cost='+work.currentWork.cost+' class="button button1" onclick="pay()" >'+cfg['A']+'</button> \
                                           <button id="button2" class="button button1" onclick="open()" >'+cfg['N']+'</button> \
                                       </div> \
                                       </div>';
        document.getElementById("button").onclick = function() {pay(this.getAttribute('key'), this.getAttribute('uuid'), payout, companyTake, company)};
        document.getElementById("button2").onclick = function() {open()};
        $('.'+work.currentWork.uuid+work.currentWork.key).append('<li>'+cfg['V']+': <span style="color:red;font-size:15px;">'+ pref2.Distance + ' ' + 'm</span></li>')
        $('.'+work.currentWork.uuid+work.currentWork.key).append('<li>'+ fuelCost + ' $' + ' * <span style="color:red;font-size:15px;">'+ fuel.toFixed(2) + ' ' + 'l</span></li>')
        $('.'+work.currentWork.uuid+work.currentWork.key).append('<li>'+cfg['FC']+': <span style="color:red;font-size:15px;">'+ companyTake.toFixed(0) + ' ' + ' $</span></li>')
        itemList(work.currentWork.key, work.currentWork.uuid)
    } else {
        open()
    }
}

function pay(key, uuid, payout, companyTake, company){
    if (payout != null && work.data[key][uuid].WorkRDone == true){
        $.post(pref + 'payout', JSON.stringify({key, uuid, payout, companyTake, company}));
    }
}

function submit(key, uuid, cost, workR) {
    if (work.data[key][uuid].WorkRDone == true){
        $.post(pref + 'payout', JSON.stringify({alreadyInWork, key, uuid, cost, workR, company}));
    } else {
        if (alreadyInWork == false){
            $.post(pref + 'submit', JSON.stringify({alreadyInWork, key, uuid, cost, workR, company}));
        } else {
            $.post(pref + 'submit', JSON.stringify({alreadyInWork}));
        }
    }
}

function itemList(key, i) {
    for (y = 0; y < work.data[key][i].ItemList.length; y++) {
        $('.'+i+key).append('<li><span style="color:red;font-size:15px;">'+ work.data[key][i].ItemList[y][2] + 'x</span>'+ ' ' + work.data[key][i].ItemList[y][1] + '  za '+ work.data[key][i].ItemList[y][3] +'$</li>')
    }
}

function count(key, i) {
    countS = 0
    for (c = 0; c < work.data[key][i].ItemList.length; c++) {
        number = work.data[key][i].ItemList[c][2]
        itemCost = work.data[key][i].ItemList[c][3]
        countS = (countS + (number * itemCost))
    }
    return countS
}