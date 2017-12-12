document.addEventListener('DOMContentLoaded', () => {
  let map = null;
  let mapDomElement = document.getElementById('map');
  let zoom = null;
  let polya = [];
  let markers = [];
  let radiusCatchment = null;
  let search = {};
  const search_icon = 'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png';
  const concurrence_icon = 'http://maps.gstatic.com/mapfiles/ms2/micons/red.png';

  if (mapDomElement) {
    zoom = parseInt(mapDomElement.getAttribute('data-zoom'));
    radiusCatchment = parseInt(mapDomElement.getAttribute('data-radius'));
    radiusSearch = parseInt(mapDomElement.getAttribute('data-radiussearch'));
    search = {
      lat: parseFloat(mapDomElement.getAttribute('data-lat')),
      lng: parseFloat(mapDomElement.getAttribute('data-long'))
    };

    initMap();
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
var mapStyle = [
    {
        "featureType": "all",
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "all",
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "saturation": 36
            },
            {
                "color": "#000000"
            },
            {
                "lightness": 40
            }
        ]
    },
    {
        "featureType": "all",
        "elementType": "labels.text.stroke",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#000000"
            },
            {
                "lightness": 16
            }
        ]
    },
    {
        "featureType": "all",
        "elementType": "labels.icon",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "administrative",
        "elementType": "geometry.fill",
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
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#000000"
            },
            {
                "lightness": 17
            },
            {
                "weight": 1.2
            }
        ]
    },
    {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "color": "#e5c163"
            }
        ]
    },
    {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "color": "#c4c4c4"
            }
        ]
    },
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
    var marker = new google.maps.Marker({
      position: search,
      icon: search_icon,
      animation: google.maps.Animation.DROP,
      map: map
    });
    var searchcircle = new google.maps.Circle({
      strokeColor: '#0f5',
      strokeOpacity: 0.8,
      strokeWeight: 4,
      fillColor: '#FF0000',
      fillOpacity: 0,
      map: map,
      center: search,
      radius: radiusCatchment
    });
    var catchcircle = new google.maps.Circle({
      strokeColor: '#05F',
      strokeOpacity: 0.8,
      strokeWeight: 4,
      fillColor: '#FFFF00',
      fillOpacity: 0,
      map: map,
      center: search,
      radius: radiusSearch
    });
    addcompetitors(map)
  }

  function delpoly() {
    polya.forEach((poly) => {
      poly.setMap(null);
    });
  }

  function addpopulation() {
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
          poly.setOptions({'fillOpacity': opacity /100})
          poly.setMap(map);
          addListenersOnPolygon(poly);
          polya.push(poly);
        });
      });
   }

  google.maps.event.addListener(map, 'bounds_changed', function() {
    addpopulation();
  });

  $("#sliderp").on("input", function(){
    polya.forEach((poly) => {
      poly.setOptions({'fillOpacity': this.value /100})
    });
  });

});

function openinf() {
  document.getElementById('show-content').classList.remove("infohide");
}

function closeinf() {
  document.getElementById('show-content').classList.add("infohide");
}

function openset() {
  document.getElementById('show-setting').classList.remove("infohide");
}

function closeset() {
  document.getElementById('show-setting').classList.add("infohide");
}
