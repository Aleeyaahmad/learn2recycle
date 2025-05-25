import 'package:flutter/material.dart';

class RecycleInfoPage extends StatelessWidget {
  const RecycleInfoPage({Key? key}) : super(key: key);

  Widget _buildCategory(String emoji, String title, String doText, String dontText) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // More rounded
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      color: Colors.lightGreen[50],
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          collapsedBackgroundColor: const Color(0xFFa4c291),
          backgroundColor: Colors.lightGreen[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // More rounded
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // More rounded
          ),
          leading: Text(
            emoji,
            style: const TextStyle(fontSize: 26),
          ),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          trailing: Image.asset('assets/icons/expand.png', height: 15, width: 15, color: Colors.black,
          ),
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Comfortaa', fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/icons/do.png', height: 24, width: 24),
                      const SizedBox(width: 6),
                      const Text(
                        'Do:',
                        style: TextStyle(fontFamily: 'Comfortaa', fontSize: 18, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doText,
                    style: const TextStyle(fontFamily: 'Comfortaa', fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Image.asset('assets/icons/dont.png', height: 24, width: 24),
                      const SizedBox(width: 6),
                      const Text(
                        'Don’t:',
                        style: TextStyle(fontFamily: 'Comfortaa', fontSize: 18, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dontText,
                    style: const TextStyle(fontFamily: 'Comfortaa', fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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
          "Recycling Guidelines",
          style: TextStyle(fontSize: 20, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFa4c291),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildCategory(
              '📄',
              'Paper',
              '• Recycle clean paper, newspapers, magazines and also colored paper',
              '• Don’t recycle dirty paper, tissues, or paper with food or glue',
            ),
            _buildCategory(
              '📦',
              'Cardboard',
              '• Recycle clean cardboard boxes\n• Always flatten the boxes to save space',
              '• Don’t recycle pizza boxes or wet cardboard',
            ),
            _buildCategory(
              '🧴',
              'Plastic',
              '• Recycle clean bottles, bottle caps, and some plastic containers\n• Look for symbols like PET, HDPE, or PP',
              '• Don’t recycle plastic bags, plastic wrap, or dirty containers',
            ),
            _buildCategory(
              '🥫',
              'Metal',
             '• Recycle clean cans like soda or food cans\n• Metal containers are okay if they’re not dirty',
             '• Don’t recycle spray cans or metal with paint or layers',
            ),
            _buildCategory(
              '🍶',
              'Glass',
              '• Recycle clean glass bottles and jars\n• Make sure they are not broken',
              '• Don’t recycle mirrors, Pyrex, or ceramic items',
            ),
          ],
        ),
      ),
    );
  }
}
