import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'SnakeGame/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCRg1mzSPSAOIajUf2cCgccGD53g9Kl2oI",
          authDomain: "snakegame-9067b.firebaseapp.com",
          projectId: "snakegame-9067b",
          storageBucket: "snakegame-9067b.appspot.com",
          messagingSenderId: "597359349957",
          appId: "1:597359349957:web:653e6495cb6c4507b460ac",
          measurementId: "G-L7XB9THKY8"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Snake Game",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.teal, brightness: Brightness.dark),
      home: HomeScreen(),
    );
  }
}
