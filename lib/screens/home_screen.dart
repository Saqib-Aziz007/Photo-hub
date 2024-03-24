import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  XFile? uploadedImage;
  List<Face> detectedFaces = [];

  void _getFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        debugPrint(imageFile.toString());
        debugPrint(inputImage.toString());
      } else {
        debugPrint('User cancelled the image picker');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _getFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickMultiImage(
        imageQuality: 50,
      );
      if (pickedFile.isNotEmpty) {
        for (var image in pickedFile) {
          setState(() {
            loading = true;
          });
          setState(() {
            uploadedImage = image;
          });
          File imageFile = File(image.path);
          final inputImage = InputImage.fromFilePath(image.path);
          debugPrint(imageFile.toString());
          final options = FaceDetectorOptions(
            enableLandmarks: true,
            enableClassification: true,
            enableContours: true,
          );
          final faceDetector = FaceDetector(options: options);
          final List<Face> faces = await faceDetector.processImage(inputImage);
          setState(() {
            detectedFaces = faces;
          });
          debugPrint('----------------');
          debugPrint(faces.length.toString());
          debugPrint(faces[0].smilingProbability.toString());
          debugPrint('----------------');
          for (Face face in faces) {
            final Rect boundingBox = face.boundingBox;

            final double? rotX =
                face.headEulerAngleX; // Head is tilted up and down rotX degrees
            final double? rotY = face
                .headEulerAngleY; // Head is rotated to the right rotY degrees
            final double? rotZ =
                face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

            // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
            // eyes, cheeks, and nose available):
            final FaceLandmark? leftEar =
                face.landmarks[FaceLandmarkType.leftEar];
            if (leftEar != null) {
              final Point<int> leftEarPos = leftEar.position;
            }

            // If classification was enabled with FaceDetectorOptions:
            if (face.smilingProbability != null) {
              final double? smileProb = face.smilingProbability;
            }

            // If face tracking was enabled with FaceDetectorOptions:
            if (face.trackingId != null) {
              final int? id = face.trackingId;
            }
            debugPrint(face.contours.toString());
          }
          setState(() {
            loading = false;
          });
        }
      } else {
        debugPrint('User cancelled the image picker');
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('************* ERROR *************');
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: loading
              ? const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator()),
                )
              : null,
          title: Text(
            'Photo Hub',
            style: GoogleFonts.getFont('Lato'),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Detected Faces: ',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    detectedFaces.length.toString(),
                    style: TextStyle(fontSize: 24),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Smiling: ',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    detectedFaces.isEmpty
                        ? 'Not Detected'
                        : detectedFaces.first.smilingProbability! >= 0.7
                            ? 'True'
                            : 'False',
                    style: const TextStyle(fontSize: 24),
                  )
                ],
              ),
              const SizedBox(
                height: 48,
              ),
              uploadedImage != null
                  ? Image.file(
                      File(uploadedImage!.path),
                      height: 250,
                      width: 250,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 48,
              ),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _getFromGallery,
                  child: const Text('UPLOAD'),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _getFromCamera,
                  child: const Text('DOWNLOAD'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
