import 'package:flutter/material.dart';
import 'package:kitap/anaSayfa.dart';
import 'package:kitap/service/kullanicilar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OkunacakKitap extends StatelessWidget {
  const OkunacakKitap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: EklenenKitaplar(
      kitap: Kitap_(id: '', kitapAdi: '', yazar: ''),
    ));
  }
}

class EklenenKitaplar extends StatefulWidget {
  final Kitap_ kitap; // Kitap_ sınıfından bir örnek
  EklenenKitaplar({required this.kitap});
  @override
  State<EklenenKitaplar> createState() => _EklenenKitaplarState();
}

// PARAMETRE ALMAMASINI SAĞLA kitabı farklı bir şekilde oluşturmaya çalış
// ortak havuzdan kitapları seçtir
class _EklenenKitaplarState extends State<EklenenKitaplar> {
  final kullanicilar userService = kullanicilar();

  // Düzenleme işlemi için dialog göster
  Future<void> showEditDialog({
    required String kitapId,
    required String eskiKitapAdi,
    required String eskiYazarAdi,
  }) async {
    TextEditingController kitapAdiController =
        TextEditingController(text: eskiKitapAdi);
    TextEditingController yazarAdiController =
        TextEditingController(text: eskiYazarAdi);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Kitap Düzenle',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  style: TextStyle(fontSize: 18),
                  controller: kitapAdiController,
                  decoration: InputDecoration(labelText: 'Yeni Kitap Adı'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  style: TextStyle(fontSize: 18),
                  controller: yazarAdiController,
                  decoration: InputDecoration(
                    labelText: 'Yeni Yazar Adı',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'İptal',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                String yeniKitapAdi = kitapAdiController.text;
                String yeniYazarAdi = yazarAdiController.text;
                await userService.okunacakKitapGuncelle(
                  kitapId,
                  yeniKitapAdi,
                  yeniYazarAdi,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Kaydet',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(String kitapId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Kitabı Sil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Text('Bu kitabı silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'İptal',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Burada kitap silme fonksiyonunu çağırıyorum
                await userService.okunacakKitapSil(kitapId);
                Navigator.pop(context);
              },
              child: Text(
                'Sil',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Kitap_> kitaplar = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[300],
          centerTitle: true,
          title: Text(
            'Okumak İstediğim Kitaplar',
            style: TextStyle(fontSize: 23),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => anaSayfa()));
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: StreamBuilder<List<Kitap_>>(
          stream: kullanicilar().okunacakKitaplariniGetir(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Kitap_> kitaplar = snapshot.data!;
            return ListView.builder(
              itemCount: kitaplar.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.deepPurple[300],
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          kitaplar[index].kitapAdi +
                              ' ( ' +
                              kitaplar[index].yazar +
                              ' )',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onSelected: (String secenek) {
                            if (secenek == 'Düzenle') {
                              showEditDialog(
                                kitapId: kitaplar[index].id,
                                eskiKitapAdi: kitaplar[index].kitapAdi,
                                eskiYazarAdi: kitaplar[index].yazar,
                              );
                            } else if (secenek == 'Sil') {
                              showDeleteDialog(kitaplar[index].id);
                            }
                          },
                          itemBuilder: (BuildContext contex) {
                            return ['Düzenle', 'Sil'].map((String secenek) {
                              return PopupMenuItem<String>(
                                value: secenek,
                                child: Text(secenek),
                              );
                            }).toList();
                          },
                        ),
                        onTap: () {
                          setState(() {});
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EklenenKitaplar(
                                kitap: kitaplar[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final kitap = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => KitapEkle_()));
            if (kitap != null) {
              setState(() {
                kitaplar.add(kitap);
              });
            }
          },
          backgroundColor: Colors.deepPurple[300],
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class KitapEkle_ extends StatefulWidget {
  @override
  State<KitapEkle_> createState() => _KitapEkle_State();
}

class _KitapEkle_State extends State<KitapEkle_> {
  final TextEditingController kitapAdiController = TextEditingController();
  final TextEditingController yazarController = TextEditingController();
  List<Kitap_> tumKitaplar = []; // Tüm kitapları tutacak liste
  Set<Kitap_> secilenKitaplar = {}; // Seçilen kitapları tutacak küme
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        centerTitle: true,
        title: Text(
          'Kitap Ekle',
          style: TextStyle(fontSize: 23),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: kitapAdiController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  hintText: 'Kitap Adı',
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9575CD)),
                      borderRadius: BorderRadius.circular(20)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9575CD)),
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: yazarController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  hintText: 'Yazar',
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9575CD)),
                      borderRadius: BorderRadius.circular(20)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9575CD)),
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[300],
                    shape: StadiumBorder()),
                onPressed: () async {
                  final kitapAdi = kitapAdiController.text;
                  final yazar = yazarController.text;
                  if (kitapAdi.isNotEmpty && yazar.isNotEmpty) {
                    await kullanicilar().okunacakKitapEkle(
                      Kitap_(id: '', kitapAdi: kitapAdi, yazar: yazar),
                    );
                    setState(() {}); // KitapListesiSayfasi widget'ını yenile
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Ekle',
                  style: TextStyle(fontSize: 18),
                )),
            SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[300],
                  shape: StadiumBorder()),
              onPressed: () async {
                Kitap_? secilenKitap = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Text(
                          'Kitap Seçiniz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        content: FutureBuilder<List<Kitap_>>(
                          future:
                              kullanicilar().okunacaktumKitaplariGetirOnce(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            List<Kitap_> kitaplar = snapshot.data!;
                            return Container(
                              width: double.maxFinite,
                              height: 600, // İstediğiniz yüksekliği belirleyin
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: kitaplar.length,
                                itemBuilder: (context, index) {
                                  if (listeKitaplar(kitaplar[index])) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        height: 70,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple[100],
                                            // Kitap kutusunun arka plan rengi
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Color(0xFF9575CD))),
                                        child: ListTile(
                                          title: Text(
                                            kitaplar[index].kitapAdi,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          onTap: () {
                                            Navigator.pop(
                                                context, kitaplar[index]);
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      );
                    });
                if (secilenKitap != null) {
                  setState(() {
                    secilenKitaplar.add(secilenKitap);
                  });
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EklenenKitaplar(
                        kitap: Kitap_(id: '', kitapAdi: '', yazar: '')),
                  ),
                );
              },
              child: Text(
                'Kitap Seç',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İletişim kutusundan seçilen kitabı kontrol eder
  // Daha önce eklenmişse false döner, aksi halde true döner
  bool listeKitaplar(Kitap_ secilenKitap) {
    for (Kitap_ kitap in secilenKitaplar) {
      if (kitap.kitapAdi == secilenKitap.kitapAdi) {
        // Eğer seçilen kitap adı daha önce eklenmişse false döner
        return false;
      }
    }
    // Kitap daha önce eklenmemişse true döner ve küme
    // ve listeye eklenir
    tumKitaplar.add(secilenKitap);
    secilenKitaplar.add(secilenKitap);
    kullanicilar().okunacakKitapEkle(secilenKitap);
    return true;
  }
}

class Kitap_ {
  final String id; // kitap ID'si
  final String kitapAdi;
  final String yazar;

  Kitap_({
    required this.id,
    required this.kitapAdi,
    required this.yazar,
  });

  // Firestore'dan dökümanı Kitap nesnesine dönüştürme
  factory Kitap_.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Kitap_(
      id: doc.id,
      kitapAdi: data['kitapAdi'] ?? '',
      yazar: data['yazar'] ?? '',
    );
  }
}
