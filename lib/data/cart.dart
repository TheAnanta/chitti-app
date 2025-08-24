import 'dart:convert';
import 'dart:io';

import 'package:chitti/cart_page.dart';
import 'package:chitti/domain/fetch_cart.dart';
import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/payment_webview.dart';
import 'package:chitti/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionType { free, mid, sem }

class CartItem {
  final String item;
  final SubscriptionType type;

  CartItem({required this.item, required this.type});
}

class CartRepository {
  String? cartId;
  List<CartItem> items;
  Coupon? coupon;

  CartRepository(this.cartId) : items = [];

  void addItem(String item, SubscriptionType type) {
    items.add(CartItem(item: item, type: type));
  }

  void removeItem(String item) {
    items.removeWhere((cartItem) => cartItem.item == item);
  }

  double get totalPrice {
    // Assuming each item has a fixed price of $10 for simplicity
    final price = items.fold(0.0, (total, cartItem) {
      return total + getPrice(cartItem.item, cartItem.type);
    });
    return price - (coupon?.discount ?? 0.0);
  }

  Future<void> persist(BuildContext context) async {
    // Logic to persist the cart items, e.g., calling the patch api to cart route
    if (cartId == null) {
      // Handle case where cartId is not set
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cart ID is not set')));
      return;
    }
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    print(
      jsonEncode({
        "cartId": cartId, // Replace with actual cart ID
        "cartItems":
            items.map((item) {
              return {
                "courseId": item.item,
                "subscriptionType": item.type.index, // Convert enum to index
              };
            }).toList(),
      }),
    );
    final response = await patch(
      Uri.parse(
        "https://asia-south1-chitti-ananta.cloudfunctions.net/api/cart",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cartId": cartId, // Replace with actual cart ID
        "cartItems":
            items.map((item) {
              return {
                "courseId": item.item,
                "subscriptionType": item.type.index, // Convert enum to index
              };
            }).toList(),
      }),
    );
    if (response.statusCode == 200) {
      if (context.mounted) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"])));
      }
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
    }
  }

  Future<Coupon?> applyCoupon(String couponCode, BuildContext context) async {
    final response = await get(
      Uri.parse(
        "https://asia-south1-chitti-ananta.cloudfunctions.net/api/coupon/$couponCode",
      ),
    ).then((response) {
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result["status"]) {
          // Apply the coupon logic here
          return Coupon(
            couponId: result["coupon"]["couponId"],
            discount: double.parse(result["coupon"]["discount"].toString()),
            code: result["coupon"]["code"],
            expiryDate: DateTime.parse(result["coupon"]["expiryDate"]),
            minAmount: double.parse(result["coupon"]["minAmount"].toString()),
            validFrom: DateTime.parse(result["coupon"]["validFrom"]),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result["message"])));
          return null;
        }
      } else {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"])));
        return null;
      }
    });
    coupon = response;
    return response;
  }

  getPrice(String courseId, SubscriptionType subscriptionType) {
    return subscriptionType == SubscriptionType.free
        ? 0.0
        : subscriptionType == SubscriptionType.mid
        ? 49.56
        : 99.56;
  }

  Future<void> checkout(
    BuildContext context, {
    Coupon? coupon,
    required Function(bool) onLoading,
  }) async {
    // initiate the payment process

    onLoading(true);
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    final paymentId = await post(
      Uri.parse(
        "https://asia-south1-chitti-ananta.cloudfunctions.net/api/initiate-payment",
      ),
      body: jsonEncode({"cartId": cartId, "couponCode": coupon?.code}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).then((response) {
      final result = json.decode(response.body);
      if (result["status"]) {
        return result["paymentId"] as String;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"])));
        onLoading(false);
        return null;
      }
    });
    if (paymentId == null) {
      onLoading(false);
      return;
    }

    if (Platform.isMacOS || Platform.isWindows) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return PaymentWebView(paymentId: paymentId);
          },
        ),
      );
      return;
    }

    final razorpayAPIRequest = await post(
      Uri.parse(
        "https://asia-south1-chitti-ananta.cloudfunctions.net/createOrder",
      ),
      body: jsonEncode({"paymentId": paymentId}),
      headers: {'Content-Type': 'application/json'},
    );
    if (razorpayAPIRequest.statusCode != 200) {
      onLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: ${razorpayAPIRequest.body}"),
        ),
      );
      return;
    }
    final razorpayAPIResponse = (json.decode(razorpayAPIRequest.body));
    var _razorpay = Razorpay();
    var options = {
      'order_id': razorpayAPIResponse["id"],
      'key': 'rzp_live_dXsSgWNlpWQ07d',
      'amount': razorpayAPIResponse["amount_due"],
      'name': 'Score With CHITTI.',
      'description': "Purchasing subscription to study materials.",
    };
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) {
      Future.delayed(Duration(seconds: 1), () async {
        final oldAuthToken =
            await FirebaseAuth.instance.currentUser?.getIdToken();
        final loginRequest = await post(
          Uri.parse(
            "https://asia-south1-chitti-ananta.cloudfunctions.net/api/auth/reauthenticate",
          ),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $oldAuthToken",
          },
          body: json.encode({"rollNo": FirebaseAuth.instance.currentUser?.uid}),
        );
        if (loginRequest.statusCode == 404) {
          // MARK: Alert the user on wrong authentication details
          onLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(json.decode(loginRequest.body)["message"]),
              ),
            );
          }
        } else if (loginRequest.statusCode == 403) {
          // MARK: Alert the user on wrong authentication details
          onLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(json.decode(loginRequest.body)["message"]),
              ),
            );
          }
        } else {
          // MARK: Authenticate the user
          final result = json.decode(loginRequest.body);
          final userCredential = await FirebaseAuth.instance
              .signInWithCustomToken(result["token"]);
          FirebaseAuth.instance.currentUser!.getIdToken(true).then((token) {
            if (token == null) {
              onLoading(false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to create token.")),
                );
              }
              return;
            }
            try {
              fetchSemester(token, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Session expired, please login again."),
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              }).then((semester) {
                SharedPreferences.getInstance().then((sharedPreferences) {
                  Navigator.of(context).pop();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => MyHomePage(
                              name:
                                  userCredential.user?.displayName?.split(
                                    " ",
                                  )[0] ??
                                  "User",
                              semester: semester,
                            ),
                      ),
                    );
                  }
                });
              });
            } on Exception catch (e) {
              onLoading(false);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          });
        }
        onLoading(false);
        Navigator.of(context).pop();
      });
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      onLoading(false);
      Navigator.of(context).pop();
      // Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: ${response.message}"),
        ),
      );
    });
    _razorpay.open(options);
  }

  Future<void> fetchCartId(BuildContext context) async {
    await fetchCart(context);
  }
}
