import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:flutter/material.dart';

class UnitRepository {
  Map<String, UnitWithResources> fetchedUnits = {};

  Future<UnitWithResources> fetchUnit(
    BuildContext context,
    String subjectId,
    Unit unit,
  ) async {
    // Fetch units from API
    if (fetchedUnits.containsKey("$subjectId/${unit.unitId}")) {
      return fetchedUnits["$subjectId/${unit.unitId}"]!;
    }
    var (
      roadmap,
      videos,
      notes,
      cheatsheet,
      impQuestions,
    ) = await fetchResourcesForUnit(context, subjectId, unit.unitId);
    final unitWithResources = UnitWithResources(
      unitId: unit.unitId,
      name: unit.name,
      description: unit.description,
      difficulty: unit.difficulty,
      isUnlocked: unit.isUnlocked,
      importantQuestions: impQuestions,
      roadmap: roadmap,
      notes: notes,
      videos: videos,
      cheatsheets: cheatsheet,
    );
    fetchedUnits["$subjectId/${unit.unitId}"] = unitWithResources;
    return unitWithResources;
  }
}
