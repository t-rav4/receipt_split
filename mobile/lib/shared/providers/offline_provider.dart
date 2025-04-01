import 'package:flutter/material.dart';
import 'package:receipt_split/services/preferences_service.dart';

class OfflineProvider extends ChangeNotifier {
  final PreferenceService _preferenceService = PreferenceService();

  bool _isOffline = true;

  bool get isOffline => _isOffline;

  void toggleOfflineMode(bool offlineMode) {
    _preferenceService.changeOfflineMode(offlineMode);
    _isOffline = offlineMode;
    notifyListeners();
  }
}