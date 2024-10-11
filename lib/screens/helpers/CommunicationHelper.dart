import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunicationHelper {
  void showCommunicationOptions({
    required BuildContext context,
    required Map<String, dynamic> order,
    required Function(String, String) sendOrderData,
    required Function(String, String) sendEmail,
    required Function(String, String, String, String, String) sendSms,
    required String barcode,
  }) {
    // Use Stateful widget for managing state
    bool emailChecked = true;
    bool smsChecked = true;

    String netgsmUsername = dotenv.env['NETGSM_USERNAME'] ?? '';
    String netgsmPassword = dotenv.env['NETGSM_PASSWORD'] ?? '';
    String netgsmHeader = dotenv.env['NETGSM_HEADER'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İletişim Seçenekleri'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Email'),
                    value: emailChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        emailChecked = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('SMS'),
                    value: smsChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        smsChecked = value ?? false;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Onayla'),
              onPressed: () async {
                Navigator.of(context).pop();
                await sendOrderData(order['order_id'].toString(), barcode);
                if (emailChecked) {
                  await sendEmail(order['email'], barcode);
                }
                if (smsChecked) {
                  await sendSms(
                    netgsmUsername,
                    netgsmPassword,
                    netgsmHeader,
                    "Değerli müşterimiz, Mektup Evi üzerinden vermiş olduğunuz siparişinizin teslimat durumunu $barcode takip kodu ile PTT'nin internet sitesi üzerinden veya verilen link üzerinden takip edebilirsiniz. https://gonderitakip.ptt.gov.tr/Track/Verify?q=$barcode",
                    order['phone_number'],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class OrderHelper {
  final CommunicationHelper communicationHelper = CommunicationHelper();

  void showOrderDetails({
    required BuildContext context,
    required Map<String, dynamic> order,
    required String barcode,
    required Function(String, String) sendOrderData,
    required Function(String, String) sendEmail,
    required Function(String, String, String, String, String) sendSms,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sipariş Bilgileri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barkod Numarası: ${barcode.isNotEmpty ? barcode : 'Girilen barkod yok'}'), // Girilen barkod bilgisi burada gösteriliyor
              Text('Kişi Adı: ${order['customer_name']}'),
              Text('Telefon Numarası: ${order['phone_number']}'),
              Text('Email: ${order['email']}')
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Onayla'),
              onPressed: () {
                Navigator.of(context).pop();
                communicationHelper.showCommunicationOptions(
                  context: context,
                  order: order,
                  sendOrderData: sendOrderData,
                  sendEmail: sendEmail,
                  sendSms: sendSms,
                  barcode: barcode,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
