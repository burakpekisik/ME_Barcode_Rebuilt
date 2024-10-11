import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddOrderDialogWidget extends StatefulWidget {
  final Function fetchOrders;

  const AddOrderDialogWidget({super.key, required this.fetchOrders});

  @override
  _AddOrderDialogWidgetState createState() => _AddOrderDialogWidgetState();
}

class _AddOrderDialogWidgetState extends State<AddOrderDialogWidget> {
  String name = '';
  String phoneNumber = '';
  String email = '';
  String orderPrice = '';
  String letterType = 'Cezaevine Mektup';
  bool isWhatsAppOrder = false;
  String addOrderLink = dotenv.env['ADD_ORDER'] ?? '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Sipariş Ekle'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'İsim Soyisim'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Telefon Numarası'),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Sipariş Ücreti'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  orderPrice = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Mektup Türü'),
            DropdownButton<String>(
              value: letterType,
              onChanged: (String? newValue) {
                setState(() {
                  letterType = newValue!;
                });
              },
              items: <String>[
                'Cezaevine Mektup',
                'Sevgiliye Mektup',
                'Askere Mektup',
                'Geleceğe Mektup',
                'Gizli Mektup'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Row(
              children: [
                Checkbox(
                  value: isWhatsAppOrder,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isWhatsAppOrder = newValue!;
                    });
                  },
                ),
                const Text('WhatsApp Siparişi Mi?'),
              ],
            ),
          ],
        ),
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
            if (!orderPrice.contains('TL')) {
              if (orderPrice.contains('.')) {
                orderPrice = '$orderPrice TL';
              } else {
                orderPrice = '$orderPrice.00 TL';
              }
            }

            Map<String, dynamic> newOrder = {
              'phone_number': phoneNumber,
              'customer_name': name,
              'order_price': orderPrice,
              'letter_name': letterType,
              'email': email,
              'is_whatsapp': isWhatsAppOrder,
            };

            final response = await http.post(
              Uri.parse(addOrderLink),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(newOrder),
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sipariş başarıyla eklendi')),
              );
              widget.fetchOrders(); // Sipariş listesini güncelle
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sipariş eklenirken hata oluştu')),
              );
            }
            Navigator.of(context).pop(); // Dialogu kapat
          },
        ),
      ],
    );
  }
}
