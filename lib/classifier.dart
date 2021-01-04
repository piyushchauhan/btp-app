import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

Future<String> loadModel() async {
  final modelFile = 'assets/porn-nonporn/student32.tflite';
  print('Loading model $modelFile');
  String res = await Tflite.loadModel(
    model: modelFile,
    labels: 'assets/porn-nonporn/labels.txt',
    numThreads: 100,
    isAsset: true,
    useGpuDelegate: true,
  );

  print('Load model result: $res');
  return res;
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

Future<List> recognizeImageBinary(File image) async {
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
  final timeToInfer = DateTime.now().difference(start);
  print("Inference took ${timeToInfer.inMilliseconds} ms");
  return recognitions;
}

Future cameraClassif(CameraImage img) async {
  var recognitions = await Tflite.runModelOnFrame(
    bytesList: img.planes.map((plane) {
      return plane.bytes;
    }).toList(),
    imageHeight: img.height,
    imageWidth: img.width,
    // imageMean: 127.5, // defaults to 127.5
    // imageStd: 127.5, // defaults to 127.5
    // rotation: 90, // defaults to 90, Android only
    // numResults: 2, // defaults to 5
    // threshold: 0.1, // defaults to 0.1
    // asynch: true // defaults to true
  );

  return recognitions;
}
