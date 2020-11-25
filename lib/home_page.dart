import 'package:flutter/material.dart';
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
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImagePage()));
              },
              child: Text('Image'),
            ),
            SizedBox(width: 20),
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
              },
              child: Text('Video'),
            ),
          ],
        ),
      ),
    );
  }
}
