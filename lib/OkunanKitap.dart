import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitap/anaSayfa.dart';
import 'package:kitap/puan.dart';
import 'package:kitap/service/kullanicilar.dart'; // Firestore işlem servisi
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(OkunanKitap());

class OkunanKitap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KitapListesiSayfasi(),
    );
  }
}

class KitapListesiSayfasi extends StatefulWidget {
  @override
  _KitapListesiSayfasiState createState() => _KitapListesiSayfasiState();
}

class _KitapListesiSayfasiState extends State<KitapListesiSayfasi> {
  final kullanicilar _userService = kullanicilar();

  // Düzenleme işlemi için dialog göster
  Future<void> _showEditDialog({
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
                await _userService.updateKitapInFirestore(
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

  void _showDeleteDialog(String kitapId) {
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
                await _userService.deleteKitapFromFirestore(kitapId);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[300],
          centerTitle: true,
          title: Text(
            'Kitap Listesi',
            style: TextStyle(fontSize: 23),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => anaSayfa()),
              );
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder<List<Kitap>>(
          stream: kullanicilar().kullaniciKitaplariniGetir(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Kitap> kitaplar = snapshot.data!;
            return ListView.builder(
              itemCount: kitaplar.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 60,
                    child: ListTile(
                      title: Text(
                        kitaplar[index].kitapAdi,
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
                            _showEditDialog(
                              kitapId: kitaplar[index].id,
                              eskiKitapAdi: kitaplar[index].kitapAdi,
                              eskiYazarAdi: kitaplar[index].yazar,
                            );
                          } else if (secenek == 'Sil') {
                            _showDeleteDialog(kitaplar[index].id);
                          } else if (secenek == 'Puan Ver') {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => puan(
                                            kitap: kitaplar[index],
                                          )));
                            });
                          }
                        },
                        itemBuilder: (BuildContext contex) {
                          return ['Düzenle', 'Sil', 'Puan Ver']
                              .map((String secenek) {
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
                            builder: (context) => KitapBilgiSayfasi(
                              kitap: kitaplar[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple[300],
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KitapEkleSayfasi(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class KitapEkleSayfasi extends StatefulWidget {
  @override
  _KitapEkleSayfasiState createState() => _KitapEkleSayfasiState();
}

class _KitapEkleSayfasiState extends State<KitapEkleSayfasi> {
  final TextEditingController kitapAdiController = TextEditingController();
  final TextEditingController yazarController = TextEditingController();
  List<Kitap> tumKitaplar = []; // Tüm kitapları tutacak liste
  Set<Kitap> _secilenKitaplar = {}; // Seçilen kitapları tutacak küme

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            children: <Widget>[
              TextField(
                controller: kitapAdiController,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Kitap Adı',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9575CD)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9575CD)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: yazarController,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Yazar',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9575CD)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9575CD)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[300],
                  shape: StadiumBorder(),
                ),
                onPressed: () async {
                  final kitapAdi = kitapAdiController.text;
                  final yazar = yazarController.text;
                  if (kitapAdi.isNotEmpty && yazar.isNotEmpty) {
                    await kullanicilar().kitapEkle(
                      Kitap(
                        kitapAdi: kitapAdi,
                        yazar: yazar,
                        id: '',
                      ),
                    );
                    setState(() {}); // KitapListesiSayfasi widget'ını yenile
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Ekle',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[300],
                    shape: StadiumBorder()),
                onPressed: () async {
                  Kitap? secilenKitap = await showDialog(
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
                          content: FutureBuilder<List<Kitap>>(
                            future: kullanicilar().tumKitaplariGetirOnce(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              List<Kitap> kitaplar = snapshot.data!;
                              return Container(
                                width: double.maxFinite,
                                height:
                                    600, // İstediğiniz yüksekliği belirleyin
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
                                              color: Colors.deepPurple[
                                                  100], // Kitap kutusunun arka plan rengi
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
                      _secilenKitaplar.add(secilenKitap);
                    });
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => KitapListesiSayfasi()));
                },
                child: Text(
                  'Kitap Seç',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // İletişim kutusundan seçilen kitabı kontrol eder
  // Daha önce eklenmişse false döner, aksi halde true döner
  bool listeKitaplar(Kitap secilenKitap) {
    for (Kitap kitap in _secilenKitaplar) {
      if (kitap.kitapAdi == secilenKitap.kitapAdi) {
        // Eğer seçilen kitap adı daha önce eklenmişse false döner
        return false;
      }
    }
    // Kitap daha önce eklenmemişse true döner ve küme
    // ve listeye eklenir
    tumKitaplar.add(secilenKitap);
    _secilenKitaplar.add(secilenKitap);
    kullanicilar().kitapEkle(secilenKitap);
    return true;
  }
}

class KitapBilgiSayfasi extends StatefulWidget {
  final Kitap kitap;
  KitapBilgiSayfasi({required this.kitap});

  @override
  _KitapBilgiSayfasiState createState() => _KitapBilgiSayfasiState();
}

class _KitapBilgiSayfasiState extends State<KitapBilgiSayfasi> {
  late TextEditingController notController;
  late String not;

  @override
  void initState() {
    super.initState();
    not = ''; // başlangıçta notu boş olarak ayarlama
    notController = TextEditingController();
    _notuGuncelle();
    notController.addListener(onNotChanged);
  }

  @override
  void dispose() {
    notController.removeListener(onNotChanged);
    notController.dispose(); // controllerın dispose edilmesi
    super.dispose();
  }

  //// Burada kaldıııııımmmmmmmmmm
  void onNotChanged() {
    setState(() {
      not = notController.text; // text alanındaki değişikliği takip etme
    });
    String kitapId = widget.kitap.id;
    DocumentReference kitapRef =
        FirebaseFirestore.instance.collection('kitaplar').doc(kitapId);
    notKaydet(kitapRef, not);
    // her değişiklikte notu kaydetme
  }

  void notKaydet(DocumentReference kitapRef, String not) async {
    await kullanicilar().notKaydet(kitapRef, not);
  }

  void _notuGuncelle() async {
    String kitapId = widget.kitap.id;
    DocumentReference kitapRef =
        FirebaseFirestore.instance.collection('kitaplar').doc(kitapId);

    kitapRef.get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        setState(() {
          not = doc['kendimeNot'] ?? '';
          notController.text = not;
        });
      }
    }).catchError((error) {
      print('Veritabanından not okunamadı: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        centerTitle: true,
        title: Text(
          widget.kitap.kitapAdi,
          style: TextStyle(fontSize: 23, color: Colors.white),
        ),
      ),
      body: Container(
        height: 1920,
        width: 1080,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/kitap2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(16),
                height: 45,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 15,
                      top: 10,
                      child: Text(
                        'Yazar: ${widget.kitap.yazar}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 500,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Kendime Not',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: notController,
                        maxLines: null,
                        onChanged: (value) {
                          String kitapId = widget.kitap.id;
                          DocumentReference kitapRef = FirebaseFirestore
                              .instance
                              .collection('kitaplar')
                              .doc(kitapId);
                          notKaydet(kitapRef, value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Notunuzu buraya giriniz.',
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Kitap {
  final String id; // kitap ID'si
  final String kitapAdi;
  final String yazar;
  final String kendimeNot;
  double ortPuan;
  List<int> puanlar; // kitaplar için verilen puanlar listesi

  Kitap({
    required this.id,
    required this.kitapAdi,
    required this.yazar,
    this.kendimeNot = '',
    this.ortPuan = 0.0,
    this.puanlar = const [],
  });

  double get ortalamaPuan {
    if (puanlar.isEmpty) {
      return 0.0;
    }
    return puanlar.reduce((a, b) => a + b) / puanlar.length;
  }

  factory Kitap.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> Puanlar = data['puanlar'] ?? [];
    List<int> puanlar = List<int>.from(Puanlar);
    double ortalamaPuan = puanlar.isEmpty
        ? 0.0
        : puanlar.reduce((a, b) => a + b) / puanlar.length;
    return Kitap(
      id: doc.id,
      kitapAdi: data['kitapAdi'] ?? '',
      yazar: data['yazar'] ?? '',
      ortPuan: ortalamaPuan,
      puanlar: puanlar,
    );
  }
}
