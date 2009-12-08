var myself = {

  // An Introduction:
  sayHi : function(name) {
    console.log("hello, " + name);
  }

};
var mandelay = {
  name : function() { return this.constructor.prototype; }
};

myself.sayHi(mandelay.name());