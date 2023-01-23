class OMSADetails {
  OMSADetails(this.name, this.codeName, this.coordenates,
      [this.routeDistance = 0,
      this.congestion = 0,
      this.price = 0,
      this.stops]);
  String name;
  String codeName;
  double routeDistance;
  double congestion;
  double price;
  List<List<double>> coordenates;
  List<OMSAStop> stops;
}

class OMSAStop {
  OMSAStop(this.code, this.name, this.reference, this.location);
  String code;
  String name;
  String reference;
  List<double> location;
}

class RouteDetails {
  RouteDetails(this.name, this.coordenates, this.price,
      [this.routeDistance = 0, this.congestion = 0]);
  String name;
  double routeDistance;
  double congestion;
  double price;
  List<List<List<double>>> coordenates;
}

class LatLng {
  LatLng([this.lat, this.lng]);
  double lng;
  double lat;
}

class RouteIntersection {
  RouteIntersection(
      [this.name, this.coordenates, this.nextRoutePosition, this.distance]);
  String name;
  LatLng nextRoutePosition;
  double distance;
  List<LatLng> coordenates;
}

class PathRoute {
  String description;
  double rating;
  PathRoute({this.routes, this.carRoutes, this.description, this.rating});
  List<String> routes;
  List<RouteIntersection> carRoutes;
}
