window.addEventListener('message', (event) => {
    var config = JSON.parse(Config);
    var cfg = config[0];
    var cBT = document.getElementsByClassName("close")[0];
    var pref = 'https://insurance/';
    var data = event.data;

    console.log(data.action)

    if (data.action == "open"){
        open()
    };

    if (data.action == "close"){
        close()
    };

    cBT.onclick = function(){
      $.post(pref + 'close', JSON.stringify({}));
     };

    function close(){
        $("body").hide();

    };

    function open(){
        $("body").show();

    };
});