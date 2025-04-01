import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/shared/providers/offline_provider.dart';
import 'package:receipt_split/shared/widgets/page_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineProvider>(builder: (context, offlineProvider, _) {
      void onChangeOfflineSwitch(bool isEnabled) {
        offlineProvider.toggleOfflineMode(isEnabled);
      }

      return RsLayout(
        title: "Settings",
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Offline Mode?"),
            Switch(
              value: offlineProvider.isOffline,
              onChanged: onChangeOfflineSwitch,
            ),
          ],
        ),
      );
    });
  }
}
