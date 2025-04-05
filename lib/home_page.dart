import 'package:chitti/animated_image.dart';
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/ds.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/size_config.dart';
import 'package:chitti/subject_page.dart';
import 'package:chitti/unit_resources_page_large.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                icon: Icon(Icons.account_circle_outlined),
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
                            "Just checking up on you.",
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
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              overlayColor: Color(0xFF053F5C),
                            ),
                            child: Text(
                              "Explore More".toUpperCase(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF053F5C),
                              ),
                            ),
                          ),
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
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1.8,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                      itemBuilder: (_, index) {
                                        final subject = subjects[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.blue.shade100,
                                          ),

                                          child: InkWell(
                                            onTap: () => onTap(subject, index),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(subject.icon),
                                                      SizedBox(height: 24),
                                                      Text(
                                                        subject.title,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      Text(
                                                        subject.description,
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                LinearProgressIndicator(
                                                  backgroundColor: Color(
                                                    0xFF053F5C,
                                                  ),
                                                  value: subject.progress,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  minHeight: 6,
                                                  color: Color(0xFFF27F0C),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: subjects.length,
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
