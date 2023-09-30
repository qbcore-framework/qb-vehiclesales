var vehicleName = ''
var percentage = 0;

window.addEventListener('message', function(event) {
  switch (event.data.action) {
    case 'sellVehicle':
      percentage = event.data.percentage;
      $("#vehicle_name").html(event.data.vehicleModel.toUpperCase());
      $("#player_name_sell").html(event.data.firstname + ' ' + event.data.lastname); 
      $("#vehicle_plate").html(event.data.plate); 
      $("#seller_iban").html(event.data.account); 
      $("#seller_phone").html(event.data.phone); 
      vehicleName = event.data.vehicleName;
      $(".sell-card").fadeIn();
      
    break;

    case 'CloseSellUI':
      $(".sell-card").fadeOut();
      $(".buy-card").fadeOut();

      setTimeout(function() {
        $("#player_name_sell, #vehicle_name, #vehicle_plate, #seller_iban, #seller_phone, #vehicle_description, #vehicle_price").val(''); 
        $("#price_with_vat").html('$0');
      }, 400);
      break;

    case 'buyVehicle':
      $("#player_name_buy").html(event.data.firstname_seller + ' ' + event.data.lastname_seller); 
      $("#vehicle_name_buy").html(event.data.vehicle_name);
      $("#vehicle_plate_buy").html(event.data.plate_seller); 
      $("#seller_iban_buy").html(event.data.account_seller); 
      $("#seller_phone_buy").html(event.data.phone_seller); 
      $("#vehicle_description_buy").html(event.data.desc_seller);
      $("#vehicle_price_buy").html('$' + event.data.price_seller);
      var isOwner = event.data.isOwner;
      var priceWithoutVat = event.data.price_seller;
      var priceWithVat = priceWithoutVat * percentage;
      $("#vehicle_price_vat_buy").html('$' + priceWithVat.toFixed(0));
      $("#buy_vehicle_buttons").html(``);
      if (isOwner) {
        $("#buy_vehicle_buttons").html(`                
        <button id="retrive_vehicle" class="content-button">Retrieve Vehicle</button>
        <button id="close-menus" class="content-button close-button">Close Menu</button>`);
      } else {
        $("#buy_vehicle_buttons").html(` 
        <button id="buy_vehicle" class="content-button">Buy Vehicle</button>               
        <button id="close-menus" class="content-button close-button">Close Menu</button>`);
      }
      $(".buy-card").fadeIn();
    }

});


$(document).on('click', '#close-menus', function() {
  $(".buy-card, .sell-card").fadeOut();
  $.post('https://qb-vehiclesales/action', JSON.stringify({
    action: "close",
}));
});

$(document).on('click', '#buy_vehicle', function() {
  $.post('https://qb-vehiclesales/action', JSON.stringify({
      action: 'buyVehicle',
  }));
})

$(document).on('click', '#retrive_vehicle', function() {
  $.post('https://qb-vehiclesales/action', JSON.stringify({
      action: 'takeVehicleBack',
  }));
})

$(document).on('click', '#send_vehicle_info', function() {
  var vehicle_price = $('#vehicle_price').val();
  var vehicle_description = $('#vehicle_description').val();
  $.post('https://qb-vehiclesales/action', JSON.stringify({
      action: 'sellVehicle',
      vehiclePrice: vehicle_price,
      vehicleInfo: vehicle_description,
      vehicleName: vehicleName,
      vehiclePriceWithVAT: vehicle_price * percentage,
  }));
})

$(document).ready(function() {
document.onkeyup = function(data) {
    if (data.which == 27) {
      $(".buy-card, .sell-card").fadeOut();
      $.post('https://qb-vehiclesales/action', JSON.stringify({
        action: "close",
    }));
    }
};
});

$(document).ready(function() {
  $('#vehicle_price').on('input', function() {
    var priceWithoutVat = parseFloat($(this).val());
    var priceWithVat = priceWithoutVat / percentage;
    if (isNaN(priceWithVat)) {
      $('#price_with_vat').text('$0');
      return;
    }
    $('#price_with_vat').text('$' + priceWithVat.toFixed(0));
  });
});