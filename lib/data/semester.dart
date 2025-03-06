import 'package:chitti/data/important_questions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Unit {
  final String unitId;
  final String name;
  final String difficulty;
  final String description;
  final bool isUnlocked;
  const Unit({
    required this.unitId,
    required this.name,
    required this.description,
    required this.difficulty,
    this.isUnlocked = false,
  });

  static fromMap(Map<String, dynamic> data) {
    return Unit(
      unitId: data["unitId"],
      name: data["name"],
      description: data["description"],
      difficulty: data["difficulty"],
      isUnlocked: data["isUnlocked"],
    );
  }
}

class Roadmap {
  final Map<String, String> roadmap;
  const Roadmap({this.roadmap = const {}});
}

class Video {
  final String name;
  final String url;
  const Video({required this.name, required this.url});
}

class Notes {
  final String name;
  final String url;
  const Notes({required this.name, required this.url});
}

class UnitWithResources {
  final String unitId;
  final String name;
  final String difficulty;
  final String description;
  final bool isUnlocked;
  final List<ImportantQuestion>? importantQuestions;
  final Roadmap? roadmap;
  final List<Video>? videos;
  final List<Notes>? notes;

  const UnitWithResources({
    required this.unitId,
    required this.name,
    required this.description,
    required this.difficulty,
    this.isUnlocked = false,
    this.importantQuestions,
    this.roadmap,
    this.notes,
    this.videos,
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
  });

  static fromMap(Map<String, dynamic> data) {
    return Subject(
      courseId: data["courseId"],
      courseCategory: data["courseCategory"],
      title: data["title"],
      description: data["description"],
      icon: IconData(data["icon"], fontFamily: "MaterialIcons"),
      image: data["image"],
      progress: 0,
      units: List<Unit>.from(
        data["units"].map((unit) {
          return Unit.fromMap(unit);
        }),
      ),
    );
  }
}

class Semester {
  final int semester;
  final Map<String, List<Subject>> courses;
  const Semester({required this.semester, required this.courses});
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
    return Semester(
      semester: data["semester"],
      courses: groupBy(courses, (s) => s.courseCategory),
    );
  }
}
