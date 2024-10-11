import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  _AddCustomerDialogState createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  String customerId = '';
  String customerName = '';
  String email = '';
  String status = 'Aktif';
  String privilege = 'Müşteri';
  String addCustomerLink = dotenv.env['ADD_CUSTOMER'] ?? '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Müşteri Ekle'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Müşteri ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                customerId = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Müşteri Adı'),
              onChanged: (value) {
                customerName = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
            ),
            const SizedBox(height: 16),
            const Text('Durum'),
            DropdownButton<String>(
              value: status,
              onChanged: (String? newValue) {
                setState(() {
                  status = newValue!;
                });
              },
              items: <String>['Aktif', 'Pasif']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Üyelik Tipi'),
            DropdownButton<String>(
              value: privilege,
              onChanged: (String? newValue) {
                setState(() {
                  privilege = newValue!;
                });
              },
              items: <String>['Müşteri', 'Admin']
                  .map<DropdownMenuItem<String>>((String value) {
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
            Map<String, dynamic> newCustomer = {
              'customer_id': customerId,
              'customer_name': customerName,
              'email': email,
              'status': status,
              'privilage': privilege,
            };

            final response = await http.post(
              Uri.parse(addCustomerLink),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(newCustomer),
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Müşteri başarıyla eklendi')),
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Müşteri eklenirken hata oluştu')),
              );
            }
          },
        ),
      ],
    );
  }
}
