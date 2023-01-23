import 'package:flutter/material.dart';
import 'package:stgo_routes/maps_tools.dart';
import 'package:stgo_routes/models.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googleMaps;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:stgo_routes/pages/created_routes_page.dart';

class CreateRoutePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateRoutePageState();
  }
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  LatLng originLocation;
  LatLng destinationLocation;
  googleMaps.GoogleMapController mapController;
  googleMaps.Marker originMarker;
  var destinationMarker;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadOriginController =
      TextEditingController();
  final TextEditingController _typeAheadDestinationController =
      TextEditingController();
  Position userPosition;
  bool directionsCompleted = false;
  String _mapStyle;

  @override
  void initState() {
    getUserPosition();
    loadMapStyle().then((String style) {
      setState(() {
        _mapStyle = style;
      });
    });
    super.initState();
  }

  Future<String> loadMapStyle() async {
    return await rootBundle.loadString('assets/maps/styles.json');
  }

  getUserPosition() async {
    userPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future _updateOriginMarker(googleMaps.LatLng position, String icon) async {
    if (originMarker == null) {
      originMarker = await mapController.addMarker(
        googleMaps.MarkerOptions(
          draggable: true,
          icon: googleMaps.BitmapDescriptor.fromAsset(
            icon,
          ),
          position: position,
        ),
      );
    } else {
      mapController.updateMarker(
        originMarker,
        googleMaps.MarkerOptions(
          draggable: true,
          icon: googleMaps.BitmapDescriptor.fromAsset(
            icon,
          ),
          position: position,
        ),
      );
    }

    setState(() {
      originLocation = LatLng(position.latitude, position.longitude);
    });

    if (originMarker != null && destinationMarker != null) {
      setState(() {
        directionsCompleted = true;
      });
    }
  }

  Future _updateDestinationMarker(
      googleMaps.LatLng position, String icon) async {
    if (destinationMarker == null) {
      destinationMarker = await mapController.addMarker(
        googleMaps.MarkerOptions(
          draggable: true,
          icon: googleMaps.BitmapDescriptor.fromAsset(
            icon,
          ),
          position: position,
        ),
      );
    } else {
      mapController.updateMarker(
        destinationMarker,
        googleMaps.MarkerOptions(
          draggable: true,
          icon: googleMaps.BitmapDescriptor.fromAsset(
            icon,
          ),
          position: position,
        ),
      );
    }

    setState(() {
      destinationLocation = LatLng(position.latitude, position.longitude);
    });

    if (originMarker != null && destinationMarker != null) {
      setState(() {
        directionsCompleted = true;
      });
    }
  }

  void _addMarker(googleMaps.LatLng position, String icon) {
    mapController.addMarker(
      googleMaps.MarkerOptions(
        icon: googleMaps.BitmapDescriptor.fromAsset(
          icon,
        ),
        position: position,
      ),
    );
  }

  void _newCameraPosition(googleMaps.LatLng position) {
    mapController.animateCamera(
      googleMaps.CameraUpdate.newCameraPosition(
        googleMaps.CameraPosition(
          target: position,
          tilt: 50.0,
          bearing: 45.0,
          zoom: 15,
        ),
      ),
    );
  }

  void _onMapCreated(googleMaps.GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 60,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: googleMaps.GoogleMap(
                  mapStyle: _mapStyle,
                  myLocationEnabled: false,
                  compassEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: googleMaps.CameraPosition(
                    bearing: 270.0,
                    target: googleMaps.LatLng(19.449539, -70.690619),
                    tilt: 30.0,
                    zoom: 13.3,
                  ),
                ),
              ),
            ),
            Positioned(
                top: 70,
                child: Container(
                  padding: EdgeInsets.all(15),
                  height: 170,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 3,
                              offset: Offset(0, 3)),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Column(
                      children: <Widget>[
                        Form(
                          key: this._formKey,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Icon(
                                        Icons.trip_origin,
                                        color: Colors.lightBlueAccent,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.more_vert,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.place,
                                        color: Colors.redAccent,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.60,
                                      child: TypeAheadFormField(
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                                  style: TextStyle(
                                                      color: Colors.blueAccent),
                                                  controller: this
                                                      ._typeAheadOriginController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Salida',
                                                      labelStyle: TextStyle(
                                                          color: Colors.grey))),
                                          suggestionsCallback: (pattern) async {
                                            var places = [];
                                            var results =
                                                await searchPlaces(pattern);
                                            places = results['candidates'];

                                            return places;
                                          },
                                          noItemsFoundBuilder:
                                              (BuildContext context) =>
                                                  Container(
                                                    height: 50,
                                                    child: Center(
                                                      child: Text(
                                                          'No hay resultados',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .blueGrey)),
                                                    ),
                                                  ),
                                          suggestionsBoxDecoration:
                                              SuggestionsBoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  elevation: 10),
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(
                                                suggestion['name'],
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              leading: Container(
                                                width: 10,
                                                child: Icon(Icons.location_on),
                                              ),
                                              subtitle: Text(
                                                  suggestion[
                                                      'formatted_address'],
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                            );
                                          },
                                          transitionBuilder: (context,
                                              suggestionsBox, controller) {
                                            return suggestionsBox;
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            this
                                                ._typeAheadOriginController
                                                .text = suggestion['name'];

                                            googleMaps.LatLng newPoint =
                                                googleMaps.LatLng(
                                                    suggestion['geometry']
                                                        ['location']['lat'],
                                                    suggestion['geometry']
                                                        ['location']['lng']);

                                            _updateOriginMarker(newPoint,
                                                'assets/images/start_nav_icon.png');

                                            _newCameraPosition(newPoint);
                                          },
                                          onSaved: (value) => {}),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.60,
                                      child: TypeAheadFormField(
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                                  style: TextStyle(
                                                      color: Colors.blueAccent),
                                                  controller: this
                                                      ._typeAheadDestinationController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Destino',
                                                      labelStyle: TextStyle(
                                                          color: Colors.grey))),
                                          suggestionsCallback: (pattern) async {
                                            var places = [];
                                            var results =
                                                await searchPlaces(pattern);
                                            places = results['candidates'];

                                            return places;
                                          },
                                          noItemsFoundBuilder:
                                              (BuildContext context) =>
                                                  Container(
                                                    height: 50,
                                                    child: Center(
                                                      child: Text(
                                                          'No hay resultados',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .blueGrey)),
                                                    ),
                                                  ),
                                          suggestionsBoxDecoration:
                                              SuggestionsBoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  elevation: 10),
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(
                                                suggestion['name'],
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              leading: Container(
                                                width: 10,
                                                child: Icon(Icons.location_on),
                                              ),
                                              subtitle: Text(
                                                  suggestion[
                                                      'formatted_address'],
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                            );
                                          },
                                          transitionBuilder: (context,
                                              suggestionsBox, controller) {
                                            return suggestionsBox;
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            this
                                                ._typeAheadDestinationController
                                                .text = suggestion['name'];

                                            googleMaps.LatLng newPoint =
                                                googleMaps.LatLng(
                                                    suggestion['geometry']
                                                        ['location']['lat'],
                                                    suggestion['geometry']
                                                        ['location']['lng']);

                                            _updateDestinationMarker(newPoint,
                                                'assets/images/destination_nav_icon.png');

                                            _newCameraPosition(newPoint);
                                          },
                                          onSaved: (value) => {}),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 12,
                                    ),
                                    IconButton(
                                      color: Colors.blueAccent,
                                      icon: Icon(Icons.my_location),
                                      onPressed: () async {
                                        this._typeAheadOriginController.text =
                                            'Ubicación actual';
                                        _updateOriginMarker(
                                            googleMaps.LatLng(
                                                userPosition.latitude,
                                                userPosition.longitude),
                                            'assets/images/start_nav_icon.png');
                                        _newCameraPosition(googleMaps.LatLng(
                                            userPosition.latitude,
                                            userPosition.longitude));
                                      },
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    directionsCompleted
                                        ? IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreatedRoutesPage(
                                                          originLocation,
                                                          destinationLocation),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.blueAccent,
                                              size: 35,
                                            ),
                                          )
                                        : SizedBox(
                                            height: 40,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Hero(
                tag: 'create_route_page',
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.center,
                        fit: BoxFit.fill,
                        image: new AssetImage(
                            'assets/images/calc_routes_header.jpg'),
                      ),
                      boxShadow: [
                        new BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 5,
                            spreadRadius: 3,
                            offset: Offset(0, 5)),
                      ],
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          alignment: Alignment.centerLeft,
                          icon: Icon(Icons.arrow_back),
                          padding:
                              EdgeInsets.only(top: 23, left: 20.0, right: 20.0),
                          color: Colors.blueAccent,
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
