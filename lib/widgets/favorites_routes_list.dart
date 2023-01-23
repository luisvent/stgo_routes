import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stgo_routes/car_routes_data.dart';
import 'package:stgo_routes/models.dart';

class FavoritesRoutesList extends StatefulWidget {
  final Function updateFavorites;
  final Function showMap;

  FavoritesRoutesList({this.updateFavorites, this.showMap});

  @override
  State<StatefulWidget> createState() {
    return _FavoritesRoutesListState(updateFavorites, showMap);
  }
}

class _FavoritesRoutesListState extends State<FavoritesRoutesList>
    with TickerProviderStateMixin {
  _FavoritesRoutesListState(this.updateFavorites, this.showMap);

  final Function updateFavorites;
  final Function showMap;
  List<RouteDetails> routes = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<RouteDetails> favoritesList = [];
  Timer timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<List<String>> _getFavoriteRoutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteRoutes = prefs.getStringList('favorite_routes') == null
        ? List<String>()
        : prefs.getStringList('favorite_routes');
    return favoriteRoutes;
  }

  Future removeFavoriteRoute(int index) async {
    var route = favoritesList.removeAt(index);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _getFavoriteRoutes().then((List<String> favorites) async {
      var newFavs = favorites.where((String f) => f != route.name).toList();
      await prefs.setStringList('favorite_routes', newFavs);
      updateFavorites(newFavs);
    });
    _listKey.currentState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return FadeTransition(
          opacity:
              CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
          child: SizeTransition(
            sizeFactor:
                CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
            axisAlignment: 0.0,
            child: _buildItem(route, index),
          ),
        );
      },
      duration: Duration(milliseconds: 600),
    );
  }

  @override
  initState() {
    super.initState();

    _getFavoriteRoutes().then((List<String> favorites) async {
      favorites.forEach((f) {
        int index = favoritesList.length;
        var route = carRoutes.firstWhere((RouteDetails r) => r.name == f);

        favoritesList.add(route);

        _listKey.currentState
            .insertItem(index, duration: Duration(milliseconds: 500));
      });
    });
  }

  Widget _buildItem(RouteDetails route, int index) {
    return GestureDetector(
      onTap: () {
        showMap(route);
      },
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  'assets/images/nav_icon_${route.name.toLowerCase()}.png',
                  height: 30,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ruta ${route.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Distancia: ${route.routeDistance}Km',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Precio: \$${route.price}',
                      style: TextStyle(color: Colors.grey.shade700),
                    )
                  ],
                )
              ],
            ),
            IconButton(
              color: Colors.redAccent,
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                removeFavoriteRoute(index);
              },
            )
          ],
        ),
      ),
    );

    //  ListTile(
    //   onTap: () {
    //     showMap(route);
    //   },
    //   key: ValueKey<RouteDetails>(route),
    //   title: Text('Ruta ${route.name}'),
    //   subtitle: Row(
    //     children: <Widget>[
    //       Text(
    //         'Distancia:',
    //         style: TextStyle(color: Colors.grey.shade700),
    //       ),
    //       SizedBox(
    //         width: 5,
    //       ),
    //       Text('${route.routeDistance.toString()} Km',
    //           style: TextStyle(color: Colors.grey.shade600)),
    //       SizedBox(
    //         width: 50,
    //       ),
    //       Text('Precio: \$${route.price}'),
    //     ],
    //   ),
    //   leading: Container(
    //     width: 50,
    //     height: 50,
    //     decoration: new BoxDecoration(
    //         // Circle shape
    //         shape: BoxShape.circle,
    //         color: Colors.white,
    //         // The border you want
    //         border: new Border.all(
    //           width: 1.0,
    //           color: Colors.white,
    //         ),
    //         // The shadow you want
    //         boxShadow: [
    //           new BoxShadow(
    //             color: Colors.black.withOpacity(0.2),
    //             blurRadius: 5.0,
    //           ),
    //         ]),
    //     child: Center(
    //       child: Image.asset(
    //         'assets/images/nav_icon_${route.name.toLowerCase()}.png',
    //         height: 40,
    //       ),
    //     ),
    //   ),
    //   trailing: IconButton(
    //     color: Colors.redAccent,
    //     icon: Icon(Icons.delete_outline),
    //     onPressed: () {
    //       removeFavoriteRoute(index);
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          child: Text(
            'Favoritos',
            style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          padding: EdgeInsets.all(10),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: favoritesList.length,
            itemBuilder:
                (BuildContext context, int index, Animation animation) {
              return FadeTransition(
                opacity: animation,
                child: Column(
                  children: <Widget>[
                    _buildItem(favoritesList[index], index),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
