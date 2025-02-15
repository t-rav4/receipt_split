import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:receipt_split/select_users_page.dart';
import 'package:receipt_split/widgets/card_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Feature 2: Capture photo of receipt to scan them instead, into app.
//  source: https://pub.dev/packages/cunning_document_scanner

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
      widgetsBinding:
          widgetsBinding); // Keeps the splash on screen until we call `remove()`

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const snackBar = SnackBar(
    content: Text("Not yet implemented"),
    behavior: SnackBarBehavior.floating,
  );

  String? selectedPdf;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> pickPdfFile() async {
      // Opens file picker - select PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null ||
          result.files.single.path == "" ||
          !context.mounted) {
        return;
      }

      setState(() {
        selectedPdf = result.files.single.path;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SelectUsersPage(selectedPdf: result.files.single.path!),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardButton(
                icon: Icons.attach_file,
                label: "Select a .pdf file from device’s storage",
                onTap: pickPdfFile,
              ),
              CardButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Take a photo of your receipt using your camera!",
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
