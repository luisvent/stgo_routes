import 'dart:math';
import 'dart:convert';

import 'package:stgo_routes/car_routes_data.dart';
import 'package:stgo_routes/constants.dart';
import 'package:stgo_routes/models.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math_64.dart';

Map routeIntersections = Map();

class CodeOptions {
  num precision;
  num factor;

  CodeOptions([this.precision = 5, this.factor]) {
    if (this.factor == null) {
      this.factor = pow(10, precision);
    }
  }
}

double pointDistance(LatLng origin, LatLng destination) {
  var x = origin.lat - destination.lat;
  var y = origin.lng - destination.lng;

  return sqrt(x * x + y * y);
}

String encode(List<LatLng> points, [CodeOptions options]) {
  if (points.isEmpty) {
    return '';
  }
  if (options == null) {
    options = new CodeOptions();
  }

  var output = _encode(points[0].lat, 0.0, options.factor) +
      _encode(points[0].lng, 0.0, options.factor);
  for (int i = 1; i < points.length; i++) {
    LatLng a = points[i];
    LatLng b = points[i - 1];
    output += _encode(a.lat, b.lat, options.factor);
    output += _encode(a.lng, b.lng, options.factor);
  }
  return output;
}

_encode(double currentPrecise, double previousPrecise, num factor) {
  int current = (currentPrecise * factor).round();
  int previous = (previousPrecise * factor).round();
  var coordinate = current - previous;
  coordinate <<= 1;
  if (current - previous < 0) {
    coordinate = ~coordinate;
  }
  var output = '';
  while (coordinate >= 0x20) {
    output += new String.fromCharCode((0x20 | (coordinate & 0x1f)) + 63);
    coordinate >>= 5;
  }
  output += new String.fromCharCode(coordinate + 63);
  return output;
}

List<List<String>> getAllPathsForRoute(List<String> path) {
  List<List<String>> paths = [path];

  List<String> it = getRouteIntersections(path);
  it.forEach((i) {
    if (!path.contains(i)) {
      List<String> newPath = new List<String>.from(path);
      newPath.add(i);
      paths..addAll(getAllPathsForRoute(newPath));
    }
  });

  return paths;
}

searchPlaces(String input) async {
  String request =
      'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&locationbias=circle:10000@19.459326,-70.693136&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=$googleMapsApiKey';
  final http.Response response = await http.get(request);
  final decodedResponse = json.decode(response.body);
  return decodedResponse;
}

RouteIntersection getPath(
    {LatLng originPosition, RouteDetails route, LatLng closestPoint}) {
  RouteIntersection originPath = RouteIntersection();

  int originCoordenateIndex = 0;

  for (var i = 0; i < route.coordenates[0].length - 1; i++) {
    if (route.coordenates[0][i][1] == originPosition.lat &&
        route.coordenates[0][i][0] == originPosition.lng) {
      originCoordenateIndex = i;
    }
  }

  List<LatLng> path1 = [];
  double path1Distance = 0;
  List<LatLng> path2 = [];
  double path2Distance = 0;
  int limit = route.coordenates[0].length - 1;
  int i = 0;

  i = originCoordenateIndex + 1;
  while (true) {
    LatLng newPoint =
        LatLng(route.coordenates[0][i][1], route.coordenates[0][i][0]);
    path1Distance +=
        path1.length < 2 ? 0 : pointDistance(path1[path1.length - 1], newPoint);
    path1.add(newPoint);
    double cLat = route.coordenates[0][i][1];
    double cLng = route.coordenates[0][i][0];
    if (cLat == closestPoint.lat && cLng == closestPoint.lng) {
      break;
    } else {
      if (i == limit) {
        i = 0;
      }
    }

    i++;
  }

  i = originCoordenateIndex - 1 < 0
      ? route.coordenates[0].length - 1
      : originCoordenateIndex - 1;
  while (true) {
    LatLng newPoint =
        LatLng(route.coordenates[0][i][1], route.coordenates[0][i][0]);
    path2Distance +=
        path2.length < 2 ? 0 : pointDistance(path2[path2.length - 1], newPoint);
    path2.add(newPoint);
    if (route.coordenates[0][i][1] == closestPoint.lat &&
        route.coordenates[0][i][0] == closestPoint.lng) {
      break;
    } else {
      if (i == 0) {
        i = route.coordenates[0].length - 1;
      }
    }
    i--;
  }

  double distance;
  originPath.name = route.name;
  List<LatLng> shortestPath = [];
  if (path1Distance > path2Distance) {
    shortestPath = path2;
    distance = path2Distance;
  } else {
    shortestPath = path1;
    distance = path1Distance;
  }
  // List<LatLng> shortestPath = path1.length > path2.length ? path2 : path1;

  if (originPath.coordenates == null || originPath.distance > distance) {
    originPath.distance = distance;
    originPath.coordenates = shortestPath;
  }

  return originPath;
}

List<List<String>> getDestinationPaths(
    String originRoute, String destinationRoute) {
  List<String> originToDestinationPathsStrings = [];
  List<List<String>> originToDestinationPaths = [];
  List<List<String>> originPaths = getAllPathsForRoute([originRoute]);

  originPaths.forEach((op) {
    if (op.contains(destinationRoute)) {
      List<String> path = [];

      for (var i = 0; i < op.length; i++) {
        path.add(op[i]);
        if (op[i] == destinationRoute) {
          break;
        }
      }
      originToDestinationPathsStrings.add(path.join('-'));
    }
  });

  originToDestinationPathsStrings =
      originToDestinationPathsStrings.toSet().toList();

  originToDestinationPathsStrings.forEach((p) {
    originToDestinationPaths.add(p.split('-'));
  });

  return originToDestinationPaths;
}

RouteIntersection getShortestDestinationPath(
    {LatLng originPosition,
    RouteDetails route,
    RouteIntersection destination,
    List<String> path,
    LatLng endPosition}) {
  RouteIntersection originPath = RouteIntersection();
  LatLng closestPoint = LatLng();
  List<RouteIntersection> paths = [];
  List<double> distances = [];

  if (path.length > 0) {
    destination.coordenates.forEach((dc) {
      double distance = 999.0;
      route.coordenates[0].forEach((c) {
        double d = pointDistance(dc, LatLng(c[1], c[0]));

        if (d < distance) {
          distance = d;
          closestPoint = LatLng(c[1], c[0]);
        }
      });

      // dc = destination.coordenates[1];
      distances.add(distance);
      RouteIntersection newOriginPath = getPath(
          closestPoint: closestPoint,
          route: route,
          originPosition: originPosition);
      newOriginPath.nextRoutePosition = dc;

      if (originPath.coordenates == null) {
        originPath = newOriginPath;
        originPath.nextRoutePosition = dc;
      }

      if (originPath.distance > newOriginPath.distance) {
        originPath = newOriginPath;
        originPath.nextRoutePosition = dc;
      }
      paths.add(newOriginPath);
    });
    return originPath;
  } else {
    return getPath(
        closestPoint: endPosition,
        route: route,
        originPosition: originPosition);
  }
}

List<dynamic> getClosestRoute(LatLng position) {
  String closestRoute = '';
  LatLng closestPoint;

  var tempDistance = 999.0;
  carRoutes.forEach((route) {
    route.coordenates[0].forEach((coordenate) {
      var lat = coordenate[1];
      var lng = coordenate[0];
      var d = pointDistance(position, LatLng(lat, lng));
      if (tempDistance > d) {
        tempDistance = d;
        closestPoint = LatLng(lat, lng);
        closestRoute = route.name;
      }
    });
  });

  return [closestRoute, closestPoint];
}

List<RouteIntersection> getPolylineForPath(String originRoute,
    LatLng originPosition, List<String> path, LatLng endPosition) {
  RouteIntersection destination = path.length == 0
      ? RouteIntersection()
      : routeIntersections[originRoute].firstWhere((ri) => ri.name == path[0]);
  RouteDetails route = carRoutes.firstWhere((ri) => ri.name == originRoute);
  RouteIntersection originPath = getShortestDestinationPath(
      destination: destination,
      endPosition: endPosition,
      path: path,
      originPosition: originPosition,
      route: route);
  originPath.coordenates.insert(0, originPosition);
  originPath.distance = (originPath.distance / 0.001) * 92.8;

  String firstRoute = path.length == 0 ? '' : path[0];

  if (path.length > 0) {
    path.removeAt(0);
  }

  List<RouteIntersection> polylines = [originPath];

  if (firstRoute != '') {
    polylines
      ..addAll(getPolylineForPath(
          firstRoute, originPath.nextRoutePosition, path, endPosition));
  }

  return polylines;
}

List<String> getRouteIntersections(List<String> route) {
  List<String> intersections = [];

  (routeIntersections[route[route.length - 1]]).forEach((ri) {
    intersections.add(ri.name);
  });

  return intersections;
}

void calcRouteDistances() {
  // double tolerance = 0.0018536248271888568;
  // double tolerance = 0.0002817268180330391;
  //26m
  // double tolerance = 0.0002;
  //18.45
  double tolerance = 0.001;
  //92.8

  carRoutes.forEach((route) {
    routeIntersections[route.name] = [];
    var otherRoutes = carRoutes.where((r) => r.name != route.name);

    otherRoutes.forEach((subRoute) {
      var routeI = RouteIntersection();
      routeI.name = subRoute.name;
      routeI.coordenates = List<LatLng>();

      subRoute.coordenates[0].forEach((coord) {
        route.coordenates[0].forEach((coordenate) {
          var lat = coordenate[1];
          var lng = coordenate[0];

          var d = pointDistance(LatLng(coord[1], coord[0]), LatLng(lat, lng));
          if (d <= tolerance) {
            routeI.coordenates.add(LatLng(coord[1], coord[0]));
          }
        });
      });
      if (routeI.coordenates.length > 0) {
        routeIntersections[route.name].add(routeI);
      }
    });
  });
}

LatLng midPoint(double lat1, double lon1, double lat2, double lon2) {
  double dLon = radians(lon2 - lon1);

  //convert to radians
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  lon1 = radians(lon1);

  double x = cos(lat2) * cos(dLon);
  double y = cos(lat2) * sin(dLon);
  double lat3 = atan2(
      sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y));
  double lon3 = lon1 + atan2(y, cos(lat1) + x);

  return LatLng(degrees(lat3), degrees(lon3));
}
