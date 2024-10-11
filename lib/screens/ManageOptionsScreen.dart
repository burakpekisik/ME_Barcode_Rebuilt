import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageOptionsScreen extends StatefulWidget {
  const ManageOptionsScreen({super.key});

  @override
  _ManageOptionsScreenState createState() => _ManageOptionsScreenState();
}

class _ManageOptionsScreenState extends State<ManageOptionsScreen> {
  String pricesLink = dotenv.env['PRICES'] ?? '';

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _characterPriceController = TextEditingController();
  final TextEditingController _postcardPriceController = TextEditingController();
  final TextEditingController _photoPriceController = TextEditingController();

  String selectedCategory = 'envelope_color';
  final List<Map<String, String>> categories = [
    {'key': 'envelope_color', 'value': 'Zarf Rengi'},
    {'key': 'paper_color', 'value': 'Kağıt Rengi'},
    {'key': 'smell', 'value': 'Mektup Kokusu'},
    {'key': 'shipment', 'value': 'Postalama Türü'},
  ];

  Map<String, dynamic> _data = {};
  String? _selectedItemName;
  String? _selectedItemCode;
  bool _isUpdating = false;

  Future<void> _fetchPrices() async {
    try {
      final response = await http.get(Uri.parse(pricesLink));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          // Set the global prices based on the fetched data
          _characterPriceController.text = _data['character'][0]['price'].toString() ?? '';
          _postcardPriceController.text = _data['cardpostal'][0]['price'].toString() ?? '';
          _photoPriceController.text = _data['photo'][0]['price'].toString() ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veri alınamadı!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu!')),
      );
    }
  }

  Future<void> _addOrUpdateItem(String category, String name, double price, String? code) async {
    try {
      final response = _isUpdating
          ? await http.put(
        Uri.parse(pricesLink),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          category: [
            {
              'name': name,
              'code': code, // Include the code during update
              'price': price,
            }
          ]
        }),
      )
          : await http.post(
        Uri.parse(pricesLink),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          category: [
            {
              'name': name,
              'price': price,
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem başarıyla tamamlandı!')),
        );
        _fetchPrices(); // Refresh the prices after the operation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu!')),
      );
    }
  }

  Future<void> _deleteItem(String category, String itemName) async {
    try {
      final response = await http.delete(
        Uri.parse(pricesLink),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          category: [
            {'name': itemName}
          ]
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$itemName başarıyla silindi!')),
        );
        _fetchPrices(); // Refresh the data after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silme işlemi başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      _itemController.text = item['name'];
      _priceController.text = item['price'].toString();
      _selectedItemName = item['name'];
      _selectedItemCode = item['code']; // Save the code for updates
      _isUpdating = true; // Set to true to indicate update mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiyatları ve Kategorileri Yönet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              items: categories.map((Map<String, String> category) {
                return DropdownMenuItem<String>(
                  value: category['key'],
                  child: Text(category['value']!), // Display user-friendly name
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  _itemController.clear();
                  _priceController.clear();
                  _isUpdating = false; // Reset update state on category change
                });
              },
            ),
            TextFormField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'Değer'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Değer alanı boş olamaz!';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Fiyat'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Fiyat alanı boş olamaz!';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                String name = _itemController.text;
                double price = double.tryParse(_priceController.text) ?? 0.0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen geçerli bir değer ve fiyat girin!')),
                  );
                } else {
                  _addOrUpdateItem(selectedCategory, name, price, _selectedItemCode);
                  _itemController.clear();
                  _priceController.clear();
                  _isUpdating = false; // Reset update state after operation
                }
              },
              child: Text(_isUpdating ? 'Güncelle' : 'Ekle/Güncelle'),
            ),
            Expanded(
              child: _data.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _data[selectedCategory]?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = _data[selectedCategory][index];
                  return ListTile(
                    title: Text('${item['name'] ?? 'N/A'} - ${item['price']} TL'),
                    onTap: () => _selectItem(item), // Handle item selection
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteItem(selectedCategory, item['name']);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const Text('Set Global Prices'),
            TextFormField(
              controller: _characterPriceController,
              decoration: const InputDecoration(labelText: 'Karakter Ücreti'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                double price = double.tryParse(_characterPriceController.text) ?? 0.0;
                _updatePrice('character', price);
              },
              child: const Text('Karakter Ücreti Güncelle'),
            ),
            TextFormField(
              controller: _postcardPriceController,
              decoration: const InputDecoration(labelText: 'Kartpostal Ücreti'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                double price = double.tryParse(_postcardPriceController.text) ?? 0.0;
                _updatePrice('cardpostal', price);
              },
              child: const Text('Kartpostal Ücreti Güncelle'),
            ),
            TextFormField(
              controller: _photoPriceController,
              decoration: const InputDecoration(labelText: 'Fotoğraf Ücreti'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                double price = double.tryParse(_photoPriceController.text) ?? 0.0;
                _updatePrice('photo', price);
              },
              child: const Text('Fotoğraf Ücreti Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePrice(String category, double price) async {
    // Similar logic for updating price goes here
    // Assuming you have an update endpoint for updating prices separately
    try {
      final response = await http.put(
        Uri.parse(pricesLink),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          category: [
            {'price': price}
          ]
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fiyat başarıyla güncellendi!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncelleme işlemi başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu!')),
      );
    }
  }
}
