import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();
  List recognitions;
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classification app'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Column(
                children: [
                  Image.file(
                    _image,
                    height: MediaQuery.of(context).size.height * .8,
                    width: MediaQuery.of(context).size.width * .8,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      print('Evaluating');
                      String res = await Tflite.loadModel(
                          model:
                              "assets/efficientnet-lite3/efficientnet-lite3-fp32.tflite",
                          labels: "assets/labels_map.txt",
                          numThreads: 1, // defaults to 1
                          isAsset:
                              true, // defaults to true, set to false to load resources outside assets
                          useGpuDelegate:
                              true // defaults to false, set to true to use GPU delegate
                          );

                      print(res);
                      // Process

                      recognitions = await Tflite.runModelOnImage(
                          path: _image.path, // required
                          // imageMean: 0.0, // defaults to 117.0
                          // imageStd: 255.0, // defaults to 1.0
                          // numResults: 2, // defaults to 5
                          threshold: 0.1, // defaults to 0.1
                          asynch: true // defaults to true
                          );
                      print(recognitions);
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return InferenceModelSheet(
                              recognitions: recognitions);
                        },
                      );
                      await Tflite.close();
                    },
                    child: Text('Evaluate'),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class InferenceModelSheet extends StatelessWidget {
  const InferenceModelSheet({
    Key key,
    @required this.recognitions,
  }) : super(key: key);

  final List recognitions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Inference Results',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            // Text(recognitions.toString()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                    itemExtent: 20,
                    itemCount: recognitions.length,
                    itemBuilder: (context, index) {
                      final recognition = recognitions[index];
                      final confidence = recognition['confidence'].toDouble();
                      final modi = recognition['label']
                          .split(':')[1]
                          .trim()
                          .substring(1);
                      final label = modi.substring(0, modi.length - 2);
                      return Text('$label:\t$confidence');
                    }),
              ),
            ),
            RaisedButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
