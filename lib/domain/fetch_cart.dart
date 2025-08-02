import 'dart:convert';

import 'package:chitti/data/cart.dart';
import 'package:chitti/injector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<void> fetchCart(BuildContext context) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

  List<String>? data = await get(
    Uri.parse(
      "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/cart",
    ),
    headers: {"Authorization": "Bearer $token"},
  ).then((response) {
    if (response.statusCode == 200) {
      print(json.decode(response.body)["cart"]?["courseId"]);
      return List<String>.from(
        (json.decode(response.body))["cart"]?["courseId"] ?? [],
      );
    } else {
      try {
        final result = json.decode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result["message"])));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
      return null;
    }
  });
  Injector.cartRepository.items.clear();

  Injector.cartRepository.items.addAll(
    (data ?? List<String>.empty()).map((e) {
      return CartItem(item: e, type: SubscriptionType.mid);
    }),
  );
}
