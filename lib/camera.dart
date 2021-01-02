import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:safety_app/classifier.dart';
import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  final String imei;
  CameraPage({@required this.cameras, this.imei});
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  bool isDetecting = false;
  bool modelLoaded = false;
  bool haltFrames = false;
  bool recording = true;

  List _recognitions;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Obscene content detected'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are recording content that is obscene'),
                Text('Your IMEI number is ${widget.imei} '
                    'will shared with admin.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue Recording'),
              onPressed: () {
                haltFrames = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Stop Recording'),
              onPressed: () {
                // controller.stopImageStream();
                haltFrames = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  printLables() {
    String ans = '';
    if (_recognitions != null && modelLoaded)
      _recognitions.forEach((element) async {
        ans += element['label'].toString() +
            ' ' +
            element['confidence'].toString() +
            '\n';
        if (element['label'] == 'obscene' && element['confidence'] > 0.5) {
          haltFrames = true;
          recording = false;
        }
      });

    return ans;
  }

  @override
  void initState() {
    super.initState();
    print('IMEI number ' + widget.imei);
    loadModel().then((_) {
      modelLoaded = true;
    });
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      setState(() {});
      await Future.delayed(Duration(milliseconds: 200));
      controller.startImageStream((CameraImage img) async {
        if (haltFrames) {
          await _showMyDialog();
        } else if (modelLoaded && !isDetecting) {
          isDetecting = true;
          int startTime = new DateTime.now().millisecondsSinceEpoch;

          Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: img.height,
            imageWidth: img.width,
            numResults: 2,
            threshold: 0,
          ).then((recognitions) {
            setState(() {
              _recognitions = recognitions;
              isDetecting = false;
            });
            /* 
            int endTime = new DateTime.now().millisecondsSinceEpoch;
            print("Detection took ${endTime - startTime}");
            print('Inference:' + recognitions.toString()); 
            */
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: !controller.value.isInitialized
          ? Container()
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: haltFrames ? CameraPreview(controller) : Container(),
                ),
                Text('Time epoch: ${DateTime.now().millisecondsSinceEpoch}\n' +
                    printLables()),
              ],
            ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
