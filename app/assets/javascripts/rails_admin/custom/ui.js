//= require_tree .

$(document).on('ready', function(){
  // Pusher.log = function(message) {
  //    if (window.console && window.console.log) {
  //      window.console.log(message);
  //    }
  //  };

  var pusher = new Pusher('0bb4888942c37f010824');

  var channel = pusher.subscribe('ports_updater');
  $.notify.defaults({
    className: "info",
    position: "bottom left",
    autoHide: false
  });
  channel.bind('report', function(data) {
    $.notify(data['notification_text']);
  });
})

$(document).on('rails_admin.dom_ready', function(){

  $('#port_comment_ids_field .ra-multiselect').hide();

  var $ports_customer_input = $('#port_customer_id_field .filtering-select input:text')
  $('#port_reserved').on('click', function() {
    var $it = $(this)
    if ($it.prop('checked')) {
      $it.prop('checked', false);
    } else {
      $it.prop('checked', true);
    };
  });

  $('.ui-menu').on('click', function() {
    if( $ports_customer_input.val() ) {
      customer = $ports_customer_input.val();
      $('#port_reserved').prop('checked', true);
    }
   });

  $ports_customer_input.blur(function() {
    if( $(this).val().length === 0 ) {
      $('#port_reserved').prop('checked', false);
    } else {
      $('#port_reserved').prop('checked', true);
    };
  });

});