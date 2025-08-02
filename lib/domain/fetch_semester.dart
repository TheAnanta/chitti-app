import 'dart:convert';
import 'dart:io';

import 'package:chitti/data/semester.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

Future<String> fetchDeviceId() async {
  if (Platform.isMacOS) {
    final deviceData = DeviceInfoPlugin();
    final macOSData = await deviceData.macOsInfo;
    return macOSData.systemGUID ?? "revoked";
  } else if (Platform.isIOS) {
    final deviceData = DeviceInfoPlugin();
    final iosData = await deviceData.iosInfo;
    return iosData.identifierForVendor ?? "revoked";
  } else if (Platform.isWindows) {
    final deviceData = DeviceInfoPlugin();
    final windowsData = await deviceData.windowsInfo;
    return windowsData.deviceId;
  } else {
    return await FirebaseMessaging.instance.getToken() ?? "revoked";
  }
}

Future<Semester> fetchSemester(String token, Function onSignOut) async {
  final request = await get(
    Uri.parse(
      "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/dashboard/${await fetchDeviceId()}",
    ),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (request.statusCode == 200) {
    print(request.body);
    final response = json.decode(request.body);
    return Semester.fromMap(response);
  } else if (request.statusCode == 401) {
    // MARK: Alert the user on wrong authentication details
    await FirebaseAuth.instance.signOut();
    onSignOut();
    throw Exception("Unable to fetch semester, ${request.statusCode}");
  } else {
    try {
      final response = json.decode(request.body);
      final message = response["message"];
      throw Exception(message);
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      throw Exception("Unable to fetch semester, $e");
    }
  }
}
