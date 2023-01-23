import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stgo_routes/constants.dart';
import 'package:stgo_routes/pages/about_page.dart';
import 'package:stgo_routes/pages/create_route_page.dart';
import 'package:stgo_routes/pages/home_page.dart';
import 'package:stgo_routes/pages/omsa_page.dart';
import 'package:stgo_routes/pages/routes_page.dart';
import 'package:map_view/map_view.dart';

void main() {
  // debugPaintSizeEnabled = true;
  MapView.setApiKey(googleMapsApiKey);
  runApp(StgoRoutesApp());
}

class StgoRoutesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stgo Routes',
      theme: ThemeData(
        fontFamily: 'RobotoMedium',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/routes': (context) => RoutesPage(),
        '/about': (context) => AboutPage(),
        '/omsa': (context) => OMSAPage(),
        '/create_route': (context) => CreateRoutePage(),
      },
    );
  }
}
