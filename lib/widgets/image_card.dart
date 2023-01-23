import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String image;
  final String title;
  final String page;

  ImageCard(this.image, this.title, this.page);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${page}_page',
      child: Container(
        height: 200,
        child: Stack(
          children: <Widget>[
            Container(
              height: 200,
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    fit: BoxFit.fitWidth,
                    image: new AssetImage(image),
                  ),
                  boxShadow: [
                    new BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 5,
                        spreadRadius: 3,
                        offset: Offset(0, 5)),
                  ],
                  borderRadius: BorderRadius.circular(20.0),
                  // border: new Border.all(
                  //   width: 1.0,
                  //   color: Colors.grey.shade100,
                  // ),
                  color: Colors.white
                  // gradient: LinearGradient(
                  //   // Where the linear gradient begins and ends
                  //   begin: Alignment.topRight,
                  //   end: Alignment.bottomLeft,
                  //   // Add one stop for each color. Stops should increase from 0 to 1
                  //   stops: [0, 1],
                  //   colors: [
                  //     // Colors are easy thanks to Flutter's Colors class.
                  //     Colors.white,
                  //     Colors.white10.withOpacity(0.01)
                  //   ],
                  // ),
                  // image: DecorationImage(
                  //   fit: BoxFit.fitHeight,
                  //   image: AssetImage(image),
                  // ),
                  ),
            ),
            // Positioned(
            //   top: 15,
            //   left: 10,
            //   child: Hero(
            //     tag: page,
            //     child: Image(width: 300, image: new AssetImage(image)),
            //   ),
            // ),
            Positioned(
              child: Text(
                title,
                style: TextStyle(
                    shadows: [
                      Shadow(
                          // bottomLeft
                          offset: Offset(-1, -1),
                          color: Colors.white),
                      Shadow(
                          // bottomRight
                          offset: Offset(1, -1),
                          color: Colors.white),
                      Shadow(
                          // topRight
                          offset: Offset(1, 1),
                          color: Colors.white),
                      Shadow(
                          // topLeft
                          offset: Offset(-1, 1),
                          color: Colors.white),
                    ],
                    fontSize: 20.0,
                    fontFamily: "RobotoMedium",
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.65)),
              ),
              top: 30,
              left: 30,
            )
          ],
        ),
      ),
    );
  }
}
