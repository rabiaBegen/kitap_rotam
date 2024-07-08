import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitap/ProfilDuzenle.dart';
import 'package:kitap/giris.dart';
import 'package:kitap/service/kullanicilar.dart';

import 'OkunanKitap.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String kullaniciAdi = '-';
  String? profilResmiUrl;
  late String hedefKitapSayisi = '-';
  int toplamOkunanKitapSayisi = 0;

  final kullanicilar kullaniciKitaplari =
      kullanicilar(); // kullanıcı sınıfını kullanmak için
  StreamSubscription<List<Kitap>>? kitaplarSubscription;

  @override
  void initState() {
    super.initState();
    getKullanici();
    // Toplam okunan kitap sayısını güncellemek için dinleyici başlat
    _startBooksListener();
  }

  @override
  void dispose() {
    // dinleyici kapat
    kitaplarSubscription?.cancel();
    super.dispose();
  }

  // kullanıcının toplam okuduğu kitapların sayısı
  void _startBooksListener() {
    kitaplarSubscription = kullaniciKitaplari
        .kullaniciKitaplariniGetir()
        .listen((List<Kitap> kitaplar) {
      setState(() {
        toplamOkunanKitapSayisi = kitaplar.length;
      });
    });
  }

  void getKullanici() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('kitaplar').doc(user.uid);

      final userData = await userDoc.get();

      if (userData.exists) {
        if (mounted) {
          setState(() {
            kullaniciAdi = userData['kullaniciAdi'] ?? '-';
            hedefKitapSayisi = userData['hedefKitapSayisi'] ?? '';
            profilResmiUrl = userData['profilResmi'];
          });
        }
      } else {
        await userDoc.set({
          'kullaniciID': user.uid,
          'kullaniciAdi': '-',
          'hedefKitapSayisi': '',
          'profilResmi': null,
        });
        if (mounted) {
          setState(() {
            kullaniciAdi = '-';
            hedefKitapSayisi = '';
            profilResmiUrl = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: Text(
          'Profilim',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilDuzenle(),
                ),
              ).then((value) {
                getKullanici();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.login_outlined),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Çıkış Yap'),
                      content:
                          Text("Hesabınızdan çıkış yapmak istiyor musunuz?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Hayır')),
                        TextButton(
                          child: Text('Evet'),
                          onPressed: () async {
                            await _auth.signOut();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => giris()));
                          },
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: profilResmiUrl != null
                      ? NetworkImage(profilResmiUrl!)
                      : null,
                  child: profilResmiUrl == null
                      ? Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        )
                      : null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı Adı : ' + kullaniciAdi,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      _auth.currentUser?.email ?? '',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 80,
            ),
            Container(
              height: 100,
              width: 300,
              child: Center(
                child: Text(
                  'Hedef Kitap Sayısı : ' + hedefKitapSayisi,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(30)),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 100,
              width: 300,
              child: Center(
                child: Text(
                  'Toplam okunan kitap sayısı : $toplamOkunanKitapSayisi',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(30)),
            ),
          ],
        ),
      ),
    );
  }
}
