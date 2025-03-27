import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deneme_v1/screens/home_screen.dart';
import 'package:deneme_v1/screens/create_room_screen.dart';
import 'package:deneme_v1/screens/join_room_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyberpunk Quiz',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Orbitron', // Cyberpunk tarzı font
          bodyColor: Colors.cyanAccent,
          displayColor: Colors.pinkAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: HomeScreen(),
      routes: {
        '/createRoom': (context) => CreateRoomScreen(),
        '/joinRoom': (context) => JoinRoomScreen(),
      },
    );
  }
}
