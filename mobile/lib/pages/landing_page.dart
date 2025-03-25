import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:receipt_split/features/select-users/select_users_page.dart';
import 'package:receipt_split/pages/settings_page.dart';
import 'package:receipt_split/widgets/card_button.dart';

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

  void handleOnSettingsPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
  }

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
      appBar: AppBar(
        title: Text("Receipt Split"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: handleOnSettingsPress,
          ),
        ],
      ),
      body: SafeArea(
        child: Expanded(
          child: Padding(
            padding: EdgeInsets.all(48),
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
      ),
    );
  }
}
