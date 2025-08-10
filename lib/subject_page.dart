import 'dart:convert';
import 'dart:io';

import 'package:chitti/data/semester.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/unit_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
                                  "(${subject.reviews.length} reviews)",
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingView(rating: subject.rating),
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
                                        "${subject.instructor.rating} rating",
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
                                        "${subject.instructor.hours} hours",
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
                                        "${subject.instructor.gpa} CGPA",
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
                        OutlinedButton(
                          onPressed: () {
                            final reviewController = TextEditingController();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                int rating = 0;
                                return StatefulBuilder(
                                  builder: (context, setSheetState) {
                                    return Padding(
                                      padding: const EdgeInsets.all(
                                        16.0,
                                      ).copyWith(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Write a review for ${subject.instructor.name}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          RatingView(
                                            rating: rating.toDouble(),
                                            isEditable: true,
                                            onTap: (ratingValue) {
                                              setSheetState(() {
                                                rating = ratingValue;
                                              });
                                            },
                                          ),
                                          SizedBox(height: 12),
                                          TextField(
                                            controller: reviewController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Share your thoughts...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            maxLines: null,
                                            minLines: 4,
                                          ),
                                          SizedBox(height: 12),
                                          FilledButton(
                                            onPressed: () {
                                              // if (reviewController
                                              //     .text
                                              //     .isEmpty) {
                                              //   ScaffoldMessenger.of(
                                              //     context,
                                              //   ).showSnackBar(
                                              //     SnackBar(
                                              //       content: Text(
                                              //         "Review cannot be empty!",
                                              //       ),
                                              //     ),
                                              //   );
                                              //   return;
                                              // }
                                              // Here you would typically send the review to your backend
                                              submitReview(
                                                rating,
                                                reviewController.text,
                                                () {
                                                  // For now, we will just clear the text field
                                                  reviewController.clear();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Review submitted!",
                                                      ),
                                                    ),
                                                  );

                                                  Navigator.of(context).pop();
                                                },
                                                context,

                                                instructorId:
                                                    subject.instructor.id,
                                              );
                                            },
                                            child: Text("Submit Review"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text("Rate instructor"),
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
                        !subject.reviews.any(
                              (e) =>
                                  e.userId ==
                                  FirebaseAuth.instance.currentUser?.uid,
                            )
                            ? OutlinedButton(
                              onPressed: () {
                                final reviewController =
                                    TextEditingController();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    int rating = 0;
                                    return StatefulBuilder(
                                      builder: (context, setSheetState) {
                                        return Padding(
                                          padding: const EdgeInsets.all(
                                            16.0,
                                          ).copyWith(
                                            bottom:
                                                MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Write a review for ${subject.title}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(height: 12),
                                              RatingView(
                                                rating: rating.toDouble(),
                                                isEditable: true,
                                                onTap: (ratingValue) {
                                                  setSheetState(() {
                                                    rating = ratingValue;
                                                  });
                                                },
                                              ),
                                              SizedBox(height: 12),
                                              TextField(
                                                controller: reviewController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Share your thoughts...",
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                maxLines: null,
                                                minLines: 4,
                                              ),
                                              SizedBox(height: 12),
                                              FilledButton(
                                                onPressed: () {
                                                  // if (reviewController
                                                  //     .text
                                                  //     .isEmpty) {
                                                  //   ScaffoldMessenger.of(
                                                  //     context,
                                                  //   ).showSnackBar(
                                                  //     SnackBar(
                                                  //       content: Text(
                                                  //         "Review cannot be empty!",
                                                  //       ),
                                                  //     ),
                                                  //   );
                                                  //   return;
                                                  // }
                                                  // Here you would typically send the review to your backend
                                                  submitReview(
                                                    rating,
                                                    reviewController.text,
                                                    () {
                                                      // For now, we will just clear the text field
                                                      reviewController.clear();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Review submitted!",
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    context,
                                                    courseId: subject.courseId,
                                                  );
                                                },
                                                child: Text("Submit Review"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text("Write a review"),
                            )
                            : Builder(
                              builder: (context) {
                                final userRating = subject.reviews.firstWhere(
                                  (e) =>
                                      e.userId ==
                                      FirebaseAuth.instance.currentUser?.uid,
                                  orElse:
                                      () => Review(
                                        userId: "",
                                        rating: 0,
                                        comment: "",
                                        name: "",
                                        image: "",
                                        date: DateTime.now(),
                                      ),
                                );
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      userRating.image,
                                    ),
                                  ),
                                  title: Text(userRating.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RatingView(
                                        rating: userRating.rating.toDouble(),
                                      ),
                                      SizedBox(height: 4),
                                      Text(userRating.comment),
                                    ],
                                  ),
                                  trailing: Text(
                                    "${userRating.date.day}/${userRating.date.month}/${userRating.date.year}",
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
                        SizedBox(height: 12),

                        subject.reviews.isEmpty
                            ? Text(
                              "No reviews yet.",
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                            : Builder(
                              builder: (context) {
                                final reviews =
                                    subject.reviews
                                        .where(
                                          (e) =>
                                              e.userId !=
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid,
                                        )
                                        .toList();
                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder: (context, ratingIndex) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          reviews[ratingIndex].image,
                                        ),
                                      ),
                                      title: Text(reviews[ratingIndex].name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RatingView(
                                            rating:
                                                reviews[ratingIndex].rating
                                                    .toDouble(),
                                          ),
                                          SizedBox(height: 4),
                                          Text(reviews[ratingIndex].comment),
                                        ],
                                      ),
                                      trailing: Text(
                                        "${reviews[ratingIndex].date.day}/${reviews[ratingIndex].date.month}/${reviews[ratingIndex].date.year}",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, _) => Divider(),
                                  itemCount: reviews.length,
                                );
                              },
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

  Future<void> submitReview(
    int rating,
    String comment,
    Function() onSuccess,
    BuildContext context, {
    String? courseId,
    String? instructorId,
  }) async {
    print(rating);
    if (courseId == null && instructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course ID or Instructor ID must be provided.")),
      );
      return;
    }
    post(
          Uri.parse(
            "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/feedback",
          ),
          body: json.encode(
            courseId != null
                ? {"courseId": courseId, "rating": rating, "review": comment}
                : {
                  "rating": rating,
                  "review": comment,
                  "instructorId": instructorId,
                },
          ),
          headers: {
            "Authorization":
                "Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}",
            "Content-Type": "application/json",
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            // Update the review for either instructor or course in semester data in the repository
            if (courseId != null) {
              var data = Injector.semesterRepository.semester?.courses.values
                  .fold(
                    List<Subject>.empty(),
                    (previous, next) => [...previous, ...next],
                  )
                  .toList()
                  .firstWhere(
                    (subject) =>
                        subject.courseId == courseId ||
                        subject.instructor.id == instructorId,
                  );
              data?.reviews.add(
                Review(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  rating: rating,
                  comment: comment,
                  name: FirebaseAuth.instance.currentUser!.displayName ?? "",
                  image: FirebaseAuth.instance.currentUser!.photoURL ?? "",
                  date: DateTime.now(),
                ),
              );
            } else {
              var datas =
                  Injector.semesterRepository.semester?.courses.values
                      .fold(
                        List<Subject>.empty(),
                        (previous, next) => [...previous, ...next],
                      )
                      .toList()
                      .where((course) => course.instructor.id == instructorId)
                      .toList();
              datas?.forEach((data) {
                data.reviews.add(
                  Review(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    rating: rating,
                    comment: comment,
                    name: FirebaseAuth.instance.currentUser!.displayName ?? "",
                    image: FirebaseAuth.instance.currentUser!.photoURL ?? "",
                    date: DateTime.now(),
                  ),
                );
              });
            }
            onSuccess();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to submit review. Please try again."),
              ),
            );
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("An error occurred: $error")));
        });
  }
}

class RatingView extends StatelessWidget {
  const RatingView({
    super.key,
    required this.rating,
    this.isEditable = false,
    this.onTap,
  }) : assert(
         rating >= 0 && rating <= 5 && (isEditable ? onTap != null : true),
       );

  final double rating;
  final bool isEditable;
  final Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return InkWell(
          onTap: isEditable ? () => onTap!(index + 1) : null,
          child: Icon(
            index + 1 <= rating
                ? Icons.star
                : (index + 0.5 <= rating ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: isEditable ? 32 : 16,
          ),
        );
      }),
    );
  }
}
