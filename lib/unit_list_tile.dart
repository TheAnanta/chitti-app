import 'dart:convert';

import 'package:chitti/animated_image.dart';
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/pdf_doc/pdf_main.dart';
import 'package:chitti/unit_resource_page.dart';
import 'package:chitti/watermark_widget.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitListTile extends StatelessWidget {
  UnitListTile({
    super.key,
    required this.units,
    required this.subjectName,
    required this.subjectId,
    required this.subjectCoverImage,
    required this.courseId,
    this.onUnitTap,
  });
  final String subjectName;
  final String subjectId;
  final String courseId;
  final List<Unit> units;
  final String subjectCoverImage;
  final Function(Unit)? onUnitTap;
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Units",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          separatorBuilder: (_, __) {
            return Divider();
          },
          itemBuilder: (context, index) {
            onTapUnitTile(String roadmapId, String roadmapName) {
              if (index != 0 && kIsWeb) {
                showModalBottomSheet(
                  context: context,
                  builder: (sheetContext) {
                    return BottomSheet(
                      onClosing: () {
                        Navigator.of(sheetContext).pop();
                      },
                      builder: (sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Download the App",
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Sorry, we currently don't support accessing all units from our web app. Instead, download our mobile app from the Play Store/App Store.\n\nUnlock a wide range of features and units that we offer.",
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              } else if (units[index].isUnlocked && roadmapId != "IMPQUES") {
                final selectedUnit = units[index];
                if (onUnitTap != null) {
                  onUnitTap!(selectedUnit);
                  return;
                }
                // Fetch all the data

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return FutureBuilder(
                        future: Injector.unitRepository.fetchUnit(
                          context,
                          subjectId,
                          selectedUnit,
                          roadmapId,
                        ),
                        builder: (context, futureValue) {
                          if (futureValue.hasData) {
                            final unit = futureValue.data!;
                            return UnitResourcePage(
                              unit: unit,
                              subjectName: subjectName,
                              unitIndex: index + 1,
                              subjectCoverImage: subjectCoverImage,
                              courseId: courseId,
                              roadmapName: roadmapName,
                            );
                          }
                          return Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 128),
                                  CircularProgressIndicator(
                                    color: Colors.grey.shade800,
                                  ),
                                  SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AnimatedImageEntry(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Transform.flip(
                                            flipX: true,
                                            child: Transform.translate(
                                              offset: Offset(0, 48),
                                              child: ColorFiltered(
                                                colorFilter:
                                                    ColorFilters.matrix(
                                                      saturation: -1,
                                                      brightness: 0.5,
                                                    ),
                                                child: Image.asset(
                                                  "assets/images/ghost_blue.png",
                                                  height: 180,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            width: 264,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey.shade400,
                                            ),
                                            child: Opacity(
                                              opacity: 0.6,
                                              child: Text(
                                                "Go grab a break while we sneak into the server.",
                                                textAlign: TextAlign.center,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              } else if (roadmapId == "IMPQUES") {
                //TODO: Fetch the PDF url
                addCompletedResource(
                  context,
                  CompletedResources(
                    courseId: courseId,
                    resourceId: units[index].importantQuestions!.id,
                    resourceName: units[index].name,
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          body: Center(
                            child: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: Builder(
                                builder: (context) {
                                  final uri =
                                      Uri.tryParse(
                                        units[index].importantQuestions!.url,
                                      ) ??
                                      Uri.parse(
                                        "https://pdfobject.com/pdf/sample.pdf",
                                      );
                                  final pdfDocumentRef = PdfDocumentRefUri(uri);
                                  return PDFViewPage(
                                    documentRef: pdfDocumentRef,
                                    pdfName:
                                        '${units[index].name} - Important Questions',
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                  ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (sheetContext) {
                    return BottomSheet(
                      onClosing: () {
                        Navigator.of(sheetContext).pop();
                      },
                      builder: (sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Subscribe",
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Choose from a wide range of plans that we offer.",
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        "What you get",
                                        style: Theme.of(
                                          sheetContext,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "• All Units\n• All Roadmaps\n• All Resources\n• All Videos\n• All Notes\n• All Cheatsheets\n• All Important Questions",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Opacity(
                                    opacity: 0.4,
                                    child: Text(
                                      "₹180",
                                      style: Theme.of(
                                        sheetContext,
                                      ).textTheme.headlineMedium?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      "₹",
                                      style: Theme.of(
                                        sheetContext,
                                      ).textTheme.titleLarge?.copyWith(
                                        color:
                                            Theme.of(
                                              sheetContext,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "109",
                                    style: Theme.of(
                                      sheetContext,
                                    ).textTheme.headlineLarge?.copyWith(
                                      height: 1,
                                      color:
                                          Theme.of(
                                            sheetContext,
                                          ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ".56",
                                    style: Theme.of(
                                      sheetContext,
                                    ).textTheme.titleSmall?.copyWith(
                                      color:
                                          Theme.of(
                                            sheetContext,
                                          ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  FilledButton(
                                    onPressed: () async {
                                      isLoading.value = true;

                                      //TODO: Change the payment later
                                      final razorpayAPIRequest = await post(
                                        Uri.parse(
                                          "https://asia-south1-chitti-ananta.cloudfunctions.net/createOrder",
                                        ),
                                        body: jsonEncode({
                                          "userId":
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid,
                                          "amount": 10956,
                                        }),
                                        headers: {
                                          'Content-Type': 'application/json',
                                        },
                                      );
                                      if (razorpayAPIRequest.statusCode !=
                                          200) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              "Error: ${razorpayAPIRequest.body}",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      final razorpayAPIResponse =
                                          (json.decode(
                                            razorpayAPIRequest.body,
                                          ))["id"];
                                      var _razorpay = Razorpay();
                                      var options = {
                                        'order_id': razorpayAPIResponse,
                                        'key': 'rzp_live_dXsSgWNlpWQ07d',
                                        'amount': 10956,
                                        'name': 'Score With CHITTI.',
                                        'description':
                                            "Purchasing subscription to study $subjectName",
                                      };
                                      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
                                        PaymentSuccessResponse response,
                                      ) {
                                        print("Payment Success");
                                        print(response);
                                        Future.delayed(Duration(seconds: 10), () async {
                                          final oldAuthToken =
                                              await FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.getIdToken();
                                          final loginRequest = await post(
                                            Uri.parse(
                                              "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/reauthenticate",
                                            ),
                                            headers: {
                                              "Content-Type":
                                                  "application/json",
                                              "Authorization":
                                                  "Bearer $oldAuthToken",
                                            },
                                            body: json.encode({
                                              "rollNo":
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid,
                                            }),
                                          );
                                          if (loginRequest.statusCode == 404) {
                                            // MARK: Alert the user on wrong authentication details
                                            isLoading.value = false;
                                            if (sheetContext.mounted) {
                                              ScaffoldMessenger.of(
                                                sheetContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    json.decode(
                                                      loginRequest.body,
                                                    )["message"],
                                                  ),
                                                ),
                                              );
                                            }
                                          } else if (loginRequest.statusCode ==
                                              403) {
                                            // MARK: Alert the user on wrong authentication details
                                            isLoading.value = false;
                                            if (sheetContext.mounted) {
                                              ScaffoldMessenger.of(
                                                sheetContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    json.decode(
                                                      loginRequest.body,
                                                    )["message"],
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            // MARK: Authenticate the user
                                            final result = json.decode(
                                              loginRequest.body,
                                            );
                                            final userCredential =
                                                await FirebaseAuth.instance
                                                    .signInWithCustomToken(
                                                      result["token"],
                                                    );
                                            FirebaseAuth.instance.currentUser!.getIdToken(true).then((
                                              token,
                                            ) {
                                              if (token == null) {
                                                isLoading.value = false;
                                                if (sheetContext.mounted) {
                                                  ScaffoldMessenger.of(
                                                    sheetContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Unable to create token.",
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return;
                                              }
                                              try {
                                                fetchSemester(token).then((
                                                  semester,
                                                ) {
                                                  SharedPreferences.getInstance().then((
                                                    sharedPreferences,
                                                  ) {
                                                    Navigator.of(context).pop();
                                                    if (context.mounted) {
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => MyHomePage(
                                                                name:
                                                                    userCredential
                                                                        .user
                                                                        ?.displayName
                                                                        ?.split(
                                                                          " ",
                                                                        )[0] ??
                                                                    "User",
                                                                semester:
                                                                    semester,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                });
                                              } on Exception catch (e) {
                                                isLoading.value = false;
                                                if (sheetContext.mounted) {
                                                  ScaffoldMessenger.of(
                                                    sheetContext,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        e.toString(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            });
                                          }
                                          isLoading.value = false;
                                          Navigator.of(sheetContext).pop();
                                        });
                                      });
                                      _razorpay.on(
                                        Razorpay.EVENT_PAYMENT_ERROR,
                                        (PaymentFailureResponse response) {
                                          print("Payment Error");
                                          print(response);
                                          Navigator.of(sheetContext).pop();
                                          ScaffoldMessenger.of(
                                            sheetContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                "Error: ${response.message}",
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      _razorpay.open(options);
                                    },
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: isLoading,
                                      builder: (sheetContext, value, child) {
                                        return value
                                            ? CircularProgressIndicator()
                                            : Text("Pay Now");
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }

            return InkWell(
              onTap: () {
                if (!units[index].isUnlocked) {
                  onTapUnitTile("PAYMENT", "PAYMENT");
                }
              },
              child: ExpansionTile(
                title: Text(
                  "${index + 1}. ${units[index].name}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                shape: Border(),
                enabled: units[index].isUnlocked,
                children: List.generate(
                  (units[index].roadmap?.roadmapItems.length ?? 0) +
                      (units[index].importantQuestions != null ? 1 : 0),
                  (topicIndex) {
                    if (topicIndex ==
                        units[index].roadmap?.roadmapItems.length) {
                      return ListTile(
                        title: Text(
                          "Important Questions",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                units[index].isUnlocked
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade400,
                          ),
                        ),
                        onTap: () {
                          onTapUnitTile("IMPQUES", "IMPQUES");
                        },
                        trailing: Icon(
                          units[index].isUnlocked
                              ? Icons.chevron_right_outlined
                              : Icons.lock_outline,
                        ),
                      );
                    }
                    final roadmapItem =
                        (units[index].roadmap?.roadmapItems ?? []).sorted((
                          a,
                          b,
                        ) {
                          final strengthA =
                              a.difficulty == "beginner"
                                  ? 1
                                  : a.difficulty == "intermediate"
                                  ? 2
                                  : 3;
                          final strengthB =
                              b.difficulty == "beginner"
                                  ? 1
                                  : b.difficulty == "intermediate"
                                  ? 2
                                  : 3;
                          return strengthB.compareTo(strengthA);
                        }).toList()[topicIndex];
                    return ListTile(
                      onTap: () {
                        onTapUnitTile(
                          units[index].roadmap?.roadmapItems[topicIndex].id ??
                              "",
                          units[index].roadmap?.roadmapItems[topicIndex].name ??
                              "",
                        );
                      },
                      title: Text(
                        units[index].roadmap?.roadmapItems[topicIndex].name ??
                            "",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              units[index].isUnlocked
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              final strength =
                                  roadmapItem.difficulty == "beginner"
                                      ? 1
                                      : roadmapItem.difficulty == "intermediate"
                                      ? 2
                                      : 3;
                              return Row(
                                children:
                                    List.generate(
                                      strength,
                                      (index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ).toList(),
                              );
                            },
                          ),
                          Icon(
                            units[index].isUnlocked
                                ? Icons.chevron_right_outlined
                                : Icons.lock_outline,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // trailing: Icon(
                //   units[index].isUnlocked
                //       ? Icons.chevron_right_outlined
                //       : Icons.lock_outline,
                // ),
              ),
            );
          },
          itemCount: units.length,
          shrinkWrap: true,
        ),
      ],
    );
  }
}
