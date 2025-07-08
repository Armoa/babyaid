import 'package:intl/intl.dart';

final numeroFormat = NumberFormat("#,###", "es_PY");

String numberFormat(String x) {
  List<String> parts = x.toString().split('.');
  RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');
  parts[0] = parts[0].replaceAll(re, '.');
  if (parts.length == 1) {
    parts.add('');
  } else {
    parts[1] = parts[1].padRight(2, '0').substring(0, 2);
  }
  return parts.join('');
}
