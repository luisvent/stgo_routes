import 'package:flutter/material.dart';

class CarRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarRouteState();
  }
}

class _CarRouteState extends State<CarRoute> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Tus rutas salvadas',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage('assets/images/favorites.png'),
            ),
          ),
        )
      ],
    );
  }
}
