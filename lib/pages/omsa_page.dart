import 'package:flutter/material.dart';
import 'package:stgo_routes/constants.dart';
import 'package:stgo_routes/maps_tools.dart';
import 'package:stgo_routes/models.dart';
import 'package:stgo_routes/omsa_routes_data.dart';
import 'package:stgo_routes/pages/omsa_details.dart';
import 'package:stgo_routes/widgets/dots_indicator.dart';

class OMSAPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OMSAPageState();
  }
}

class _OMSAPageState extends State<OMSAPage> {
  List<OMSADetails> omsas = [omsaC3];
  final pageController = PageController(initialPage: 0);

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  String _generateOMSAStaticImageUrl(OMSADetails omsa) {
    List<LatLng> points = [];

    omsa.coordenates.forEach((c) {
      points.add(LatLng(c[1], c[0]));
    });

    String encodedPath = encode(points);
    String imageUrl =
        'https://maps.googleapis.com/maps/api/staticmap?zoom=13&size=600x600&center=19.449539,-70.690619&maptype=roadmap&path=color:0x66ddaa|weight:5|enc:$encodedPath&key=$googleMapsApiKey';
    return imageUrl;
  }

  Widget _buildOMSAItem(OMSADetails omsa) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OMSADetailsPage(omsa),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Hero(
            tag: omsa.codeName,
            child: Container(
              height: 100,
              color: Colors.greenAccent,
              child: Container(
                child: Center(
                  child: Text(
                    '${omsa.name}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  fit: BoxFit.fitHeight,
                  image: NetworkImage(_generateOMSAStaticImageUrl(omsa)),
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
        // appBar: AppBar(
        //   backgroundColor: Colors.greenAccent,
        //   iconTheme: IconThemeData(color: Colors.black.withOpacity(0.54)),
        //   title: Container(
        //     decoration: BoxDecoration(
        //         image: DecorationImage(
        //           alignment: Alignment.center,
        //           fit: BoxFit.fill,
        //           image: new AssetImage('assets/images/calc_routes_header.jpg'),
        //         ),
        //         boxShadow: [
        //           new BoxShadow(
        //               color: Color.fromRGBO(0, 0, 0, 0.06),
        //               blurRadius: 5,
        //               spreadRadius: 3,
        //               offset: Offset(0, 5)),
        //         ],
        //         color: Colors.white),
        //   ),
        //   // title: Text('OMSA',
        //   //     textAlign: TextAlign.left,
        //   //     style: TextStyle(
        //   //       color: Colors.black.withOpacity(0.6),
        //   //     )),
        //   elevation: 0.0,
        //   leading: Container(
        //     width: 50,
        //     color: Colors.red,
        //   ),
        //   centerTitle: false,
        //   // actions: <Widget>[
        //   //   Container(
        //   //     color: Colors.red,
        //   //     width: 40,
        //   //   )
        //   // ],
        // ),

        // leading: Container(
        //   margin: EdgeInsets.only(left: 5),
        //   child: Hero(
        //     tag: 'omsa',
        //     child: Container(
        //         height: 40,
        //         child: Image.asset(
        //           'assets/images/omsa.png',
        //         )),
        //   ),
        // )),
        body: Column(
          children: <Widget>[
            Hero(
              tag: 'omsa_page',
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.fitHeight,
                      image: new AssetImage(
                          'assets/images/omsa_routes_header.jpg'),
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  new PageView.builder(
                    itemCount: omsas.length,
                    physics: new AlwaysScrollableScrollPhysics(),
                    controller: pageController,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildOMSAItem(omsas[index % omsas.length]);
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
                          itemCount: omsas.length,
                          color: Colors.greenAccent,
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
              ),
            )
          ],
        ));
  }
}
