import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitap/OkunacakKitap.dart';
import 'package:kitap/OkunanKitap.dart';

class kullanicilar {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final StreamController<String> _notGuncelleController =
      StreamController<String>.broadcast();

  // kullanıcının kitaplarını gerçek zamanlı dinleyen bir stream
  Stream<List<Kitap>> kullaniciKitaplariSayisi() {
    // kullanıcı bilgisini al
    User? user = _auth.currentUser;

    // Firestore'dan ilgili kullanıcının kitaplarını dinleyen bir stream oluştur
    if (user != null) {
      Stream<QuerySnapshot> snapshot = _firestore
          .collection('kitaplar')
          .where('kullaniciID', isEqualTo: user.uid)
          .snapshots();
      return snapshot.map((event) =>
          event.docs.map((doc) => Kitap.fromFirestore(doc)).toList());
    }
    // kullanıcı yoksa boş bir stream döndür
    return Stream.empty();
  }

  // not güncelleme bildirimlerini dinlemek için stream
  static Stream<String> get notGuncelleStream => _notGuncelleController.stream;

  // notları kaydetme , silme işlemleri
  Future<void> notKaydet(DocumentReference kitapRef, String not) async {
    try {
      String? kullaniciId = _auth.currentUser?.uid;
      if (kullaniciId != null) {
        await kitapRef.update({'kendimeNot': not});
        print('Not başarıyla kaydedildi.');

        // not güncellendiğinde bildirim gönder
        _notGuncelleController.add(kitapRef.id);
      } else {
        print('Oturum açık değil.');
      }
    } catch (error) {
      print('Not kaydedilirken hata oluştu: $error');
    }
  }

  Future<void> kitapEkle(Kitap kitap) async {
    try {
      String? kullaniciId = _auth.currentUser?.uid;
      // Kullanıcının mevcut kitaplarını getir
      List<Kitap> kullaniciKitaplar = await kullaniciKitaplariniGetir().first;

      // Eğer kullanıcı zaten seçilen kitabı eklediyse ekleme işlemini yapma
      if (!kullaniciKitaplar.any((k) => k.kitapAdi == kitap.kitapAdi)) {
        if (kullaniciId != null) {
          await _firestore.collection('kitaplar').add({
            'kitapAdi': kitap.kitapAdi,
            'yazar': kitap.yazar,
            'kullaniciId': kullaniciId,
          });
        } else {
          print('Oturum açık değil.');
        }
      }
    } catch (e) {
      print('Kitap ekleme hatası: $e');
    }
  }

  // kullanıcı kimliğine göre kitap filtreleme
  Stream<List<Kitap>> kullaniciKitaplariniGetir() {
    String? kullaniciId = _auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('kitaplar')
        .where('kullaniciId', isEqualTo: kullaniciId)
        .orderBy('kitapAdi') // alfabetik sıralama yapar
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Kitap.fromFirestore(doc)).toList());
  }

  // firestoreden tüm kitapları almak için
  Stream<List<Kitap>> getKitap() {
    try {
      String? kullaniciId = _auth.currentUser?.uid;
      if (kullaniciId != null) {
        return _firestore
            .collection('kullanicilar')
            .doc(kullaniciId)
            .collection('kitaplar')
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Kitap.fromFirestore(doc)).toList());
      } else {
        print('Oturum açık değil.');
        return Stream<List<Kitap>>.empty();
      }
    } catch (e) {
      print('Kitap getirme hatası: $e');
      return Stream<List<Kitap>>.empty();
    }
  }

  Future<List<Kitap>> tumKitaplariGetirOnce() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('kitaplar').get();
      List<Kitap> tumKitaplar =
          querySnapshot.docs.map((doc) => Kitap.fromFirestore(doc)).toList();

      // Daha önce alınmış kitapların adlarını saklamak için bir set oluştur
      Set<String> alinanKitapAdlari = Set<String>();

      // Tüm kitapları döngü ile kontrol et
      // Eğer daha önce alınmışsa listeye ekleme
      List<Kitap> yeniKitaplar = [];
      for (var kitap in tumKitaplar) {
        if (!alinanKitapAdlari.contains(kitap.kitapAdi)) {
          yeniKitaplar.add(kitap);
          alinanKitapAdlari.add(kitap.kitapAdi);
        }
      }
      return yeniKitaplar;
    } catch (e) {
      print("Tüm kitapları alma hatası : $e");
      return [];
    }
  }

  // firestoreden okunan kitap güncellemek için
  Future<void> updateKitapInFirestore(
      String kitapId, String? yeniKitapAdi, String yeniYazarAdi) async {
    try {
      // kullanınıcın belirli bir kitabını güncellemek için belirli bir doküman refenası alma
      DocumentReference kitapRef =
          _firestore.collection('kitaplar').doc(kitapId);

      // güncellenmiş alanları içeren bir harita oluşturma
      Map<String, dynamic> updatedFields = {
        'kitapAdi': yeniKitapAdi,
        'yazarAdi': yeniYazarAdi,
      };

      // kitap firestore'da güncelleniyor
      await kitapRef.update(updatedFields);
      print('Kitap başarıyla güncellendi.');
    } catch (e) {
      print('Güncelleme yapılırken hata oluştu : $e');
    }
  }

  // Firestore'dan bir kitap silmek için metot
  Future<void> deleteKitapFromFirestore(String kitapId) async {
    try {
      // kullanıcının belirli bir kitabını silmek için belirli bir doküman referansı oluşturma
      DocumentReference kitapRef =
          _firestore.collection('kitaplar').doc(kitapId);
      // kitabı silmek için delete metodu kullanılır
      await kitapRef.delete();
      print('Kitap başarıyla silindi.');
    } catch (e) {
      print('Kitabı silerken hata oluştu: $e');
    }
  }

  Future<List<Kitap_>> okunacaktumKitaplariGetirOnce() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('_okunacakKitaplar')
          .get();
      List<Kitap_> tumKitaplar =
          querySnapshot.docs.map((doc) => Kitap_.fromFirestore(doc)).toList();

      // Daha önce alınmış kitapların adlarını saklamak için bir set oluştur
      Set<String> alinanKitapAdlari = Set<String>();

      // Tüm kitapları döngü ile kontrol et
      // Eğer daha önce alınmışsa listeye ekleme
      List<Kitap_> yeniKitaplar = [];
      for (var kitap in tumKitaplar) {
        if (!alinanKitapAdlari.contains(kitap.kitapAdi)) {
          yeniKitaplar.add(kitap);
          alinanKitapAdlari.add(kitap.kitapAdi);
        }
      }
      return yeniKitaplar;
    } catch (e) {
      print("Tüm kitapları alma hatası : $e");
      return [];
    }
  }

  // Firestore'dan okunacak kitapları getirme
  Stream<List<Kitap_>> okunacakKitaplariniGetir() {
    String? kullaniciId = _auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('_okunacakKitaplar')
        .where('kullaniciId', isEqualTo: kullaniciId)
        .orderBy('kitapAdi')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Kitap_.fromFirestore(doc)).toList());
  }

// Firestore'a yeni bir okunacak kitap ekleme
  Future<void> okunacakKitapEkle(Kitap_ kitap) async {
    try {
      String? kullaniciId = _auth.currentUser?.uid;
      if (kullaniciId != null) {
        await _firestore.collection('_okunacakKitaplar').add({
          'kitapAdi': kitap.kitapAdi,
          'yazar': kitap.yazar,
          'kullaniciId': kullaniciId,
        });
      } else {
        print('Oturum açık değil.');
      }
    } catch (e) {
      print('Okunacak kitap ekleme hatası: $e');
    }
  }

  // okumak istenilen kitabın güncellenmesi
  Future<void> okunacakKitapGuncelle(
      String kitapId, String yeniKitapAdi, String yeniYazarAdi) async {
    try {
      // Belirli bir kitabın Firestore referansını al
      DocumentReference kitapRef =
          _firestore.collection('_okunacakKitaplar').doc(kitapId);

      // Güncellenmiş alanları içeren bir harita oluştur
      Map<String, dynamic> updatedFields = {
        'kitapAdi': yeniKitapAdi,
        'yazarAdi': yeniYazarAdi,
      };

      // Kitap Firestore'da güncelleniyor
      await kitapRef.update(updatedFields);
      print('Kitap başarıyla güncellendi.');
    } catch (e) {
      print('Güncelleme yapılırken hata oluştu: $e');
    }
  }

  // Firestore'dan bir okunacak kitabı silme
  Future<void> okunacakKitapSil(String kitapId) async {
    try {
      await _firestore.collection('_okunacakKitaplar').doc(kitapId).delete();
      print('Okunacak kitap başarıyla silindi.');
    } catch (e) {
      print('Okunacak kitap silme hatası: $e');
    }
  }

  // veritabanından tüm belgeleri çekip stream'e dönüştürür.
  Stream<List<Kitap>> tumKitaplariGetir() {
    String? kullaniciId = _auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('kitaplar')
        .orderBy('kitapAdi') // alfabetik sıralama yapar
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Kitap.fromFirestore(doc)).toList());
  }

  // Veritabanına kitaba puan verme işlevi
  Future<void> kitabaPuanVer(Kitap kitap, int puan) async {
    try {
      // Kullanıcının kimliğini al
      String? kullaniciId = _auth.currentUser?.uid;

      // Kullanıcı oturumu açmışsa
      if (kullaniciId != null) {
        DocumentReference kitapRef =
            _firestore.collection('kitaplar').doc(kitap.id);
        await kitapRef.update({
          'puanlar': FieldValue.arrayUnion([puan])
        });

        print('Kitaba puan başarıyla verildi.');
      } else {
        print('Oturum açık değil.');
      }
    } catch (e) {
      print('Kitaba puan verme hatası: $e');
    }
  }

  Stream<List<Kitap>> tumKitaplar() {
    return _firestore.collection('kitaplar').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Kitap.fromFirestore(doc)).toList());
  }

  // Kullanıcının okuduğu toplam kitap sayısını getir
  Future<int> getToplamOkunanKitapSayisi() async {
    try {
      String userId = ''; // Kullanıcı ID'sini buraya eklemeniz gerekiyor
      QuerySnapshot snapshot = await _firestore
          .collection('kitaplar')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Toplam kitap sayısı alınırken hata oluştu: $e');
      return 0; // Hata durumunda sıfır döner
    }
  }
}
