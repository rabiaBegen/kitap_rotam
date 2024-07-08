// lib/screens/kitap_listesi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:kitap/service/kullanicilar.dart';
import 'package:kitap/puan.dart';

import 'OkunanKitap.dart';

class favoriler extends StatelessWidget {
  final kullanicilar _kullanicilar = kullanicilar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<Kitap>>(
            stream: _kullanicilar.tumKitaplariGetir(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<Kitap> kitaplar = snapshot.data!;
              // Puanı olmayan kitapları filtreleme
              List<Kitap> puanliKitaplar =
                  kitaplar.where((kitap) => kitap.ortPuan > 0).toList();
              // Puan sırasına göre kitapları sıralama
              puanliKitaplar.sort((a, b) => b.ortPuan.compareTo(a.ortPuan));

              // Kitapları isimlerine göre benzersiz hale getirme
              Map<String, Kitap> benzersizKitapMap = {};
              for (var kitap in puanliKitaplar) {
                if (!benzersizKitapMap.containsKey(kitap.kitapAdi)) {
                  benzersizKitapMap[kitap.kitapAdi] = kitap;
                }
              }

              // Benzersiz kitapları listeye çevirme ve puan sırasına göre sıralama
              List<Kitap> benzersizKitaplar = benzersizKitapMap.values.toList();
              benzersizKitaplar.sort((a, b) => b.ortPuan.compareTo(a.ortPuan));

              return ListView.builder(
                itemCount: benzersizKitaplar.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.deepPurple.shade300)),
                          height: 75,
                          child: ListTile(
                            title: Text(
                              benzersizKitaplar[index].kitapAdi,
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height:
                                        8), // Boşluk eklemek için SizedBox kullandık
                                Text(
                                  'Puan : ${benzersizKitaplar[index].ortalamaPuan.toStringAsFixed(1)} / 10',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          )));
                },
              );
            }));
  }
}
