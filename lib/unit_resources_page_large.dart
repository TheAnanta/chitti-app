import 'dart:convert';
import 'dart:math' show max, min;

import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/subject_page.dart';
import 'package:chitti/unit_list_tile.dart';
import 'package:chitti/unit_resource_page.dart';
import 'package:chitti/watermark_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pdfrx/pdfrx.dart';

class UnitWithResourcesAndIndex {
  final UnitWithResources unit;
  final int index;
  final String roadmapName;
  UnitWithResourcesAndIndex(this.unit, this.index, this.roadmapName);
}

class UnitResourcePageExtended extends StatefulWidget {
  final Subject subject;
  final String courseId;
  final String subjectName;
  final String subjectCoverImage;
  const UnitResourcePageExtended({
    super.key,
    required this.subjectName,
    required this.subjectCoverImage,
    required this.courseId,
    required this.subject,
  });

  @override
  State<UnitResourcePageExtended> createState() =>
      _UnitResourcePageExtendedState();
}

class _UnitResourcePageExtendedState extends State<UnitResourcePageExtended>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  // Use ValueNotifier to hold and notify about scroll offset changes
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );

  final ValueNotifier<UnitWithResourcesAndIndex?> _unit = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    // _unit.value = UnitWithResourcesAndIndex(
    //   widget.initialUnit,
    //   widget.initialUnitIndex,
    // );
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController(
      onAttach: (scrollPosition) {
        _scrollController.addListener(() {
          double _newScrollOffset = max(0, min(_scrollController.offset, 134));
          if (_scrollOffsetNotifier.value != _newScrollOffset) {
            _scrollOffsetNotifier.value = _newScrollOffset;
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollOffsetNotifier.value = max(
            0,
            min(_scrollController.offset, 134),
          );
        });
      },
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
            "https://asia-south1-chitti-ananta.cloudfunctions.net/api/feedback",
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
                        subject.instructor
                            .where(
                              (instructor) => instructor.id == instructorId,
                            )
                            .isNotEmpty,
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
                      .where(
                        (course) =>
                            course.instructor
                                .where(
                                  (instructor) => instructor.id == instructorId,
                                )
                                .isNotEmpty,
                      )
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

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollOffsetNotifier.dispose(); // Dispose the ValueNotifier
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
          body: Column(
            children: [
              ClipRect(
                child: Stack(
                  children: [
                    Image.network(
                      widget.subjectCoverImage,
                      height: 208,
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
                      height: 184,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _scrollOffsetNotifier,
                      builder: (context, _scrollOffset, _) {
                        return Opacity(
                          opacity: _scrollOffset / 134,
                          child: Container(
                            margin: EdgeInsets.only(top: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            height: 184,
                          ),
                        );
                      },
                    ),
                    AppBar(
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
                    SizedBox(
                      height: 208,
                      child: Column(
                        children: [
                          Spacer(),
                          ValueListenableBuilder(
                            valueListenable: _unit,
                            builder: (context, _unitWithValue, _) {
                              final unit = _unitWithValue?.unit;
                              final unitIndex = _unitWithValue?.index;
                              if (unit == null) {
                                return SizedBox();
                              }
                              return ValueListenableBuilder(
                                valueListenable: _scrollOffsetNotifier,
                                builder: (context, _scrollOffset, _) {
                                  return Opacity(
                                    opacity: (_scrollOffset / 134),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilters.matrix(
                                        brightness: _scrollOffset * 5 / 134,
                                      ),
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          134 - ((-_scrollOffset / 134) * -134),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            16.0,
                                          ).copyWith(top: 32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "UNIT $unitIndex",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black38,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                unit.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                    ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              ValueListenableBuilder(
                                valueListenable: widget.subject.progress,
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value / 100,
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              Opacity(
                                opacity: 0.3,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: ValueListenableBuilder(
                                    valueListenable: widget.subject.progress,
                                    builder: (context, value, child) {
                                      return Text(
                                        "${(value).toInt()}% completed",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              UnitListTile(
                                units: widget.subject.units,
                                subjectName: widget.subject.title,
                                subjectId: widget.subject.courseId,
                                subjectCoverImage: widget.subject.image,
                                courseId: widget.subject.courseId,
                                onUnitTap: (
                                  selectedUnit,
                                  roadmapId,
                                  roadmapName,
                                ) async {
                                  _unit.value = null;
                                  //TODO: roadmapItems and expansiontile
                                  final newUnit = await Injector.unitRepository
                                      .fetchUnit(
                                        context,
                                        widget.courseId,
                                        selectedUnit,
                                        roadmapId,
                                      );
                                  _unit.value = UnitWithResourcesAndIndex(
                                    newUnit,
                                    widget.subject.units.indexOf(selectedUnit) +
                                        1,
                                    roadmapName,
                                  );
                                  _tabController.animateTo(0);
                                  setState(() {});
                                },
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
                              ListView.separated(
                                padding: const EdgeInsets.all(8.0),
                                itemBuilder: (context, index) {
                                  final instructor =
                                      widget.subject.instructor[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        instructor.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                instructor.image,
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
                                                      "${instructor.rating} rating",
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
                                                    Icon(
                                                      Icons.timer_outlined,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "${instructor.hours} hours",
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
                                                    Icon(
                                                      Icons.school_outlined,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "${instructor.gpa} CGPA",
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
                                        instructor.bio,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () {
                                          final reviewController =
                                              TextEditingController();
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              int rating = 0;
                                              return StatefulBuilder(
                                                builder: (
                                                  context,
                                                  setSheetState,
                                                ) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16.0,
                                                        ).copyWith(
                                                          bottom:
                                                              MediaQuery.of(
                                                                    context,
                                                                  )
                                                                  .viewInsets
                                                                  .bottom,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Write a review for ${instructor.name}",
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        RatingView(
                                                          rating:
                                                              rating.toDouble(),
                                                          isEditable: true,
                                                          onTap: (ratingValue) {
                                                            setSheetState(() {
                                                              rating =
                                                                  ratingValue;
                                                            });
                                                          },
                                                        ),
                                                        SizedBox(height: 12),
                                                        TextField(
                                                          controller:
                                                              reviewController,
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
                                                              reviewController
                                                                  .text,
                                                              () {
                                                                // For now, we will just clear the text field
                                                                reviewController
                                                                    .clear();
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

                                                              instructorId:
                                                                  instructor.id,
                                                            );
                                                          },
                                                          child: Text(
                                                            "Submit Review",
                                                          ),
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
                                    ],
                                  );
                                },
                                separatorBuilder: (context, _) => Divider(),
                                itemCount: widget.subject.instructor.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
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
                              !widget.subject.reviews.any(
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Write a review for ${widget.subject.title}",
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
                                                      controller:
                                                          reviewController,
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
                                                            reviewController
                                                                .clear();
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
                                                          courseId:
                                                              widget
                                                                  .subject
                                                                  .courseId,
                                                        );
                                                      },
                                                      child: Text(
                                                        "Submit Review",
                                                      ),
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
                                      final userRating = widget.subject.reviews
                                          .firstWhere(
                                            (e) =>
                                                e.userId ==
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser
                                                    ?.uid,
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
                                        title: Text("${userRating.name} (You)"),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RatingView(
                                              rating:
                                                  userRating.rating.toDouble(),
                                            ),
                                            SizedBox(height: 4),
                                            Text(userRating.comment),
                                          ],
                                        ),
                                        trailing: Text(
                                          "${userRating.date.day}/${userRating.date.month}/${userRating.date.year}",
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                        ),
                                      );
                                    },
                                  ),
                              SizedBox(height: 12),

                              widget.subject.reviews.isEmpty
                                  ? Text(
                                    "No reviews yet.",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  )
                                  : Builder(
                                    builder: (context) {
                                      final reviews =
                                          widget.subject.reviews
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
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shrinkWrap: true,
                                        itemBuilder: (context, ratingIndex) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                reviews[ratingIndex].image,
                                              ),
                                            ),
                                            title: Text(
                                              reviews[ratingIndex].name,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RatingView(
                                                  rating:
                                                      reviews[ratingIndex]
                                                          .rating
                                                          .toDouble(),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  reviews[ratingIndex].comment,
                                                ),
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
                    ),
                    VerticalDivider(),
                    ValueListenableBuilder(
                      valueListenable: _unit,
                      builder: (context, _unitWithIndex, _) {
                        final unit = _unitWithIndex?.unit;
                        if (unit == null) {
                          return Expanded(
                            flex: 2,
                            child: Center(child: Text("No unit selected.")),
                          );
                        }
                        return Expanded(
                          flex: 2,
                          child: NestedScrollView(
                            controller: _scrollController,
                            headerSliverBuilder: (context, innerBoxIsScrolled) {
                              return [
                                SliverAppBar(
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black
                                          : Colors.white,
                                  foregroundColor: Colors.white,
                                  expandedHeight:
                                      242 -
                                      ((AppBar().preferredSize.height +
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.bottom) >
                                              100
                                          ? 54
                                          : 0),
                                  toolbarHeight: 0,
                                  collapsedHeight: 8,
                                  floating: true,
                                  pinned: true,
                                  flexibleSpace: ValueListenableBuilder(
                                    valueListenable: _scrollOffsetNotifier,
                                    builder: (context, _scrollOffset, _) {
                                      return Wrap(
                                        clipBehavior: Clip.antiAlias,
                                        children: [
                                          ColorFiltered(
                                            colorFilter: ColorFilters.matrix(
                                              brightness:
                                                  _scrollOffset * 5 / 134,
                                            ),
                                            child: Transform.translate(
                                              offset: Offset(0, -_scrollOffset),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ).copyWith(top: 32),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      unit.name.toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black38,
                                                            fontSize: 16,
                                                          ),
                                                    ),
                                                    Text(
                                                      _unitWithIndex
                                                              ?.roadmapName ??
                                                          "Roadmap Name",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 22,
                                                          ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "${unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                                                    ),
                                                    SizedBox(height: 8),
                                                    Opacity(
                                                      opacity:
                                                          1 -
                                                          (_scrollOffset / 134),
                                                      child: Text(
                                                        unit.description,
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  bottom: PreferredSize(
                                    preferredSize: Size.fromHeight(
                                      kTextTabBarHeight,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 8),
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                      child: TabBar(
                                        isScrollable: true,
                                        controller: _tabController,
                                        tabs: [
                                          Tab(text: "Videos"),
                                          Tab(text: "Notes"),
                                          // Tab(text: "Cheatsheets"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ];
                            },
                            body: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildVideoView(unit.videos, widget.courseId),
                                  _buildNotesView(unit.notes, widget.courseId),
                                  // _buildCheatsheetView(
                                  //   unit.cheatsheets,
                                  //   widget.courseId,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesView(List<Notes>? notes, String courseId) {
    return notes == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : notes.isEmpty
        ? Center(child: Text("No notes available."))
        : ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          itemBuilder: (context, index) {
            final notesItem = notes[index];
            return ListTile(
              onTap: () {
                addCompletedResource(
                  context,
                  CompletedResources(
                    courseId: courseId,
                    resourceId: notesItem.id,
                    resourceName: notesItem.name,
                    unitId: _unit.value?.unit.unitId ?? "",
                    resourceType: "notes",
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          appBar: AppBar(title: Text(notesItem.name)),
                          body: Center(
                            child: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: Builder(
                                builder: (context) {
                                  final viewController = PdfViewerController();
                                  if (viewController.isReady) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!notesItem.url.contains(".pdf")) {
                                    return Center(
                                      child: Text("Invalid resource."),
                                    );
                                  }
                                  return PdfViewer.uri(
                                    Uri.tryParse(notesItem.url) ??
                                        Uri.parse(
                                          "https://pdfobject.com/pdf/sample.pdf",
                                        ),
                                    controller: viewController,
                                    params: PdfViewerParams(
                                      // enableTextSelection: false,
                                      loadingBannerBuilder: (
                                        context,
                                        bytesDownloaded,
                                        totalBytes,
                                      ) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                  ),
                );
              },
              title: Text(
                notesItem.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right_outlined),
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: notes.length,
          shrinkWrap: true,
        );
  }

  Widget _buildVideoView(List<Video>? videos, String courseId) {
    return videos == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : videos.isEmpty
        ? Center(child: Text("No videos available."))
        : GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      VideoThumbnailWidget(
                        url: videos[index].thumbnail,
                        index: index,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => VideoPlayerWidget(
                                        video: videos[index],
                                        onPlayedVideo: () {
                                          Navigator.of(context).pop();
                                          addCompletedResource(
                                            context,
                                            CompletedResources(
                                              courseId: courseId,
                                              resourceId: videos[index].id,
                                              resourceName: videos[index].name,
                                              unitId:
                                                  _unit.value?.unit.unitId ??
                                                  "",
                                              resourceType: "video",
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                            child:
                                (Injector.semesterRepository.semester?.completed
                                            .contains(
                                              CompletedResources(
                                                courseId: widget.courseId,
                                                resourceId: videos[index].id,
                                                resourceName:
                                                    videos[index].name,
                                                unitId:
                                                    _unit.value?.unit.unitId ??
                                                    "",
                                                resourceType: "video",
                                              ),
                                            ) ??
                                        false)
                                    ? Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        "Watched",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : Center(
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  videos[index].name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   "Compiler design is a complex process that involves multiple stages and requires a deep understanding of both the programming language and the target platform.",
                //   maxLines: 2,
                //   style: Theme.of(context).textTheme.bodySmall,
                // ),
              ],
            );
          },
          itemCount: videos.length,
          shrinkWrap: true,
        );
  }

  Widget _buildCheatsheetView(List<Cheatsheet>? cheatsheets, String courseId) {
    return cheatsheets == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : cheatsheets.isEmpty
        ? Center(child: Text("No cheatsheets available."))
        : ListView.separated(
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            final cheatsheet = cheatsheets[index];
            var showCheatsheet = false;
            return StatefulBuilder(
              key: ValueKey(cheatsheet.name),
              builder: (context, setTileState) {
                return InkWell(
                  onTap: () {
                    if (!showCheatsheet) {
                      addCompletedResource(
                        context,
                        CompletedResources(
                          courseId: courseId,
                          resourceId: cheatsheet.id,
                          resourceName: cheatsheet.name,
                          unitId: _unit.value?.unit.unitId ?? "",
                          resourceType: "cheatsheet",
                        ),
                      );
                    }
                    showCheatsheet = !showCheatsheet;
                    setTileState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cheatsheet.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 24),
                            AnimatedRotation(
                              turns: showCheatsheet ? 0.25 : 0,
                              duration: Duration(milliseconds: 500),
                              child: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          child:
                              showCheatsheet
                                  ? Image.network(cheatsheet.url)
                                  : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: cheatsheets.length,
          shrinkWrap: true,
        );
  }

  // Widget _buildIQView(List<ImportantQuestion>? iqs, String courseId) {
  //   return iqs == null
  //       ? Center(child: Text("You haven't purchased a valid subscription."))
  //       : iqs.isEmpty
  //       ? Center(child: Text("No important questions available."))
  //       : ListView.separated(
  //         padding: EdgeInsets.all(0),
  //         itemBuilder: (context, index) {
  //           final iq = iqs[index];
  //           var showAnswer = false;
  //           return StatefulBuilder(
  //             builder: (context, setTileState) {
  //               return InkWell(
  //                 onTap: () {
  //                   if (!showAnswer) {
  //                     addCompletedResource(
  //                       context,
  //                       CompletedResources(
  //                         courseId: courseId,
  //                         resourceId: iq.id,
  //                         resourceName: iq.question,
  //                       ),
  //                     );
  //                   }
  //                   showAnswer = !showAnswer;
  //                   setTileState(() {});
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Opacity(
  //                         opacity: 0.5,
  //                         child: Text(
  //                           iq.tag.toUpperCase(),
  //                           style: Theme.of(context).textTheme.bodySmall
  //                               ?.copyWith(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                       SizedBox(height: 4),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               iq.question,
  //                               style: Theme.of(context).textTheme.bodyLarge
  //                                   ?.copyWith(fontWeight: FontWeight.w600),
  //                             ),
  //                           ),
  //                           SizedBox(width: 24),
  //                           AnimatedRotation(
  //                             turns: showAnswer ? 0.25 : 0,
  //                             duration: Duration(milliseconds: 500),
  //                             child: Icon(Icons.chevron_right),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 8),
  //                       AnimatedContainer(
  //                         duration: Duration(milliseconds: 500),
  //                         child: showAnswer ? Text(iq.answer) : SizedBox(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         separatorBuilder: (_, __) => Divider(),
  //         itemCount: iqs.length,
  //         shrinkWrap: true,
  //       );
  // }
}
