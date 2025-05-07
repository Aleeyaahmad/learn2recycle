import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:learn2recycle/recycle_info.dart';

class Homepage extends StatefulWidget {
  final List<File> imageFiles;
  final Function()? pickImageFromGallery;
  final Function()? pickImageFromCamera;
  final Function(List<File>) onImagesUpdated;

  const Homepage({
    Key? key,
    required this.imageFiles,
    this.pickImageFromGallery,
    this.pickImageFromCamera,
    required this.onImagesUpdated,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  List<File> imageFiles = [];
  List<Map<String, dynamic>> _output = [];
  final FlutterVision vision = FlutterVision();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    imageFiles = List.from(widget.imageFiles);
    _loadModel();

    // Fade animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  Future<void> _loadModel() async {
    await vision.loadYoloModel(
      modelPath: 'assets/best_saved_model.tflite',
      labels: 'assets/labels.txt',
      modelVersion: 'yolov8',
      quantization: false,
      numThreads: 1,
      useGpu: false,
    );
  }

  Future<void> _classifyImage(File image) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;

    final output = await vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: decoded.height,
      imageWidth: decoded.width,
      iouThreshold: 0.5,
      confThreshold: 0.5,
      classThreshold: 0.5,
    );

    if (output == null) return;

    final results = output.map((pred) {
      var box = pred['box'];
      return {
        'index': imageFiles.indexOf(image),
        'label': pred['tag'],
        'confidence': (box[4] * 100).toStringAsFixed(2), // Confidence percentage
      };
    }).toList();

    setState(() {
      _output.addAll(results);
    });
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        imageFiles.add(file);  // Add the image to the list
      });
      widget.onImagesUpdated(imageFiles);

      // Classify the new image
      await _classifyImage(file);
    }
  }

  Future<void> _uploadPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        imageFiles.add(file);  // Add the image to the list
      });
      widget.onImagesUpdated(imageFiles);

      // Classify the new image
      await _classifyImage(file);
    }
  }

  void _removeImage(int index) {
    setState(() {
      imageFiles.removeAt(index);
      _output.removeWhere((e) => e['index'] == index);
      for (var e in _output) {
        if (e['index'] > index) e['index'] -= 1;
      }
    });
    widget.onImagesUpdated(imageFiles);
  }

  Widget _buildButton(String label, String iconPath, Function() onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        iconPath,
        width: 24,
        height: 24,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF245651),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa4c291),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Snap & Recycle! 📸♻️",
                  style: TextStyle(
                    fontSize: 34,
                    fontFamily: 'Pacifico',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Take a picture & learn about recycling!",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Comfortaa',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildButton("Take Photo", "assets/icons/camera.png", _takePhoto),
                const SizedBox(height: 15),
                _buildButton("Upload Photo", "assets/icons/gallery.png", _uploadPhoto),

                // Show the classified images and their results
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: imageFiles.length,
                    itemBuilder: (context, index) {
                      final image = imageFiles[index];
                      final detections = _output.where((e) => e['index'] == index).toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.file(image, height: 150, fit: BoxFit.cover, width: double.infinity),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: detections.isEmpty
                                  ? const Text('No recyclable items detected')
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: detections.map((det) {
                                        return Text(
                                          '${det['label']} - ${det['confidence']}%',  // Display label and confidence
                                        );
                                      }).toList(),
                                    ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
