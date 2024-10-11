import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeHelper {
  Future<String> startBarcodeScan(
      BuildContext context, Function(String) onConfirm) async {
    try {
      String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'İptal',
        true,
        ScanMode.BARCODE,
      );

      if (scannedBarcode != '-1') {
        _showAlertDialog(context, scannedBarcode, onConfirm);
        return scannedBarcode;
      } else {
        return '';
      }
    } catch (e) {
      return 'Taranamadı';
    }
  }

  void _showAlertDialog(
      BuildContext context, String scannedBarcode, Function(String) onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barkod Numarası'),
          content: Text('Taranan Barkod: $scannedBarcode'), // Barkod numarasını burada göster
          actions: <Widget>[
            TextButton(
              child: const Text('Yeniden Çek'), // Buton adı değiştirildi
              onPressed: () {
                Navigator.of(context).pop();
                startBarcodeScan(context, onConfirm); // Taramayı yeniden başlat
              },
            ),
            TextButton(
              child: const Text('Onayla'),
              onPressed: () {
                onConfirm(scannedBarcode); // Onayla butonuna basılınca onConfirm fonksiyonunu çağır ve barkodu gönder
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
