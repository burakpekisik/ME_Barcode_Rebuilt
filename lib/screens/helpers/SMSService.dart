import 'package:http/http.dart' as http;

Future<bool> sendSms(String username, String password, String header, String msg, String gsm) async {
  const String url = "http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl";
  final String body = """<?xml version="1.0"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <SOAP-ENV:Body>
    <ns3:smsGonder1NV2 xmlns:ns3="http://sms/">
      <username>$username</username>
      <password>$password</password>
      <header>$header</header>
      <msg>$msg</msg>
      <gsm>$gsm</gsm>
      <encoding>TR</encoding>
      <filter>0</filter>
      <startdate></startdate>
      <stopdate></stopdate>
      <appkey></appkey>
    </ns3:smsGonder1NV2>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>""";

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'text/xml'},
    body: body,
  );

  return response.statusCode == 200; // Başarılı ise true döndür
}
