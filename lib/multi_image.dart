import 'dart:typed_data';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

import 'package:image/image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safety_app/camera.dart';
import 'package:safety_app/classifier.dart';

import 'model/recognition.dart';

class MultiImagePage extends StatefulWidget {
  @override
  _MultiImagePageState createState() => _MultiImagePageState();
}

class _MultiImagePageState extends State<MultiImagePage> {
  // ignore: deprecated_member_use
  List<Asset> images = List<Asset>();
  List<Recognition> recognitions;
  List<bool> statusImage;
  String _error;

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    if (images != null)
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return Stack(
            children: [
              AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
              statusImage[index]
                  ? Container(
                      color: Colors.white54,
                      width: 300,
                      child: Text(
                        recognitions[index].toString(),
                        style: TextStyle(fontSize: 10),
                      ))
                  : CircularProgressIndicator(),
            ],
          );
        }),
      );
    else
      return Container(color: Colors.white);
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      if (error == null) _error = 'No Error Dectected';

      // TODO Start processing here
      processImages();
    });
  }

  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<File> assetThumbToFile(Asset asset, String path) async {
    final ByteData byteData = await asset.getByteData();
    final path2 = await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
    return await writeToFile(byteData, path2);
  }

  Future<Recognition> processImage(int index) async {
    final path = 'assets/$index.jpg';
    Asset asset = images[index];
    final File img = await assetThumbToFile(asset, path);
    final recognitions = await recognizeImageBinary(img);
    return Recognition(List<RecognitionValue>.from(recognitions
        .map((e) => RecognitionValue.fromJson(Map<String, dynamic>.from(e)))));
  }

  processImages() async {
    final int numImages = images.length;
    statusImage = List.generate(numImages, (index) => false);
    recognitions = List.generate(numImages, (index) => null);
    for (var i = 0; i < numImages; i++) {
      recognitions[i] = await processImage(i);

      setState(() {
        statusImage[i] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Image'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadAssets,
        child: Icon(Icons.add_a_photo),
      ),
      body: Column(
        children: <Widget>[
          // Center(child: Text('Error: $_error')),
          // ElevatedButton(
          //   child: Text("Pick images"),
          //   onPressed: loadAssets,
          // ),
          Expanded(
            child: buildGridView(),
          ),
        ],
      ),
    );
  }
}
