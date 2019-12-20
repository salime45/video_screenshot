import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController playerController;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Screenshot"),
      ),
      body: Center(
        child: Screenshot(
            controller: screenshotController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                playerController != null
                    ? AspectRatio(
                        aspectRatio: playerController.value.aspectRatio,
                        child: VideoPlayer(playerController),
                      )
                    : Container(),
                FloatingActionButton(
                  onPressed: saveImage,
                  child: Icon(Icons.image),
                ),
              ],
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickVideo,
        child: Icon(Icons.videocam),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  pickVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      playerController = VideoPlayerController.file(File(video.path))
        ..setLooping(true)
        ..setVolume(0)
        ..initialize();
      playerController.play();
      setState(() {});
    }
  }

  saveImage() async {
    var path = await screenShot();
    exportToGallery(path);
  }

  Future<String> screenShot() async {
    File image = await screenshotController.capture(pixelRatio: 1.2, delay: Duration(microseconds: 300));
    return image.path;
  }

  exportToGallery(String image) async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    final result = await ImageGallerySaver.saveFile(image);
    print("File Saved to Gallery " + result.toString());
  }
}
