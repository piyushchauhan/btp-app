import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:safety_app/camera.dart';
import 'package:safety_app/image_page.dart';
import 'package:safety_app/video_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                      builder: (context) => CameraPage(camera: cameras[0]),
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
              child: Container(child: Center(child: Text('IMAGE'))),
            ),
            RaisedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
