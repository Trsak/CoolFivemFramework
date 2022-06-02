// Gesture
;(function ($) {
    var GesturePasswd= function (element, options) {
        this.$element	= $(element);
        this.options	= options;
        var that=this;
        this.pr=options.pointRadii;
        this.rr=options.roundRadii;
        this.o=options.space;
        this.color=options.color;
        //全局样式
        this.$element.css({
            "position":"relation",
            "width":this.options.width,
            "height":this.options.height,
            "background-color":options.backgroundColor,
            "overflow":"hidden",
            "cursor":"default"
        });


        //选择器规范
        if(! $(element).attr("id"))
            $(element).attr("id",(Math.random()*65535).toString());
        this.id="#"+$(element).attr("id");

        var Point = function (x,y){
            this.x  =x;this.y=y
        };

        this.result="";
        this.pList=[];
        this.sList=[];
        this.tP=new Point(0,0);

        this.$element.append('<canvas class="main-c" width="'+options.width+'" height="'+options.height+'" >');
        //this.$element.append('<canvas class="main-p" width="'+options.width+'" height="'+options.height+'" >');
        this.$c= $(this.id+" .main-c")[0];
        this.$ctx=this.$c.getContext('2d');

        this.initDraw=function(){
            this.$ctx.strokeStyle=this.color;
            this.$ctx.lineWidth=2;
            for(var j=0; j<3;j++ ){
                for(var i =0;i<3;i++){
                    this.$ctx.moveTo(this.o/2+this.rr*2+i*(this.o+2*this.rr),this.o/2+this.rr+j*(this.o+2*this.rr));
                    this.$ctx.arc(this.o/2+this.rr+i*(this.o+2*this.rr),this.o/2+this.rr+j*(this.o+2*this.rr),this.rr,0,2*Math.PI);
                    var tem=new Point(this.o/2+this.rr+i*(this.o+2*this.rr),this.o/2+this.rr+j*(this.o+2*this.rr));
                    if (that.pList.length < 9)
                        this.pList.push(tem);
                }
            }
            this.$ctx.stroke();
            this.initImg=this.$ctx.getImageData(0,0,this.options.width,this.options.height);
        };
        this.initDraw();
        //this.$ctx.stroke();
        this.isIn=function(x,y){

            for (var p in that.pList){
                //console.log(that.pList[p][x]);
                //  console.log(( Math.pow((x-that.pList[p][x]),2)+Math.pow((y-that.pList[p][y]),2)));
                if(( Math.pow((x-that.pList[p]["x"]),2)+Math.pow((y-that.pList[p]["y"]),2) ) < Math.pow(this.rr,2)){
                    return that.pList[p];
                }
            }
            return 0;
        };

        this.pointDraw =function(c){
            if (arguments.length>0){
                that.$ctx.strokeStyle=c;
                that.$ctx.fillStyle=c;
            }
            for (var p in that.sList){
                that.$ctx.moveTo(that.sList[p]["x"]+that.pr,that.sList[p]["y"]);
                that.$ctx.arc(that.sList[p]["x"],that.sList[p]["y"],that.pr,0,2*Math.PI);
                that.$ctx.fill();
            }
        };
        this.lineDraw=function (c){
            if (arguments.length>0){
                that.$ctx.strokeStyle=c;
                that.$ctx.fillStyle=c;
            }
            if(that.sList.length > 0){
                for( var p in that.sList){
                    if(p == 0){
                        //console.log(that.sList[p]["x"],that.sList[p]["y"]);
                        that.$ctx.moveTo(that.sList[p]["x"],that.sList[p]["y"]);
                        continue;
                    }
                    that.$ctx.lineTo(that.sList[p]["x"],that.sList[p]["y"]);
                    //console.log(that.sList[p]["x"],that.sList[p]["y"]);
                }

            }
        };

        this.allDraw =function(c){
            if (arguments.length>0){
                this.pointDraw(c);
                this.lineDraw(c);
                that.$ctx.stroke();
            }
            else {
                this.pointDraw();
                this.lineDraw();
            }

        };

        this.draw=function(x,y){
            that.$ctx.clearRect(0,0,that.options.width,that.options.height);
            that.$ctx.beginPath();
            //that.initDraw();
            that.$ctx.putImageData(this.initImg,0,0);
            that.$ctx.lineWidth=4;
            that.pointDraw(that.options.lineColor);
            that.lineDraw(that.options.lineColor);
            that.$ctx.lineTo(x,y);
            that.$ctx.stroke();
        };

        this.pointInList=function(poi,list){
            for (var p in list){
                if( poi["x"] == list[p]["x"] && poi["y"] == list[p]["y"]){
                    return ++p;
                }
            }
            return false;
        };

        this.touched=false;
        $(this.id).on ("mousedown touchstart",{that:that},function(e){
            e.data.that.touched=true;
        });
        $(this.id).on ("mouseup touchend",{that:that},function(e){
            e.data.that.touched=false;
            that.$ctx.clearRect(0,0,that.options.width,that.options.height);
            that.$ctx.beginPath();
            that.$ctx.putImageData(e.data.that.initImg,0,0);
            that.allDraw(that.options.lineColor);
            // that.$ctx.stroke();
            for(var p in that.sList){
                if(e.data.that.pointInList(that.sList[p], e.data.that.pList)){
                    e.data.that.result= e.data.that.result+(e.data.that.pointInList(that.sList[p], e.data.that.pList)).toString();
                }
            }
            $(element).trigger("hasPasswd",that.result);
        });

        //
        $(this.id).on('touchmove mousemove',{that:that}, function(e) {
            if(e.data.that.touched){
                var x= e.pageX || e.originalEvent.targetTouches[0].pageX ;
                var y = e.pageY || e.originalEvent.targetTouches[0].pageY;
                x=x-that.$element.offset().left;
                y=y-that.$element.offset().top;
                var p = e.data.that.isIn(x, y);
                //console.log(x)
                if(p != 0 ){
                    if ( !e.data.that.pointInList(p,e.data.that.sList)){
                        e.data.that.sList.push(p);
                    }
                }
                //console.log( e.data.that.sList);
                e.data.that.draw(x, y);
            }

        });

        $(this.id).on('passwdWrong',{that:that}, function(e) {
            that.$ctx.clearRect(0,0,that.options.width,that.options.height);
            that.$ctx.beginPath();
            that.$ctx.putImageData(that.initImg,0,0);
            that.allDraw("#cc1c21");
            that.result="";
            that.pList=[];
            that.sList=[];
            setTimeout(function(){
                that.$ctx.clearRect(0,0,that.options.width,that.options.height);
                that.$ctx.beginPath();
                that.initDraw()
            },500)

        });


        $(this.id).on('passwdRight',{that:that}, function(e) {
            that.$ctx.clearRect(0,0,that.options.width,that.options.height);
            that.$ctx.beginPath();
            that.$ctx.putImageData(that.initImg,0,0);
            that.allDraw("#00a254");
            that.result="";
            that.pList=[];
            that.sList=[];
            setTimeout(function(){
                that.$ctx.clearRect(0,0,that.options.width,that.options.height);
                that.$ctx.beginPath();
                that.initDraw()
            },500)
        });

        $(this.id).on('passwdClear',{that:that}, function(e) {
            setTimeout(function(){
                that.$ctx.clearRect(0,0,that.options.width,that.options.height);
                that.$ctx.beginPath();
                that.initDraw()
            },500)
        });


    };

    GesturePasswd.DEFAULTS = {
        zindex :100,
        roundRadii:25,
        pointRadii:6,
        space:30,
        width:240,
        height:240,
        lineColor:"#00aec7",
        backgroundColor:"#252736",
        color:"#FFFFFF"
    };

    function Plugin(option,arg) {
        return this.each(function () {
            var $this   = $(this);
            var options = $.extend({}, GesturePasswd.DEFAULTS, typeof option == 'object' && option);
            var data    = $this.data('GesturePasswd');
            var action  = typeof option == 'string' ? option : NaN;
            if (!data) $this.data('danmu', (data = new GesturePasswd(this, options)));
            if (action)	data[action](arg);
        })
    }


    $.fn.GesturePasswd             = Plugin;
    $.fn.GesturePasswd.Constructor = GesturePasswd;
})(jQuery);

// Fingerprint

var wrap = $('.wrap');
var clone = $('.clone');
var successIcon = $('.success');
var fingerprintSetup = $('.fingerprintSetup');
var fingerPrintSetup = false;

var finishedDrawing = function() {
    var drawStatus = animation.getStatus();
    if (drawStatus === "end") {
        fingerPrintSetup = true;
        successIcon.addClass('active');
    } else {
        fingerPrintSetup = false;
        successIcon.removeClass('active');
    }
};

var options = {
    duration: 80,
    type: 'scenario',
    animTimingFunction: Vivus.EASE_OUT
};

var animation = new Vivus('fingerprintSetup', options, finishedDrawing);
animation.stop();

// ugh, I'm sorry
fingerprintSetup.hover(function() {
    clone.addClass('hover')
}, function() {
    clone.removeClass('hover');
})

wrap.on('mousedown', function() {
    if (!fingerPrintSetup) {
        $.post('https://phone/FingerprintScan', JSON.stringify({}), function(callback) {
            if (callback) {
                clone.addClass('active');
                animation.play(1);
            }
        })
    }
});

wrap.on('mouseup', function() {
    clone.removeClass('active');
    if (!fingerPrintSetup) {
        animation.play(-1);
    } else {
        animation.stop();
    }
})

QB.Phone.Functions.getFingerSetup = function() {
    return fingerPrintSetup
}

QB.Phone.Functions.resetFingerSetup = function() {
    animation.reset();
}


// FACEID

var scan = document.querySelector('.face-id-wrapper')
var faceIDStatus = false;

$(document).on('click', '.btn-trigger', function(e){
    e.preventDefault();
    QB.Phone.Functions.animateScan()
});

$(document).on('animationend', '.face-id-wrapper', function(e){
    e.preventDefault();
    QB.Phone.Functions.FaceIDScan()
});

QB.Phone.Functions.animateScan = function() {
    faceIDStatus = false;
    scan.classList.remove('scan-success');
    scan.classList.remove('scan-error');
    scan.classList.add('animate-scan');
}

QB.Phone.Functions.FaceIDReset = function() {
    faceIDStatus = false;
    scan.classList.remove('scan-success');
    scan.classList.remove('scan-error');
}

QB.Phone.Functions.FaceIDStatus = function() {
    return faceIDStatus
}

QB.Phone.Functions.FaceIDScan = function() {
    scan.classList.remove('animate-scan');
    var num = Math.floor(Math.random() * (50 - 10) + 10);
    $.post('https://phone/FaceIDScan', JSON.stringify({}), function(callback){
        if (callback) {
            if (num % 2 === 0 ) {
                faceIDStatus = true;
                scan.classList.add('scan-success');
            } else {
                scan.classList.add('scan-error');
            }
        } else {
            scan.classList.add('scan-error');
            QB.Phone.Notifications.Add("fas fa-feather-alt", "Error", "Face is covered!", "#ff0000", 1000);
        }
    })
}


// Lock Screen
$(document).on('click', '.phone-lock', function(e){
    e.preventDefault();
    if (QB.Phone.Settings.Security.type === "none" || !QB.Phone.Settings.Security.primary) {
        QB.Phone.Functions.UnLockScreen()
    }
});

QB.Phone.Functions.UnLockScreen = function() {
    $.post('https://phone/UnlockMobile')
    QB.Phone.Animations.TopSlideUp('.phone-lock', 400, -160);
}

// PIN

var PinLenght = 4
var PWLength = 4

QB.Phone.Functions.LockScreen = function() {
    lockScreen = $(".lock-open");
    $(lockScreen).html('<i class="fas fa-lock-open"></i>')
    QB.Phone.Animations.TopSlideDown('.phone-lock', 0, 0);
    if (QB.Phone.Settings.Security.type !== "none" && QB.Phone.Settings.Security.primary){
        $(lockScreen).html('<i class="fas fa-lock"></i>')
        $.each(QB.Phone.Settings.Security.type, function(name, password) {
            if (name === QB.Phone.Settings.Security.primary) {
                $("." + name + "").show()
                if (name === "PIN") {
                    PinLenght = QB.Phone.Settings.Security.type.PIN.length
                    var inputBoxes = $(".inputBoxes");
                    $(inputBoxes).html("")
                    // Generates the boxes
                    for(var i = 1; i < PinLenght + 1; i++){
                        inputBoxes.append("<input class='input-PIN' type='password' maxlength=1 id='" + i + "' />");
                    }
                } else if (name === "GESTURE") {
                    $("#GESTURE-BOX").GesturePasswd({
                        backgroundColor: "transparent",  //背景色
                        color: "black",   //主要的控件颜色
                        roundRadii: 15,    //大圆点的半径
                        pointRadii: 12, //大圆点被选中时显示的圆心的半径
                        space: 35,  //大圆点之间的间隙
                        width: 250,   //整个组件的宽度
                        height: 250,  //整个组件的高度
                        lineColor: "grey",   //用户划出线条的颜色
                        zindex: 200  //整个组件的css z-index属性
                    });
                } else if (name === "FINGERPRINT") {
                    FINGERPRINT_animation.reset();
                    fingerPrintSuccessIcon.removeClass('active');
                    fingerPrintErrorIcon.removeClass('active');
                } else if (name === "FACEID") {
                    $.post('https://phone/FaceIDScan', JSON.stringify({}), function(callback){
                        if (callback) {
                            if (QB.Phone.Settings.Security.type.FACEID === QB.Phone.Data.PlayerData.charid) {
                                QB.Phone.Functions.UnLockScreen()
                            } else {
                                $("#FACEID").html("<i class=\"fas fa-meh-blank\"></i>")
                            }
                        } else {
                            $("#FACEID").html("<i class=\"fas fa-head-side-mask\"></i>")
                        }
                    })
                }
            } else {
                $("." + name + "").hide()
            }
        })
    }
}

$(document).on('click', '.phone-PIN-key', function(e){
    e.preventDefault();
    var PressedButton = $(this).data('keypadvalue');
    PinLenght = QB.Phone.Settings.Security.type.PIN.length
    if (!isNaN(PressedButton)) {
        for(var i = 1; i < PinLenght + 1; i++){
            if (!$('#'+i+'').val()) {
                $("#"+i+"").val(PressedButton).css({"background-color": "rgba(255, 255, 255, 0.50)", "color": "rgba(255, 255, 255, 0)"});
                break
            }
        }
        if ($("#"+PinLenght+"").val()) {
            donePin()
        }
    } else if (PressedButton === "dellAll") {
        deleteAll()
    } else if (PressedButton === "dell") {
        for(var id = 1; id < PinLenght + 1; id++){
            if ($('#'+id+'').val()) {
                $('#'+id+'').val('').css({"background-color": "transparent", "color": "rgba(255, 255, 255, 0)"});
            }
        }
    }
});

deleteAll = function() {
    for(var i = 1; i < PinLenght + 1; i++){
        $("#"+i+"").val('').css({"background-color": "transparent", "color": "rgba(255, 255, 255, 0)"});
    }
}

donePin = function() {
    var PIN = "";
    for(var i = 1; i < PinLenght + 1; i++){
        PIN += $("#"+i+"").val()
    }
    if (Number.isInteger(parseInt(PIN))) {
        if (PIN === QB.Phone.Settings.Security.type.PIN) {
            QB.Phone.Functions.UnLockScreen()
        } else {
            $(".input-PIN").css({"background-color": "red", "color": "rgba(255, 255, 255, 0)"})
            setTimeout(function(){
                deleteAll()
            }, 600)
        }
    }
}


// PW

$("#PW-INPUT").keyup(function(){
    PWLength = QB.Phone.Settings.Security.type.PW.length;
    lala = (PWLength - $(this).val().length);
    if (lala === 0){
        document.getElementById("PW-INPUT").readOnly = true;
        if ($(this).val() === QB.Phone.Settings.Security.type.PW ) {
            QB.Phone.Functions.UnLockScreen();
            document.getElementById("PW-INPUT").readOnly = false;
            $("#PW-INPUT").val("");
        } else {
            $(this).css({"color": "red"});
            setTimeout(function(){
                $(this).css({"color": "black"});
                document.getElementById("PW-INPUT").readOnly = false;
                $("#PW-INPUT").val("");
            }, 200)
        }
    }
});

// Gesture

$("#GESTURE-BOX").on("hasPasswd",function(e,passwd){
    if (passwd === QB.Phone.Settings.Security.type.GESTURE) {
        $("#GESTURE-BOX").trigger("passwdRight");
        QB.Phone.Functions.UnLockScreen();
    } else {
        $("#GESTURE-BOX").trigger("passwdWrong");
    }
});

// Fingerprint

var fingerPrint = $('.FINGERPRINT-wrap');
var fingerPrintClone = $('.FINGERPRINT-clone');
var fingerPrintSuccessIcon = $('.FINGERPRINT-success');
var fingerPrintErrorIcon = $('.FINGERPRINT-error');
var FingerPrintSetup = $('.FINGERPRINTSetup');
var FingerPrintDone = false;

var FINGERPRINT_finishedDrawing = function() {
    var drawStatus = FINGERPRINT_animation.getStatus();
    if (drawStatus === "end") {
        FingerPrintDone = true;
        fingerPrintSuccessIcon.addClass('active');
        if (QB.Phone.Settings.Security.type.FINGERPRINT === QB.Phone.Data.PlayerData.charid) {
            QB.Phone.Functions.UnLockScreen();
            FingerPrintDone = false
            fingerPrintSuccessIcon.removeClass('active');
            fingerPrintErrorIcon.removeClass('active');
            fingerPrintClone.removeClass('active');
        } else {
            fingerPrintErrorIcon.addClass('active');
        }
    } else {
        fingerPrintSuccessIcon.removeClass('active');
        fingerPrintErrorIcon.removeClass('active');
    }
};

var FINGERPRINT_options = {
    duration: 80,
    type: 'scenario',
    animTimingFunction: Vivus.EASE_OUT
};

var FINGERPRINT_animation = new Vivus('FINGERPRINTSetup', FINGERPRINT_options, FINGERPRINT_finishedDrawing);
FINGERPRINT_animation.stop();

// ugh, I'm sorry
FingerPrintSetup.hover(function() {
    fingerPrintClone.addClass('hover')
}, function() {
    fingerPrintClone.removeClass('hover');
})

fingerPrint.on('mousedown', function() {
    $.post('https://phone/FingerprintScan', JSON.stringify({}), function(callback) {
        if (callback) {
            fingerPrintClone.addClass('active');
            FINGERPRINT_animation.play(1);
        }
    })
});

fingerPrint.on('mouseup', function() {
    fingerPrintClone.removeClass('active');
    if (!FingerPrintDone) {
        FINGERPRINT_animation.play(-1);
    } else {
        FINGERPRINT_animation.stop();
    }

})