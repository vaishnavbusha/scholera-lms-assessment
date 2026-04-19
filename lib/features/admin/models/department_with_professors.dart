import '../../profile/models/app_profile.dart';
import 'department.dart';

class DepartmentWithProfessors {
  const DepartmentWithProfessors({
    required this.department,
    required this.professors,
  });

  final Department department;
  final List<AppProfile> professors;
}
