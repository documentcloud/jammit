var myself={sayHi:function(a){console.log("hello, "+a)}},mandelay={name:function(){return this.constructor.prototype}};myself.sayHi(mandelay.name());