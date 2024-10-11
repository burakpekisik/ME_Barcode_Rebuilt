import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderDetailsDialogWidget extends StatefulWidget {
  final Map<String, dynamic> order;
  final Function fetchOrders;

  const OrderDetailsDialogWidget({super.key, required this.order, required this.fetchOrders});

  @override
  _OrderDetailsDialogWidgetState createState() => _OrderDetailsDialogWidgetState();
}

class _OrderDetailsDialogWidgetState extends State<OrderDetailsDialogWidget> {
  late int orderId;
  late String name;
  late String phoneNumber;
  late String orderPrice;
  late String letterType;
  String editOrderLink = dotenv.env['EDIT_ORDER'] ?? '';

  @override
  void initState() {
    super.initState();
    orderId = widget.order['order_id'];
    name = widget.order['customer_name'];
    phoneNumber = widget.order['phone_number'];
    orderPrice = widget.order['order_price'];
    letterType = widget.order['letter_name'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sipariş Detayları'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Müşteri Adı'),
              controller: TextEditingController(text: name),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Sipariş Ücreti'),
              controller: TextEditingController(text: orderPrice),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  orderPrice = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Telefon Numarası'),
              controller: TextEditingController(text: phoneNumber),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
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
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('İptal Et'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Onayla'),
          onPressed: () async {
            Map<String, dynamic> updatedOrder = {
              'order_id': orderId,
              'customer_name': name,
              'phone_number': phoneNumber,
              'order_price': orderPrice.toString(),
              'letter_name': letterType,
            };

            final response = await http.put(
              Uri.parse(editOrderLink),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(updatedOrder),
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sipariş başarıyla güncellendi')),
              );
              widget.fetchOrders(); // Sipariş listesini güncelle
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sipariş güncellenirken hata oluştu')),
              );
            }
            Navigator.of(context).pop(); // Dialogu kapat
          },
        ),
      ],
    );
  }
}
