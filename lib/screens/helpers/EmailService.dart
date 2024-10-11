import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<bool> sendEmail(String recipientsEmail, String trackCode) async {
  String username = dotenv.env['EMAIL_USERNAME'] ?? '';
  String password = dotenv.env['EMAIL_PASSWORD'] ?? '';


  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'Mektup Evi') // Gönderen adı ve e-posta adresi
    ..recipients.add(recipientsEmail) // Alıcı e-posta adresi
    ..subject = 'Siparişiniz Kargoya Verildi!'
    ..text =
        "Değerli müşterimiz, Mektup Evi üzerinden vermiş olduğunuz siparişinizin teslimat durumunu $trackCode takip kodu ile PTT'nin internet sitesi üzerinden veya verilen link üzerinden takip edebilirsiniz. https://gonderitakip.ptt.gov.tr/Track/Verify?q=$trackCode";

  try {
    final sendReport = await send(message, smtpServer);
    print('E-posta başarıyla gönderildi: ${sendReport.toString()}');
    return true;
  } catch (e) {
    print('E-posta gönderimi sırasında hata oluştu: $e');
    return false;
  }


}