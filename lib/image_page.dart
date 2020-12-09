import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File _imageFile;
  final picker = ImagePicker();
  List _recognitions;
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

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  loadModel() async {
    print('Loading model');
    String res = await Tflite.loadModel(
      model: 'assets/porn-nonporn/porn-classif-fp-32.tflite',
      // model: 'assets/real-fake/real-fake-classif-fp32.tflite',
      labels: 'assets/porn-nonporn/labels.txt',
      // labels: 'assets/real-fake/labels.txt',
      numThreads: 4,
      // defaults to 1
      isAsset: true,
      // defaults to true, set to false to load resources outside assets
      // useGpuDelegate: true,
      // defaults to false, set to true to use GPU delegate
    );

    print('Load model result: $res');
  }

  Future recognizeImageBinary(File image) async {
    final start = DateTime.now();
    img.Image oriImage = img.decodeImage(image.readAsBytesSync());
    final inputSize = 64;
    img.Image resizedImage = img.copyResize(
      oriImage,
      height: inputSize,
      width: inputSize,
    );
    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, inputSize, 117.0, 1),
      numResults: 6,
      threshold: 0.05,
    );
    setState(() {
      _recognitions = recognitions;
    });
    timeToInfer = DateTime.now().difference(start);
    print("Inference took ${timeToInfer.inMilliseconds} ms");
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
                      await loadModel();
                      try {
                        await recognizeImageBinary(_imageFile);
                      } on Exception catch (e) {
                        print(e.toString());
                      }

                      print(_recognitions.toString());
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return InferenceModelSheet(
                            recognitions: _recognitions,
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
                          final double confidence = recognition['confidence'];
                          final String label = recognition['label'];
                          return Text('$label : $confidence');
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
