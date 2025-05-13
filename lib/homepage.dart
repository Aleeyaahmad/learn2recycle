import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:learn2recycle/classify_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadModel();
    _loadStoredData();

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

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('stored_images') ?? [];
    final outputJson = prefs.getString('detection_output');
    final decodedOutput = outputJson != null ? List<Map<String, dynamic>>.from(jsonDecode(outputJson)) : [];

    setState(() {
      imageFiles = paths.map((p) => File(p)).where((f) => f.existsSync()).toList();
      _output = decodedOutput.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _saveStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = imageFiles.map((f) => f.path).toList();
    await prefs.setStringList('stored_images', paths);
    await prefs.setString('detection_output', jsonEncode(_output));
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
        'confidence': (box[4] * 100).toStringAsFixed(2),
      };
    }).toList();

    setState(() {
      _output.addAll(results);
    });

    await _saveStoredData();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        imageFiles.add(file);
      });
      widget.onImagesUpdated(imageFiles);

      // Show green loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFa4c291),
            ),
          );
        },
      );

      await _classifyImage(file);
      Navigator.of(context).pop(); // Dismiss loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadedImagesPage(
            imageFiles: imageFiles,
            output: _output,
          ),
        ),
      );
    }
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        imageFiles.add(file);
      });
      widget.onImagesUpdated(imageFiles);

      // Show green loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFa4c291),
            ),
          );
        },
      );

      await _classifyImage(file);
      Navigator.of(context).pop(); // Dismiss loader

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadedImagesPage(
            imageFiles: imageFiles,
            output: _output,
          ),
        ),
      );
    }
  }

  Widget _buildButton(String label, String iconPath, Function() onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Comfortaa',
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF245651),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        fixedSize: const Size(250, 60),
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
                const SizedBox(height: 15),
                _buildButton("Uploaded Images", "assets/icons/list.png", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadedImagesPage(
                        imageFiles: imageFiles,
                        output: _output,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
