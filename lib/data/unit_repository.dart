import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:flutter/material.dart';

class UnitRepository {
  Map<String, UnitWithResources> fetchedUnits = {};

  Future<UnitWithResources> fetchUnit(
    BuildContext context,
    String subjectId,
    Unit unit,
    String roadmapId,
  ) async {
    // Fetch units from API
    if (fetchedUnits.containsKey("$subjectId/${unit.unitId}/$roadmapId")) {
      return fetchedUnits["$subjectId/${unit.unitId}/$roadmapId"]!;
    }
    var (roadmap, videos, notes, cheatsheet) = await fetchResourcesForUnit(
      context,
      subjectId,
      unit.unitId,
      roadmapId,
    );
    final unitWithResources = UnitWithResources(
      unitId: unit.unitId,
      name: unit.name,
      description: unit.description,
      difficulty: unit.difficulty,
      isUnlocked: unit.isUnlocked,
      roadmap: roadmap,
      notes: notes,
      videos: videos,
    );
    fetchedUnits["$subjectId/${unit.unitId}/$roadmapId"] = unitWithResources;
    return unitWithResources;
  }
}
