import 'package:flutter/material.dart';
import 'package:stgo_routes/constants.dart';
import 'package:stgo_routes/models.dart';

class OMSAStopPage extends StatefulWidget {
  final OMSAStop stop;

  OMSAStopPage(this.stop);

  @override
  State<StatefulWidget> createState() {
    return _OMSAStopPageState(stop);
  }
}

class _OMSAStopPageState extends State<OMSAStopPage> {
  OMSAStop stop;
  String mapImageUrl;
  _OMSAStopPageState(this.stop) {
    mapImageUrl =
        "https://maps.googleapis.com/maps/api/staticmap?zoom=18&size=600x600&maptype=roadmap&markers=anchor:bottom|icon:https://i.imgur.com/4OEmDcU.png|${stop.location[1]},${stop.location[0]}&key=$googleMapsApiKey";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 60, bottom: 30, left: 30, right: 30),
              child: Row(
                children: <Widget>[
                  IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Icon(Icons.arrow_back),
                    padding: EdgeInsets.only(top: 23, left: 20.0, right: 20.0),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/bus_stop_icon_white.png',
                        height: 60,
                      ),
                      title: Text(
                        '${stop.name}',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${stop.reference}',
                          style:
                              TextStyle(fontSize: 15, color: Colors.white70)),
                    ),
                  ),
                ],
              )),
          Hero(
            tag: '${stop.code}',
            child: Container(
              margin: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    fit: BoxFit.fitHeight,
                    image: NetworkImage(mapImageUrl),
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
            ),
          )
        ],
      ),
    );
  }
}
