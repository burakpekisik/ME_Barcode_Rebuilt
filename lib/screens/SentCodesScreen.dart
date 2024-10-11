import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_barcode_flutter/screens/WebViewScreen.dart';
import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';
import 'package:me_barcode_flutter/screens/helpers/SearchHelper.dart';
import 'package:me_barcode_flutter/screens/widgets/PaginationControls.dart';
import 'package:me_barcode_flutter/widgets/ListViewBuilder.dart';

class SentCodesScreen extends StatefulWidget {
  const SentCodesScreen({super.key});

  @override
  _SentCodesScreenState createState() => _SentCodesScreenState();
}

class _SentCodesScreenState extends State<SentCodesScreen> {
  SearchHelper searchHelper = SearchHelper();
  FetchHelper fetchHelper = FetchHelper();
  List<dynamic> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isOrder = true;
  bool isLoading = false;
  String tracksLink = dotenv.env['TRACKS'] ?? '';
  String orderDeleteLink = dotenv.env['ORDER_DELETE'] ?? '';

  String sortingType = 'Sipariş Numarası';
  String sortingOrder = 'Azalan';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    setState(() {
      isLoading = true; // Yükleme başlıyor
    });

    final response = await fetchHelper.fetchData(
        isOrder, currentPage, sortingType, sortingOrder, tracksLink);

    setState(() {
      orders = response['data'];
      totalPages = response['totalPages'];
      isLoading = false; // Yükleme tamamlandı
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderilmiş Kodlar'),
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
                    isOrder,
                        (List<dynamic> results) {
                      setState(() {
                        orders = results;
                      });
                    },
                    orders,
                    sortingType,
                    sortingOrder,
                    'track_id',
                    tracksLink
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
                          fetchOrders();
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
                          fetchOrders();
                        });
                      },
                      underline: Container(),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: sortingOrder == "Artan" ? const Icon(Icons.arrow_upward) : const Icon(Icons.arrow_downward),
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
            child: ListViewBuilder(
              deleteUrl: orderDeleteLink,
              items: orders,
              fetchList: (currentPage, isOrder) {
                fetchOrders(); // Updated to use fetchOrders directly
              },
              onTap: (item) {
                final trackId = item['track_id'];
                if (trackId != null && trackId.isNotEmpty) {
                  final trackingUrl = 'https://gonderitakip.ptt.gov.tr/Track/Verify?q=$trackId';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(url: trackingUrl),
                    ),
                  );
                }
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
              fetchOrders();
            },
          ),
        ],
      ),
    );
  }
}