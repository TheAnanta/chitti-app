import 'dart:math';

import 'package:chitti/data/semester.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text("User not found")));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 16,
              width: double.infinity,
              color: Color(0xFFF27F0C),
            ),
            AppBar(
              scrolledUnderElevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFF27F0C),
              title: Text(
                "CHITTI.",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Stack(
              children: [
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    height: 240,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Color(0xFFF7AD19)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipPath(
                          clipper: MyClipper(),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(color: Color(0xFFF27F0C)),
                            alignment: Alignment.topRight,
                            width: double.infinity,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -48),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Image.asset(
                          "assets/images/ghost_blue.png",
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 130),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 8, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "https://doeresults.gitam.edu/photo/img.aspx?id=${user.uid}",
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              user.displayName ?? "User",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
            Text("Joined in ${user.metadata.creationTime?.year}"),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Progress",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final titles =
                            Injector.semesterRepository.semester?.completed.map(
                              (e) {
                                return (
                                  e.resourceName,
                                  List<Subject>.from(
                                        Injector
                                                .semesterRepository
                                                .semester
                                                ?.courses
                                                .values
                                                .fold<List<Subject>>(
                                                  [],
                                                  (i, p) => (i)..addAll(p),
                                                ) ??
                                            [],
                                      )
                                      .where((f) => f.courseId == e.courseId)
                                      .first
                                      .icon,
                                );
                              },
                            ).toList() ??
                            [];
                        if (titles.isEmpty) {
                          return Card(
                            color: Colors.white,
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: Center(
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hourglass_empty_outlined),

                                      SizedBox(height: 8),
                                      Text(
                                        "No progress yet",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 280,
                                        child: Text(
                                          "Start preparing to ace your exam to see your progress here.",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(titles[index].$2),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(titles[index].$1),
                            );
                          },
                          shrinkWrap: true,
                          primary: false,
                          separatorBuilder: (_, __) => Divider(),
                          itemCount: min(5, titles.length ?? 0),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
              child: Text("Sign out"),
            ),
            SizedBox(height: 16),
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
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
