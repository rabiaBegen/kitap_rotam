import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitap/anaSayfa.dart';
import 'package:kitap/navBar.dart';
import 'package:kitap/uyeOlSayfasi.dart';

class giris extends StatelessWidget {
  const giris({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late String email, sifre;
  final formKey = GlobalKey<FormState>(); // formu dışarıdan kontrol etmek için
  final firebaseAuth = FirebaseAuth.instance;

  void giris() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        final kullanici = await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: sifre,
        );
        if (kullanici.user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navBar()),
          );
        } else {
          print('Giriş başarısız.');
        }
      } catch (e) {
        print('Giriş hatası: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width; //392.72
    double text = MediaQuery.textScaleFactorOf(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.deepPurple.shade100,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(right: 29, left: 29, top: 123),
                  child: AnimatedBackground(
                    vsync: this,
                    behaviour: RandomParticleBehaviour(
                        options: ParticleOptions(
                      spawnMaxRadius: 40,
                      spawnMinSpeed: 15,
                      particleCount: 80,
                      spawnMaxSpeed: 40,
                      baseColor: Colors.deepPurple,
                    )),
                    child: Center(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: height / 8.48,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.deepPurple.shade100),
                                  borderRadius: BorderRadius.circular(15)),
                              height: height / 13.9,
                              width: width / 1.44,
                              child: emailTextField(),
                            ),
                            SizedBox(
                              height: height / 22,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.deepPurple.shade100),
                                  borderRadius: BorderRadius.circular(15)),
                              height: height / 13.9,
                              width: width / 1.44,
                              child: sifreTextField(),
                            ),
                            SizedBox(
                              height: height / 8.5,
                            ),
                            Container(
                              height: height / 13.9,
                              width: width / 1.44,
                              child: girisButon(),
                            ),
                            SizedBox(
                              height: height / 15,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => uyeOlSayfasi()),
                                );
                              },
                              child: Text(
                                "Üye Ol",
                                style: TextStyle(
                                    color: Color(0xFF5E35B1),
                                    fontSize: text * 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }

  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri eksiksiz doldurunuz.';
        }
      },
      onSaved: (value) {
        email =
            value!; // value! dolu olacak demek kullanıcının girdiği veriyi alma
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "deneme@gmail.com",
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF5E35B1)),
          ),
          prefixIcon: Icon(Icons.mail, color: Colors.black),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  TextFormField sifreTextField() {
    return TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'Bilgileri eksiksiz doldurunuz.';
          }
        },
        onSaved: (value) {
          sifre = value!;
        },
        obscureText: true,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '********',
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF5E35B1)),
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white)),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.black,
            )));
  }

  Center girisButon() {
    return Center(
      child: TextButton(
        onPressed: giris,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5E35B1), Color(0xFF9688ED)])),
          child: Center(
            child: Text(
              'Oturum Aç',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
