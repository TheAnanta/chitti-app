import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_semester.dart' as fs;

class SemesterRepository {
  Semester? semester;

  Future<Semester> fetchSemester(String token) async {
    semester = await fs.fetchSemester(token);
    return semester!;
  }
}
