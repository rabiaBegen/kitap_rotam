import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kitap/service/kullanicilar.dart'; // Kullanıcı işlevlerinizi içeri aktarın

import 'OkunanKitap.dart'; // Kitap veri modelinizi içeri aktarın

class puan extends StatefulWidget {
  final Kitap kitap;

  puan({required this.kitap});
  @override
  _puanState createState() => _puanState();
}

class _puanState extends State<puan> {
  final kullanicilar _kullanicilar = kullanicilar();
  double _Puan = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        title: Text(
          widget.kitap.kitapAdi,
          style: TextStyle(fontSize: 23),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kitaba puan veriniz.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              height: 16,
            ),
            RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _Puan = rating * 2; // 10 üzerinden hesaplama yapıyor
                  });
                }),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _kullanicilar.kitabaPuanVer(widget.kitap, _Puan.toInt());
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  'Puanı Kaydet',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(width: 2, color: Colors.deepPurple.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ],
        ),
      ),
    );
  }
}
