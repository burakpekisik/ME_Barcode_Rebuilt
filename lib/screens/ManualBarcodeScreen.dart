import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:me_barcode_flutter/screens/helpers/CommunicationHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/EmailService.dart';
import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/ImportTrackHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/ManualDialogHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/SMSService.dart';
import 'package:me_barcode_flutter/screens/helpers/SearchHelper.dart';
import 'package:me_barcode_flutter/widgets/ListViewBuilder.dart';
import 'package:me_barcode_flutter/screens/widgets/PaginationControls.dart';

class ManualBarcodeScreen extends StatefulWidget {
  const ManualBarcodeScreen({super.key});

  @override
  _ManualBarcodeScreenState createState() => _ManualBarcodeScreenState();
}

class _ManualBarcodeScreenState extends State<ManualBarcodeScreen> {
  FetchHelper fetchHelper = FetchHelper();
  SearchHelper searchHelper = SearchHelper();
  String barcode = '';
  List<dynamic> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isOrdersFetched = false;
  bool emailChecked = true; // Email seçeneği kontrolü
  bool smsChecked = true; // SMS seçeneği kontrolü
  bool dialogShown = false; // Flag to track if dialog has been shown
  bool isOrder = true;
  bool isLoading = false;
  String orderDeleteLink = dotenv.env['ORDER_DELETE'] ?? '';

  // Add sorting state variables
  String sortingType = 'Sipariş Numarası'; // Default sorting type
  String sortingOrder = 'Azalan'; // Default sorting order

  void fetchOrders() async {
    setState(() {
      isLoading = true; // Yükleme başlıyor
    });

    final response = await fetchHelper.fetchData(
        isOrder, currentPage, sortingType, sortingOrder);

    setState(() {
      orders = response['data'];
      totalPages = response['totalPages'];
      isOrdersFetched = true;
      isLoading = false; // Yükleme tamamlandı
    });
  }

  @override
  void initState() {
    super.initState();
    // No longer call the dialog here
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the dialog only if it hasn't been shown before
    if (!dialogShown) {
      dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ManualDialogHelper.showBarcodeDialog(
          context: context,
          onConfirm: (String enteredBarcode) {
            setState(() {
              barcode = enteredBarcode; // Update barcode state
            });
            fetchOrders(); // Fetch orders after barcode is entered
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elle Barkod Gir'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Sipariş Ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchHelper.onSearchChanged(
                  value,
                  false,
                      (List<dynamic> results) {
                    setState(() {
                      orders = results;
                    });
                  },
                  orders,
                  sortingType,
                  sortingOrder,
                );
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
                      value: sortingType,
                      // Default value
                      onChanged: (String? newValue) {
                        setState(() {
                          // Update the selected value in the setState
                          sortingType = newValue!;
                          currentPage = 1;
                          fetchOrders();
                        });
                      },
                      underline: Container(),
                      // Remove underline
                      isExpanded: true,
                      // Make dropdown expand to fill container
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        // Sağdan padding ekledik
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
                            padding: const EdgeInsets.only(left: 10.0),
                            // Soldan padding ekledik
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
                      // Seçilen değeri buraya koyun
                      onChanged: (String? newValue) {
                        setState(() {
                          sortingOrder = newValue!;
                          currentPage = 1;
                          fetchOrders();
                        });
                      },
                      underline: Container(),
                      // Remove underline
                      isExpanded: true,
                      // Make dropdown expand to fill container
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        // Sağdan padding ekledik
                        child: sortingOrder == "Artan"
                            ? const Icon(Icons.arrow_upward)
                            : const Icon(Icons
                            .arrow_downward), // Ascending/Descending icon
                      ),
                      items: <String>['Artan', 'Azalan']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            // Soldan padding ekledik
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
            child: isOrdersFetched
                ? ListViewBuilder(
              deleteUrl: orderDeleteLink,
              items: orders,
              fetchList: (currentPage, isOrder) {
                fetchHelper.fetchData(
                    isOrder, currentPage, sortingType, sortingOrder);
              },
              onTap: (order) {
                OrderHelper().showOrderDetails(
                  context: context,
                  order: order,
                  sendOrderData: (orderId, barcode) async {
                    bool result = await sendOrderData(orderId, barcode);
                    if (result) {
                      showSnackbar('Barkod başarıyla kaydedildi.');
                      fetchOrders();
                    } else {
                      showSnackbar('Barkod kaydedilirken hata oluştu.');
                    }
                  },
                  sendEmail: (recipientsEmail, barcode) async {
                    bool result = await sendEmail(recipientsEmail, barcode);
                    if (result) {
                      showSnackbar('Email başarıyla gönderildi.');
                    } else {
                      showSnackbar('Email gönderiminde hata oluştu.');
                    }
                  },
                  sendSms: (username, password, header, msg, gsm) async {
                    bool result = await sendSms(
                        username, password, header, msg, gsm);
                    if (result) {
                      showSnackbar('SMS başarıyla gönderildi.');
                    } else {
                      showSnackbar('SMS gönderiminde hata oluştu.');
                    }
                  },
                  barcode: barcode,
                );
              }, // Handle tap event
            )
                : const Center(
              child: CircularProgressIndicator(), // CircularProgressIndicator eklendi
            ),
          ),
          if (isOrdersFetched) ...[
            PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: (int newPage) {
                setState(() {
                  currentPage = newPage;
                });
                fetchOrders();
              },
            ),
          ],
        ],
      ),
    );
  }
}
