import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'Profil.dart';
import 'anaSayfa.dart';
import 'favoriler.dart';

class navBar extends StatefulWidget {
  const navBar({super.key});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  int seciliIndex = 0;

  // Sayfaların listesi
  final List<Widget> sayfalar = [
    anaSayfa(),
    favoriler(),
    Profil(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigator bar ayarlama
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.deepPurple.shade300,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          // seçilen icona göre sayfa geçişi sağlama
          setState(() {
            seciliIndex = index;
          });
        },
        items: [
          CurvedNavigationBarItem(
              child: Icon(
            Icons.home,
            color: Colors.white,
          )),
          CurvedNavigationBarItem(
              child: Icon(Icons.favorite, color: Colors.white)),
          CurvedNavigationBarItem(
              child: Icon(Icons.person_rounded, color: Colors.white)),
        ],
      ),
      body: sayfalar[seciliIndex],
    );
  }
}
