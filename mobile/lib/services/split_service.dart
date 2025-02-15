import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_split/models/item.dart';

class SplitService {
  SplitService._privateConstructor();

  static final SplitService _instance = SplitService._privateConstructor();

  factory SplitService() {
    return _instance;
  }

  final String _apiUrl = dotenv.env["API_URL"]!;

  Future<List<Item>> extractItemsFromReceipt(File file) async {
    var uri = Uri.parse("$_apiUrl/extract-receipt/");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode != 200) {
      // Catch errors
      print("ERROR HELLO: ${response.reasonPhrase}");
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
}
