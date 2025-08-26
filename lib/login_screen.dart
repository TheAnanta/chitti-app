import 'dart:convert';
import 'dart:developer' as developer show log;
import 'dart:io';
import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/size_config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic>? payload;
  var username = "";
  var password = "";
  var gitamPageDetails = "";
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final isLoading = ValueNotifier<bool>(false);
  getGITAMLoginPage() async {
    // print(response.body);
    return gitamPageDetails
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
  var isCredentialCorrect = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          password == "" || !isCredentialCorrect
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
                                padding: EdgeInsets.only(
                                  top: 48,
                                  left: 24,
                                  right: 24,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hack through your exam prep",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            "Chitti is your go-to exam prep platform, offering curated resources like notes, cheat sheets, and videos crafted by top students for stress-free studying. We provide clear roadmaps for each subject, guiding you to focus on what matters most as exams approach.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Transform.translate(
                                      offset: Offset(24, 0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Image.asset(
                                          "assets/images/ghost-launch.png",
                                          height: 200,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : SizedBox(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getSizeClass() == WidthSizeClass.large
                                  ? Spacer()
                                  : Expanded(child: OnboardingSlideOne()),
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
                                            isLoading.value = false;
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
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onBackground,
                                          ),
                                        ],
                                      ),
                                      child: MaterialButton(
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 28,
                                        ),
                                        minWidth: double.infinity,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.background,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onBackground,
                                          ),
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
                                                "https://asia-south1-chitti-ananta.cloudfunctions.net/api/auth/login",
                                              ),
                                              headers: {
                                                "Content-Type":
                                                    "application/json",
                                              },
                                              body: json.encode({
                                                "rollNo": username,
                                                "pass": password,
                                                "deviceId":
                                                    await fetchDeviceId(),
                                                "fcmToken":
                                                    Platform.isWindows
                                                        ? "windows"
                                                        : await FirebaseMessaging
                                                            .instance
                                                            .getToken(),
                                              }),
                                            );
                                            if (loginRequest.statusCode ==
                                                404) {
                                              isCredentialCorrect = true;
                                              gitamPageDetails =
                                                  (json.decode(
                                                    loginRequest.body,
                                                  ))["webpage"];
                                              isLoading.value = false;
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
                                              isCredentialCorrect = false;
                                              setState(() {});
                                            } else {
                                              isCredentialCorrect = true;
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
                                                  Injector.semesterRepository
                                                      .fetchSemester(
                                                        context,
                                                        token,
                                                        () {
                                                          Navigator.of(
                                                            context,
                                                          ).pushReplacement(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      LoginScreen(),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                      .then((semester) {
                                                        SharedPreferences.getInstance().then((
                                                          sharedPreferences,
                                                        ) {
                                                          if (context.mounted) {
                                                            sharedPreferences
                                                                .setBool(
                                                                  "isFirstTime",
                                                                  true,
                                                                );
                                                            Navigator.of(
                                                              context,
                                                            ).pushReplacement(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => MyHomePage(
                                                                      name:
                                                                          userCredential.user?.displayName?.split(
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
                              getSizeClass() == WidthSizeClass.large
                                  ? Spacer()
                                  : SizedBox(),
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
                        var cookieObj = CookieManager.instance();
                        int? semester;
                        String? name;

                        return InAppWebView(
                          initialSettings: InAppWebViewSettings(
                            sharedCookiesEnabled: true,
                            incognito: false,
                          ),
                          initialData: InAppWebViewInitialData(
                            data: htmlString,
                          ),
                          onLoadStop: (controller, url) {
                            if (Platform.isWindows
                                ? url.toString() == ""
                                : url.toString() == "about:blank") {
                              try {
                                controller.evaluateJavascript(
                                  source:
                                      "document.getElementById('Submit').click();",
                                );
                              } on Exception catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            } else if (url.toString().contains(
                              "https://login.gitam.edu",
                            )) {
                              (controller.evaluateJavascript(
                                source:
                                    'document.body.innerHTML.search("Invalid User ID / Password. Please try again. !")',
                              )).then((isError) {
                                if (double.parse(isError.toString()) > 0) {
                                  _passwordController.clear();
                                  password = "";
                                  setState(() {
                                    isLoading.value = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Invalid roll number/password. Please try again.",
                                        ),
                                      ),
                                    );
                                  });
                                }
                              });
                            } else if (url.toString() ==
                                    "https://gstudent.gitam.edu/Home" &&
                                payload == null) {
                              cookieObj
                                  .getCookie(
                                    url: WebUri.uri(
                                      Uri.parse("https://gstudent.gitam.edu"),
                                    ),
                                    name: "ASP.NET_SessionId",
                                  )
                                  .then((cookie) {
                                    print("COOKIEDATA: ${cookie?.value}");
                                    get(
                                      Uri.parse(
                                        "https://gstudent.gitam.edu/Home/GetStudentData",
                                      ),
                                      headers: {
                                        "Cookie":
                                            "ASP.NET_SessionId=${cookie?.value}",
                                      },
                                    ).then((response) async {
                                      print(response);
                                      final tag =
                                          RegExp(
                                                r'<input\s+class="form-control"\s+id="curr_sem"\s+name="curr_sem"\s+onkeydown="return ValidateSpecialText\(event\);"\s+readonly="readonly"\s+type="text"\s+value="[0-9]*"\s*/>',
                                              )
                                              .firstMatch(response.body)
                                              ?.group(0)
                                              .toString() ??
                                          "No value";
                                      final nameTag =
                                          RegExp(
                                                r'<input\s+class="form-control"\s+id="name"\s+name="name"\s+onkeydown="return ValidateSpecialText\(event\);"\s+readonly="readonly"\s+type="text"\s+value="([^"]*)"\s*/>',
                                              )
                                              .firstMatch(response.body)
                                              ?.group(0)
                                              .toString() ??
                                          "No value";
                                      semester = int.tryParse(
                                        tag.split('value="')[1].split('"')[0],
                                      );
                                      name = nameTag
                                          .split('value="')[1]
                                          .split('"')[0]
                                          .split(" ")
                                          .reversed
                                          .map((f) {
                                            return f[0] +
                                                f.substring(1).toLowerCase();
                                          })
                                          .join(" ");
                                      developer.log(semester.toString());
                                      developer.log(name ?? "No Name");
                                      if (username.startsWith("202") &&
                                          !username.startsWith("2023")) {
                                        await controller.evaluateJavascript(
                                          source:
                                              'document.getElementsByClassName("course")[1].click();',
                                        );
                                      } else {
                                        await controller.evaluateJavascript(
                                          source:
                                              'document.getElementsByClassName("course")[0].click();',
                                        );
                                      }
                                    });
                                  });
                            } else if (url.toString().contains(
                              "https://glearn.gitam.edu",
                            )) {
                              cookieObj
                                  .getCookie(
                                    url: WebUri.uri(
                                      Uri.parse("https://glearn.gitam.edu"),
                                    ),
                                    name: ".AspNetCore.Session",
                                  )
                                  .then((cook1) {
                                    get(
                                      Uri.parse(
                                        "https://glearn.gitam.edu/student/my_courses",
                                      ),
                                      headers: {
                                        "Cookie":
                                            ".ASPNetCore.Session=${cook1?.value}",
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
                                                          responseData.body,
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
                                                        ?.split('">')[1]
                                                        .split("</h4")[0] ??
                                                    "No Data",
                                              )
                                              .toList();
                                      if (res.length > 1) {
                                        payload = {
                                          "rollNo": username,
                                          "pass": password,
                                          "deviceId": await fetchDeviceId(),
                                          "schedule": "",
                                          "subId": 0,
                                          "semester": semester,
                                          "name": name,
                                          "courses": res.toSet().toList(),
                                          "fcmToken":
                                              Platform.isWindows
                                                  ? "windows"
                                                  : await FirebaseMessaging
                                                      .instance
                                                      .getToken(),
                                        };
                                        print("PAYLOAD: $payload");
                                        final signupRequest = await post(
                                          Uri.parse(
                                            "https://asia-south1-chitti-ananta.cloudfunctions.net/api/auth/signup",
                                          ),
                                          headers: {
                                            "Content-Type": "application/json",
                                          },
                                          body: json.encode(payload),
                                        );
                                        if (signupRequest.statusCode == 200) {
                                          //MARK: Successful creating the auth
                                          final result = json.decode(
                                            signupRequest.body,
                                          );
                                          final token = result["token"];
                                          final userCredential =
                                              await FirebaseAuth.instance
                                                  .signInWithCustomToken(token);
                                          await userCredential.user
                                              ?.updateDisplayName(name);
                                          FirebaseAuth.instance.currentUser!.getIdToken(true).then((
                                            token,
                                          ) {
                                            if (token == null) {
                                              if (context.mounted) {
                                                isLoading.value = false;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Unable to create token.",
                                                    ),
                                                  ),
                                                );
                                                setState(() {});
                                              }
                                              return;
                                            }
                                            try {
                                              Injector.semesterRepository
                                                  .fetchSemester(
                                                    context,
                                                    token,
                                                    () {
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  LoginScreen(),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  .then((semester) {
                                                    SharedPreferences.getInstance().then((
                                                      sharedPreferences,
                                                    ) {
                                                      final name =
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.displayName
                                                              ?.split(" ")[0];
                                                      if (context.mounted) {
                                                        sharedPreferences
                                                            .setBool(
                                                              "isFirstTime",
                                                              true,
                                                            );
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
                                                isLoading.value = false;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(e.toString()),
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
                                            isLoading.value = false;
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
                                        SharedPreferences.getInstance().then((
                                          sharedPreferences,
                                        ) {
                                          sharedPreferences.setString(
                                            "userdata",
                                            json.encode(payload),
                                          );

                                          setState(() {});
                                        });
                                      }
                                    });
                                  });
                            }
                          },
                        );
                      },
                    ),
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              "Hang on there for a moment...",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              ".. as we break some walls for you.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              "This may take a while, upto 2 minutes depending on your network.",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

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
}

class OnboardingSlideOne extends StatelessWidget {
  const OnboardingSlideOne({super.key});

  @override
  Widget build(BuildContext context) {
    final headlines = [
      "Hack through your exam prep",
      "Chitti turns one!!",
      "99% users passed with Chitti",
      "Hear it from our students",
    ];
    final descriptions = [
      "Chitti is your go-to exam prep platform, offering curated resources like notes, cheat sheets, and videos crafted by top students for stress-free studying. We provide clear roadmaps for each subject, guiding you to focus on what matters most as exams approach.",
      "Chitti is celebrating its first anniversary! Join us in this journey of academic excellence and discover how we can help you ace your exams with ease.",
      "With a 99% success rate, Chitti has helped over 300 students achieve their academic goals. Our platform is designed to simplify your exam preparation, ensuring you have the best resources at your fingertips.",
      //Testimonial from student
      "Chitti made studying so much easier for me! I couldn't have done it without their help.\n~ John Doe",
    ];
    return PageView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          color:
              (Theme.of(context).brightness == Brightness.light
                  ? [
                    Color(0xFFF26E0C),
                    Color(0xFFA08DFF),
                    Color(0xFF8FD14F),
                    Color(0xFFF7AD19),
                  ]
                  : [
                    Color.fromARGB(255, 34, 34, 34),
                    Color.fromARGB(255, 31, 31, 31),
                    Color.fromARGB(255, 8, 8, 8),
                    Color.fromARGB(255, 37, 37, 37),
                  ])[index],
          width: double.infinity,
          padding: EdgeInsets.only(top: 48, left: 24, right: 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headlines[index],

                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      descriptions[index],
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Transform.translate(
                offset: Offset(24, 0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/images/ghost-launch.png",
                    height: 150,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              index == 0
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              index == 1
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              index == 2
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              index == 3
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
