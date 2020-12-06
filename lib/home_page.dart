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
            /* RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImagePage()));
              },
              color: ,
              child: Container(
                child: Center(child: Text('IMAGE')),
                height: MediaQuery.of(context).size.height * 8 / 10,
                width: MediaQuery.of(context).size.width * 3 / 10,
              ),
            ), */
            OperationButton(
              name: 'IMAGE',
              color: Colors.yellow,
              screen: ImagePage(),
            ),
            SizedBox(width: 20),
            OperationButton(
              name: 'VIDEO',
              screen: VideoPlayerScreen(),
              color: Colors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class OperationButton extends StatelessWidget {
  final screen;

  final color;
  final String name;
  const OperationButton({
    Key key,
    this.color,
    @required this.screen,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        child: Center(child: Text(name)),
        height: MediaQuery.of(context).size.height * 8 / 10,
        width: MediaQuery.of(context).size.width * 3 / 10,
      ),
    );
  }
}
