import 'course.dart';

/// A specific offering of a [Course] taught by a professor in a given term.
///
/// When fetched with `courses(*)` joined, [course] is populated. Repositories
/// that don't need the joined course data can leave it null.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.courseId,
    required this.professorId,
    required this.term,
    required this.sectionCode,
    this.course,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final courseJson = json['courses'] as Map<String, dynamic>?;
    return CourseSection(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      professorId: json['professor_id'] as String,
      term: json['term'] as String,
      sectionCode: json['section_code'] as String,
      course: courseJson == null ? null : Course.fromJson(courseJson),
    );
  }

  final String id;
  final String courseId;
  final String professorId;
  final String term;
  final String sectionCode;
  final Course? course;
}
