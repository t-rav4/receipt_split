import 'package:flutter/material.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/widgets/page_layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isOffline = false;

  var preferenceService = PreferenceService();

  @override
  void initState() {
    super.initState();
    _loadOfflineMode();
  }

  Future<void> _loadOfflineMode() async {
    var isOffline = await preferenceService.getOfflineMode();

    setState(() {
      _isOffline = isOffline;
    });
  }

  Future<void> _setOfflineMode(bool isEnabled) async {
    await preferenceService.changeOfflineMode(isEnabled);

    setState(() {
      _isOffline = isEnabled;
    });
  }

  void onChangeOfflineSwitch(bool isEnabled) {
    _setOfflineMode(isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return RsLayout(
      title: "Settings",
      showBackButton: true,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Offline Mode?"),
          Switch(value: _isOffline, onChanged: onChangeOfflineSwitch),
        ],
      ),
    );
  }
}
