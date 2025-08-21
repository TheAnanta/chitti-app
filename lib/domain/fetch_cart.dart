import 'dart:convert';

import 'package:chitti/data/cart.dart';
import 'package:chitti/injector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<void> fetchCart(BuildContext context) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

  List<CartItem>? data = await get(
    Uri.parse("https://asia-south1-chitti-ananta.cloudfunctions.net/api/cart"),
    headers: {"Authorization": "Bearer $token"},
  ).then((response) {
    if (response.statusCode == 200) {
      print(json.decode(response.body)["cart"]?["courseId"]);
      final result = json.decode(response.body);
      Injector.cartRepository.cartId = result["cart"]["cartId"];
      return List<CartItem>.from(
        result["cart"]?["cartItems"]?.map(
              (cartItem) => CartItem(
                item: cartItem["courseId"],
                type: SubscriptionType.values[cartItem["subscriptionType"]],
              ),
            ) ??
            [],
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

  Injector.cartRepository.items.addAll((data ?? List<CartItem>.empty()));
}
