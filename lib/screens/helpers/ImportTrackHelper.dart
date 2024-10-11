import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> sendOrderData(String orderId, String barcode) async {
  String importTrackUrl = dotenv.env['IMPORT_TRACK_URL'] ?? '';

  final response = await http.post(
    Uri.parse('$importTrackUrl/import_track/$orderId/$barcode'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Sipariş verileri başarıyla kaydedildi: ${response.body}');
    return true;
  } else {
    print('Sipariş verileri kaydedilirken hata oluştu: ${response.statusCode}');
    return false;
  }
}