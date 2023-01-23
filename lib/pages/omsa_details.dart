import 'package:flutter/material.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';
import 'package:stgo_routes/colors.dart';
import 'package:stgo_routes/models.dart';
import 'package:stgo_routes/pages/omsa_stop_page.dart';

class OMSADetailsPage extends StatefulWidget {
  final OMSADetails omsa;

  OMSADetailsPage(this.omsa);

  @override
  State<StatefulWidget> createState() {
    return _OMSADetailsPageState(omsa);
  }
}

class _OMSADetailsPageState extends State<OMSADetailsPage> {
  OMSADetails omsa;
  MapView mapView = new MapView();

  _OMSADetailsPageState(this.omsa);

  Widget _buildOMSAStopItem(OMSAStop stop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OMSAStopPage(stop),
          ),
        );
      },
      child: Hero(
        tag: '${stop.code}',
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            new BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5.0,
                offset: Offset(0, 5)),
          ], borderRadius: BorderRadius.circular(20), color: Colors.white),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          margin: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 50,
                height: 50,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: new Border.all(
                      width: 1.0,
                      color: Colors.white,
                    ),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5.0,
                      ),
                    ]),
                child: Center(
                  child: Image.asset(
                    'assets/images/bus_stop_icon.png',
                    height: 30,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(
                  '${stop.name}',
                  style: TextStyle(fontSize: 18, color: darkText),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRouteMapView() {
    mapView.clearPolylines();
    List<Location> routeLocations = new List();

    omsa.coordenates.forEach((polyline) {
      routeLocations.add(new Location(polyline[1], polyline[0]));
    });

    var routeCenter = _getRouteCenter();
    var toolbarActions = [new ToolbarAction("Atrás", 1)];

    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            initialCameraPosition: new CameraPosition(routeCenter, 13),
            title: '${omsa.name}'),
        toolbarActions: toolbarActions);

    mapView.onMapReady.listen((Null _) {
      List<Marker> markers = [];

      omsa.stops.forEach((s) {
        markers.add(new Marker("1", "Parada ${s.name} (${s.reference})",
            s.location[1], s.location[0],
            markerIcon: MarkerIcon('assets/images/bus_stop2.png')));
      });

      mapView.setMarkers(markers);
      mapView.setPolylines([
        new Polyline(omsa.coordenates.length.toString(), routeLocations,
            color: Colors.greenAccent,
            jointType: FigureJointType.round,
            width: 10)
      ]);
      mapView.zoomToFit(padding: 50);
    });

    mapView.onToolbarAction.listen((id) async {
      if (id == 1) {
        mapView.dismiss();
      }
    });
  }

  Location _getRouteCenter() {
    var latitudes = [];
    var longitudes = [];

    omsa.coordenates.forEach((c) {
      latitudes.add(c[1]);
      longitudes.add(c[0]);
    });

    // sort the arrays low to high
    latitudes.sort();
    longitudes.sort();

    // get the min and max of each
    var lowX = latitudes[0];
    var highX = latitudes[latitudes.length - 1];
    var lowy = longitudes[0];
    var highy = longitudes[latitudes.length - 1];

    // center of the polygon is the starting point plus the midpoint
    var centerX = lowX + ((highX - lowX) / 2);
    var centerY = lowy + ((highy - lowy) / 2);

    return (new Location(centerX, centerY));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        body: Column(
          children: <Widget>[
            Hero(
                tag: omsa.codeName,
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: Container(
                    height: 130,
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Material(
                              color: Colors.transparent,
                              child: Text(
                                omsa.codeName,
                                style: TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showRouteMapView();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 10),
                                decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: new Border.all(
                                      width: 1.0,
                                      color: Colors.white,
                                    ),
                                    boxShadow: [
                                      new BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5.0,
                                      ),
                                    ]),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(
                                      Icons.map,
                                      color: Colors.greenAccent,
                                    ),
                                    Text('Mapa'),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          // margin: EdgeInsets.only(top: 35),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                child: Text(
                                  omsa.name,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      'Precio: \$${omsa.price}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      'Distancia: ${omsa.routeDistance}Km',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    color: Colors.greenAccent,
                  ),
                )),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                'Paradas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: omsa.stops.length,
                itemBuilder: (context, index) {
                  return _buildOMSAStopItem(omsa.stops[index]);
                },
              ),
            )
          ],
        ));
  }
}
