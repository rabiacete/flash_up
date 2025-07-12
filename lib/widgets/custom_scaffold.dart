import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String title;

  const CustomScaffold({
    super.key,
    required this.child,
    this.showAppBar = true,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/wallpaper.jpg"),
            fit: BoxFit.cover, // Görseli ekran boyutuna göre kırpar
          ),
        ),
        child: child, // Ekranın içeriği burada gösterilir
      ),
    );
  }
}