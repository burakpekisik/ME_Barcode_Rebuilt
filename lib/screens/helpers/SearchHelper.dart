import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:me_barcode_flutter/screens/helpers/FetchHelper.dart';

class SearchHelper {
  Timer? _debounce;
  FetchHelper fetchHelper = FetchHelper();

  String standartFetchLink = dotenv.env['STANDART_FETCH_LINK'] ?? '';

  Future<List<dynamic>> searchData(String searchQuery, bool isOrder, [String? filterParam]) async {
    // Eğer filter_param dolu ise onu da json'a ekle, boşsa sadece search_param'ı gönder
    Map<String, dynamic> body = {
      'search_param': searchQuery,
    };
    
    if (filterParam != null && filterParam.isNotEmpty) {
      body['filter_param'] = filterParam;
    }

    final response = await http.post(
      Uri.parse('$standartFetchLink/${isOrder ? 'orders' : 'customers'}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return isOrder ? data['orders'] : data['customers'];
    } else {
      throw Exception('Failed to search data');
    }
  }

  void onSearchChanged(String query, bool isOrder, Function(List<dynamic>) fetchData, List<dynamic> customers, String sortingType, String sortingOrder, [String? filterParam, String? fetchLink]) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    List results;

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        // filter_param null olup olmadığını kontrol et
        results = await searchData(query, isOrder, filterParam);
        fetchData(results); // Pass results to the callback to update the UI
      } else {
        final data = await fetchHelper.fetchData(isOrder, 1, sortingType, sortingOrder, fetchLink); // Pass fetch_link here
        customers = data['data'];
        fetchData(customers); // Clear search results if the query is empty
      }
    });
  }

  void dispose() {
    _debounce?.cancel();
  }
}
