import 'package:flutter/material.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/polyline.dart';
import 'package:random_color/random_color.dart';
import 'package:stgo_routes/constants.dart';
import 'package:stgo_routes/maps_tools.dart';
import 'package:stgo_routes/models.dart';
import 'package:stgo_routes/omsa_routes_data.dart';
import 'package:stgo_routes/widgets/dots_indicator.dart';
import 'package:map_view/map_view.dart' as mapView;
import 'package:smooth_star_rating/smooth_star_rating.dart';

class CreatedRoutesPage extends StatefulWidget {
  final LatLng originLocation;
  final LatLng destinationLocation;

  CreatedRoutesPage(this.originLocation, this.destinationLocation);
  @override
  State<StatefulWidget> createState() {
    return _CreatedRoutesPageState(originLocation, destinationLocation);
  }
}

class _CreatedRoutesPageState extends State<CreatedRoutesPage> {
  List<OMSADetails> omsas = [omsaC3];
  final pageController = PageController(initialPage: 0);
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  List<PathRoute> calculatedRoutes = [];

  LatLng originLocation;
  LatLng destinationLocation;
  LatLng closestOriginLocation;
  LatLng closestDestinationLocation;

  _CreatedRoutesPageState(this.originLocation, this.destinationLocation);

  @override
  void initState() {
    calcRouteDistances();

    double result = pointDistance(
        LatLng(19.456327, -70.702319), LatLng(19.456250, -70.702048));
    print(result);
    List<dynamic> closestStart = getClosestRoute(originLocation);
    List<dynamic> closestEnd = getClosestRoute(destinationLocation);
    closestOriginLocation = closestStart[1];
    closestDestinationLocation = closestEnd[1];

    print('start process');
    List<List<String>> paths =
        getDestinationPaths(closestStart[0], closestEnd[0]);

    paths.forEach((path) {
      PathRoute calculatedRoute = PathRoute();
      calculatedRoute.routes = new List<String>.from(path);
      String firstRoute = path[0];
      path.removeAt(0);

      List<RouteIntersection> pathPolylines = getPolylineForPath(
          firstRoute, closestOriginLocation, path, closestDestinationLocation);

      calculatedRoute.carRoutes = pathPolylines;
      calculatedRoutes.add(calculatedRoute);
    });

    setState(() {
      calculatedRoutes = calculateRoutesRating(calculatedRoutes);
    });

    print('proccess ended');

    super.initState();
  }

  List<PathRoute> calculateRoutesRating(List<PathRoute> routes) {
    PathRoute shortest = routes[0];
    PathRoute cheapest = routes[0];
    double shortestDistance = 99999;

    routes.forEach((r) {
      r.rating = 3;
      r.description = 'Ruta alternativa';
      double distance = 0;
      r.carRoutes.forEach((cr) {
        distance += cr.distance;
      });

      if (r.routes.length < cheapest.routes.length) {
        cheapest = r;
      }

      if (distance < shortestDistance) {
        shortest = r;
        shortestDistance = distance;
      }
    });

    if (shortest == cheapest) {
      shortest.rating = 5;
      shortest.description = 'Ruta más corta \nRuta más económica';
    } else {
      shortest.rating = 4;
      shortest.description = 'Ruta más corta';
      cheapest.rating = 4;
      cheapest.description = 'Ruta más económica';
    }

    return routes;
  }

  void _showRouteMapView(PathRoute route) {
    RandomColor randomColor = RandomColor();

    mapView.MapView map = mapView.MapView();

    List<LatLng> routeLocations = new List();
    List<Polyline> polylines = [];
    List<mapView.Marker> markers = [];

    for (var i = 0; i < route.carRoutes.length; i++) {
      List<mapView.Location> points = [];

      if (i == 0) {
        mapView.Location start =
            mapView.Location(originLocation.lat, originLocation.lng);

        mapView.Location end = mapView.Location(
            route.carRoutes[0].coordenates[0].lat,
            route.carRoutes[0].coordenates[0].lng);
        points.add(start);
        points.add(end);

        LatLng midpoint = midPoint(
            start.latitude, start.longitude, end.latitude, end.longitude);

        markers.add(new mapView.Marker("", "", midpoint.lat, midpoint.lng,
            markerIcon: mapView.MarkerIcon('assets/images/nav_walk.png')));
      } else {
        mapView.Location start = mapView.Location(
            route.carRoutes[i - 1]
                .coordenates[route.carRoutes[i - 1].coordenates.length - 1].lat,
            route
                .carRoutes[i - 1]
                .coordenates[route.carRoutes[i - 1].coordenates.length - 1]
                .lng);
        mapView.Location end = mapView.Location(
            route.carRoutes[i].coordenates[0].lat,
            route.carRoutes[i].coordenates[0].lng);

        points.add(start);
        points.add(end);
        LatLng midpoint = midPoint(
            start.latitude, start.longitude, end.latitude, end.longitude);

        markers.add(new mapView.Marker("", "", midpoint.lat, midpoint.lng,
            markerIcon: mapView.MarkerIcon('assets/images/nav_walk.png')));
      }

      polylines.add(new Polyline('', points,
          color: Colors.blueAccent,
          jointType: FigureJointType.round,
          width: 10));
    }

    route.carRoutes.forEach((polyline) {
      routeLocations..addAll(polyline.coordenates);
      List<mapView.Location> locations = [];

      polyline.coordenates.forEach((p) {
        if (p.lat != null && p.lng != null) {
          locations.add(new mapView.Location(p.lat, p.lng));
        }
      });

      polylines.add(new Polyline(
          polyline.coordenates.length.toString(), locations,
          color: randomColor.randomColor(),
          jointType: FigureJointType.round,
          width: 10));
    });

    print(routeLocations.length);
    var toolbarActions = [new mapView.ToolbarAction("Atrás", 1)];

    map.show(
        new mapView.MapOptions(
            mapViewType: mapView.MapViewType.normal,
            showUserLocation: true,
            initialCameraPosition: new mapView.CameraPosition(
                mapView.Location(19.449539, -70.690619), 13),
            title: 'Ruta ${route.routes.join(' \u2192 ')}'),
        toolbarActions: toolbarActions);

    map.onMapReady.listen((Null _) {
      markers.add(new mapView.Marker(
          "start", "", originLocation.lat, originLocation.lng,
          markerIcon: mapView.MarkerIcon('assets/images/start_nav_icon.png')));

      markers.add(new mapView.Marker(
          "finish", "", destinationLocation.lat, destinationLocation.lng,
          markerIcon:
              mapView.MarkerIcon('assets/images/destination_nav_icon.png')));

      route.carRoutes.forEach((p) {
        LatLng position = p.coordenates[(p.coordenates.length ~/ 2)];
        markers.add(new mapView.Marker(
            "${p.name}", "Ruta ${p.name})", position.lat, position.lng,
            markerIcon: mapView.MarkerIcon(
                'assets/images/nav_icon_${p.name.toLowerCase()}.png')));
      });

      map.setMarkers(markers);
      map.setPolylines(polylines);
      map.zoomToFit(padding: 80);
    });

    map.onToolbarAction.listen((id) async {
      if (id == 1) {
        map.dismiss();
      }
    });
  }

  String _generateRouteStaticImageUrl(PathRoute route) {
    List<LatLng> points = [];

    route.carRoutes.forEach((cr) {
      points..addAll(cr.coordenates);
    });

    String encodedPath = encode(points);
    String imageUrl =
        'https://maps.googleapis.com/maps/api/staticmap?zoom=14.5&size=600x600&center=19.449539,-70.690619&maptype=roadmap&path=color:0x0000EE|weight:5|enc:$encodedPath&key=$googleMapsApiKey';
    return imageUrl;
  }

  double calcRoutesDistance(PathRoute route) {
    double total = 0;

    route.carRoutes.forEach((r) {
      total += r.distance;
    });

    return total / 1000;
  }

  Widget _buildRouteItem(PathRoute route) {
    return GestureDetector(
      onTap: () {
        _showRouteMapView(route);
      },
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Hero(
            tag: route.routes.join('-'),
            child: Container(
              height: 150,
              color: Colors.blueAccent,
              child: Container(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${route.routes.join(' \u2192 ')}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            alignment: Alignment.centerLeft,
                            icon: Icon(Icons.arrow_back),
                            padding: EdgeInsets.only(
                                top: 23, left: 20.0, right: 20.0),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          ),
                          Text(
                            'Distancia: ${calcRoutesDistance(route).toStringAsFixed(3)}Km',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          Text(
                            'Costo: \$${25 * route.routes.length} Pesos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SmoothStarRating(
                        allowHalfRating: true,
                        onRatingChanged: (v) {},
                        starCount: 5,
                        rating: route.rating,
                        size: 25,
                        color: Colors.amberAccent,
                        borderColor: Colors.amber,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${route.description ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                    )
                  ],
                )),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  fit: BoxFit.fitHeight,
                  image: NetworkImage(_generateRouteStaticImageUrl(route)),
                ),
                boxShadow: [
                  new BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: Offset(5, 10)),
                ],
                borderRadius: BorderRadius.circular(30),
                color: Colors.white),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        body: Stack(
          children: <Widget>[
            new PageView.builder(
              itemCount: calculatedRoutes.length,
              physics: new AlwaysScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (BuildContext context, int index) {
                return _buildRouteItem(
                    calculatedRoutes[index % calculatedRoutes.length]);
              },
            ),
            new Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: new Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20.0),
                child: new Center(
                  child: DotsIndicator(
                    controller: pageController,
                    itemCount: calculatedRoutes.length,
                    color: Colors.blueAccent,
                    onPageSelected: (int page) {
                      pageController.animateToPage(
                        page,
                        duration: _kDuration,
                        curve: _kCurve,
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
