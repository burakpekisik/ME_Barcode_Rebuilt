import 'dart:io';
import 'package:flutter/services.dart';

class HttpClientProviderCert {
  static final HttpClientProviderCert _instance = HttpClientProviderCert._internal();
  late final HttpClient httpClient;

  // Singleton erişimi için getter
  static HttpClientProviderCert get instance => _instance;

  // Private constructor to prevent external instantiation
  HttpClientProviderCert._internal();

  // Initialize HttpClient with SSL certificate
  Future<void> init() async {
    SecurityContext context = SecurityContext.defaultContext;

    // SSL sertifikasını yükle
    final certData = await rootBundle.load('assets/cert.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());

    httpClient = HttpClient(context: context);
  }
}
