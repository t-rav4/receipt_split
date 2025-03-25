import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'dart:core';

class SplitService {
  SplitService._privateConstructor();

  static final SplitService _instance = SplitService._privateConstructor();

  factory SplitService() {
    return _instance;
  }

  final String _apiUrl = dotenv.env["API_URL"]!;

  Future<List<Item>> extractItemsFromReceipt(File file) async {
    final PreferenceService preferenceService = PreferenceService();
    if (await preferenceService.getOfflineMode() == true) {
      String text = await ReadPdfText.getPDFtext(file.path);

      var items = extractItemsFromText(text);
      return items;
    }

    var uri = Uri.parse("$_apiUrl/extract-receipt/");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode != 200) {
      print("ERROR: ${response.reasonPhrase}");
      return [];
    }

    // Read response body ONCE and store it
    String responseBody = await response.stream.bytesToString();

    Map<String, dynamic> jsonData = json.decode(responseBody);

    List<Item> items = (jsonData['items'] as List)
        .map((itemJson) => Item.fromJson(itemJson))
        .toList();

    print(items);

    return items;
  }

  List<Item> extractItemsFromText(String text) {
    // Regex pattern for matching item names w/ prices
    final itemPattern = RegExp(r"([\w\s\-%\*]+)\s+(\d+\.\d{2})");

    final matches = itemPattern.allMatches(text);

    List<Item> items = [];
    for (final match in matches) {
      final name = match.group(1)?.trim() ?? ''; // Group 1 => Item name
      final price =
          double.tryParse(match.group(2) ?? '') ?? 0.0; // Group 2 => Price

      if (name.isNotEmpty && price >= 0.0) {
        items.add(Item(name: name, price: price));
      }
    }

    return items;
  }
}
