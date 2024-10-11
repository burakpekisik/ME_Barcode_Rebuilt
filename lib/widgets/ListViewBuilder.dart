import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListViewBuilder extends StatefulWidget {
  final String deleteUrl;
  final List<dynamic> items;
  final Function(Map<String, dynamic> item)? onTap;
  final Function(int currentPage, bool isOrder) fetchList;

  const ListViewBuilder({
    super.key,
    required this.deleteUrl,
    required this.items,
    this.onTap,
    required this.fetchList,
  });

  @override
  _ListViewBuilderState createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder> {
  bool isLoading = false; // Loading state variable

  Future<void> deleteItem(String itemId, bool isOrder) async {
    final response = await http.delete(
      Uri.parse(widget.deleteUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        (isOrder ? 'order_id' : 'customer_id'): itemId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silme işlemi başarıyla tamamlandı.')),
      );
      print(response.body);
      widget.fetchList(1, isOrder);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silme işlemi başarısız oldu.')),
      );
    }
  }

  void confirmDelete(String itemId, int index, bool isOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content: const Text('Bu öğeyi silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteItem(itemId, isOrder).then((_) {
                  setState(() {
                    widget.items.removeAt(index);
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading // Show loading indicator if isLoading is true
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isOrder = item.containsKey('order_id');

        return Dismissible(
          key: Key(isOrder ? item['order_id'].toString() : item['customer_id'].toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            confirmDelete(
              isOrder ? item['order_id'].toString() : item['customer_id'].toString(),
              index,
              isOrder,
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Text(isOrder ? item['customer_name'][0] : item['customer_name'][0]),
            ),
            title: Text(item['customer_name']),
            subtitle: Text(isOrder
                ? 'ID: ${item['order_id']} \nFiyat: ${item['order_price']}${item['track_id'] != null && item['track_id'].isNotEmpty ? '\nTakip Kodu: ${item['track_id']}' : ''}'
                : 'Email: ${item['email']} \nID: ${item['customer_id']}'),
            trailing: isOrder
                ? (item['date_for_transport'] != null ? Text(item['date_for_transport']) : const Text(''))
                : Text(item['privilage']),
            onTap: () {
              widget.onTap!(item);
            },
          ),
        );
      },
    );
  }
}
