import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';
import 'package:stgo_routes/car_routes_data.dart';
import 'package:stgo_routes/models.dart';
import 'package:stgo_routes/widgets/car_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stgo_routes/widgets/favorites_routes_list.dart';

class RoutesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RoutesPageState();
  }
}

class _RoutesPageState extends State<RoutesPage> with TickerProviderStateMixin {
  double zoom;
  MapView mapView = new MapView();

  AnimationController _controller;
  List<String> favoriteRoutes = [];
  double containerHeight = 100;

  @override
  void initState() {
    _getFavoriteRoutes().then((value) {
      print(value);
      setState(() {
        favoriteRoutes = value;
      });
    });
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (_controller.isDismissed) {
      Future.delayed(const Duration(milliseconds: 450), () {
        _controller.forward();
      });
    }
    super.initState();
  }

  Future<List<String>> _getFavoriteRoutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteRoutes = prefs.getStringList('favorite_routes') == null
        ? List<String>()
        : prefs.getStringList('favorite_routes');
    return favoriteRoutes;
  }

  Widget _buildRouteSelector(RouteDetails route) {
    return Container(
      height: containerHeight,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          new BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 15.0,
              spreadRadius: 5,
              offset: Offset(0, 10)),
        ],
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            route.name,
            style: TextStyle(fontSize: 30),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  color: Colors.greenAccent,
                  icon: Icon(Icons.map),
                  onPressed: () {
                    setState(() {
                      setState(() {
                        _showRouteMapView(RouteDetails(
                            route.name, route.coordenates, route.price));
                        Navigator.pop(context, true);
                      });
                    });
                  },
                ),
                IconButton(
                  color: Colors.blueAccent,
                  icon: Icon(Icons.info),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text('Información Ruta ${route.name}'),
                          content: Text(
                              'Distancia: ${route.routeDistance}\nCongestión: ${route.congestion}'),
                          actions: <Widget>[
                            // usually buttons at the bottom of the dialog
                            new FlatButton(
                              child: new Text("Ok"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        body: Column(
          children: <Widget>[
            Hero(
              tag: 'routes_page',
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.fitHeight,
                      image:
                          new AssetImage('assets/images/car_routes_header.jpg'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        alignment: Alignment.centerLeft,
                        icon: Icon(Icons.arrow_back),
                        padding:
                            EdgeInsets.only(top: 23, left: 20.0, right: 20.0),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 23, right: 20),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)),
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.directions_car),
                          color: Colors.blueAccent,
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Center(
                                        child: Text(
                                          'Rutas',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: GridView.count(
                                          children: <Widget>[
                                            _buildRouteSelector(routeM),
                                            _buildRouteSelector(routeP),
                                            _buildRouteSelector(routeK),
                                            _buildRouteSelector(routeA),
                                          ],
                                          crossAxisCount: 3,
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: favoriteRoutes.length > 0
                  ? FavoritesRoutesList(
                      updateFavorites: (newFavs) {
                        setState(() {
                          favoriteRoutes = newFavs;
                          if (newFavs.length == 0) {
                            Future.delayed(const Duration(milliseconds: 450),
                                () {
                              _controller.forward();
                            });
                          }
                        });
                      },
                      showMap: (RouteDetails route) {
                        _showRouteMapView(route);
                      },
                    )
                  : ScaleTransition(
                      child: CarRoute(),
                      scale: CurvedAnimation(
                          curve: Interval(0.0, 0.1, curve: Curves.easeInOut),
                          parent: _controller)),
            )
          ],
        ));
  }

  void _showRouteMapView(RouteDetails route) {
    mapView.clearPolylines();
    List<List<Location>> allPolylines = new List();

    route.coordenates.forEach((polylines) {
      List<Location> routeLocations = new List();

      polylines.forEach((polyline) {
        routeLocations.add(new Location(polyline[1], polyline[0]));
      });

      allPolylines.add(routeLocations);
    });

    var routeCenter = _getRouteCenter(route);
    var toolbarActions = [new ToolbarAction("Atrás", 1)];

    _getFavoriteRoutes().then((List<String> favorites) async {
      var found = favorites.any((f) => f == route.name);
      print(found);
      if (!found) {
        toolbarActions.add(new ToolbarAction("Favorito", 2));
      }

      mapView.show(
          new MapOptions(
              mapViewType: MapViewType.normal,
              showUserLocation: true,
              initialCameraPosition: new CameraPosition(routeCenter, 11),
              title: 'Ruta ${route.name}'),
          toolbarActions: toolbarActions);

      mapView.onMapReady.listen((Null _) {
        // mapView.setPolygons(<Polygon>[
        //   new Polygon("111", routeLocations,
        //       jointType: FigureJointType.round,
        //       strokeWidth: 10.0,
        //       strokeColor: Colors.blueAccent,
        //       fillColor: Colors.transparent),
        // ]);
        List<Polyline> polys = [];
        List<Marker> markers = [];
        markers.add(new Marker("1", "Ruta ${route.name}",
            allPolylines[0][0].latitude, allPolylines[0][0].longitude,
            markerIcon: MarkerIcon(
                'assets/images/nav_icon_${route.name.toLowerCase()}.png')));
        allPolylines.forEach((poly) {
          polys.add(new Polyline(polys.length.toString(), poly,
              color: polys.length == 0 ? Colors.blueAccent : Colors.redAccent,
              jointType: FigureJointType.round,
              width: 10));
        });
        mapView.setMarkers(markers);
        mapView.setPolylines(polys);
        mapView.zoomToFit(padding: 50);
      });

      mapView.onMapTapped.listen((location) {});

      mapView.onToolbarAction.listen((id) async {
        if (id == 1) {
          mapView.dismiss();
        } else if (id == 2) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          _getFavoriteRoutes().then((List<String> favorites) async {
            favorites.add(route.name);
            favorites = favorites.toSet().toList();
            print('favorites $favorites');
            setState(() {
              favoriteRoutes = favorites;
            });
            await prefs.setStringList('favorite_routes', favorites);
          });
        }
      });
    });
  }

  Location _getRouteCenter(RouteDetails route) {
    var latitudes = [];
    var longitudes = [];

    route.coordenates[0].forEach((c) {
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
    zoom = 414.89 * (highX - lowX);
    zoom = zoom < 0 ? zoom * -1 : zoom;
    var centerX = lowX + ((highX - lowX) / 2);
    var centerY = lowy + ((highy - lowy) / 2);

    return (new Location(centerX, centerY));
  }
}
