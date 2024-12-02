import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/SplashScreen.dart';

// void main() {
//   Firebase.initializeApp();
//   runApp(const MainApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    DevicePreview(
      enabled: false, // Enable preview only in debug mode
      builder: (context) => MainApp(),
    ),);
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF24263A),
          primaryColor: Colors.tealAccent,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF73FA92),
              selectionColor: Color(0xFF73FA92).withOpacity(0.2),
              selectionHandleColor: Color(0xFF73FA92)),
        ),
        home: const Scaffold(
          body: Center(
            child: SplashScreen(),
          ),
        ),
      ),
    );
  }
}
