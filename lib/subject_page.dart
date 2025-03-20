import 'dart:io';

import 'package:chitti/data/semester.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/unit_list_tile.dart';
import 'package:flutter/material.dart';

class SubjectPage extends StatelessWidget {
  final Subject subject;
  const SubjectPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.white,
            expandedHeight: 312,
            flexibleSpace: Stack(
              children: [
                Image.network(
                  subject.image,
                  height: 372,
                  width: double.infinity,
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withAlpha(0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  height: 234,
                ),
                Padding(
                  padding:
                      Platform.isMacOS
                          ? const EdgeInsets.only(top: 24.0)
                          : const EdgeInsets.only(top: 0.0),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    title: Text(
                      "CHITTI.",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                        icon: Icon(Icons.account_circle_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0).copyWith(top: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${subject.courseId} • ${subject.courseCategory.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")}",
                        ),
                        SizedBox(height: 8),
                        Text(
                          subject.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(value: subject.progress),
                        SizedBox(height: 8),
                        Opacity(
                          opacity: 0.3,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "${(subject.progress * 100).toInt()}% completed",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        UnitListTile(
                          units: subject.units,
                          subjectName: subject.title,
                          subjectId: subject.courseId,
                          subjectCoverImage: subject.image,
                          courseId: subject.courseId,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
