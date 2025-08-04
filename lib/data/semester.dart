import 'dart:convert';

import 'package:chitti/data/important_questions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Instructor {
  final String name;
  final String image;
  final String bio;
  final String id;
  final int gpa;
  final int rating;
  final int hours;
  const Instructor({
    required this.name,
    required this.image,
    required this.bio,
    required this.id,
    required this.gpa,
    required this.rating,
    required this.hours,
  });
}

class Unit {
  final String unitId;
  final String name;
  final String difficulty;
  final String description;
  final bool isUnlocked;
  final int totalResources;
  final Roadmap? roadmap;
  final ImportantQuestion? importantQuestions;
  const Unit({
    required this.unitId,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.importantQuestions,
    this.isUnlocked = false,
    this.totalResources = 0,
    this.roadmap,
  });

  static fromMap(Map<String, dynamic> data) {
    return Unit(
      unitId: data["unitId"],
      name: data["name"],
      description: data["description"],
      difficulty: data["difficulty"],
      isUnlocked: data["isUnlocked"],
      totalResources: data["total-resources"] ?? 0,
      importantQuestions:
          data["importantQuestions"] != null
              ? List<ImportantQuestion>.from(
                data["importantQuestions"].map((e) {
                  return ImportantQuestion(id: e["iqId"], url: e["url"]);
                }),
              ).firstOrNull
              : null,
      roadmap:
          data["roadmap"] != null
              ? Roadmap(
                roadmapItems: List<RoadmapItem>.from(
                  data["roadmap"].map((e) {
                    return RoadmapItem(
                      id: e["roadId"],
                      name: e["name"],
                      difficulty: e["difficulty"],
                      isUnlocked: e["isUnlocked"] ?? false,
                    );
                  }),
                ),
              )
              : null,
    );
  }
}

class Roadmap {
  final List<RoadmapItem> roadmapItems;
  const Roadmap({this.roadmapItems = const []});
}

class RoadmapItem {
  final String id;
  final String name;
  final String difficulty;
  final bool isUnlocked;
  const RoadmapItem({
    required this.name,
    required this.difficulty,
    required this.id,
    required this.isUnlocked,
  });
}

class Cheatsheet {
  final String id;
  final String name;
  final String url;
  const Cheatsheet({required this.name, required this.url, required this.id});
}

class Video {
  final String id;
  final String name;
  final String url;
  final String thumbnail;
  const Video({
    required this.name,
    required this.url,
    required this.id,
    required this.thumbnail,
  });
}

class Notes {
  final String id;
  final String name;
  final String url;
  const Notes({required this.name, required this.url, required this.id});
}

class UnitWithResources {
  final String unitId;
  final String name;
  final String difficulty;
  final String description;
  final bool isUnlocked;
  final Roadmap? roadmap;
  final List<Video>? videos;
  final List<Notes>? notes;
  final List<Cheatsheet>? cheatsheets;

  const UnitWithResources({
    required this.unitId,
    required this.name,
    required this.description,
    required this.difficulty,
    this.isUnlocked = false,
    this.roadmap,
    this.notes,
    this.videos,
    this.cheatsheets,
  });
}

class Subject {
  final String courseId;
  final String courseCategory;
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final String image;
  final List<Unit> units;
  final Instructor instructor;
  final double rating;
  final List<Review> reviews;

  const Subject({
    required this.courseId,
    required this.courseCategory,
    required this.title,
    required this.description,
    this.icon = Icons.category_outlined,
    this.progress = 0.0,
    this.image =
        "https://images.squarespace-cdn.com/content/v1/570b9bd42fe131a6e20717c2/1730901328712-ARXW9LQ4S2MVG2PULIKV/Gitam_Banner.jpg?format=2500w",
    this.units = const [],
    required this.instructor,
    required this.rating,
    this.reviews = const [],
  });

  static fromMap(Map<String, dynamic> data) {
    return Subject(
      courseId: data["courseId"],
      courseCategory: data["courseCategory"],
      title: data["title"]
          .toString()
          .split(" ")
          .map((f) => f[0].toUpperCase() + f.substring(1).toLowerCase())
          .join(" "),
      description: data["description"],
      icon: IconData(data["icon"], fontFamily: "MaterialIcons"),
      image: data["image"],
      progress: double.tryParse(data["progress"].toString()) ?? 0,
      units: List<Unit>.from(
        data["units"].map((unit) {
          return Unit.fromMap(unit);
        }),
      ),
      rating: double.tryParse(data["rating"].toString()) ?? 0,
      reviews: List<Review>.from(
        data["feedback"].map((review) {
          return Review(
            userId: review["userId"],
            rating: review["rating"],
            comment: review["review"],
            name: review["name"],
            image: review["image"],
            date: DateTime.parse(review["createdAt"]),
          );
        }),
      ),
      instructor: Instructor(
        id: data["instructor"]["instructorId"],
        name: data["instructor"]["name"],
        image: data["instructor"]["image"],
        bio: data["instructor"]["bio"],
        gpa: data["instructor"]["gpa"] ?? 0,
        rating: data["instructor"]["rating"] ?? 0,
        hours: data["instructor"]["hours"] ?? 0,
      ),
    );
  }

  copyWithProgress(double progress) {
    return Subject(
      courseId: courseId,
      courseCategory: courseCategory,
      title: title,
      description: description,
      icon: icon,
      image: image,
      progress: progress,
      units: units,
      instructor: instructor,
      rating: rating,
      reviews: reviews,
    );
  }
}

class Review {
  final String userId;
  final int rating;
  final String comment;
  final String name;
  final String image;
  final DateTime date;
  const Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.name,
    required this.image,
    required this.date,
  });
}

class Semester {
  final int semester;
  final List<CompletedResources> completed;
  final Map<String, List<Subject>> courses;
  const Semester({
    required this.semester,
    required this.courses,
    required this.completed,
  });
  static fromMap(Map<String, dynamic> data) {
    List<Subject> courses = List<Subject>.from(
      data["courses"]
          .where((e) {
            return e["courseId"] != null;
          })
          .map((e) {
            return Subject.fromMap(e);
          })
          .toList(),
    );
    final completed = List<CompletedResources>.from(
      ((data["completed"] as List<dynamic>)..sorted((a, b) {
            return a["updatedAt"].compareTo(b["updatedAt"]);
          }))
          .map((e) {
            return CompletedResources.fromSnapshot(e);
          })
          .toSet()
          .toList(),
    );
    return Semester(
      semester: data["semester"],
      courses: groupBy(courses, (s) => s.courseCategory),
      completed: completed,
    );
  }
}

class CompletedResources {
  final String courseId;
  final String unitId;
  final String resourceId;
  final String resourceName;
  final String resourceType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other as CompletedResources).courseId + other.resourceId ==
          courseId + resourceId;

  @override
  int get hashCode => (courseId + resourceId).hashCode;

  const CompletedResources({
    required this.courseId,
    required this.resourceId,
    required this.resourceName,
    required this.unitId,
    required this.resourceType,
  });

  static fromSnapshot(Map<String, dynamic> data) {
    print(data);
    return CompletedResources(
      courseId: data["courseId"],
      resourceId: data["resourceId"],
      resourceName: data["resourceName"],
      unitId: data["unitId"],
      resourceType:
          data["resourceType"] ?? "video", // Default to video if not specified
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "courseId": courseId,
      "resourceId": resourceId,
      "resourceName": resourceName,
      "unitId": unitId,
      "resourceType": resourceType,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }
}
