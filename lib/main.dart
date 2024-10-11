import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:me_barcode_flutter/home.dart';
import 'package:me_barcode_flutter/screens/helpers/HttpClientProvider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await HttpClientProviderCert.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: HomeScreen(),
    );
  }
}
