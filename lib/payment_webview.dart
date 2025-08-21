import 'dart:convert';

import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentWebView extends StatelessWidget {
  final String paymentId;
  const PaymentWebView({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          sharedCookiesEnabled: true,
          incognito: false,
        ),
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
              "https://app.scorewithchitti.in/payments?paymentId=$paymentId",
            ),
          ),
        ),
        onLoadStop: (controller, url) {
          if (url.toString().contains(
            "https://app.scorewithchitti.in/payments",
          )) {
            controller.evaluateJavascript(
              source: "document.getElementById('payButton').click();",
            );
          } else if (url.toString().contains(
            "https://app.scorewithchitti.in/payment-failed",
          )) {
            Navigator.pop(context, false);
          } else if (url.toString().contains(
            "https://app.scorewithchitti.in/payment-success",
          )) {
            Future.delayed(Duration(seconds: 10), () async {
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
                body: json.encode({
                  "rollNo": FirebaseAuth.instance.currentUser?.uid,
                }),
              );
              if (loginRequest.statusCode == 404) {
                // MARK: Alert the user on wrong authentication details

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(json.decode(loginRequest.body)["message"]),
                    ),
                  );
                }
              } else if (loginRequest.statusCode == 403) {
                // MARK: Alert the user on wrong authentication details

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
                FirebaseAuth.instance.currentUser!.getIdToken(true).then((
                  token,
                ) {
                  if (token == null) {
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
                        // Navigator.of(context).pop();
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                });
              }
              // Navigator.of(context).pop();
            });
          }
        },
      ),
    );
  }
}
