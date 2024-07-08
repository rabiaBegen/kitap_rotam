import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilDuzenle extends StatefulWidget {
  @override
  _ProfilDuzenleState createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController kadiController = TextEditingController();
  final TextEditingController hedefKitapController = TextEditingController();
  String? profilResmiUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        // Firebase Storage'a resmi yükle
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${_auth.currentUser?.uid}.jpg');

        UploadTask uploadTask = storageRef.putFile(imageFile);

        // Yükleme işlemi tamamlanana kadar bekleyin
        await uploadTask.whenComplete(() => null);

        // Resmin indirilebilir URL'sini al
        String downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          profilResmiUrl = downloadUrl;
        });
      } catch (e) {
        print('Resim yükleme hatası: $e');
      }
    }
  }

  Future<void> _updateProfile(String newUsername, String? newhedefKitapSayisi,
      String? newProfileImageUrl) async {
    try {
      // Firestore'daki belgeyi güncelle
      final userDoc = FirebaseFirestore.instance
          .collection('kitaplar')
          .doc(_auth.currentUser?.uid);
      await userDoc.update({
        'kullaniciAdi': newUsername,
        'hedefKitapSayisi': newhedefKitapSayisi,
        'profilResmi': newProfileImageUrl,
      });
    } catch (e) {
      print('Profil güncelleme hatası: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcı bilgilerini yükle
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('kitaplar').doc(user.uid);
        final userData = await userDoc.get();

        if (userData.exists) {
          setState(() {
            kadiController.text = userData['kullaniciAdi'];
            hedefKitapController.text = userData['hedefKitapSayisi'];
            profilResmiUrl = userData['profilResmi'];
          });
        }
      }
    } catch (e) {
      print('Kullanıcı verileri yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    kadiController.dispose();
    hedefKitapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepPurple.shade300,
          title: Text('Profil Düzenle'),
          centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profilResmiUrl != null
                      ? NetworkImage(profilResmiUrl!)
                      : null,
                  child: profilResmiUrl == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              TextFormField(
                controller: kadiController,
                decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kullanıcı adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: hedefKitapController,
                decoration: InputDecoration(
                    labelText: 'Hedef Kitap Sayısı',
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple))),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _updateProfile(kadiController.text,
                        hedefKitapController.text, profilResmiUrl);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
