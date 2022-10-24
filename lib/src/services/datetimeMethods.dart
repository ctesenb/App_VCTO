import 'dart:convert';
import 'package:http/http.dart' as http;

class DateTimeMethods {
  DateTimeMethods();

  Future<String?> getTime() async {
    try {
      var url = Uri.parse(
          'https://timeapi.io/api/Time/current/zone?timeZone=America/Lima');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      return data['time'];
    } catch (e) {
      print('getTime: $e');
    }
  }

  Future<String?> getDate() async {
    try {
      var url = Uri.parse(
          'https://timeapi.io/api/Time/current/zone?timeZone=America/Lima');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      var date = data['date'];
      date = date.replaceAll('/', '-');
      return date;
    } catch (e) {
      print('getDate: $e');
    }
  }

  Future<DateTime?> getDateTimeYYYYMMDDHHMMSS() async {
    try {
      String? time = await getTime();
      time = '${time!}:00';
      String? date = await getDate();
      var dateSplit = date!.split('-');
      var dateReverse = dateSplit.reversed;
      var dateReverseString = dateReverse.join('-');
      var dateTime = '$dateReverseString $time';
      var dateTimeFormat = DateTime.parse(dateTime);
      return dateTimeFormat;
    } catch (e) {
      print('getDateTimeYYYYMMDDHHMMSS: $e');
    }
  }
}
