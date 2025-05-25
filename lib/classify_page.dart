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
    File removedImage = imageFiles.removeAt(index);
    output.removeWhere((e) => e['path'] == removedImage.path);

    final prefs = await SharedPreferences.getInstance();
    final paths = imageFiles.map((f) => f.path).toList();
    await prefs.setStringList('stored_images', paths);
    await prefs.setString('detection_output', jsonEncode(output));

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
                backgroundColor: const Color(0xFFa4c291),
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

  String _DisposalTip(String label) {
    switch (label.toLowerCase()) {
      case 'paper':
        return 'Keep paper clean and dry.';
      case 'cardboard':
        return 'Flatten boxes and remove plastic wrap or tape.';
      case 'glass':
        return 'Rinse containers and remove lids.';
      case 'metal':
        return 'Rinse cans and compress if possible.\nScrap metal should be collected separately.';
      case 'plastic':
        return 'Check recycling number, rinse and remove caps.';
      default:
        return 'Dispose of this item responsibly.';
    }
  }

  Map<String, dynamic> getEmojiAndColor(String label) {
    switch (label.toLowerCase()) {
      case 'paper':
      case 'cardboard':
        return {'iconPath': 'assets/icons/blue.png', 'color': Colors.blue};
      case 'glass':
        return {'iconPath': 'assets/icons/brown.png', 'color': Colors.brown};
      case 'metal':
      case 'plastic':
        return {'iconPath': 'assets/icons/orange.png', 'color': Colors.orange};
      default:
        return {'iconPath': 'assets/icons/green.png', 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF0),
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', height: 20, width: 20, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Waste Classification",
          style: TextStyle(fontSize: 20,fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFa4c291),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          final reversedIndex = imageFiles.length - 1 - index;
          final image = imageFiles[reversedIndex];
          final detections = output.where((e) => e['path'] == image.path).toList();

          return Dismissible(
            key: Key(image.path),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await _deleteImage(context, reversedIndex);
            },
            background: Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset('assets/icons/bin.png', height: 24, width: 24, color: Colors.white),
                ),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: FutureBuilder<Size>(
                future: _getImageSize(image),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snapshot.hasData)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final aspectRatio = snapshot.data!.width / snapshot.data!.height;

                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: SizedBox(
                                width: maxWidth,
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: Image.file(
                                    image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      if (snapshot.hasData)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            'Image Size: ${snapshot.data!.width.toInt()} x ${snapshot.data!.height.toInt()} px',
                            style: TextStyle(fontSize: 14, fontFamily: 'Comfortaa', color: Colors.grey[700],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: detections.isEmpty
                            ? Text(
                                'No recyclable items detected',
                                style: const TextStyle(fontSize: 16,fontFamily: 'Comfortaa', color: Colors.black,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detected Items:',
                                    style: TextStyle(fontSize: 16, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Color(0xFF245651),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...detections.map((det) {
                                    final emojiColor = getEmojiAndColor(det['label']);
                                    final iconPath = emojiColor['iconPath'] as String;
                                    final color = emojiColor['color'] as Color;
                                    final tipText = _DisposalTip(det['label']);

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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${det['label']} - ${det['confidence']}%',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Comfortaa',
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Image.asset(
                                                  iconPath,
                                                  height: 40,
                                                  width: 40,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  tipText,
                                                  style: const TextStyle(fontSize: 14, fontFamily: 'Comfortaa', color: Color(0xFF245651), fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
