var map;

function setup_map() {
	var latlng = new google.maps.LatLng(-34.397, 150.644);
    var myOptions = {
      zoom: 2,
      center: latlng,
      scaleControl: true,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map"), myOptions);
}

function goto(place) {
    if (place.longitude) {
        goto_point(place);
    } else {
        goto_boundingbox(place);
    }
}

function goto_boundingbox(boundingbox) {
    var sw = new google.maps.LatLng(boundingbox.southLat, boundingbox.westLong);
    var ne = new google.maps.LatLng(boundingbox.northLat, boundingbox.eastLong);
    var bounds = new google.maps.LatLngBounds(sw,ne);
    map.fitBounds(bounds);
}

function goto_point(point) {
    var latlng = new google.maps.LatLng(point.latitude, point.longitude);
    map.panTo(latlng);
    map.setZoom(6);
}