import 'package:chitti/animated_image.dart';
import 'package:chitti/cart_page.dart';
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/ds.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/size_config.dart';
import 'package:chitti/subject_page.dart';
import 'package:chitti/unit_resources_page_large.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  final String name;
  final Semester semester;
  const MyHomePage({super.key, required this.name, required this.semester});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    disableScreenshot(context);
    _controller = TabController(
      length: widget.semester.courses.length,
      vsync: this,
    );

    SharedPreferences.getInstance().then((prefs) {
      //Check if the user is first time using the app
      bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        // Show onboarding
        showTermsModalSheet(context, prefs);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WindowSizeClass().init(constraints);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "CHITTI.",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Color(0xFFF27F0C),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Navigate to the cart page
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => CartPage()));
                },
                icon: Icon(Icons.shopping_cart),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Report a bug or issue to us at scorewithchitti@gmail.com",
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  launchUrl(Uri.parse("mailto:scorewithchitti@gmail.com"));
                },
                icon: Icon(Icons.support_agent_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                icon: Icon(Icons.account_circle_outlined),
                // icon: AspectRatio(
                //   aspectRatio: 1,
                //   child: ClipOval(
                //     child: CircleAvatar(
                //       child: Image.network(
                //         "https://doeresults.gitam.edu/photo/img.aspx?id=${FirebaseAuth.instance.currentUser!.uid}",
                //         fit: BoxFit.cover,
                //         width: double.infinity,
                //         height: double.infinity,
                //         alignment: Alignment.topCenter,
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome back, ${widget.name.split(" ").first}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text("Here’s a quick overview of your exam preparation"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 100, maxHeight: 240),
                    child: PageView.builder(
                      itemCount: 1,
                      itemBuilder: (context, pageIndex) {
                        return Center(
                          child: Card(
                            color: Color(0xFF429EBD),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                24.0,
                              ).copyWith(right: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "All the best!",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          "We are here to help you ace your exams. So, the first two topics are on us!\nYes, free, so you can try them out.",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        // TextButton(
                                        //   onPressed: () {},
                                        //   style: TextButton.styleFrom(
                                        //     overlayColor: Color(0xFF053F5C),
                                        //     padding: EdgeInsets.only(top: 16),
                                        //   ),
                                        //   child: Text(
                                        //     "Explore More".toUpperCase(),
                                        //     style: Theme.of(
                                        //       context,
                                        //     ).textTheme.bodyLarge?.copyWith(
                                        //       fontWeight: FontWeight.w800,
                                        //       color: Color(0xFFFFFFFF),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Image.asset(
                                    "assets/images/ghost_blue.png",
                                    height: 120,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ...(widget.semester.courses.entries.isNotEmpty
                    ? [
                      TabBar(
                        isScrollable: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        tabs:
                            widget.semester.courses.keys
                                .map(
                                  (e) => Tab(
                                    text: e
                                        .split("-")
                                        .map(
                                          (f) =>
                                              "${f[0].toUpperCase()}${f.substring(1)}",
                                        )
                                        .join(" "),
                                  ),
                                )
                                .toList(),
                        controller: _controller,
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _controller,
                          children:
                              widget.semester.courses.values.toList().map((
                                subjects,
                              ) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    WindowSizeClass().init(constraints);
                                    onTap(Subject subject, index) {
                                      if (getSizeClass() ==
                                          WidthSizeClass.large) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return FutureBuilder(
                                                future: fetchSubjectForExtended(
                                                  context,
                                                  subject,
                                                ),
                                                builder: (
                                                  context,
                                                  futureValue,
                                                ) {
                                                  if (futureValue
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    return UnitResourcePageExtended(
                                                      subjectName:
                                                          subject.title,
                                                      subjectCoverImage:
                                                          subject.image,
                                                      courseId:
                                                          subject.courseId,
                                                      subject: subject,
                                                    );
                                                  }
                                                  return Scaffold(
                                                    body: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(height: 128),
                                                          CircularProgressIndicator(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade800,
                                                          ),
                                                          SizedBox(height: 24),
                                                          Align(
                                                            alignment:
                                                                Alignment
                                                                    .centerLeft,
                                                            child: AnimatedImageEntry(
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Transform.flip(
                                                                    flipX: true,
                                                                    child: Transform.translate(
                                                                      offset:
                                                                          Offset(
                                                                            0,
                                                                            48,
                                                                          ),
                                                                      child: ColorFiltered(
                                                                        colorFilter: ColorFilters.matrix(
                                                                          saturation:
                                                                              -1,
                                                                          brightness:
                                                                              0.5,
                                                                        ),
                                                                        child: Image.asset(
                                                                          "assets/images/ghost_blue.png",
                                                                          height:
                                                                              180,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          12,
                                                                        ),
                                                                    width: 264,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                      color:
                                                                          Colors
                                                                              .grey
                                                                              .shade400,
                                                                    ),
                                                                    child: Opacity(
                                                                      opacity:
                                                                          0.6,
                                                                      child: Text(
                                                                        "Go grab a break while we sneak into the server.",
                                                                        textAlign:
                                                                            TextAlign.center,
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
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => SubjectPage(
                                                  subject: subject,
                                                ),
                                          ),
                                        );
                                      }
                                    }

                                    itemBuilder(_, index) {
                                      final subject = subjects[index];
                                      return ListTile(
                                        title: Text(
                                          subject.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Text(
                                              subject.description,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 16),
                                            ValueListenableBuilder(
                                              valueListenable: subject.progress,
                                              builder: (context, value, child) {
                                                return LinearProgressIndicator(
                                                  value: value / 100,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right_outlined,
                                        ),
                                        leading: Icon(subject.icon),
                                        isThreeLine: true,
                                        onTap: () {
                                          onTap(subject, index);
                                        },
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 6,
                                        ).copyWith(bottom: 6),
                                      );
                                    }

                                    return getSizeClass() ==
                                            WidthSizeClass.large
                                        ? Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              children:
                                                  subjects.mapIndexed((
                                                    index,
                                                    subject,
                                                  ) {
                                                    return ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                            maxWidth: 300,
                                                            minWidth: 200,
                                                          ),
                                                      child: AspectRatio(
                                                        aspectRatio: 0.98,
                                                        child:
                                                            SubjectCardExpanded(
                                                              subject: subject,
                                                              onTap: (subject) {
                                                                onTap(
                                                                  subject,
                                                                  index,
                                                                );
                                                              },
                                                            ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        )
                                        : ListView.separated(
                                          itemCount: subjects.length,
                                          separatorBuilder: (_, __) {
                                            return Divider();
                                          },
                                          itemBuilder: itemBuilder,
                                        );
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ]
                    : [
                      Expanded(
                        child: Transform.translate(
                          offset: Offset(0, -24),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: Image.asset(
                                      "assets/images/construction.png",
                                    ),
                                  ),
                                ),
                                Text(
                                  "Oops! CHITTI isn't there for you yet.",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No courses available for this semester. We'll be adding more soon. But, thanks for using CHITTI.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchSubjectForExtended(
    BuildContext context,
    Subject subject,
  ) async {
    for (var unit in subject.units) {
      for (var roadmap
          in (unit.roadmap?.roadmapItems ?? List<Roadmap>.empty())) {
        await Injector.unitRepository.fetchUnit(
          context,
          subject.courseId,
          unit,
          (roadmap as RoadmapItem).id,
        );
      }
    }
  }
}

Future showTermsModalSheet(
  BuildContext context,
  SharedPreferences prefs, {
  bool showCheckbox = true,
}) {
  return showModalBottomSheet(
    showDragHandle: true,
    enableDrag: true,
    context: context,
    isDismissible: !showCheckbox,
    builder: (context) {
      bool isTermsAccepted = false;
      return BottomSheet(
        onClosing: () {
          Navigator.of(context).pop();
        },
        builder: (context) {
          return SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ).copyWith(top: 24, bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to CHITTI!",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "This app will help you prepare for your exams effectively. You can track your progress, access resources, and stay motivated.",
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Here’s how to get started:",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        itemBuilder: (context, index) {
                          final steps = [
                            "Choose the course you aim to ace.",
                            "Make the payment.",
                            "Track your progress and stay motivated.",
                            "Oops, no sharing of credentials, please.",
                            "Device restrictions apply.",
                            "If you face any issues, report them to us.",
                          ];
                          final descriptions = [
                            "Select the course you want to focus on from the list.",
                            "Complete the payment, to unlock all resources for the course.",
                            "Monitor your learning progress and stay motivated with our tools.",
                            "Your credentials are for your use only. Please do not share them. Any misuse will lead to account suspension.",
                            "Please use the app on a single device only. Any attempt to use the app on multiple devices will result in account suspension.",
                            "For any issues, please contact us at scorewithchitti@gmail.com",
                          ];
                          final icons = [
                            Icons.book,
                            Icons.payment,
                            Icons.bar_chart,
                            Icons.lock,
                            Icons.devices,
                            Icons.report_problem,
                          ];
                          return ListTile(
                            leading: Icon(icons[index]),
                            title: Text(steps[index]),
                            subtitle: Text(descriptions[index]),
                          );
                        },
                        itemCount: 6,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                      ...(showCheckbox
                          ? [
                            Row(
                              children: [
                                Checkbox(
                                  value: isTermsAccepted,
                                  onChanged: (value) {
                                    setSheetState(() {
                                      isTermsAccepted = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  "I accept the terms and conditions.",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed:
                                    isTermsAccepted
                                        ? () async {
                                          await prefs.setBool(
                                            'isFirstTime',
                                            false,
                                          );
                                          Navigator.of(context).pop();
                                        }
                                        : null,
                                child: Text("Get Started"),
                              ),
                            ),
                          ]
                          : []),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

class SubjectCardExpanded extends StatelessWidget {
  const SubjectCardExpanded({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final Subject subject;
  final Function(Subject subject) onTap;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onTap(subject),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              subject.image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subject.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      subject.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Start Learning",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF053F5C),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_outlined,
                        color: Color(0xFF053F5C),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            ValueListenableBuilder(
              valueListenable: subject.progress,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  backgroundColor: Color(0xFF053F5C),
                  value: value,
                  borderRadius: BorderRadius.circular(12),
                  minHeight: 6,
                  color: Color(0xFFF27F0C),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
