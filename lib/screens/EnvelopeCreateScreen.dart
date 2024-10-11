import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class EnvelopeCreateScreen extends StatefulWidget {
  const EnvelopeCreateScreen({super.key});

  @override
  _EnvelopeCreateScreenState createState() => _EnvelopeCreateScreenState();
}

class _EnvelopeCreateScreenState extends State<EnvelopeCreateScreen> {
  String selectedCityName = '';
  String selectedJailName = '';
  String selectedJailAddress = '';

  String senderName = '';
  String senderAddress = '';
  String districtCity = '';
  String date = '';

  String receiverName = '';
  String fatherName = '';
  String dormNo = '';
  bool addDate = false;

  final now = DateTime.now();

  List<Map<String, dynamic>> jailCities = [];
  List<Map<String, dynamic>> jailNames = [];
  List<Map<String, dynamic>> jailAddresses = [];

  ui.Image? backgroundImage;
  double? imageWidth;
  double? imageHeight;

  @override
  void initState() {
    super.initState();
    fetchCityNames();
    loadImage('assets/images/EnvelopeBase.png');
  }

  Future<void> loadImage(String assetPath) async {
    final imageProvider = AssetImage(assetPath);
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final completer = Completer<ui.Image>();

    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    backgroundImage = await completer.future;
    imageWidth = backgroundImage!.width.toDouble();
    imageHeight = backgroundImage!.height.toDouble();

    setState(() {});
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
        final imagePath = '${directory.path}/zarf_$formattedDate.png'; // Dinamik isimlendirme

        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);

        final asset = await PhotoManager.editor.saveImageWithPath(imagePath);
        if (asset != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zarf galeriye kaydedildi!')),
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
        const SnackBar(content: Text('Zarf kaydedilirken bir sorun oluştu!')),
      );
    }
  }

  final GlobalKey renderKey = GlobalKey();

  Future<void> fetchCityNames() async {
    String cityNamesLink = dotenv.env['CITY_NAMES'] ?? '';
    final response =
        await http.get(Uri.parse(cityNamesLink));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        jailCities = List<Map<String, dynamic>>.from(
          data.map((cityName) => {'name': cityName}),
        );
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<void> fetchJails(String jailCity) async {
    String jailNamesLink = dotenv.env['JAIL_NAMES'] ?? '';
    final response =
        await http.get(Uri.parse('$jailNamesLink/$jailCity'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        jailNames = data
            .map((json) => {
                  'name': json['name'],
                  'id': json['id'],
                  'adres': json['adres']
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load jails');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarf Oluştur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gönderici Adı', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    senderName = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Gönderici Adresi', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    senderAddress = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Gönderici İl/İlçe', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    districtCity = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Alıcı İsmi', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    receiverName = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Alıcı Baba Adı', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    fatherName = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text('Alıcı Koğuş Numarası', style: TextStyle(fontSize: 16)),
              TextFormField(
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    dormNo = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildDropdown(
                'Cezaevi Şehri',
                jailCities,
                selectedCityName,
                    (value) {
                  setState(() {
                    selectedCityName = value['name'];
                    selectedJailName = '';
                    fetchJails(selectedCityName);
                  });
                },
              ),
              const SizedBox(height: 10),
              buildDropdown(
                'Cezaevi Adı',
                jailNames,
                selectedJailName,
                    (value) {
                  setState(() {
                    selectedJailName = value['name'];
                    selectedJailAddress = value['adres'];
                  });
                },
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Tarih Ekle'),
                value: addDate,
                onChanged: (bool? value) {
                  setState(() {
                    addDate = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width,
                      child: backgroundImage == null
                          ? const Center(child: CircularProgressIndicator())
                          : RepaintBoundary(
                        key: renderKey,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: CustomPaint(
                            size: Size(imageWidth!, imageHeight!),
                            painter: ImageTextPainter(
                              senderName: senderName,
                              senderAddress: senderAddress,
                              districtCity: districtCity,
                              receiverName: receiverName,
                              fatherName: fatherName,
                              dormNo: dormNo,
                              selectedJailName: selectedJailName,
                              selectedJailAddress: selectedJailAddress,
                              backgroundImage: backgroundImage!,
                              currentDate: DateFormat('yMd').format(now),
                              addDate: addDate,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width, // Resimle aynı genişlikte yap
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            value: options.isNotEmpty && selectedValue.isNotEmpty
                ? options.firstWhere(
                    (option) => option['name'] == selectedValue,
                    orElse: () => {'name': ''})
                : null,
            hint: Text('$label Seçiniz'),
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
        ),
      ],
    );
  }
}

class ImageTextPainter extends CustomPainter {
  final String senderName;
  final String senderAddress;
  final String districtCity;
  final String receiverName;
  final String fatherName;
  final String dormNo;
  final String selectedJailName;
  final String selectedJailAddress;
  final ui.Image backgroundImage;
  final String currentDate;
  final bool addDate;

  ImageTextPainter(
      {required this.senderName,
      required this.senderAddress,
      required this.districtCity,
      required this.receiverName,
      required this.fatherName,
      required this.dormNo,
      required this.selectedJailName,
      required this.selectedJailAddress,
      required this.backgroundImage,
      required this.currentDate,
      required this.addDate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(backgroundImage, Offset.zero, paint);

    drawSenderText(canvas);
    drawRecipientText(canvas);
  }

  void drawText(
      Canvas canvas, String text, double x, double y, TextStyle textStyle) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 637);
    textPainter.paint(canvas, Offset(x, y));
  }

  void drawRecipientText(Canvas canvas) {
    double xAlici = 21;
    double yAlici, yBabaAdi, yKogusNo, yCezaeviAdi, yCezaeviAdresi;
    double shift = 0; // Variable to shift the text upward

    const recipientTextStyle = TextStyle(
      fontFamily: 'GoudyBookletter1911',
      fontSize: 21,
      color: Colors.black,
    );

    // Measure the width of selectedJailAddress to determine if it exceeds the max width
    final addressTextSpan = TextSpan(
      text: selectedJailAddress,
      style: recipientTextStyle,
    );
    final addressTextPainter = TextPainter(
      text: addressTextSpan,
      textDirection: ui.TextDirection.ltr,
    );
    addressTextPainter.layout(minWidth: 0, maxWidth: double.infinity);

    // If the address width exceeds 637, shift all text by 25 pixels upward
    if (addressTextPainter.width > 637) {
      shift = 31;
    }

    if (fatherName.isEmpty && dormNo.isEmpty) {
      yAlici = 398 - shift;
      yCezaeviAdi = 427 - shift;
      yCezaeviAdresi = 454 - shift;
      drawText(canvas, receiverName, xAlici, yAlici, recipientTextStyle);
      drawText(
          canvas, selectedJailName, xAlici, yCezaeviAdi, recipientTextStyle);
      drawText(canvas, selectedJailAddress, xAlici, yCezaeviAdresi,
          recipientTextStyle);
    } else if (fatherName.isNotEmpty && dormNo.isEmpty) {
      yBabaAdi = 397 - shift;
      yAlici = 343 - shift;
      yCezaeviAdi = 427 - shift;
      yCezaeviAdresi = 454 - shift;
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, receiverName, xAlici + 52, yAlici, recipientTextStyle);
      drawText(canvas, "Baba Adı: $fatherName", xAlici, yBabaAdi,
          recipientTextStyle);
      drawText(
          canvas, selectedJailName, xAlici, yCezaeviAdi, recipientTextStyle);
      drawText(canvas, selectedJailAddress, xAlici, yCezaeviAdresi,
          recipientTextStyle);
    } else if (fatherName.isEmpty && dormNo.isNotEmpty) {
      yAlici = 373 - shift;
      yKogusNo = 400 - shift;
      yCezaeviAdi = 427 - shift;
      yCezaeviAdresi = 454 - shift;
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, receiverName, xAlici + 52, yAlici, recipientTextStyle);
      drawText(
          canvas, "Koğuş No: $dormNo", xAlici, yKogusNo, recipientTextStyle);
      drawText(
          canvas, selectedJailName, xAlici, yCezaeviAdi, recipientTextStyle);
      drawText(canvas, selectedJailAddress, xAlici, yCezaeviAdresi,
          recipientTextStyle);
    } else if (fatherName != '' && dormNo != '') {
      yAlici = 343 - shift;
      yKogusNo = 370 - shift;
      yCezaeviAdi = 427 - shift;
      yCezaeviAdresi = 454 - shift;
      yBabaAdi = 397 - shift;
      drawText(canvas, "Baba Adı: $fatherName", xAlici, yBabaAdi,
          recipientTextStyle);
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, "Alıcı: ", xAlici, yAlici, recipientTextStyle);
      drawText(canvas, receiverName, xAlici + 52, yAlici, recipientTextStyle);
      drawText(
          canvas, "Koğuş No: $dormNo", xAlici, yKogusNo, recipientTextStyle);
      drawText(
          canvas, selectedJailName, xAlici, yCezaeviAdi, recipientTextStyle);
      drawText(canvas, selectedJailAddress, xAlici, yCezaeviAdresi,
          recipientTextStyle);
    }
  }

  void drawSenderText(Canvas canvas) {
    const senderNameStyle = TextStyle(
      fontFamily: 'Lobster',
      fontSize: 32,
      color: Colors.black,
    );
    const senderInfoStyle = TextStyle(
      fontFamily: 'GoudyBookletter1911',
      fontSize: 21,
      color: Colors.black,
    );
    const dateStyle = TextStyle(
      fontFamily: 'GoudyBookletter1911',
      fontSize: 18,
      color: Colors.black,
    );

    drawText(canvas, senderName, 163, 62, senderNameStyle); // Gönderen adı
    drawText(
        canvas, senderAddress, 21, 116, senderInfoStyle); // Gönderen adresi
    drawText(
        canvas, districtCity, 21, 147, senderInfoStyle); // Gönderen ilçe/il

    // Tarih alanı (bugünün tarihi)
    addDate ? drawText(canvas, currentDate, 591, 63, dateStyle) : ''; // Tarih
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
