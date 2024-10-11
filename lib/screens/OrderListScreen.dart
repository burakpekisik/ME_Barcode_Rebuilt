import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/SearchHelper.dart';
import 'package:me_barcode_flutter/screens/widgets/AddOrderDialog.dart';
import 'package:me_barcode_flutter/screens/widgets/EditOrderDialog.dart';
import 'package:me_barcode_flutter/screens/widgets/PaginationControls.dart';
import 'package:me_barcode_flutter/widgets/ListViewBuilder.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  FetchHelper fetchHelper = FetchHelper();
  SearchHelper searchHelper = SearchHelper();
  List<dynamic> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  Timer? _debounce; // Debounce işlemi için bir Timer
  bool isOrder = true;
  bool isLoading = false; // CircularProgressIndicator için durum
  late final Function(int currentPage, bool isOrder) fetchList;
  String orderDeleteLink = dotenv.env['ORDER_DELETE'] ?? '';

  // Add sorting state variables
  String sortingType = 'Sipariş Numarası'; // Default sorting type
  String sortingOrder = 'Azalan'; // Default sorting order

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    setState(() {
      isLoading = true; // Yükleme başlıyor
    });
    final data = await fetchHelper.fetchData(
        isOrder, currentPage, sortingType, sortingOrder);
    setState(() {
      orders = data['data']; // Update the state with the fetched orders data
      totalPages = data['totalPages'];
      isLoading = false; // Yükleme tamamlandı
    });
  }

  void _showAddOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddOrderDialogWidget(
          fetchOrders: fetchOrderData, // fetchOrders metodu yerine fetchOrderData kullanılıyor
        );
      },
    );
  }

  void _showOrderDetailsDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (context) {
        return OrderDetailsDialogWidget(
          order: order,
          fetchOrders: fetchOrderData, // fetchOrders metodu yerine fetchOrderData kullanılıyor
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddOrderDialog, // Eski showAddOrderDialog fonksiyonu yerine yeni widget kullanıldı
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Sipariş Ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search), // Search icon
              ),
              onChanged: (value) {
                searchHelper.onSearchChanged(value, false,
                        (List<dynamic> results) {
                      setState(() {
                        orders = results; // Update orders with search results
                      });
                    }, orders, sortingType, sortingOrder);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sorting Type Dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: sortingType, // Default value
                      onChanged: (String? newValue) {
                        setState(() {
                          // Update the selected value in the setState
                          sortingType = newValue!;
                          currentPage = 1;
                          fetchOrderData();
                        });
                      },
                      underline: Container(), // Remove underline
                      isExpanded: true, // Make dropdown expand to fill container
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10.0), // Sağdan padding ekledik
                        child: Icon(Icons.sort), // Sorting icon
                      ),
                      items: <String>[
                        'Sipariş Numarası',
                        'Sipariş Fiyatı',
                        'Sipariş Tarihi'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0), // Soldan padding ekledik
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Spacing between dropdowns
                // Sorting Order Dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: sortingOrder, // Seçilen değeri buraya koyun
                      onChanged: (String? newValue) {
                        setState(() {
                          sortingOrder = newValue!;
                          currentPage = 1;
                          fetchOrderData();
                        });
                      },
                      underline: Container(), // Remove underline
                      isExpanded: true, // Make dropdown expand to fill container
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0), // Sağdan padding ekledik
                        child: sortingOrder == "Artan"
                            ? const Icon(Icons.arrow_upward)
                            : const Icon(Icons.arrow_downward), // Ascending/Descending icon
                      ),
                      items: <String>[
                        'Artan',
                        'Azalan'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0), // Soldan padding ekledik
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // CircularProgressIndicator ekledik
                : ListViewBuilder(
              deleteUrl: orderDeleteLink,
              items: orders,
              onTap: _showOrderDetailsDialog, // Eski showOrderDetailsDialog yerine yeni widget kullanıldı
              fetchList: (currentPage, isOrder) {
                fetchHelper.fetchData(isOrder, currentPage, sortingType, sortingOrder);
              },
            ),
          ),
          PaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: (int newPage) {
              setState(() {
                currentPage = newPage;
              });
              fetchOrderData();
            },
          ),
        ],
      ),
    );
  }
}
