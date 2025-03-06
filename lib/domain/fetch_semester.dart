import 'dart:convert';

import 'package:chitti/data/semester.dart';
import 'package:http/http.dart';

Future<Semester> fetchSemester(String token) async {
  final request = await get(
    Uri.parse("https://webapi-zu6v4azneq-uc.a.run.app/dashboard"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (request.statusCode == 200) {
    final response = json.decode(request.body);
    return Semester.fromMap(response);
  } else {
    try {
      final response = json.decode(request.body);
      final message = response["message"];
      throw Exception(message);
    } catch (e) {
      throw Exception("Unable to fetch semester, ${e}");
    }
  }
}
