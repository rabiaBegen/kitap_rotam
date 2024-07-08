import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kitap/OkunanKitap.dart';

void main() {
  runApp(
    MaterialApp(
      home: Oduller(),
    ),
  );
}

class Karakter {
  final String isim;
  final int kitapSayimKilidi;
  final String resimYolu;
  bool kilitAc;

  Karakter(this.isim, this.kitapSayimKilidi, this.resimYolu, this.kilitAc);
}

class Oduller extends StatefulWidget {
  @override
  _OdullerState createState() => _OdullerState();
}

class _OdullerState extends State<Oduller> {
  int kitapSayimi = 0;
  List<Karakter> karakter = [
    Karakter('Anka Kuşu', 3, 'assets/k1.jpg', false),
    Karakter('Civciv', 20, 'assets/k2.jpg', false),
    Karakter('Denizyıldızı', 30, 'assets/k2.jpg', false),
    Karakter('Ejderha', 40, 'assets/k2.jpg', false),
    Karakter('Flamingo', 50, 'assets/k2.jpg', false),
    Karakter('Geyik', 60, 'assets/k2.jpg', false),
    Karakter('Kelebek', 70, 'assets/k2.jpg', false),
    Karakter('Leopar', 80, 'assets/k2.jpg', false),
    Karakter('Martı', 90, 'assets/k2.jpg', false),
    Karakter('Ördek', 100, 'assets/k2.jpg', false),
    Karakter('Penguen', 110, 'assets/k2.jpg', false),
    Karakter('Sincap', 120, 'assets/k2.jpg', false),
    Karakter('Tavşan', 130, 'assets/k2.jpg', false),
    Karakter('Uğur Böceği', 140, 'assets/k2.jpg', false),
    Karakter('Van Kedisi', 150, 'assets/k2.jpg', false),
    Karakter('Yunus', 160, 'assets/k2.jpg', false),
    Karakter('Zürafa', 170, 'assets/k2.jpg', false),
    // Diğer karakterleri burada ekleyin
  ];
  @override
  void initState() {
    super.initState();
    updateBookCount(kitapSayimi);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Seviyeler', style: TextStyle(fontSize: 23)),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Toplam Kitap Sayısı: $kitapSayimi',
                  style: TextStyle(fontSize: 18),
                ),
                for (Karakter character in karakter)
                  ListTile(
                      title: Text(
                        character.isim,
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                          'Kilidi Açmak için ${character.kitapSayimKilidi} kitap oku'),
                      leading: character.kilitAc
                          ? ClipOval(
                              child: Image.asset(
                                character.resimYolu,
                                colorBlendMode:
                                    kitapSayimi >= character.kitapSayimKilidi
                                        ? null
                                        : BlendMode.saturation,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(
                              Icons.lock,
                              size: 48,
                              color: kitapSayimi >= character.kitapSayimKilidi
                                  ? Colors.deepPurple[300]
                                  : Colors.deepPurple[300],
                            )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateBookCount(int newBookCount) {
    setState(() {
      kitapSayimi = newBookCount;
      for (Karakter character in karakter) {
        if (kitapSayimi >= character.kitapSayimKilidi) {
          character.kilitAc = true;
        }
      }
    });
  }
}
