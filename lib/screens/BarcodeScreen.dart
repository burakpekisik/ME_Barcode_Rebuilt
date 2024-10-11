import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_barcode_flutter/screens/helpers/BarcodeHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/CommunicationHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/EmailService.dart';
import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/SMSService.dart';
import 'package:me_barcode_flutter/screens/helpers/SearchHelper.dart';
import 'package:me_barcode_flutter/screens/widgets/PaginationControls.dart';
import 'package:me_barcode_flutter/widgets/ListViewBuilder.dart';
import 'package:me_barcode_flutter/screens/helpers/ImportTrackHelper.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  FetchHelper fetchHelper = FetchHelper();
  SearchHelper searchHelper = SearchHelper();
  BarcodeHelper barcodeHelper = BarcodeHelper();
  String barcode = '';
  List<dynamic> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isOrdersFetched = false;
  bool emailChecked = true;
  bool smsChecked = true;
  bool isOrder = true;
  bool isLoading = false; // Yükleme durumu için yeni değişken
  String orderDeleteLink = dotenv.env['ORDER_DELETE'] ?? '';

  String sortingType = 'Sipariş Numarası';
  String sortingOrder = 'Azalan';

  @override
  void initState() {
    super.initState();
    // Start barcode scanning and handle the result in a callback
    barcodeHelper.startBarcodeScan(context, (String scannedBarcode) {
      setState(() {
        barcode = scannedBarcode; // Update the barcode string
      });
      fetchOrders(scannedBarcode); // Fetch orders with the new barcode
    });
  }

  void fetchOrders(String scannedBarcode) async {
    setState(() {
      isLoading = true; // Yükleme başlıyor
    });

    final response = await fetchHelper.fetchData(isOrder, currentPage, sortingType, sortingOrder);

    setState(() {
      orders = response['data'];
      totalPages = response['totalPages'];
      isOrdersFetched = true;
      isLoading = false; // Yükleme tamamlandı
    });
  }

  void resetScanner() {
    setState(() {
      orders.clear();
      currentPage = 1;
      isOrdersFetched = false;
      barcode = '';
      isLoading = false;
    });
    barcodeHelper.startBarcodeScan(context, (String scannedBarcode) {
      setState(() {
        barcode = scannedBarcode; // Update the barcode string
      });
      fetchOrders(scannedBarcode); // Fetch orders with the new barcode
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod Tarayıcı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              resetScanner(); // Butona tıklandığında tarayıcıyı sıfırla
            },
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: sortingType,
                      onChanged: (String? newValue) {
                        setState(() {
                          sortingType = newValue!;
                          currentPage = 1;
                          fetchOrders(barcode); // Fetch orders with the current barcode
                        });
                      },
                      underline: Container(),
                      isExpanded: true,
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.sort),
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
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                          fetchOrders(barcode); // Fetch orders with the current barcode
                        });
                      },
                      underline: Container(),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: sortingOrder == "Artan"
                            ? const Icon(Icons.arrow_upward)
                            : const Icon(Icons.arrow_downward),
                      ),
                      items: <String>[
                        'Artan',
                        'Azalan'
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
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Yükleme sırasında gösterilecek
                : isOrdersFetched
                ? ListViewBuilder(
              deleteUrl: orderDeleteLink,
              items: orders,
              fetchList: (currentPage, isOrder) {
                fetchHelper.fetchData(isOrder, currentPage, sortingType, sortingOrder);
              },
              onTap: (order) {
                OrderHelper().showOrderDetails(
                  context: context,
                  order: order,
                  sendOrderData: (orderId, barcode) async {
                    bool result = await sendOrderData(orderId, barcode);
                    if (result) {
                      showSnackbar('Barkod başarıyla kaydedildi.');
                      fetchOrders(barcode); // Refresh orders after saving
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
                    bool result = await sendSms(username, password, header, msg, gsm);
                    if (result) {
                      showSnackbar('SMS başarıyla gönderildi.');
                    } else {
                      showSnackbar('SMS gönderiminde hata oluştu.');
                    }
                  },
                  barcode: barcode,
                );
              },
            )
                : const Center(child: Text('')),
          ),
          if (isOrdersFetched) ...[
            PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: (int newPage) {
                setState(() {
                  currentPage = newPage;
                });
                fetchOrders(barcode); // Fetch orders with the current barcode
              },
            ),
          ],
        ],
      ),
    );
  }
}
