import 'package:chitti/data/cart.dart';
import 'package:chitti/data/semester_repository.dart';
import 'package:chitti/data/unit_repository.dart';

class Injector {
  static UnitRepository unitRepository = UnitRepository();
  static SemesterRepository semesterRepository = SemesterRepository();
  static CartRepository cartRepository = CartRepository();
}
