import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/landing/presentation/landing_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receipt_split/services/split_service.dart';
import 'package:receipt_split/shared/providers/offline_provider.dart';
import 'package:receipt_split/shared/providers/receipt_split_provider.dart';

// Feature 2: Capture photo of receipt to scan them instead, into app.
//  source: https://pub.dev/packages/cunning_document_scanner

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  ); // Keeps the splash on screen until we call `remove()`

  await dotenv.load(fileName: ".env");

  FlutterNativeSplash.remove();

  final splitService = SplitService();

  runApp(App(splitService: splitService));
}

class App extends StatelessWidget {
  final SplitService splitService;

  const App({super.key, required this.splitService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SplitService>.value(value: splitService),
        // TODO: add auth provider when firebase is hooked up
        ChangeNotifierProvider(create: (_) => OfflineProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptSplitProvider(splitService))
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
