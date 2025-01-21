import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todomanage/component/theme.dart';
import 'package:todomanage/component/theme_provider.dart';
import 'Screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    DevicePreview(
      enabled: true, // Enable DevicePreview only in debug mode
      builder: (context) => ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Consume ThemeProvider to apply the theme dynamically
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Update the status bar style based on the current theme
    final isDarkMode = themeProvider.themeData.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? const Color(0xFF14142B) : Colors.white, // Set appropriate color
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard on tap outside input fields
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        builder: DevicePreview.appBuilder, // Enable DevicePreview
        useInheritedMediaQuery: true, // Use the media query from DevicePreview
        debugShowCheckedModeBanner: false,
        theme: themeProvider.themeData, // Apply dynamic theme
        home: const SplashScreen(),
      ),
    );
  }
}
