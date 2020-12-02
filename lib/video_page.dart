import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  File videoFile;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Visibility(
            visible: _controller != null,
            child: Center(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          Center(
            child: RaisedButton(
              color: Colors.blue,
              child: Text("Video"),
              onPressed: () {
                getVideo();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Wrap the play or pause in a call to `setState`. This ensures the
                // correct icon is shown.
                _controller.position.then((value) => print(
                    '${value.inMinutes} m : ${value.inSeconds} s: ${value.inMilliseconds} ms'));

                setState(() {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              },
              // Display the correct icon depending on the state of the player.
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future getVideo() async {
    final _picker = ImagePicker();

    Future<PickedFile> _videoFile =
        _picker.getVideo(source: ImageSource.gallery);
    _videoFile.then((file) async {
      setState(() {
        _controller = VideoPlayerController.file(File(file.path));

        // Initialize the controller and store the Future for later use.
        _initializeVideoPlayerFuture = _controller.initialize();

        // Use the controller to loop the video.
        _controller.setLooping(true);
      });
    });
  }
}
