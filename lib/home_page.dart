import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:safety_app/camera.dart';
import 'package:safety_app/image_page.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.green,
                    ),
                  ),
                  onPressed: () async {
                    List<CameraDescription> cameras = await availableCameras();
                    if (cameras.length > 0)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraExampleHome(
                            cameras: cameras,
                            imei: imei,
                          ),
                        ),
                      );
                  },
                  child: Center(
                    child: Text('REAL TIME'),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) =>
                          Colors.yellow, // Use the component's default.
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImagePage()),
                    );
                  },
                  child: Container(child: Center(child: Text('Gallery'))),
                ),
                /* 
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
                ), */
              ],
            ),
          ),
          Report(imei: imei),
        ],
      ),
    );
  }
}

class Report extends StatelessWidget {
  const Report({
    Key key,
    @required this.imei,
  }) : super(key: key);

  final String imei;

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('obscene-recorders');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      return users
          .add({
            'imei': imei, // John Doe
            'datetime': DateTime.now().toIso8601String(), // Stokes and Sons
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text('Your IMEI number is $imei'),
          // RaisedButton(onPressed: addUser, child: Text('Report'))
        ],
      ),
    );
  }
}
