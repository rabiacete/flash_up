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
        backgroundColor: const Color(0xFF5B8BDF), // Arka plan rengi
        appBar: AppBar(
          title: const Text(
            'Çalışma Bitti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF5B8BDF),
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Tüm kartlar bitti.',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      );
    }
    final card = reviewList[currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF5B8BDF), // Arka plan rengi
      appBar: AppBar(
        title: const Text(
          'Desteyi Çalış',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5B8BDF),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => showBack = !showBack),
              child: Card(
                color: Colors.white, // Kart arka planı beyaz
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Kart köşeleri yuvarlatıldı
                ),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(48), // Daha büyük padding
                  child: Text(
                    showBack ? card['back'] : card['front'],
                    style: const TextStyle(
                      fontSize: 32, // Daha büyük font boyutu
                      color: Colors.black, // Siyah yazı rengi
                    ),
                    textAlign: TextAlign.center, // Metni ortala
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32), // Butonlar için daha fazla boşluk
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => mark(true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Daha büyük buton
                    textStyle: const TextStyle(fontSize: 20), // Daha büyük yazı boyutu
                    backgroundColor: Colors.green, // Buton arka planı yeşil
                  ),
                  child: const Text('TRUE ✔️'),
                ),
                const SizedBox(width: 24), // Butonlar arasında boşluk
                ElevatedButton(
                  onPressed: () => mark(false),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Daha büyük buton
                    textStyle: const TextStyle(fontSize: 20), // Daha büyük yazı boyutu
                    backgroundColor: Colors.red, // Buton arka planı kırmızı
                  ),
                  child: const Text('FALSE ✖️'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}