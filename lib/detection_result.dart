import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

class DetectionResultPage extends StatelessWidget {
  final File image;
  final List<Map<String, dynamic>> detections;
  final VoidCallback onBack;

  const DetectionResultPage({
    Key? key,
    required this.image,
    required this.detections,
    required this.onBack,
  }) : super(key: key);

  Future<Size> _getImageSize(File file) async {
    final completer = Completer<Size>();
    final imageWidget = Image.file(file);
    imageWidget.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    return completer.future;
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

  Map<String, dynamic> getIconAndColor(String label) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF0),
      appBar: AppBar(
        title: const Text(
          "Detection Result",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFa4c291),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png', height: 20, width: 20, color: Colors.white),
          onPressed: () {
            onBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
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
                                final iconColor = getIconAndColor(det['label']);
                                final iconPath = iconColor['iconPath'] as String;
                                final color = iconColor['color'] as Color;
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
        ),
      ),
    );
  }
}
