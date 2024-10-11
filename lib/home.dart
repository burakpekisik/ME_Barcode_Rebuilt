import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_barcode_flutter/screens/BarcodeScreen.dart';
import 'package:me_barcode_flutter/screens/CustomerListScreen.dart';
import 'package:me_barcode_flutter/screens/EnvelopeCreateScreen.dart';
import 'package:me_barcode_flutter/screens/LetterOrderScreen.dart';
import 'package:me_barcode_flutter/screens/ManualBarcodeScreen.dart';
import 'package:me_barcode_flutter/screens/OrderListScreen.dart';
import 'package:me_barcode_flutter/screens/SentCodesScreen.dart';
import 'package:me_barcode_flutter/widgets/BuildButton.dart';
import 'package:me_barcode_flutter/widgets/BuildCard.dart';
import 'package:me_barcode_flutter/widgets/GreetingsWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> dailyCustomerCounts = [];
  List<dynamic> dailyOrderCounts = [];
  double monthlyRevenue = 0.0;
  double previousMonthRevenue = 0.0;
  double revenueChangePercentage = 0;
  int totalCustomersMonth = 0;
  int totalCustomersWeek = 0;
  int totalCustomersYear = 0;
  int totalOrdersMonth = 0;
  int totalOrdersWeek = 0;
  int totalOrdersYear = 0;
  double weeklyRevenue = 0.0;
  double yearlyRevenue = 0.0;
  String statusLink = dotenv.env['STATUS'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(statusLink));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // Debugging line
      setState(() {
        dailyCustomerCounts = data['daily_customer_counts'];
        dailyOrderCounts = data['daily_order_counts'];
        monthlyRevenue = data['monthly_revenue'];
        previousMonthRevenue = data['previous_month_revenue'];
        revenueChangePercentage = data['revenue_change_percentage'];
        totalCustomersMonth = data['total_customers_month'];
        totalCustomersWeek = data['total_customers_week'];
        totalCustomersYear = data['total_customers_year'];
        totalOrdersMonth = data['total_orders_month'];
        totalOrdersWeek = data['total_orders_week'];
        totalOrdersYear = data['total_orders_year'];
        weeklyRevenue = data['weekly_revenue'];
        yearlyRevenue = data['yearly_revenue'];
      });
    } else {
      print(response.body);
      throw Exception('Failed to load data');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Center(child: GreetingWidget()),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PageView(
                      children: [
                        CustomCard(
                          colors: const [
                            Colors.blueAccent,
                            Colors.lightBlueAccent
                          ],
                          title: 'Bu Hafta Sipariş',
                          value: 'Sipariş Sayısı: $totalOrdersWeek',
                          status: 'Haftalık Gelir: ',
                          price: weeklyRevenue.toString(),
                        ),
                        CustomCard(
                          colors: const [Colors.greenAccent, Colors.green],
                          title: 'Bu Ay Sipariş',
                          value: 'Sipariş Sayısı: $totalOrdersMonth',
                          status: 'Aylık Gelir: ',
                          price: monthlyRevenue.toString(),
                          percent: revenueChangePercentage,
                        ),
                        CustomCard(
                          colors: const [Colors.redAccent, Colors.deepOrange],
                          title: 'Bu Yıl Sipariş',
                          value: 'Sipariş Sayısı: $totalOrdersYear',
                          status: 'Yıllık Gelir: ',
                          price: yearlyRevenue.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PageView(
                      children: [
                        CustomCard(
                          colors: const [Colors.orangeAccent, Colors.amber],
                          title: 'Müşteri Verileri',
                          subtitle: 'Yıllık: $totalCustomersYear',
                          value: 'Aylık: $totalCustomersMonth',
                          status: 'Haftalık: $totalCustomersWeek',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // First chart (Daily Order Counts)
            const Text(
              'Sipariş Tablosu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Days of the week
                          const daysOfWeek = [
                            'Pzt',
                            'Sal',
                            'Çrş',
                            'Perş',
                            'Cum',
                            'Cmt',
                            'Pzr'
                          ];
                          if (value.toInt() < daysOfWeek.length) {
                            return Text(daysOfWeek[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyOrderCounts
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var value = entry.value;
                        return FlSpot(
                            index.toDouble(), value['count'].toDouble());
                      }).toList(),
                      isCurved: false,
                      // Set to false for straight lines
                      barWidth: 4,
                      color: Colors.purpleAccent,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Second chart (Daily Customer Counts)
            const Text(
              'Üye Tablosu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Days of the week
                          const daysOfWeek = [
                            'Pzt',
                            'Sal',
                            'Çrş',
                            'Perş',
                            'Cum',
                            'Cmt',
                            'Pzr'
                          ];
                          if (value.toInt() < daysOfWeek.length) {
                            return Text(daysOfWeek[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyCustomerCounts
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var value = entry.value;
                        return FlSpot(
                            index.toDouble(), value['count'].toDouble());
                      }).toList(),
                      isCurved: false,
                      // Set to false for straight lines
                      barWidth: 4,
                      color: Colors.cyanAccent,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'İşlemler:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            // Buttons below the charts
            Center(
              child: Builder(
                builder: (context) {
                  List<Widget> buttons = [
                    CustomButton(
                      label: 'Müşteri Listesi',
                      icon: Icons.list,
                      onPressed: () {
                        Get.to(() => const CustomerListScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Sipariş Listesi',
                      icon: Icons.receipt,
                      onPressed: () {
                        Get.to(() => const OrderListScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Barkod Ekle',
                      icon: Icons.qr_code_scanner,
                      onPressed: () {
                        Get.to(() => const BarcodeScannerScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Elle Barkod Ekle',
                      icon: Icons.add,
                      onPressed: () {
                        Get.to(() => const ManualBarcodeScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Gönderilmiş Kodlar',
                      icon: Icons.send,
                      onPressed: () {
                        Get.to(() => const SentCodesScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Fiyat Tablosu Oluştur',
                      icon: Icons.table_chart,
                      onPressed: () {
                        Get.to(() => const LetterOrderScreen());
                      },
                    ),
                    CustomButton(
                      label: 'Zarf Oluştur',
                      icon: Icons.adf_scanner,
                      onPressed: () {
                        Get.to(() => const EnvelopeCreateScreen());
                      },
                    ),
                  ];

                  return Column(
                    children: List.generate((buttons.length / 2).ceil(), (index) {
                      if (index * 2 + 1 < buttons.length) {
                        // Two buttons in a row
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: buttons[index * 2]),
                            const SizedBox(width: 16),
                            Expanded(child: buttons[index * 2 + 1]),
                          ],
                        );
                      } else {
                        // Only one button in the row
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: buttons[index * 2]),
                          ],
                        );
                      }
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
