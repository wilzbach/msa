// simple function
define(["cs!util"], function (util) {
    //Do setup work here

    return {
        color: "black",
        size: "unisize",
        testCoffee: function(text){
         return  util.toDom(text);
        }
    }
});

