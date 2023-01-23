import 'package:flutter/material.dart';
import 'package:stgo_routes/colors.dart';
import 'package:stgo_routes/widgets/image_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Widget _buildMenuCard(
      String image, String title, BuildContext context, String page) {
    return GestureDetector(
      child: ImageCard(image, title, page),
      onTap: () {
        Navigator.pushNamed(context, '/' + page);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: lightGrey,
          title: Center(
            child: Text('Rutas de Santiago',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w700)),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            // Stack(
            //   children: <Widget>[
            //     Positioned(
            //       child: Container(
            //         height: 80,
            //         child: WaveWidget(
            //           config: CustomConfig(
            //             gradients: [
            //               [Colors.blueGrey, Colors.blueGrey.withOpacity(0.5)],
            //             ],
            //             durations: [6000],
            //             heightPercentages: [0.25],
            //             gradientBegin: Alignment.bottomLeft,
            //             gradientEnd: Alignment.topRight,
            //           ),
            //           waveAmplitude: 0,
            //           backgroundColor: Colors.white,
            //           size: Size(
            //             double.infinity,
            //             double.infinity,
            //           ),
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       top: 40,
            //       left: MediaQuery.of(context).size.width / 4,
            //       child: Center(
            //         child: Text(
            //           'Rutas de Santiago',
            //           style: TextStyle(
            //               fontSize: 30,
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Column(
                    children: [
                      _buildMenuCard('assets/images/car_routes.jpg', 'Conchos',
                          context, 'routes'),
                      _buildMenuCard('assets/images/omsa_routes.jpg', 'Omsa',
                          context, 'omsa'),
                      _buildMenuCard('assets/images/calc_routes.jpg',
                          'Obtener Ruta', context, 'create_route'),
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, bottom: 0, left: 20, right: 20),
                        height: 1.0,
                        color: const Color.fromRGBO(151, 151, 151, 0.29),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0, top: 10, left: 5),
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/about');
                            },
                            color: Colors.transparent,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 17),
                                    child: Icon(Icons.info,
                                        color: Colors.black.withOpacity(0.65)),
                                  ),
                                  Text(
                                    "Acerda de",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: "RobotoMedium",
                                        color: Colors.black.withOpacity(0.65)),
                                  )
                                ])),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
