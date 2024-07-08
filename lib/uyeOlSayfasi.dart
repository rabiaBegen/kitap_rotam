import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitap/giris.dart';

class uyeOlSayfasi extends StatelessWidget {
  const uyeOlSayfasi({super.key});

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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width; //392.72
    double text = MediaQuery.textScaleFactorOf(context);
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                              height: height / 15.6,
                            ),
                            SizedBox(
                              height: height / 43,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 210),
                              child: Text(
                                'Email :',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: height / 50,
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
                              height: height / 43,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 215),
                              child: Text(
                                'Şifre :',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: height / 50,
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
                              height: height / 12,
                            ),
                            Container(
                                height: height / 13.9,
                                width: width / 1.44,
                                child: uyeOlButon()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
      }),
    );
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
        hintText: 'deneme@gmail.com',
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF5E35B1)),
            borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white)),
      ),
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
          hintText: '**********',
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5E35B1)),
              borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white)),
        ));
  }

  Center uyeOlButon() {
    return Center(
      child: TextButton(
        onPressed: uyeOl,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5E35B1), Color(0xFF9688ED)])),
          child: Center(
              child: Text(
            'Üye Ol',
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
        ),
      ),
    );
  }

  void uyeOl() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      var kullanici = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: sifre);
      formKey.currentState!
          .reset(); // kullanıcı kaydı olduktan sonra ekranı sıfırlıyor
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kayıt Başarılı.')));
      Navigator.push(context, MaterialPageRoute(builder: (context) => giris()));
    }
  }
}
