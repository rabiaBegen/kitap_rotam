import 'package:flutter/material.dart';
import 'package:kitap/OkunacakKitap.dart';
import 'package:kitap/OkunanKitap.dart';
import 'package:lottie/lottie.dart';

class anaSayfa extends StatelessWidget {
  const anaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home(),
    );
  }
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int seciliIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              height: 1920,
              width: 1080,
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  buton('Okuduğum Kitaplar', () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OkunanKitap()));
                  }),
                  SizedBox(
                    height: 47,
                  ),
                  buton('Okumak İstediğim Kitaplar', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OkunacakKitap()));
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 600,
            ),
            Container(
                margin: EdgeInsets.only(top: 320),
                child: Lottie.asset(
                  "assets/animasyon/Animation - 1715977837246.json",
                  repeat: true,
                )),
          ],
        ),
      ),
    );
  }

  Widget buton(String metin, void Function() onPressed) {
    return Container(
      height: 69,
      width: 326,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.deepPurple.shade300)),
      child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            metin,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)))),
    );
  }
}
