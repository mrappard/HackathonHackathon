/*globals $, SimpleStorage, document*/

var addToLog = function(id, txt) {
  $(id + " .logs").append("<br>" + txt);
};

// ===========================
// Blockchain example
// ===========================
$(document).ready(function() {

  $("#blockchain button.set").click(function() {
    var value = parseInt($("#blockchain input.text").val(), 10);
    SimpleStorage.set(value);
    addToLog("#blockchain", "SimpleStorage.set(" + value + ")");
  });

  $("#blockchain button.get").click(function() {
    SimpleStorage.get().then(function(value) {
      $("#blockchain .value").html(value.toNumber());
    });
    addToLog("#blockchain", "SimpleStorage.get()");
  });





});
