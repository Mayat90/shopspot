document.addEventListener('DOMContentLoaded', () => {
  let polya = [];
  let markers = [];
  let loaded = false;
  let map = null;
  let mapDomElement = document.getElementById('map');
  let zoom = null;
  let radiusCatchment = null;
  let radiusSearch = null;
  let search = {};
  let places = {};
  let bounds = null;
  let competitors_place = {};
  let competitors_all = {};
  let points = [];
  let lat = null;
  // let lng = null;
  let heatmap = null;
  let heatmaps = {};
  const search_icon = 'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png';
  let concurrence_icon = 'http://maps.gstatic.com/mapfiles/ms2/micons/red.png';

  if (mapDomElement) {
// concurrence_icon = mapDomElement.getAttribute('data-icon-market');

    zoom = parseInt(mapDomElement.getAttribute('data-zoom'));
    radiusCatchment = parseInt(mapDomElement.getAttribute('data-radius'));
    radiusSearch = parseInt(mapDomElement.getAttribute('data-radiussearch'));

    search = {
      lat: parseFloat(mapDomElement.getAttribute('data-lat')),
      lng: parseFloat(mapDomElement.getAttribute('data-long'))
    };

    initMap();


    google.maps.event.addListener(map, "rightclick", function(event) {
        var lat = event.latLng.lat();
        var lng = event.latLng.lng();
        // populate yor box/field with lat, lng
           url =`https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&sensor=true&key=AIzaSyD-TW_-Rxwg7XpL2JaS2FFJZRrle3qP9IA`;
        console.log(url)
        fetch(url)
          .then((response) => response.json())
          .then((results) => {
            if (results["status"] == "OK" ) {

              address = results["results"][0]["formatted_address"];

              element = document.querySelector('.rcframe');
              activity = element.getAttribute('data-activity');
              radiusSearch = parseInt(element.getAttribute('data-radiussearch'));
              radiusCatchment = parseInt(element.getAttribute('data-radius_catchment_area'));

              document.getElementById('query_address').value = address;
              select = document.getElementById('query_activity');
 select.value=activity;
console.log(select.value)
              document.getElementById('query_radius_search').value = radiusSearch;
              document.getElementById('query_radius_catchment_area').value = radiusCatchment;
              document.getElementById('formid').submit();
            }

          });
    });

    bounds = new google.maps.LatLngBounds();
    const rescard = document.querySelectorAll('.rcframe');
    rescard.forEach(function(element) { affichecard(element) });
    map.fitBounds(bounds);
    afficheheatmap();

    document.getElementById('infos-button').addEventListener('click', ()=>{
      document.getElementById('show-content').classList.remove("infohide");
        polya.forEach((poly) => {
          poly.setOptions({clickable: true });
        });
    })
    google.maps.event.addListener(map, 'bounds_changed', function() {
      addpopulation();
    });

    document.getElementById('infos-close').addEventListener('click', ()=>{
      document.getElementById('show-content').classList.add("infohide");
        polya.forEach((poly) => {
          poly.setOptions({clickable: false });
        });
    })

    loaded = true;
    // function openinf() {
    //   document.getElementById('show-content').classList.remove("infohide");
    //     polya.forEach((poly) => {
    //       poly.setOptions({clickable: true });
    //     });
    // }infos-close

    // function closeinf() {
    //   document.getElementById('show-content').classList.add("infohide");
    //       polya.forEach((poly) => {
    //       poly.setOptions({clickable: false });
    //     });
    // }
  }

  function reloadcompetitors() {
    points = []
    markers.forEach((marker) => { marker.setMap(null); });
    heatmap.setMap(null);
    heatmap = null;
    markers = [];
    competitors_place = {};
    bounds = new google.maps.LatLngBounds();
    const rescard = document.querySelectorAll('.rcframe');
    rescard.forEach(function(element) { check(element) });
    afficheheatmap();
    map.fitBounds(bounds);
  }


  function check(element) {
    if (element.querySelector('.fa-eye-slash').classList.contains('infohide')) {
      const json = JSON.parse(element.getAttribute('data-competitors'));
      json.forEach(function(competitor) { affichecompetitors(competitor) });

    }
  }

  function affichecard(element) {
    // radiusCatchment = parseInt(element.getAttribute('data-radius_catchment_area'));
    radiusSearch = parseInt(element.getAttribute('data-radiussearch'));
    radiusCatchment = parseInt(element.getAttribute('data-radius_catchment_area'));
    let title = element.getAttribute('data-title');
    let id = element.getAttribute('data-id');
    lat = parseFloat(element.getAttribute('data-lat'));
    const search_icon = element.getAttribute('data-icon');
    search = {
      lat: parseFloat(element.getAttribute('data-lat')),
      lng: parseFloat(element.getAttribute('data-lng'))
    };
    var marker = new google.maps.Marker({
      position: search,
      icon: search_icon,
      animation: google.maps.Animation.DROP,
      title: title,
      map: map,
      zIndex: 9999
    });
    var searchcircle = new google.maps.Circle({
      strokeColor: '#0f5',
      strokeOpacity: 0.5,
      strokeWeight: 4,
      fillColor: '#FF0000',
      fillOpacity: 0,
      map: map,
      clickable: false,
      center: search,
      radius: radiusCatchment
    });
    var catchcircle = new google.maps.Circle({
      strokeColor: '#05F',
      strokeOpacity: 0.2,
      strokeWeight: 4,
      fillColor: '#FFFF00',
      fillOpacity: 0,
      clickable: false,
      map: map,
      center: search,
      radius: radiusSearch
    });
    places[id] = [marker, searchcircle, catchcircle];
    bounds.extend( marker.getPosition() );
    // points = []
    const json = JSON.parse(element.getAttribute('data-competitors'));
    json.forEach(function(competitor) {
      affichecompetitors(competitor);
      // points.push(new google.maps.LatLng(competitor["lat"], competitor["lng"]))
    });
    //     afficheheatmap()
    // heatmaps[id] = heatmap

  }

  function metersPerPixel(map) {
    a= (Math.cos(lat * Math.PI/180) * 2 * Math.PI * 6378137 / (256 * Math.pow(2, map.getZoom())));
    return a
  }

  function changeRadius(radius) {
    heatmap.set('radius', radius * 1.5);
    // for (var key in heatmaps) {
    //      heatmaps[key].set('radius', radius * 1.5);
    // }
  }

  function changeGradient() {
    var gradient = [
      'rgba(0, 255, 255, 0)',
      'rgba(0, 0, 223, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)',
      'rgba(255, 0, 0, 1)'
    ]
    heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
  }

  function afficheheatmap() {
      var radius = Math.floor(radiusCatchment / metersPerPixel(map));
      const opacity = document.getElementById('sliderh').value/100;
      heatmap = new google.maps.visualization.HeatmapLayer({
        data: points,
        radius: radius,
        radiusCatch: radiusCatchment,
        clickable: false,
        opacity: opacity,
        map: map
      });
      changeGradient();
      map.addListener('zoom_changed', function() {
        var radius = Math.floor(heatmap.radiusCatch / metersPerPixel(map));
        changeRadius(radius);
      });
  }

  function affichecompetitors(competitor) {
    if (competitors_place[competitor["place_id"]]) {
      console.log('exist deja');
    }else{
        var marker = new google.maps.Marker({
          position: {lat: competitor["lat"], lng:competitor["lng"]},
          map: map,
          icon: concurrence_icon,
          title: competitor["name"],
        });
          markers.push(marker);
          competitors_place[competitor["place_id"]] = marker;
          bounds.extend( marker.getPosition() );
      points.push(new google.maps.LatLng(competitor["lat"], competitor["lng"]))
    }
  }

  var addListenersOnPolygon = function(polygon) {
    google.maps.event.addListener(polygon, 'mouseover', function (event) {
      document.getElementById('pop').innerHTML = polygon.population;
      document.getElementById('rev').innerHTML = polygon.revenus;
      document.getElementById('res65').innerHTML = polygon.res65;
      document.getElementById('res25').innerHTML = polygon.res25;
    });
  }

  function initMap() {
    var mapStyle = [{"featureType": "all", "elementType": "labels",
          "stylers": [{"visibility": "on"}]},
      {"featureType": "all","elementType": "labels.text.fill",
          "stylers": [{"saturation": 36},{"color": "#000000"},
              {"lightness": 40}]},
      {"featureType": "all","elementType": "labels.text.stroke",
          "stylers": [{"visibility": "on"}, {"color": "#000000" },{"lightness": 16 }] },
      {"featureType": "all","elementType": "labels.icon",
          "stylers": [{ "visibility": "off"} ] },{ "featureType": "administrative", "elementType": "geometry.fill",
          "stylers": [{"color": "#000000" },  { "lightness": 20} ]},
      {"featureType": "administrative", "elementType": "geometry.stroke",
          "stylers": [ { "color": "#000000"},  { "lightness": 17 }, {"weight": 1.2 } ] },
      {"featureType": "administrative.country","elementType": "labels.text.fill",
          "stylers": [{"color": "#e5c163" } ]},
      {"featureType": "administrative.locality", "elementType": "labels.text.fill",
          "stylers": [ { "color": "#c4c4c4" } ]},
      {
          "featureType": "administrative.neighborhood",
          "elementType": "labels.text.fill",
          "stylers": [
              {
                  "color": "#e5c163"
              }
          ]
      },
      {
          "featureType": "landscape",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 20
              }
          ]
      },
      {
          "featureType": "poi",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 21
              },
              {
                  "visibility": "on"
              }
          ]
      },
      {
          "featureType": "poi.business",
          "elementType": "geometry",
          "stylers": [
              {
                  "visibility": "on"
              }
          ]
      },
      {
          "featureType": "road.highway",
          "elementType": "geometry.fill",
          "stylers": [
              {
                  "color": "#e5c163"
              },
              {
                  "lightness": "0"
              }
          ]
      },
      {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [
              {
                  "visibility": "off"
              }
          ]
      },
      {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
              {
                  "color": "#ffffff"
              }
          ]
      },
      {
          "featureType": "road.highway",
          "elementType": "labels.text.stroke",
          "stylers": [
              {
                  "color": "#e5c163"
              }
          ]
      },
      {
          "featureType": "road.arterial",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 18
              }
          ]
      },
      {
          "featureType": "road.arterial",
          "elementType": "geometry.fill",
          "stylers": [
              {
                  "color": "#575757"
              }
          ]
      },
      {
          "featureType": "road.arterial",
          "elementType": "labels.text.fill",
          "stylers": [
              {
                  "color": "#ffffff"
              }
          ]
      },
      {
          "featureType": "road.arterial",
          "elementType": "labels.text.stroke",
          "stylers": [
              {
                  "color": "#2c2c2c"
              }
          ]
      },
      {
          "featureType": "road.local",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 16
              }
          ]
      },
      {
          "featureType": "road.local",
          "elementType": "labels.text.fill",
          "stylers": [
              {
                  "color": "#999999"
              }
          ]
      },
      {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 19
              }
          ]
      },
      {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
              {
                  "color": "#000000"
              },
              {
                  "lightness": 17
              }
          ]
      }
    ];

    map = new google.maps.Map(mapDomElement, {
      zoom: zoom,
      center: search,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles:    mapStyle,
      streetViewControl: false,
    });
  }

  function delpoly() {
    polya.forEach((poly) => {
      poly.setMap(null);
    });
  }

  function addpopulation() {
    if (loaded == false) { return }
    let zoom = map.getZoom();
    let lat1 = map.getBounds().getSouthWest().lat() // latitude du coin inférieur gauche
    let lng1 = map.getBounds().getSouthWest().lng() // longitude du coin inférieur gauche
    let lat2 = map.getBounds().getNorthEast().lat() // latitude du coin supérieur droit
    let lng2 = map.getBounds().getNorthEast().lng() // longitude du coin supérieur droit

    fetch(`/tiles?lat1=${lat1}&lng1=${lng1}&lat2=${lat2}&lng2=${lng2}&zoom=${zoom}`)
      .then((response) => response.json())
      .then((tiles) => {
        delpoly();
        const opacity = document.getElementById('sliderp').value;
        tiles.forEach((tile) => {
          poly = new google.maps.Polygon(tile);
          addListenersOnPolygon(poly);
          poly.setOptions({'fillOpacity': opacity /100, clickable: false });
            poly.setMap(map);
          polya.push(poly);
        });
      });
  }

  $("#sliderp").on("input", function(){
    polya.forEach((poly) => {
      poly.setOptions({'fillOpacity': this.value /100})
    });
  });

  $("#sliderh").on("input", function(){
    heatmap.set('opacity', (this.value/100));
  });

  $(".fa-eye").on("click", function(){
    let id = parseInt(this.getAttribute('data-id'));
    document.querySelector("#icon" + id + " .fa-eye").classList.add("infohide");
    document.querySelector("#icon" + id + " .fa-eye-slash").classList.remove("infohide");
    p = "query" + id;
    places[p][0].setMap(null);
    places[p][1].setMap(null);
    places[p][2].setMap(null);
    reloadcompetitors()
  });

  $(".fa-eye-slash").on("click", function(){
    let id = parseInt(this.getAttribute('data-id'));
    document.querySelector("#icon" + id + " .fa-eye-slash").classList.add("infohide");
    document.querySelector("#icon" + id + " .fa-eye").classList.remove("infohide");
    this.classList.add("infohide");
    p = "query" + id;
    places[p][0].setMap(map);
    places[p][1].setMap(map);
    places[p][2].setMap(map);
    reloadcompetitors()
  });

});

