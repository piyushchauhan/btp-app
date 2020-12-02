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
              color: Colors.yellow,
              child: Container(
                child: Center(child: Text('IMAGE')),
                height: MediaQuery.of(context).size.height * 8 / 10,
                width: MediaQuery.of(context).size.width * 3 / 10,
              ),
            ),
            SizedBox(width: 20),
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
                height: MediaQuery.of(context).size.height * 8 / 10,
                width: MediaQuery.of(context).size.width * 3 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
