import '../../courses/models/course_section.dart';
import '../../profile/models/app_profile.dart';

class ProfessorWithCourses {
  const ProfessorWithCourses({
    required this.professor,
    required this.sections,
  });

  final AppProfile professor;
  final List<CourseSection> sections;
}
