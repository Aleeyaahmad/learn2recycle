import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadedImagesPage extends StatelessWidget {
  final List<File> imageFiles;
  final List<Map<String, dynamic>> output;

  const UploadedImagesPage({
    Key? key,
    required this.imageFiles,
    required this.output,
  }) : super(key: key);

  Future<Size> _getImageSize(File file) async {
    final completer = Completer<Size>();
    final image = Image.file(file);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
  }

  Future<void> _deleteImage(BuildContext context, int index) async {
    // Remove the image from the list
    File removedImage = imageFiles.removeAt(index);

    // Also remove the corresponding detection output
    output.removeAt(index);

    // Update shared preferences to reflect the change
    final prefs = await SharedPreferences.getInstance();
    final paths = imageFiles.map((f) => f.path).toList();
    await prefs.setStringList('stored_images', paths);
    await prefs.setString('detection_output', jsonEncode(output));

    // Show a dialog to indicate the deletion
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Image Deleted',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'The image has been deleted successfully.',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFa4c291),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF0),
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', height: 20, width: 20, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Waste Classification",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFa4c291),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          final image = imageFiles[index];
          final detections = output.where((e) => e['index'] == index).toList();

          return Dismissible(
            key: Key(imageFiles[index].path),
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) async {
              await _deleteImage(context, index); // Delete image and update SharedPreferences
            },
            background: Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Image.asset('assets/icons/bin.png', height: 24, width: 24, color: Colors.white),
                ),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: FutureBuilder<Size>(
                future: _getImageSize(image),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.file(
                          image,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (snapshot.hasData)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            'Image Size: ${snapshot.data!.width.toInt()} x ${snapshot.data!.height.toInt()} px',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Comfortaa',
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: detections.isEmpty
                            ? Text(
                                'No recyclable items detected',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Comfortaa',
                                  color: Colors.black,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detected Items:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...detections.map((det) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5FFF5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFa4c291),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${det['label']} - ${det['confidence']}%',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Comfortaa',
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
