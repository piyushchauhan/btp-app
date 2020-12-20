import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:safety_app/classifier.dart';
import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  CameraPage({@required this.camera});
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
                Text('Your phone details will be stored?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue Recording'),
              onPressed: () {
                haltFrames = false;
                Navigator.of(context).pop();
                // TODO Store IMEI data
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
    loadModel().then((_) {
      modelLoaded = true;
    });
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream((CameraImage img) async {
        if (haltFrames) {
          // await _showMyDialog();
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
                  child: CameraPreview(controller),
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
