let firstOpen = false;
let headlights = false
window.addEventListener("message", (event) =>{
    let item = event.data;
    if (item.type == "ui") {
        if (item.status === true) {
            for (name in item.colors){
                if (firstOpen == false){
                    createButton(name, item.colors[name])
                }
            }
            changeContainerBackground(item.currentVehColor)
            display(true)
            firstOpen = true
        } else {
            display(false)
        }
    }
    function display(bool){
        if (bool) {
            $("body").show();
            //$("#container").show();
        } else{
            $("body").hide();
            //$("#container").hide();
        }
    }
    function createButton(name, color){
        let btn = document.createElement("button");
        let bcgroundColor = color["rgb"][0] + ", " + color["rgb"][1] + ", " + color["rgb"][2]
        btn.classList.add("name");
        btn.style.background = "rgb(" + bcgroundColor + ")"
        btn.addEventListener("click", function () {
            changeContainerBackground(bcgroundColor)
            $.post('https://neon/neon', JSON.stringify({color, headlights}));
        });
        document.getElementById("buttons").appendChild(btn);
    }
    
    function changeContainerBackground(color) {
        document.getElementById("container").style.borderColor = "rgb(" + color + ")";
    }

    if (firstOpen) {
        document.getElementById('close').onclick = function(){
            $.post('https://neon/exit', JSON.stringify({}));
            display(false)
            headlights = false
        };
        
        document.getElementById('rgb').onclick = function(){
            rgb = []
            rgb[0] = Math.floor(Math.random() * 255) + 1;
            rgb[1] = Math.floor(Math.random() * 255) + 1;
            rgb[2] = Math.floor(Math.random() * 255) + 1;
            color = {rgb}
            changeContainerBackground(rgb[0] + ", " + rgb[1] + ", " + rgb[2])
            $.post('https://neon/neon', JSON.stringify({color, headlights}));
        };
        document.getElementById('on').onclick = function(){
            $.post('https://neon/toggleNeon', JSON.stringify({}));
        };

        document.getElementById('lights').onclick = function(){
            if (headlights == false){
                headlights = true
                this.style.color = "rgb(255, 239, 3)";

            } else {
                headlights = false
                this.style.color = "rgb(255, 255, 255)";
            }
        };

    }
})



    

