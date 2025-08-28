import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/data/important_questions.dart';

void main() {
  group('Data Model Tests', () {
    group('Instructor Tests', () {
      test('should create instructor with valid data', () {
        const instructor = Instructor(
          name: 'John Doe',
          image: 'https://example.com/image.jpg',
          bio: 'Test bio',
          id: 'instructor_1',
          gpa: 3.5,
          rating: 4.0,
          hours: 120,
        );

        expect(instructor.name, 'John Doe');
        expect(instructor.gpa, 3.5);
        expect(instructor.rating, 4.0);
        expect(instructor.hours, 120);
      });

      test('should handle edge case values for instructor', () {
        const instructor = Instructor(
          name: '',
          image: '',
          bio: '',
          id: '',
          gpa: 0.0,
          rating: 0.0,
          hours: 0,
        );

        expect(instructor.name, '');
        expect(instructor.gpa, 0.0);
        expect(instructor.rating, 0.0);
        expect(instructor.hours, 0);
      });

      test('should handle maximum values for instructor', () {
        const instructor = Instructor(
          name: 'Very Long Instructor Name That Might Cause Issues',
          image: 'https://verylongdomainname.com/very/long/path/to/image/file.jpg',
          bio: 'Very long bio that might exceed normal limits and could potentially cause issues in the UI if not handled properly',
          id: 'very_long_instructor_id_that_might_cause_database_issues',
          gpa: 4.0,
          rating: 5.0,
          hours: 9999,
        );

        expect(instructor.name.length, greaterThan(20));
        expect(instructor.gpa, 4.0);
        expect(instructor.rating, 5.0);
        expect(instructor.hours, 9999);
      });
    });

    group('Unit Tests', () {
      test('should create unit with valid data', () {
        const unit = Unit(
          unitId: 'unit_1',
          name: 'Introduction to Programming',
          description: 'Basic programming concepts',
          difficulty: 'Easy',
          importantQuestions: null,
          cheatsheets: null,
          isUnlocked: true,
          totalResources: 5,
        );

        expect(unit.unitId, 'unit_1');
        expect(unit.name, 'Introduction to Programming');
        expect(unit.isUnlocked, true);
        expect(unit.totalResources, 5);
      });

      test('should handle unit with null optional fields', () {
        const unit = Unit(
          unitId: 'unit_2',
          name: 'Advanced Topics',
          description: 'Advanced programming',
          difficulty: 'Hard',
          importantQuestions: null,
          cheatsheets: null,
        );

        expect(unit.isUnlocked, false); // default value
        expect(unit.totalResources, 0); // default value
        expect(unit.roadmap, null);
        expect(unit.importantQuestions, null);
        expect(unit.cheatsheets, null);
      });

      test('should deserialize unit from valid map', () {
        final map = {
          'unitId': 'unit_1',
          'name': 'Test Unit',
          'description': 'Test Description',
          'difficulty': 'Medium',
          'isUnlocked': true,
          'total-resources': 10,
        };

        final unit = Unit.fromMap(map);

        expect(unit.unitId, 'unit_1');
        expect(unit.name, 'Test Unit');
        expect(unit.description, 'Test Description');
        expect(unit.difficulty, 'Medium');
        expect(unit.isUnlocked, true);
        expect(unit.totalResources, 10);
      });

      test('should handle malformed map data', () {
        final map = {
          'unitId': null,
          'name': '',
          'description': null,
          'difficulty': '',
          'isUnlocked': 'invalid_bool',
          'total-resources': 'invalid_number',
        };

        expect(() => Unit.fromMap(map), throwsA(isA<TypeError>()));
      });

      test('should handle missing optional fields in map', () {
        final map = {
          'unitId': 'unit_1',
          'name': 'Test Unit',
          'description': 'Test Description',
          'difficulty': 'Medium',
          'isUnlocked': true,
          // Missing total-resources, cheatsheet, importantQuestions, topic
        };

        final unit = Unit.fromMap(map);

        expect(unit.unitId, 'unit_1');
        expect(unit.totalResources, 0); // default when null
        expect(unit.cheatsheets, null);
        expect(unit.importantQuestions, null);
        expect(unit.roadmap, null);
      });
    });

    group('Subject Tests', () {
      test('should create subject with valid data', () {
        final progressNotifier = ValueNotifier<double>(0.5);
        const instructor = Instructor(
          name: 'John Doe',
          image: 'image.jpg',
          bio: 'Bio',
          id: 'instructor_1',
          gpa: 3.5,
          rating: 4.0,
          hours: 120,
        );

        final subject = Subject(
          courseId: 'course_1',
          courseCategory: 'Programming',
          title: 'Computer Science',
          description: 'Introduction to Computer Science',
          icon: Icons.computer,
          progress: progressNotifier,
          image: 'course_image.jpg',
          units: [],
          instructor: [instructor],
          rating: 4.5,
          reviews: [],
        );

        expect(subject.courseId, 'course_1');
        expect(subject.title, 'Computer Science');
        expect(subject.rating, 4.5);
        expect(subject.instructor.length, 1);
        expect(subject.instructor.first.name, 'John Doe');
      });

      test('should handle subject with empty collections', () {
        final progressNotifier = ValueNotifier<double>(0.0);

        final subject = Subject(
          courseId: 'course_empty',
          courseCategory: 'Empty',
          title: 'Empty Course',
          description: 'Course with no content',
          icon: Icons.help,
          progress: progressNotifier,
          image: '',
          units: [],
          instructor: [],
          rating: 0.0,
          reviews: [],
        );

        expect(subject.units.isEmpty, true);
        expect(subject.instructor.isEmpty, true);
        expect(subject.reviews.isEmpty, true);
        expect(subject.rating, 0.0);
      });
    });

    group('Review Tests', () {
      test('should create review with valid data', () {
        final review = Review(
          userId: 'user_1',
          rating: 5,
          comment: 'Excellent course!',
          name: 'Student Name',
          image: 'student.jpg',
          date: DateTime(2024, 1, 1),
        );

        expect(review.userId, 'user_1');
        expect(review.rating, 5);
        expect(review.comment, 'Excellent course!');
        expect(review.date.year, 2024);
      });

      test('should handle review with edge case values', () {
        final review = Review(
          userId: '',
          rating: 0,
          comment: '',
          name: '',
          image: '',
          date: DateTime.now(),
        );

        expect(review.userId, '');
        expect(review.rating, 0);
        expect(review.comment, '');
        expect(review.name, '');
      });

      test('should handle very long comment', () {
        final longComment = 'A' * 1000; // 1000 character comment
        
        final review = Review(
          userId: 'user_1',
          rating: 3,
          comment: longComment,
          name: 'Test User',
          image: 'test.jpg',
          date: DateTime.now(),
        );

        expect(review.comment.length, 1000);
        expect(review.rating, 3);
      });
    });

    group('CompletedResources Tests', () {
      test('should create completed resource with valid data', () {
        const completed = CompletedResources(
          courseId: 'course_1',
          unitId: 'unit_1',
          resourceId: 'resource_1',
          resourceName: 'Introduction Video',
          resourceType: 'video',
        );

        expect(completed.courseId, 'course_1');
        expect(completed.unitId, 'unit_1');
        expect(completed.resourceId, 'resource_1');
        expect(completed.resourceName, 'Introduction Video');
        expect(completed.resourceType, 'video');
      });

      test('should test equality operator', () {
        const completed1 = CompletedResources(
          courseId: 'course_1',
          unitId: 'unit_1',
          resourceId: 'resource_1',
          resourceName: 'Video',
          resourceType: 'video',
        );

        const completed2 = CompletedResources(
          courseId: 'course_1',
          unitId: 'unit_1',
          resourceId: 'resource_1',
          resourceName: 'Video',
          resourceType: 'video',
        );

        const completed3 = CompletedResources(
          courseId: 'course_2',
          unitId: 'unit_1',
          resourceId: 'resource_1',
          resourceName: 'Video',
          resourceType: 'video',
        );

        expect(completed1 == completed2, true);
        expect(completed1 == completed3, false);
        expect(completed1.hashCode == completed2.hashCode, true);
      });
    });

    group('Semester Tests', () {
      test('should create semester with valid data', () {
        final progressNotifier = ValueNotifier<double>(0.5);
        const instructor = Instructor(
          name: 'John Doe',
          image: 'image.jpg',
          bio: 'Bio',
          id: 'instructor_1',
          gpa: 3.5,
          rating: 4.0,
          hours: 120,
        );

        final subject = Subject(
          courseId: 'course_1',
          courseCategory: 'Programming',
          title: 'Computer Science',
          description: 'Introduction to Computer Science',
          icon: Icons.computer,
          progress: progressNotifier,
          image: 'course_image.jpg',
          units: [],
          instructor: [instructor],
          rating: 4.5,
          reviews: [],
        );

        final semester = Semester(
          semester: 'Fall 2024',
          courses: {'Programming': [subject]},
          completed: [],
        );

        expect(semester.semester, 'Fall 2024');
        expect(semester.courses.containsKey('Programming'), true);
        expect(semester.courses['Programming']?.length, 1);
        expect(semester.completed.isEmpty, true);
      });

      test('should handle semester with empty courses', () {
        final semester = Semester(
          semester: 'Empty Semester',
          courses: {},
          completed: [],
        );

        expect(semester.courses.isEmpty, true);
        expect(semester.completed.isEmpty, true);
      });
    });
  });
}