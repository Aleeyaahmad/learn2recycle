import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadedImagesPage extends StatefulWidget {
  final List<File> imageFiles;
  final List<Map<String, dynamic>> output;

  const UploadedImagesPage({
    Key? key,
    required this.imageFiles,
    required this.output,
  }) : super(key: key);

  @override
  State<UploadedImagesPage> createState() => _UploadedImagesPageState();
}

class _UploadedImagesPageState extends State<UploadedImagesPage> {
  late List<bool> _expandedList;

  @override
  void initState() {
    super.initState();
    _expandedList = List.generate(widget.imageFiles.length, (_) => false);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = widget.imageFiles.map((f) => f.path).toList();
    await prefs.setStringList('stored_images', paths);
    await prefs.setString('detection_output', jsonEncode(widget.output));
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
        return {'iconPath': 'assets/icons/green.png', 'color': Colors.green};
    }
  }

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

  Future<void> _confirmAndDeleteImage(BuildContext context, int index) async {
    File imageToDelete = widget.imageFiles[index];
    List<Map<String, dynamic>> detectionsToDelete =
        widget.output.where((e) => e['path'] == imageToDelete.path).toList();

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Image?',
            style: TextStyle(fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ),
          content: const Text(
            'Are you sure you want to delete this image? You can undo this action.',
            style: TextStyle(fontFamily: 'Comfortaa', fontSize: 14, color: Colors.black),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Comfortaa', color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(fontFamily: 'Comfortaa', color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.imageFiles.removeAt(index);
      widget.output.removeWhere((e) => e['path'] == imageToDelete.path);
      bool wasExpanded = _expandedList.removeAt(index);

      setState(() {});
      _saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFa4c291),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Image deleted',
                style: TextStyle(color: Colors.white, fontFamily: 'Comfortaa', fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    widget.imageFiles.insert(index, imageToDelete);
                    widget.output.insertAll(index, detectionsToDelete);
                    _expandedList.insert(index, wasExpanded);
                  });
                  _saveData();
                },
                child: const Text(
                  'Undo',
                  style: TextStyle(color: Colors.white, fontFamily: 'Comfortaa', fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } else {
      setState(() {
        _expandedList[index] = !_expandedList[index];
      });
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
        itemCount: widget.imageFiles.length,
        itemBuilder: (context, i) {
          // Show newest image at the top by iterating in reverse
          final index = widget.imageFiles.length - 1 - i;
          final image = widget.imageFiles[index];
          final detections = widget.output.where((e) => e['path'] == image.path).toList();

          return Dismissible(
            key: Key(image.path),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await _confirmAndDeleteImage(context, index);
              return false; // Prevent automatic deletion; handled manually.
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expandedList[index] = !_expandedList[index];
                });
              },
              child: Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail and info row (when not expanded)
                    if (!_expandedList[index])
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          detections.isNotEmpty
                              ? detections.map((d) => '${d['label']} - ${d['confidence']}%').join(' , ')
                              : 'No recyclable items detected',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Tap to view details',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Comfortaa',
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    // Expanded view (full image and details)
                    if (_expandedList[index]) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(
                          'Tap to hide details',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Comfortaa',
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      FutureBuilder<Size>(
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
                                          child: Stack(
                                            children: [
                                              Image.file(
                                                image,
                                                fit: BoxFit.contain,
                                                width: maxWidth,
                                              ),
                                              ...detections.map((det) {
                                                final box = det['box'];
                                                final imageWidth = det['imageWidth'];
                                                final imageHeight = det['imageHeight'];
                                                if (box == null || imageWidth == null || imageHeight == null) {
                                                  return const SizedBox();
                                                }

                                                final scaleX = maxWidth / imageWidth;
                                                final scaleY = maxWidth / imageWidth * (imageHeight / imageWidth);

                                                final left = box[0] * scaleX;
                                                final top = box[1] * scaleY;
                                                final width = (box[2] - box[0]) * scaleX;
                                                final height = (box[3] - box[1]) * scaleY;

                                                return Positioned(
                                                  left: left,
                                                  top: top,
                                                  width: width,
                                                  height: height,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.redAccent, width: 2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                        color: Colors.redAccent.withOpacity(0.7),
                                                        child: Text(
                                                          '${det['label']}',
                                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
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
                                    ? const Text(
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
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: 'Comfortaa',
                                                            color: Color(0xFF245651),
                                                            fontStyle: FontStyle.normal,
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
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}