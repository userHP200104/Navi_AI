import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

import '../main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
        required this.title,
        required this.customPaint,
        this.text,
        required this.onImage,
        this.onScreenModeChanged,
        this.initialDirection = CameraLensDirection.front})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  int _cameraIndex = 1;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  bool isWorking = false;
  String result="";
  String newResult="";
  late CameraImage imgCamera;

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller?.initialize().then((value) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  runModelOnStreamFrames() async {
    print("Model Running!!?");

    var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        // required
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        // defaults to 127.5
        imageStd: 127.5,
        // defaults to 127.5
        rotation: 90,
        // defaults to 90, Android only
        numResults: 1,
        // defaults to 5
        threshold: 0.1,
        // defaults to 0.1
        asynch: true
    );

    print("I ran agian!!");
    print(recognitions);
    result = "";

    recognitions?.forEach((response)
    {
      print("Response: " + response.toString());
      // result += response["label"].toString() + " " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      result += response["label"].toString();
    });
    

    setState(() {
      result;
    });

    print("Result, " + result);

    isWorking = false;
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    _imagePicker = ImagePicker();

    if (cameras.any(
          (element) =>
      element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
        element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
              (element) => element.lensDirection == widget.initialDirection,
        ),
      );
    }

    _startLiveFeed();
  }

  @override
  void dispose() async {
    await Tflite.close();
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');

        dispose();

        //trigger leaving and use own data
        Navigator.pop(context, false);

        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          // actions: [
          //   if (_allowPicker)
          //     Padding(
          //       padding: EdgeInsets.only(right: 20.0),
          //       child: GestureDetector(
          //         onTap: _switchScreenMode,
          //         child: Icon(
          //           _mode == ScreenMode.liveFeed
          //               ? Icons.photo_library_outlined
          //               : (Platform.isIOS
          //               ? Icons.camera_alt_outlined
          //               : Icons.camera),
          //         ),
          //       ),
          //     ),
          // ],
        ),
        body: _body(result),

        // floatingActionButton: _floatingActionButton(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // Widget? _floatingActionButton() {
  //   if (_mode == ScreenMode.gallery) return null;
  //   if (cameras.length == 1) return null;
  //   return SizedBox(
  //       height: 70.0,
  //       width: 70.0,
  //       child: FloatingActionButton(
  //         child: Icon(
  //           Platform.isIOS
  //               ? Icons.flip_camera_ios_outlined
  //               : Icons.flip_camera_android_outlined,
  //           size: 40,
  //         ),
  //         onPressed: _switchLiveCamera,
  //       ));
  // }


  Widget _body(String result) {
    Widget body;
    if (_mode == ScreenMode.liveFeed) {
      body = _liveFeedBody(result);
    } else {
      body = _galleryBody();
    }
    return body;
  }

  Widget _liveFeedBody(String result) {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;


    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (widget.title == result)
              ?Colors.lightGreenAccent
              :Colors.redAccent,
          width: 8
        ),
        color: Colors.black87
      ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: scale,
                child: Center(
                  child: _changingCameraLens
                      ? Center(
                    child: const Text('Changing camera lens'),
                  )
                      : CameraPreview(_controller!),
                ),
              ),
              if (widget.customPaint != null) widget.customPaint!,
              Positioned(
                bottom: 10,
                left: 70,
                right: 70,

                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 34),
                    child: SizedBox(
                      child: Center(
                        child: Text(
                            result,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              // Positioned(
              //   bottom: 100,
              //   left: 50,
              //   right: 50,
              //   child: Slider(
              //     value: zoomLevel,
              //     min: minZoomLevel,
              //     max: maxZoomLevel,
              //     onChanged: (newSliderValue) {
              //       setState(() {
              //         zoomLevel = newSliderValue;
              //         _controller!.setZoomLevel(zoomLevel);
              //       });
              //     },
              //     divisions: (maxZoomLevel - 1).toInt() < 1
              //         ? null
              //         : (maxZoomLevel - 1).toInt(),
              //   ),
              // ),
            ],
          ),
    );
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
        height: 400,
        width: 400,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(_image!),
            if (widget.customPaint != null) widget.customPaint!,
          ],
        ),
      )
          : Icon(
        Icons.image,
        size: 200,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  void _switchScreenMode() {
    _image = null;
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      _startLiveFeed();
    }
    if (widget.onScreenModeChanged != null) {
      widget.onScreenModeChanged!(_mode);
    }
    setState(() {});
  }

  Future _stopLiveFeed() async {
    await Tflite.close();
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
    InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    if(!isWorking){
      isWorking = true;
      imgCamera = image;
      runModelOnStreamFrames();
    }

    widget.onImage(inputImage);
  }
}