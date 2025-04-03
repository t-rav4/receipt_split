import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/select_users/presentation/select_users_page.dart';
import 'package:receipt_split/features/settings/presentation/settings_page.dart';
import 'package:receipt_split/shared/providers/receipt_split_provider.dart';
import 'package:receipt_split/shared/widgets/card_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const snackBar = SnackBar(
    content: Text("Not yet implemented"),
    behavior: SnackBarBehavior.floating,
  );

  void handleOnSettingsPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
  }

  Future<void> pickPdfFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == "" || !context.mounted) {
      return;
    }

    final selectedPdf = File(result.files.single.path!);

    Provider.of<ReceiptSplitProvider>(context, listen: false)
        .selectPdf(selectedPdf);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectUsersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Receipt Split",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => handleOnSettingsPress(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CardButton(
              icon: Icons.attach_file,
              label: "Select a .pdf file from device’s storage",
              onTap: () => pickPdfFile(context),
            ),
            CardButton(
              icon: Icons.camera_alt_rounded,
              label: "Take a photo of your receipt using your camera!",
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
