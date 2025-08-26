import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_cart.dart';
import 'package:chitti/domain/fetch_semester.dart' as fs;
import 'package:flutter/cupertino.dart';

class SemesterRepository {
  Semester? semester;

  Future<Semester> fetchSemester(
    BuildContext context,
    String token,
    Function onSignOut,
  ) async {
    semester = await fs.fetchSemester(context, token, onSignOut);
    await fetchCart(context);
    print(semester);
    return semester!;
  }
}
