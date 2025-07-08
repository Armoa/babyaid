import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<Map<String, dynamic>> getLatestVersion() async {
  final response = await http.get(
    Uri.parse("https://helfer.flatzi.com/app/version.json"),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Error al obtener la versión");
  }
}

Future<bool> isUpdateRequired(String currentVersion) async {
  final latestData = await getLatestVersion();
  final latestVersion = latestData["latest_version"];
  return currentVersion != latestVersion;
}
