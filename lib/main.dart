import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kitap/firebase_options.dart';

import 'giris.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //hiçbir şey başlatılmadan önce firebase başlatılmış oluyor
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: giris(),
    );
  }
}
