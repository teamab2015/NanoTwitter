PNotify.prototype.options.delay = 3000;
PNotify.prototype.options.styling = "bootstrap3";

var notify = (function() {
    var custom_stack = {"dir1": "down", "dir2": "left", "firstpos1": 70, "firstpos2": 25, "push": "top"};
    return function(type, title, text) {
        new PNotify({
            type: type || "info",
            title: title || "",
            text: text || "",
            animate_speed: 'fast',
            stack: custom_stack
        });
    };
}());
