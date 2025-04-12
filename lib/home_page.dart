import 'package:chitti/animated_image.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(Icons.bug_report_outlined), Text("Help")],
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                icon: ClipOval(
                  child: CircleAvatar(
                    child: Image.network(
                      "https://doeresults.gitam.edu/photo/img.aspx?id=${FirebaseAuth.instance.currentUser!.uid}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
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
                  child: Card(
                    color: Color(0xFF429EBD),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            "Hope you’re motivated enough to prepare for you exam?",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   style: TextButton.styleFrom(
                          //     overlayColor: Color(0xFF053F5C),
                          //   ),
                          //   child: Text(
                          //     "Explore More".toUpperCase(),
                          //     style: Theme.of(
                          //       context,
                          //     ).textTheme.bodyLarge?.copyWith(
                          //       fontWeight: FontWeight.w800,
                          //       color: Color(0xFF053F5C),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        widget.semester.courses.values.toList().map((subjects) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              WindowSizeClass().init(constraints);
                              onTap(Subject subject, index) {
                                // if (getSizeClass() == WidthSizeClass.large) {
                                //   Navigator.of(context).push(
                                //     MaterialPageRoute(
                                //       builder: (context) {
                                //         return FutureBuilder(
                                //           future: Injector.unitRepository
                                //               .fetchUnit(
                                //                 context,
                                //                 subject.courseId,
                                //                 subject.units[0],
                                //                 subject
                                //                         .units[0]
                                //                         .roadmap
                                //                         ?.roadmapItems
                                //                         .firstOrNull
                                //                         ?.id ??
                                //                     "",
                                //               ),
                                //           builder: (context, futureValue) {
                                //             if (futureValue.hasData) {
                                //               final unit = futureValue.data!;
                                //               return UnitResourcePageExtended(
                                //                 initialUnit: unit,
                                //                 subjectName: subject.title,
                                //                 initialUnitIndex: index + 1,
                                //                 subjectCoverImage:
                                //                     subject.image,
                                //                 courseId: subject.courseId,
                                //                 subject: subject,
                                //               );
                                //             }
                                //             return Scaffold(
                                //               body: Center(
                                //                 child: Column(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment.center,
                                //                   children: [
                                //                     SizedBox(height: 128),
                                //                     CircularProgressIndicator(
                                //                       color:
                                //                           Colors.grey.shade800,
                                //                     ),
                                //                     SizedBox(height: 24),
                                //                     Align(
                                //                       alignment:
                                //                           Alignment.centerLeft,
                                //                       child: AnimatedImageEntry(
                                //                         child: Row(
                                //                           mainAxisSize:
                                //                               MainAxisSize.min,
                                //                           mainAxisAlignment:
                                //                               MainAxisAlignment
                                //                                   .start,
                                //                           children: [
                                //                             Transform.flip(
                                //                               flipX: true,
                                //                               child: Transform.translate(
                                //                                 offset: Offset(
                                //                                   0,
                                //                                   48,
                                //                                 ),
                                //                                 child: ColorFiltered(
                                //                                   colorFilter:
                                //                                       ColorFilters.matrix(
                                //                                         saturation:
                                //                                             -1,
                                //                                         brightness:
                                //                                             0.5,
                                //                                       ),
                                //                                   child: Image.asset(
                                //                                     "assets/images/ghost_blue.png",
                                //                                     height: 180,
                                //                                   ),
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             Container(
                                //                               padding:
                                //                                   EdgeInsets.all(
                                //                                     12,
                                //                                   ),
                                //                               width: 264,
                                //                               decoration: BoxDecoration(
                                //                                 borderRadius:
                                //                                     BorderRadius.circular(
                                //                                       8,
                                //                                     ),
                                //                                 color:
                                //                                     Colors
                                //                                         .grey
                                //                                         .shade400,
                                //                               ),
                                //                               child: Opacity(
                                //                                 opacity: 0.6,
                                //                                 child: Text(
                                //                                   "Go grab a break while we sneak into the server.",
                                //                                   textAlign:
                                //                                       TextAlign
                                //                                           .center,
                                //                                   style:
                                //                                       Theme.of(
                                //                                         context,
                                //                                       ).textTheme.titleMedium,
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ],
                                //                 ),
                                //               ),
                                //             );
                                //           },
                                //         );
                                //       },
                                //     ),
                                //   );
                                // } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            SubjectPage(subject: subject),
                                  ),
                                );
                                // }
                              }

                              itemBuilder(_, index) {
                                final subject = subjects[index];
                                return ListTile(
                                  title: Text(
                                    subject.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Text(
                                        subject.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 16),
                                      LinearProgressIndicator(
                                        value: subject.progress,
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.chevron_right_outlined),
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

                              return getSizeClass() == WidthSizeClass.large
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
                                                constraints: BoxConstraints(
                                                  maxWidth: 300,
                                                  minWidth: 200,
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 0.98,
                                                  child: SubjectCardExpanded(
                                                    subject: subject,
                                                    onTap: (subject) {
                                                      onTap(subject, index);
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
              ],
            ),
          ),
        );
      },
    );
  }
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
            LinearProgressIndicator(
              backgroundColor: Color(0xFF053F5C),
              value: subject.progress,
              borderRadius: BorderRadius.circular(12),
              minHeight: 6,
              color: Color(0xFFF27F0C),
            ),
          ],
        ),
      ),
    );
  }
}
