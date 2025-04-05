import 'dart:convert';
import 'dart:developer' as developer show log;

import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic>? payload;
  var username = "";
  var password = "";
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final isLoading = ValueNotifier<bool>(false);
  getGITAMLoginPage() async {
    final response = await get(Uri.parse('https://login.gitam.edu/Login.aspx'));
    // print(response.body);
    return response.body
        .replaceAll(
          'id="txtusername"',
          'id="txtusername" value="${username.trim().toUpperCase()}"',
        )
        .replaceAll(
          'id="password"',
          'id="password" value="${password.trimRight()}"',
        )
        .replaceAll("./Login.aspx", "https://login.gitam.edu/Login.aspx");
  }

  var obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          password == ""
              ? LayoutBuilder(
                builder: (context, constraints) {
                  WindowSizeClass().init(constraints);
                  return Scaffold(
                    body: Row(
                      children: [
                        getSizeClass() == WidthSizeClass.large
                            ? Expanded(
                              child: Container(
                                color: Color(0xFFF26E0C),
                                width: double.infinity,
                              ),
                            )
                            : SizedBox(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getSizeClass() == WidthSizeClass.large
                                  ? Spacer()
                                  : Expanded(
                                    child: Container(
                                      color: Color(0xFFF26E0C),
                                      width: double.infinity,
                                    ),
                                  ),
                              Padding(
                                padding: EdgeInsets.all(
                                  getSizeClass() == WidthSizeClass.large
                                      ? 36
                                      : 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      "Sign in to CHITTI.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Authorize with your MyGITAM credentials.",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                    ),
                                    SizedBox(height: 24),
                                    TextField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        hintText: "Roll Number",
                                        hintStyle:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      obscureText: obscurePassword,

                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            obscurePassword = !obscurePassword;
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            !obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(10, 12),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: MaterialButton(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 28,
                                        ),
                                        minWidth: double.infinity,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onPressed: () async {
                                          isLoading.value = true;
                                          if (_usernameController.text != "" &&
                                              _passwordController.text != "") {
                                            username =
                                                _usernameController.text
                                                    .toUpperCase()
                                                    .trim();
                                            password =
                                                _passwordController.text
                                                    .trimRight();
                                            final loginRequest = await post(
                                              Uri.parse(
                                                "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/login",
                                              ),
                                              headers: {
                                                "Content-Type":
                                                    "application/json",
                                              },
                                              body: json.encode({
                                                "rollNo": username,
                                                "pass": password,
                                              }),
                                            );
                                            if (loginRequest.statusCode ==
                                                404) {
                                              setState(() {});
                                            } else if (loginRequest
                                                    .statusCode ==
                                                403) {
                                              // MARK: Alert the user on wrong authentication details
                                              isLoading.value = false;
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
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
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
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
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
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
                                          } else {
                                            isLoading.value = false;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Enter a valid roll number and password",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ValueListenableBuilder(
                                          valueListenable: isLoading,
                                          builder: (context, _isLoading, _) {
                                            return _isLoading
                                                ? CircularProgressIndicator(
                                                  color: Colors.grey.shade800,
                                                )
                                                : Text("Sign in with GITAM");
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 48),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
              : Scaffold(
                body: Stack(
                  children: [
                    FutureBuilder(
                      future: getGITAMLoginPage(),
                      builder: (context, futurePayload) {
                        if (futurePayload.connectionState !=
                            ConnectionState.done) {
                          return CircularProgressIndicator();
                        }

                        var htmlString = futurePayload.data.toString();
                        var controller = WebViewController();
                        int? semester;
                        String? name;
                        return WebViewWidget(
                          controller:
                              controller
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..setNavigationDelegate(
                                  NavigationDelegate(
                                    onPageFinished: (url) {
                                      if (url == "about:blank") {
                                        //Hit submit
                                        controller.runJavaScript(
                                          "document.getElementById('Submit').click();",
                                        );
                                      } else if (url.contains(
                                        "https://login.gitam.edu",
                                      )) {
                                        (controller.runJavaScriptReturningResult(
                                          'document.body.innerHTML.search("Invalid User ID / Password. Please try again. !")',
                                        )).then((isError) {
                                          if (int.parse(isError.toString()) >
                                              0) {
                                            _passwordController.clear();
                                            password = "";
                                            setState(() {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Invalid roll number/password. Please try again.",
                                                  ),
                                                ),
                                              );
                                            });
                                          }
                                        });
                                      } else if (url ==
                                              "https://gstudent.gitam.edu/Home" &&
                                          payload == null) {
                                        WebviewCookieManager()
                                            .getCookies(
                                              "https://gstudent.gitam.edu",
                                            )
                                            .then(
                                              (c1) =>
                                                  c1
                                                      .where(
                                                        (e) =>
                                                            e.name ==
                                                            "ASP.NET_SessionId",
                                                      )
                                                      .first,
                                            )
                                            .then((cookie) {
                                              get(
                                                Uri.parse(
                                                  "https://gstudent.gitam.edu/Home/GetStudentData",
                                                ),
                                                headers: {
                                                  "Cookie":
                                                      "ASP.NET_SessionId=${cookie.value}",
                                                },
                                              ).then((response) {
                                                // developer.log(response.body);
                                                final tag =
                                                    RegExp(
                                                          r'<input\s+class="form-control"\s+id="curr_sem"\s+name="curr_sem"\s+onkeydown="return ValidateSpecialText\(event\);"\s+readonly="readonly"\s+type="text"\s+value="[0-9]*"\s*/>',
                                                        )
                                                        .firstMatch(
                                                          response.body,
                                                        )
                                                        ?.group(0)
                                                        .toString() ??
                                                    "No value";
                                                final nameTag =
                                                    RegExp(
                                                          r'<input\s+class="form-control"\s+id="name"\s+name="name"\s+onkeydown="return ValidateSpecialText\(event\);"\s+readonly="readonly"\s+type="text"\s+value="([^"]*)"\s*/>',
                                                        )
                                                        .firstMatch(
                                                          response.body,
                                                        )
                                                        ?.group(0)
                                                        .toString() ??
                                                    "No value";
                                                semester = int.tryParse(
                                                  tag
                                                      .split('value="')[1]
                                                      .split('"')[0],
                                                );
                                                name = nameTag
                                                    .split('value="')[1]
                                                    .split('"')[0]
                                                    .split(" ")
                                                    .reversed
                                                    .map((f) {
                                                      return f[0] +
                                                          f
                                                              .substring(1)
                                                              .toLowerCase();
                                                    })
                                                    .join(" ");
                                                developer.log(
                                                  semester.toString(),
                                                );
                                                developer.log(
                                                  name ?? "No Name",
                                                );
                                                controller.runJavaScript(
                                                  'document.getElementsByClassName("course")[0].click();',
                                                );
                                              });
                                            });
                                      } else if (url.contains(
                                        "https://glearn.gitam.edu",
                                      )) {
                                        WebviewCookieManager()
                                            .getCookies(
                                              "https://glearn.gitam.edu",
                                            )
                                            .then(
                                              (c2) =>
                                                  c2
                                                      .where(
                                                        (f) =>
                                                            f.name ==
                                                            ".AspNetCore.Session",
                                                      )
                                                      .first,
                                            )
                                            .then((cook1) {
                                              get(
                                                Uri.parse(
                                                  "https://glearn.gitam.edu/student/my_courses",
                                                ),
                                                headers: {
                                                  "Cookie":
                                                      ".ASPNetCore.Session=${cook1.value}",
                                                },
                                              ).then((responseData) async {
                                                final currentSemester =
                                                    r'<h6>Current Semester - \d+<\/h6>\s*<div class="box-inner">[\s\S]*?<h6>';
                                                final h4CourseCode =
                                                    r'<h4\s+class="courseCode">\s*([^\s].*[^\s]|[^\s])?\s*</h4>';

                                                final res =
                                                    RegExp(h4CourseCode)
                                                        .allMatches(
                                                          RegExp(currentSemester)
                                                                  .allMatches(
                                                                    responseData
                                                                        .body,
                                                                  )
                                                                  .toList()
                                                                  .first
                                                                  .group(0) ??
                                                              responseData.body,
                                                        )
                                                        .map(
                                                          (element) =>
                                                              element
                                                                  .group(0)
                                                                  ?.split(
                                                                    '">',
                                                                  )[1]
                                                                  .split(
                                                                    "</h4",
                                                                  )[0] ??
                                                              "No Data",
                                                        )
                                                        .toList();
                                                if (res.length > 1) {
                                                  payload = {
                                                    "rollNo": username,
                                                    "pass": password,
                                                    "schedule": "",
                                                    "subId": 0,
                                                    "semester": semester,
                                                    "name": name,
                                                    "courses":
                                                        res.toSet().toList(),
                                                  };
                                                  final signupRequest = await post(
                                                    Uri.parse(
                                                      "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/signup",
                                                    ),
                                                    headers: {
                                                      "Content-Type":
                                                          "application/json",
                                                    },
                                                    body: json.encode(payload),
                                                  );
                                                  if (signupRequest
                                                          .statusCode ==
                                                      200) {
                                                    //MARK: Successful creating the auth
                                                    final result = json.decode(
                                                      signupRequest.body,
                                                    );
                                                    final token =
                                                        result["token"];
                                                    final userCredential =
                                                        await FirebaseAuth
                                                            .instance
                                                            .signInWithCustomToken(
                                                              token,
                                                            );
                                                    await userCredential.user
                                                        ?.updateDisplayName(
                                                          name,
                                                        );
                                                    FirebaseAuth.instance.currentUser!.getIdToken(true).then((
                                                      token,
                                                    ) {
                                                      if (token == null) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
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
                                                        fetchSemester(
                                                          token,
                                                        ).then((semester) {
                                                          SharedPreferences.getInstance().then((
                                                            sharedPreferences,
                                                          ) {
                                                            final name =
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    ?.displayName
                                                                    ?.split(
                                                                      " ",
                                                                    )[0];
                                                            if (context
                                                                .mounted) {
                                                              Navigator.of(
                                                                context,
                                                              ).pushReplacement(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => MyHomePage(
                                                                        name:
                                                                            name?.split(
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
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
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
                                                  } else {
                                                    final result = json.decode(
                                                      signupRequest.body,
                                                    );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            result["theError"] ??
                                                                result["message"],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  SharedPreferences.getInstance()
                                                      .then((
                                                        sharedPreferences,
                                                      ) {
                                                        sharedPreferences
                                                            .setString(
                                                              "userdata",
                                                              json.encode(
                                                                payload,
                                                              ),
                                                            );

                                                        setState(() {});
                                                      });
                                                }
                                              });
                                            });
                                      }
                                    },
                                  ),
                                )
                                ..loadHtmlString(htmlString),
                        );
                      },
                    ),
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
    );
  }
}
