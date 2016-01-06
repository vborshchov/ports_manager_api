$(function(){
  var $ports_customer_input = $('#port_customer_id_field .filtering-select input:text')
  $('#port_reserved').prop('disabled', true);

  $('.ui-menu').on('click', function() {
    if( $ports_customer_input.val() ) {
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