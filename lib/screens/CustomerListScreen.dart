import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/SearchHelper.dart';
import 'package:me_barcode_flutter/screens/widgets/AddCustomerDialog.dart';
import 'package:me_barcode_flutter/screens/widgets/EditCustomerDialog.dart';
import 'package:me_barcode_flutter/screens/widgets/PaginationControls.dart';
import 'package:me_barcode_flutter/widgets/ListViewBuilder.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  FetchHelper fetchHelper = FetchHelper();
  SearchHelper searchHelper = SearchHelper();
  List<dynamic> customers = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isOrder = false;
  bool isLoading = false; // Added loading state variable
  late final Function(int currentPage, bool isOrder) fetchList;
  String customerDeleteLink = dotenv.env['CUSTOMER_DELETE'] ?? '';

  String sortingType = 'Müşteri Numarası';
  String sortingOrder = 'Azalan';

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    setState(() {
      isLoading = true; // Start loading
    });
    final data = await fetchHelper.fetchData(
        isOrder, currentPage, sortingType, sortingOrder);
    setState(() {
      customers = data['data']; // Update the state with fetched customer data
      totalPages = data['totalPages'];
      isLoading = false; // Stop loading after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Listesi'), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // AddCustomerDialog'u bir modal dialog olarak açıyoruz
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AddCustomerDialog();
              },
            ).then((value) {
              // Yeni müşteri eklendikten sonra müşteri listesini yenile
              setState(() {
                fetchCustomerData(); // Güncel müşteri verilerini çek
              });
            });
          },
        ),
      ]),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Müşteri Ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search), // Search icon
              ),
              onChanged: (value) {
                searchHelper.onSearchChanged(value, false, (List<dynamic> results) {
                  setState(() {
                    customers = results; // Update customers with search results
                  });
                }, customers, sortingType, sortingOrder);
              },
            ),
          ),
          // Sorting Row
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
                      value: sortingType,
                      // Default value
                      onChanged: (String? newValue) {
                        setState(() {
                          sortingType = newValue!;
                          currentPage = 1;
                          fetchCustomerData(); // Fetch data with updated value
                        });
                      },
                      underline: Container(),
                      isExpanded: true,
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.sort), // Sorting icon
                      ),
                      items: <String>[
                        'Müşteri Numarası',
                        'Müşteri Adı',
                        'Kayıt Tarihi'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
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
                      value: sortingOrder,
                      onChanged: (String? newValue) {
                        setState(() {
                          sortingOrder = newValue!;
                          currentPage = 1;
                          fetchCustomerData(); // Fetch data with updated value
                        });
                      },
                      underline: Container(),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: sortingOrder == "Artan"
                            ? const Icon(Icons.arrow_upward)
                            : const Icon(Icons.arrow_downward), // Ascending/Descending icon
                      ),
                      items: <String>['Artan', 'Azalan'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
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
                ? const Center(child: CircularProgressIndicator()) // Show CircularProgressIndicator when loading
                : ListViewBuilder(
              deleteUrl: customerDeleteLink,
              items: customers,
              fetchList: (currentPage, isOrder) async {
                // This can be removed if FutureBuilder handles fetching data
              },
              onTap: (item) {
                // Show EditCustomerDialog when a customer item is tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditCustomerDialog(
                      customerId: item['customer_id'].toString(),
                      // Assuming item contains 'customer_id'
                      currentName: item['customer_name'],
                      // Assuming item contains 'customer_name'
                      currentEmail: item['email'],
                      // Assuming item contains 'email'
                      currentStatus: item['status'],
                      // Assuming item contains 'status'
                      currentPrivilege: item['privilage'],
                      // Assuming item contains 'privilage'
                    );
                  },
                ).then((value) {
                  // Refresh the customer list after the dialog is closed
                  fetchCustomerData();
                });
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
              fetchCustomerData();
            },
          ),
        ],
      ),
    );
  }
}
