import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smawarriors/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smawarriors/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(centerTitle: true,backgroundColor: const Color(0xFF546A7B),iconTheme: IconThemeData(color: Colors.white),),
        cardTheme: CardTheme(elevation:5, color: Color(0xFFF8F0E7), ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF546A7B)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
