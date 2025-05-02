// screens/study_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class StudyScreen extends StatefulWidget {
  final List<dynamic> cards;
  const StudyScreen({super.key, required this.cards});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<Map<String, dynamic>> reviewList;
  int currentIndex = 0;
  bool showBack = false;

  @override
  void initState() {
    super.initState();
    final shuffled = [...widget.cards]..shuffle(Random());
    reviewList = shuffled.cast<Map<String, dynamic>>();
  }

  void mark(bool knewIt) {
    setState(() {
      if (!knewIt) {
        reviewList.add(reviewList[currentIndex]);
      }
      currentIndex++;
      showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= reviewList.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Çalışma Bitti')),
        body: const Center(child: Text('Tüm kartlar bitti.')),
      );
    }
    final card = reviewList[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Desteyi Çalış')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => showBack = !showBack),
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    showBack ? card['back'] : card['front'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => mark(true),
                  child: const Text('Bildim'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => mark(false),
                  child: const Text('Bilemedim'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
