document.addEventListener("DOMContentLoaded", function() {
  var flatAddress = document.getElementById('query_address');

  if (flatAddress) {
    var autocomplete = new google.maps.places.Autocomplete(flatAddress, { types: ['geocode'] });
  }
});
