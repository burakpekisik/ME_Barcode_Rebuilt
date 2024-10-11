import 'package:flutter/material.dart';

class ManualDialogHelper {
  static void showBarcodeDialog({
    required BuildContext context,
    required Function(String) onConfirm,
  }) {
    final TextEditingController barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barkod Girişi'),
          content: TextField(
            controller: barcodeController,
            decoration: const InputDecoration(hintText: "Barkodu girin"),
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Onayla'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(barcodeController.text); // Pass barcode back
              },
            ),
          ],
        );
      },
    );
  }
}