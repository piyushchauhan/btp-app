import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File _imageFile;
  final picker = ImagePicker();
  List recognitions;
  Duration timeToInfer;
  bool isLoading;
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Center(
        child: _imageFile == null
            ? Text('No image selected.')
            : Column(
                children: [
                  Image.file(
                    _imageFile,
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
                          numThreads: 1,
                          // defaults to 1
                          isAsset: true,
                          // defaults to true, set to false to load resources outside assets
                          useGpuDelegate: true
                          // defaults to false, set to true to use GPU delegate
                          );

                      print(res);
                      DateTime start = DateTime.now();

                      // Process
                      /*
                      img.Image image =
                          img.decodeImage(_imageFile.readAsBytesSync());
                      recognitions = await Tflite.runModelOnBinary(
                          binary: imageToByteListUint8(image, 112), // required
                          numResults: 6, // defaults to 5
                          threshold: 0.1, // defaults to 0.1

                          asynch: true // defaults to true
                          );
                          */

                      recognitions = await Tflite.runModelOnImage(
                          path: _imageFile.path, // required
                          // imageMean: 0.0, // defaults to 117.0
                          // imageStd: 255.0, // defaults to 1.0
                          // numResults: 2, // defaults to 5
                          threshold: 0.1, // defaults to 0.1
                          asynch: true // defaults to true
                          );
                      timeToInfer = DateTime.now().difference(start);
                      print(recognitions);
                      print('Time to infer: ${timeToInfer.inMilliseconds} ms');
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return InferenceModelSheet(
                            recognitions: recognitions,
                            timetoInfer: timeToInfer,
                          );
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
    @required this.timetoInfer,
  }) : super(key: key);
  final Duration timetoInfer;
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
                child: recognitions.length > 0
                    ? ListView.separated(
                        // itemExtent: 20,
                        itemCount: recognitions.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 2,
                            color: Colors.white,
                          );
                        },
                        itemBuilder: (context, index) {
                          final recognition = recognitions[index];
                          final confidence =
                              recognition['confidence'].toDouble();
                          final modi = recognition['label']
                              .split(':')[1]
                              .trim()
                              .substring(1);
                          final label = modi.substring(0, modi.length - 2);
                          return Text('$label:\t$confidence');
                        })
                    : Text('No results'),
              ),
            ),
            Text('Time to infer: ${timetoInfer.inMilliseconds} ms'),
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
