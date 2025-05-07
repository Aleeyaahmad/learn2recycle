import 'package:flutter/material.dart';

class RecycleInfo extends StatelessWidget {
  final List<String> detectedItems;

  const RecycleInfo({Key? key, required this.detectedItems}) : super(key: key);

  // Example recycling tips per item label
  static const Map<String, String> recycleTips = {
    'plastic bottle': 'Rinse and remove the cap before recycling.',
    'aluminum can': 'Crush to save space. Rinse before disposal.',
    'glass jar': 'Remove lid and rinse. Avoid broken glass.',
    'paper': 'Keep clean and dry. Don’t recycle greasy paper.',
    'cardboard': 'Flatten and remove tape before recycling.',
    'metal': 'Rinse off food residue. Small pieces may not be accepted.',
    'plastic bag': 'Do not put in curbside bin; take to store drop-off.',
    // Add more custom tips as needed
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Tips'),
        backgroundColor: const Color(0xFF245651),
      ),
      backgroundColor: const Color(0xFFE6F6CB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: detectedItems.isEmpty
            ? const Center(child: Text("No items to show."))
            : ListView.builder(
                itemCount: detectedItems.length,
                itemBuilder: (context, index) {
                  final item = detectedItems[index];
                  final tip = recycleTips[item.toLowerCase()] ??
                      'No specific tip available. Please check with your local recycling program.';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.recycling, color: Colors.green),
                      title: Text(
                        item[0].toUpperCase() + item.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(tip),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
