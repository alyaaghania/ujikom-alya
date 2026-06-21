import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  // Wajib dipanggil sebelum runApp() ketika menggunakan plugin native (Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi koneksi ke Firebase menggunakan konfigurasi
  // yang sudah otomatis dibuat oleh flutterfire configure
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Arahkan Firestore ke Emulator lokal (untuk development tanpa billing)
  FirebaseFirestore.instance.useFirestoreEmulator('192.168.0.117', 8080);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiUMKM BPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}