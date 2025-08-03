import 'dart:io';

import 'package:chitti/data/semester.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/unit_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
                      kIsWeb || Platform.isMacOS
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
                        Row(
                          children: [
                            Text(
                              subject.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "(3.5K enrolled)",
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingView(rating: 4.5),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${subject.courseId} • ${subject.courseCategory.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")}",
                        ),
                        SizedBox(height: 8),
                        Text(
                          subject.description,
                          maxLines: 2,
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
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        Text(
                          "Instructor",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          subject.instructor.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  subject.instructor.image,
                                ),
                                radius: 30,
                              ),
                              SizedBox(width: 12),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5 rating",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "120 hours",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.school_outlined, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "9.6 CGPA",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          subject.instructor.bio,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        Text(
                          "Reviews",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Write a review...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: null,
                          minLines: 4,
                        ),
                        SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {},
                          child: Text("Submit Review"),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No reviews yet.",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 24),
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

class RatingView extends StatelessWidget {
  const RatingView({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index + 1 <= rating
              ? Icons.star
              : (index + 0.5 <= rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}
