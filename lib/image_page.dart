import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_app/classifier.dart';
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
    await loadModel();

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
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
                      var recognitions;
                      final now = DateTime.now();
                      try {
                        recognitions = await recognizeImageBinary(_imageFile);
                      } on Exception catch (e) {
                        print(e.toString());
                      }
                      setState(() {
                        _recognitions = recognitions;
                      });
                      timeToInfer = DateTime.now().difference(now);

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
