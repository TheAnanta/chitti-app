import 'package:chitti/domain/fetch_cart.dart';
import 'package:chitti/home_page.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/login_screen.dart';
import 'package:chitti/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Future.delayed(Duration(seconds: 2), () async {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        try {
          FirebaseAuth.instance.currentUser!.getIdToken(true).then((token) {
            if (token == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to create token.")),
                );
              }
              return;
            }
            try {
              fetchCart(context);
              Injector.semesterRepository
                  .fetchSemester(token, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Session expired, please login again."),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                    );
                  })
                  .then((semester) {
                    SharedPreferences.getInstance().then((sharedPreferences) {
                      final name =
                          FirebaseAuth.instance.currentUser?.displayName?.split(
                            " ",
                          )[0];
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => MyHomePage(
                                  name: name ?? "User",
                                  semester: semester,
                                ),
                          ),
                        );
                      }
                    });
                  });
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          });
        } catch (e) {
          if (FirebaseAuth.instance.currentUser == null) {
            Future.delayed(Duration(seconds: 2), () async {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            });
            return;
          }
        }
      });
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            WindowSizeClass().init(constraints);
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 48),
                  Text(
                    "Chitti.".toUpperCase(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF26E0C),
                    ),
                  ),
                  Text(
                    "Your last moment preparation buddy",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(width: 280, child: LinearProgressIndicator()),
                  getSizeClass() == WidthSizeClass.large
                      ? Expanded(
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Image.asset(
                                "assets/images/ghost_yellow.png",
                              ),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                "assets/images/ghost_blue.png",
                              ),
                            ),
                          ],
                        ),
                      )
                      : Expanded(
                        child: Column(
                          children: [
                            Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                "assets/images/ghost_blue.png",
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Image.asset(
                                "assets/images/ghost_yellow.png",
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                  SizedBox(height: 24),
                  Opacity(
                    opacity: 0.2,
                    child: Column(
                      children: [
                        Text("Made with 🖤 by"),
                        SizedBox(height: 4),
                        Transform.translate(
                          offset: Offset(6, 0),
                          child: SvgPicture.asset(
                            "assets/images/theananta.svg",
                            colorFilter: ColorFilter.mode(
                              Colors.grey.shade700,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
