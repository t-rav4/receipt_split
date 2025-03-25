import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:receipt_split/pages/landing_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Feature 2: Capture photo of receipt to scan them instead, into app.
//  source: https://pub.dev/packages/cunning_document_scanner

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
      widgetsBinding:
          widgetsBinding); // Keeps the splash on screen until we call `remove()`

  await dotenv.load(fileName: ".env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt-Split',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: Color(0xFF2C2C2C),
        ),
      ),
      theme: ThemeData(
          colorScheme: ColorScheme.light(),
          useMaterial3: true,
          textTheme: TextTheme(bodyMedium: TextStyle(fontFamily: "Roboto"))),
      themeMode: ThemeMode.dark,
      home: const LandingPage(),
    );
  }
}
