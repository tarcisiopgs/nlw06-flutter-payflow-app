import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

class BarcodeScannerController {
  final statusNotifier =
      ValueNotifier<BarcodeScannerStatus>(BarcodeScannerStatus());

  BarcodeScannerStatus get status => statusNotifier.value;

  set status(BarcodeScannerStatus status) => statusNotifier.value = status;

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  void getAvailableCameras() async {
    try {
      final response = await availableCameras();
      final camera = response.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);

      final cameraController =
          CameraController(camera, ResolutionPreset.max, enableAudio: false);

      await cameraController.initialize();

      status = BarcodeScannerStatus.available(cameraController);

      scanWithCamera();
    } catch (error) {
      BarcodeScannerStatus.error(error.toString());
    }
  }

  void listenCamera() {
    if (status.cameraController!.value.isStreamingImages == false) {
      status.cameraController!.startImageStream((image) async {
        try {
          final WriteBuffer allBytes = WriteBuffer();

          for (Plane plane in image.planes) {
            allBytes.putUint8List(plane.bytes);
          }

          final bytes = allBytes.done().buffer.asUint8List();
          final Size imageSize =
              Size(image.width.toDouble(), image.height.toDouble());

          final InputImageRotation imageRotation =
              InputImageRotation.Rotation_0deg;
          final InputImageFormat inputImageFormat =
              InputImageFormatMethods.fromRawValue(image.format.raw) ??
                  InputImageFormat.NV21;
          final planeData = image.planes.map((Plane plane) {
            return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: plane.height,
                width: plane.width);
          }).toList();
          final inputImageData = InputImageData(
              size: imageSize,
              imageRotation: imageRotation,
              inputImageFormat: inputImageFormat,
              planeData: planeData);
          final inputImageCamera = InputImage.fromBytes(
              bytes: bytes, inputImageData: inputImageData);
          await Future.delayed(Duration(seconds: 3));
        } catch (error) {
          print(error);
        }
      });
    }
  }

  void scanWithCamera() {
    Future.delayed(Duration(seconds: 10)).then((value) {
      if (status.cameraController != null) {
        if (status.cameraController!.value.isStreamingImages) {
          status.cameraController!.stopImageStream();
        }
      }

      status = BarcodeScannerStatus.error('Timeout de leitura de boleto');
    });

    listenCamera();
  }

  void scanWithImagePicker() async {
    try {
      await status.cameraController!.stopImageStream();

      final response =
          await ImagePicker().getImage(source: ImageSource.gallery);
      final inputImage = InputImage.fromFilePath(response!.path);

      scannerBarcode(inputImage);
    } catch (error) {
      print(error);
    }
  }

  Future<void> scannerBarcode(InputImage inputImage) async {
    try {
      if (status.cameraController != null) {
        if (status.cameraController!.value.isStreamingImages) {
          status.cameraController!.stopImageStream();
        }

        final barcodes = await barcodeScanner.processImage(inputImage);
        var barcode;

        for (Barcode item in barcodes) {
          barcode = item.value.displayValue;
        }

        if (barcode != null && status.barcode.isEmpty) {
          status = BarcodeScannerStatus.barcode(barcode);
          status.cameraController!.dispose();
        } else {
          getAvailableCameras();
        }
      }
    } catch (error) {
      print(error);
    }
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();

    if (status.showCamera) {
      status.cameraController!.dispose();
    }
  }
}
