import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';

import 'package:me_barcode_flutter/screens/helpers/HttpClientProvider.dart';

class FetchHelper {
  // Initialize properties to hold orders and customers data
  List<dynamic> orders = [];
  List<dynamic> customers = [];
  int totalPages = 1;

  String standartFetchLink = dotenv.env['STANDART_FETCH_LINK'] ?? '';

  // Fetch data from server
  Future<Map<String, dynamic>> fetchData(bool isOrder, int currentPage,
      String sortingType, String sortingOrder, [String? fetchLink]) async {
    String type;
    String sort;

    // Maps to convert sorting type to query parameters
    final Map<String, String> sortingTypeMap;
    final Map<String, String> sortingOrderMap;

    if (isOrder) {
      sortingTypeMap = {
        'Sipariş Numarası': 'order_id',
        'Sipariş Fiyatı': 'order_price',
        'Sipariş Tarihi': 'order_date',
      };

      sortingOrderMap = {
        'Artan': 'ascending',
        'Azalan': 'descending',
      };

      type = sortingTypeMap[sortingType] ?? 'order_id';
      sort = sortingOrderMap[sortingOrder] ?? 'descending';
    } else {
      sortingTypeMap = {
        'Müşteri Numarası': 'customer_id',
        'Müşteri Adı': 'customer_name',
        'Kayıt Tarihi': 'signup_date',
      };

      sortingOrderMap = {
        'Artan': 'ascending',
        'Azalan': 'descending',
      };

      type = sortingTypeMap[sortingType] ?? 'customer_id';
      sort = sortingOrderMap[sortingOrder] ?? 'descending';
    }

    // HttpClientProvider singleton'ını kullan
    final http.Client client = IOClient(HttpClientProviderCert.instance.httpClient);

    final http.Response response;

    if (fetchLink != null) {
      response = await client.get(
        Uri.parse('$fetchLink/$currentPage?type=$type&sort=$sort'),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await client.get(
        Uri.parse('$standartFetchLink/${isOrder
            ? 'orders'
            : 'customers'}/pages/$currentPage?type=$type&sort=$sort'),
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (isOrder) {
        orders = data['orders'];
      } else {
        customers = data['customers'];
      }

      totalPages = data['total_pages'];

      return {
        'data': isOrder ? orders : customers,
        'totalPages': totalPages,
      };
    } else {
      print(response.body);
      throw Exception('Failed to load data');
    }
  }
}
