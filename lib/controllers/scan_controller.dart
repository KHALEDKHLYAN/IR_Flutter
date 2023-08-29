import 'dart:math';

import 'package:camera/camera.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:tflite/tflite.dart';
import 'dart:developer';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    Tflite.close();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  late CameraImage cameraImage;

  var isCameraInitializied = false.obs;
  var cameraCount = 0;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
      );
      await cameraController.initialize().then((value) {
        cameraCount++;
        if (cameraCount % 10 == 0) {
          cameraCount = 0;
          cameraController.startImageStream((image) => objectDetector(image));
          update();
        }
      });
      isCameraInitializied.value = true;
      update();
    } else {
      print("Permission denied");
    }
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null) {
      log("Result is $detector");
    }
  }
}
