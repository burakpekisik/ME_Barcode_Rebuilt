import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditCustomerDialog extends StatefulWidget {
  final String customerId;
  final String currentName;
  final String currentEmail;
  final String currentStatus;
  final String currentPrivilege;

  const EditCustomerDialog({
    super.key,
    required this.customerId,
    required this.currentName,
    required this.currentEmail,
    required this.currentStatus,
    required this.currentPrivilege,
  });

  @override
  _EditCustomerDialogState createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String selectedStatus;
  late String selectedPrivilege;
  String editCustomerLink = dotenv.env['EDIT_CUSTOMER'] ?? '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
    selectedStatus = widget.currentStatus;
    selectedPrivilege = widget.currentPrivilege;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Müşteri Bilgilerini Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Müşteri Adı'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Durum', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Üyelik Tipi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DropdownButton<String>(
              value: selectedPrivilege,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPrivilege = newValue!;
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
          onPressed: () {
            Map<String, dynamic> updatedData = {
              'customer_id': widget.customerId,
              'customer_name':
                  nameController.text.isNotEmpty ? nameController.text : null,
              'email':
                  emailController.text.isNotEmpty ? emailController.text : null,
              'status': selectedStatus != widget.currentStatus
                  ? selectedStatus
                  : null,
              'privilage': selectedPrivilege != widget.currentPrivilege
                  ? selectedPrivilege
                  : null,
            };
            updatedData.removeWhere((key, value) => value == null);

            http
                .put(
              Uri.parse(editCustomerLink),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(updatedData),
            )
                .then((response) {
              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Müşteri bilgileri başarıyla güncellendi.')),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Güncelleme işlemi başarısız.')),
                );
              }
            });
          },
        ),
      ],
    );
  }
}
