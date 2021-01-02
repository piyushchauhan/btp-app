import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:safety_app/camera.dart';
import 'package:safety_app/image_page.dart';
import 'package:safety_app/video_page.dart';
import 'package:imei_plugin/imei_plugin.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imei;
  getImei() async {
    String i = await ImeiPlugin.getImei();
    setState(() {
      imei = i;
    });
  }

  @override
  void initState() {
    super.initState();
    getImei();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classification app'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              color: Colors.green,
              onPressed: () async {
                List<CameraDescription> cameras = await availableCameras();
                if (cameras.length > 0)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        cameras: cameras,
                        imei: imei,
                      ),
                    ),
                  );
              },
              child: Container(child: Center(child: Text('CAMERA'))),
            ),
            RaisedButton(
              color: Colors.yellow,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImagePage()));
              },
              child: Container(child: Center(child: Text('GALLERY'))),
            ),
            /* RaisedButton(
              color: Colors.lightBlue,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen()));
              },
              child: Container(
                child: Center(child: Text('VIDEO')),
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
