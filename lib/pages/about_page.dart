import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:stgo_routes/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutPage();
  }
}

class _AboutPage extends State<AboutPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: lightGrey,
          iconTheme: IconThemeData(color: Colors.black.withOpacity(0.54)),
          title: Text('Acerca de',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w700)),
          elevation: 0.0,
          leading: IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.arrow_back),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            color: Colors.black.withOpacity(0.5),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: AnimatedBackground(
            behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
              image: Image(image: new AssetImage('assets/images/top_car.png')),
              particleCount: 25,
              spawnMinSpeed: 50,
              spawnMaxSpeed: 80,
              spawnMinRadius: 10,
              spawnMaxRadius: 20,
              minOpacity: 0.1,
              maxOpacity: 0.4,
            )),
            vsync: this,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    "Rutas de Santiago",
                    style: TextStyle(
                        fontFamily: "RobotoMedium",
                        fontSize: 34.0,
                        color: darkText.withOpacity(darkText.opacity * 0.75)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0, bottom: 14.0),
                    child: Text(
                      "v1.0-b",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 17.0,
                          height: 1.5,
                          color: darkText.withOpacity(darkText.opacity * 0.5)),
                    ),
                  ),
                  Container(
                      child: Column(children: [
                    Text(
                      'Creado por Luis Ventura',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: darkText.withOpacity(darkText.opacity * 0.75),
                        fontFamily: "Roboto",
                        fontSize: 17.0,
                        height: 1.5,
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        'luis.ventura005@gmail.com',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontFamily: "Roboto",
                          fontSize: 17.0,
                          height: 1.5,
                        ),
                      ),
                      onPressed: () async {
                        const url = 'mailto:luis.ventura005@gmail.com';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {}
                      },
                    ),
                  ])),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Este es un proyecto en desarrollo, errores e inexactitudes pueden ocurrir, utilizar los resultados de esta aplicación solo como referencias.\n Para contribuir con el proyecto ponerse en contacto via email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ))
                  // Text(
                  //   "Creado con",
                  //   style: TextStyle(
                  //       fontFamily: "Roboto",
                  //       fontSize: 17.0,
                  //       height: 1.5,
                  //       color: Colors.black.withOpacity(0.5)),
                  // ),
                  // Padding(
                  //     padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  //     child: Row(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           Image.asset("assets/images/flutter_logo.png",
                  //               height: 45.0, width: 37.0),
                  //           Container(
                  //             margin: const EdgeInsets.only(left: 5.0),
                  //             child: Text(
                  //               "Flutter",
                  //               style: TextStyle(
                  //                   fontSize: 26.0,
                  //                   color: darkText
                  //                       .withOpacity(darkText.opacity * 0.6)),
                  //             ),
                  //           )
                  //         ])),
                ],
              ),
            )));
  }
}
