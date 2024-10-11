import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:me_barcode_flutter/screens/ManageOptionsScreen.dart';
import 'dart:ui' as ui; // UI kütüphanesini ekleyin
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class LetterOrderScreen extends StatefulWidget {
  const LetterOrderScreen({super.key});

  @override
  _LetterOrderScreenState createState() => _LetterOrderScreenState();
}

class _LetterOrderScreenState extends State<LetterOrderScreen> {
  String letterText = '';
  String selectedEnvelopeColor = '';
  String selectedPaperColor = '';
  String selectedScent = '';
  String selectedShippingType = '';
  int postcardCount = 0;
  int photoCount = 0;

  double envelopeColorPrice = 0.0;
  double paperColorPrice = 0.0;
  double scentPrice = 0.0;
  double shippingTypePrice = 0.0;
  double characterPrice = 0.0;
  double postcardPrice = 0.0;
  double photoPrice = 0.0;
  double taxRate = 0.20;

  int characterCount = 0;
  double letterCost = 0.0;
  double postcardCost = 0.0;
  double photoCost = 0.0;
  double totalBeforeTax = 0.0;
  double taxAmount = 0.0;

  List<Map<String, dynamic>> envelopeColors = [];
  List<Map<String, dynamic>> paperColors = [];
  List<Map<String, dynamic>> scents = [];
  List<Map<String, dynamic>> shippingTypes = [];

  ui.Image? backgroundImage;
  double? imageWidth; // Yeni eklenen değişken
  double? imageHeight; // Yeni eklenen değişken

  @override
  void initState() {
    super.initState();
    fetchPrices();
    loadImage('assets/images/PriceChart.png');
  }

  // Function to load the image
  Future<void> loadImage(String assetPath) async {
    final imageProvider = AssetImage(assetPath);
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final completer = Completer<ui.Image>();

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    backgroundImage = await completer.future;

    // Resmin genişlik ve yüksekliğini alıyoruz
    imageWidth = backgroundImage!.width.toDouble();
    imageHeight = backgroundImage!.height.toDouble();

    setState(() {}); // Trigger a rebuild after the image is loaded
  }


  Future<void> saveImage() async {
    try {
      var status = await Permission.photos.request();

      if (status.isGranted) {
        RenderRepaintBoundary boundary =
        renderKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Şu anki zamanı al ve dosya adı için bir format oluştur
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/fiyat_$formattedDate.png'; // Dinamik isimlendirme

        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);

        final asset = await PhotoManager.editor.saveImageWithPath(imagePath);
        if (asset != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fiyat listesi galeriye kaydedildi!')),
          );
        } else {
          throw Exception('Failed to save image');
        }
      } else {
        throw Exception('Permission to access gallery not granted');
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiyat listesi kaydedilirken bir sorun oluştu!')),
      );
    }
  }

  final GlobalKey renderKey = GlobalKey();

  Future<void> fetchPrices() async {
    String pricesLink = dotenv.env['PRICES'] ?? '';
    final response = await http.get(Uri.parse(pricesLink));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        characterPrice = double.parse(data['character'][0]['price']) / 10;
        postcardPrice = double.parse(data['cardpostal'][0]['price']);
        photoPrice = double.parse(data['photo'][0]['price']);

        envelopeColors =
        List<Map<String, dynamic>>.from(data['envelope_color']);
        paperColors = List<Map<String, dynamic>>.from(data['paper_color']);
        scents = List<Map<String, dynamic>>.from(data['smell']);
        shippingTypes = List<Map<String, dynamic>>.from(data['shipment']);
      });
    } else {
      throw Exception('Failed to load prices');
    }
  }

  double getTotalPrice() {
    characterCount = letterText.length;
    letterCost = (characterCount / 2) * characterPrice;
    postcardCost = postcardCount * postcardPrice;
    photoCost = photoCount * photoPrice;

    totalBeforeTax = letterCost +
        envelopeColorPrice +
        paperColorPrice +
        scentPrice +
        shippingTypePrice +
        postcardCost +
        photoCost;
    taxAmount = totalBeforeTax * taxRate;
    return totalBeforeTax + taxAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiyat Listesi Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageOptionsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mektup Metni', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 5,
                onChanged: (value) {
                  setState(() {
                    letterText = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildDropdown('Zarf Rengi', envelopeColors, selectedEnvelopeColor,
                      (value) {
                    setState(() {
                      selectedEnvelopeColor = value['name'];
                      envelopeColorPrice = double.parse(value['price']);
                    });
                  }),
              const SizedBox(height: 10),
              buildDropdown('Kağıt Rengi', paperColors, selectedPaperColor,
                      (value) {
                    setState(() {
                      selectedPaperColor = value['name'];
                      paperColorPrice = double.parse(value['price']);
                    });
                  }),
              const SizedBox(height: 10),
              const Text('Kartpostal Sayısı', style: TextStyle(fontSize: 16)),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    postcardCount = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Fotoğraf Sayısı', style: TextStyle(fontSize: 16)),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    photoCount = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildDropdown('Mektup Kokusu', scents, selectedScent, (value) {
                setState(() {
                  selectedScent = value['name'];
                  scentPrice = double.parse(value['price']);
                });
              }),
              const SizedBox(height: 10),
              buildDropdown(
                  'Postalama Türü', shippingTypes, selectedShippingType,
                      (value) {
                    setState(() {
                      selectedShippingType = value['name'];
                      shippingTypePrice = double.parse(value['price']);
                    });
                  }),
              const SizedBox(height: 10),
              Text('Ödenecek Tutar: ${getTotalPrice().toStringAsFixed(2)} TL',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              // Image Container with CustomPainter
              Center( // Ortalamak için
                child: Column(
                  children: [
                    Container(
                      height: imageHeight ?? MediaQuery.of(context).size.height * 0.75,
                      width: imageWidth ?? MediaQuery.of(context).size.width * 0.8, // Genişliği sınırlıyoruz
                      alignment: Alignment.center, // Center the image
                      child: backgroundImage == null
                          ? const Center(child: CircularProgressIndicator())
                          : RepaintBoundary(
                        key: renderKey, // Render key burada kullanılır
                        child: CustomPaint(
                          size: Size(imageWidth!, imageHeight!), // Resmin boyutlarına göre ayarlama
                          painter: ImageTextPainter(
                            letterText: letterText,
                            selectedEnvelopeColor: selectedEnvelopeColor,
                            selectedPaperColor: selectedPaperColor,
                            postcardCount: postcardCount,
                            photoCount: photoCount,
                            smell: selectedScent,
                            shipment: selectedShippingType,
                            taxRate: taxRate,
                            letterCost: letterCost,
                            postcardCost: postcardCost,
                            photoCost: photoCost,
                            totalBeforeTax: totalBeforeTax,
                            taxAmount: taxAmount,
                            envelopeColorPrice: envelopeColorPrice,
                            paperColorPrice: paperColorPrice,
                            scentPrice: scentPrice,
                            shippingTypePrice: shippingTypePrice,
                            backgroundImage: backgroundImage!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Kaydet butonu, resim genişliği ile uyumlu olacak
                    SizedBox(
                      width: imageWidth ?? MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: saveImage,
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<Map<String, dynamic>> options,
      String selectedValue, Function(Map<String, dynamic>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        DropdownButton<Map<String, dynamic>>(
          value: options.isNotEmpty && selectedValue.isNotEmpty
              ? options.firstWhere((option) => option['name'] == selectedValue)
              : null,
          hint: Text('$label Seçin'),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option['name']),
            );
          }).toList(),
          onChanged: (value) {
            onChanged(value!);
          },
        ),
      ],
    );
  }
}


class ImageTextPainter extends CustomPainter {
  final String letterText;
  final String selectedEnvelopeColor;
  final String selectedPaperColor;
  final int postcardCount;
  final int photoCount;
  final String smell;
  final String shipment;
  final double taxRate;

  final double letterCost;
  final double postcardCost;
  final double photoCost;
  final double totalBeforeTax;
  final double taxAmount;
  final double envelopeColorPrice;
  final double paperColorPrice;
  final double scentPrice;
  final double shippingTypePrice;
  final ui.Image backgroundImage;

  ImageTextPainter({
    required this.letterText,
    required this.selectedEnvelopeColor,
    required this.selectedPaperColor,
    required this.postcardCount,
    required this.photoCount,
    required this.smell,
    required this.shipment,
    required this.taxRate,
    required this.letterCost,
    required this.postcardCost,
    required this.photoCost,
    required this.totalBeforeTax,
    required this.taxAmount,
    required this.envelopeColorPrice,
    required this.paperColorPrice,
    required this.scentPrice,
    required this.shippingTypePrice,
    required this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the preloaded image
    Paint paint = Paint();
    canvas.drawImage(backgroundImage, Offset.zero, paint);

    // Draw the letter text and other elements
    drawText(canvas, letterText.length.toString(), 123, 37);
    drawText(canvas, selectedEnvelopeColor, 94, 106);
    drawText(canvas, selectedPaperColor, 99, 176);
    drawText(canvas, postcardCount.toString(), 76, 245);
    drawText(canvas, photoCount.toString(), 76, 313);
    drawText(canvas, smell, 15, 382);
    drawText(canvas, shipment, 15, 450);
    drawText(
        canvas, "%${(taxRate * 100).toInt()} KDV", 15, 520);

    drawPriceText(canvas, letterCost.toStringAsFixed(2), 279, 25);
    drawPriceText(canvas, envelopeColorPrice.toStringAsFixed(2), 279, 92);
    drawPriceText(canvas, paperColorPrice.toStringAsFixed(2), 279, 162);
    drawPriceText(canvas, postcardCost.toStringAsFixed(2), 279, 232);
    drawPriceText(canvas, photoCost.toStringAsFixed(2), 279, 302);
    drawPriceText(canvas, scentPrice.toStringAsFixed(2), 279, 372);
    drawPriceText(canvas, shippingTypePrice.toStringAsFixed(2), 279, 442);
    drawPriceText(canvas, taxAmount.toStringAsFixed(2), 279, 512);
    drawPriceText(
        canvas, (totalBeforeTax + taxAmount).toStringAsFixed(2), 269, 608);
  }

  void drawText(Canvas canvas, String text, double x, double y) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.normal,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(maxWidth: 300); // Set a max width for the text
    textPainter.paint(canvas, Offset(x, y)); // Starting coordinates
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when letterText or selectedEnvelopeColor changes
  }

  void drawPriceText(Canvas canvas, String text, double x, double y) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: "$text TL",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    textPainter.layout(maxWidth: 300); // Set a max width for the text
    textPainter.paint(canvas, Offset(x, y)); // Starting coordinates
  }
}