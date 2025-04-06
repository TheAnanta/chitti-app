import 'dart:convert';

import 'package:chitti/data/important_questions.dart';
import 'package:chitti/data/semester.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<
  (
    Roadmap?,
    List<Video>?,
    List<Notes>?,
    List<Cheatsheet>?,
  )
>
fetchResourcesForUnit(
  BuildContext context,
  String subjectId,
  String unitId,
  String roadmapId,
) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

  Map<String, dynamic>? data = await get(
    Uri.parse(
      "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/unit/$subjectId/$unitId/$roadmapId/all",
    ),
    headers: {"Authorization": "Bearer $token"},
  ).then((response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        final result = json.decode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result["message"])));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
      return null;
    }
  });

  // Map<String, dynamic>? notes = await get(
  //   Uri.parse(
  //     "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/unit/${subjectId}/${unitId}/notes",
  //   ),
  //   headers: {"Authorization": "Bearer $token"},
  // ).then((response) {
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     try {
  //       final result = json.decode(response.body);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(result["message"])));
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(e.toString())));
  //     }
  //     return null;
  //   }
  // });
  // Map<String, dynamic>? cheatsheet = await get(
  //   Uri.parse(
  //     "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/unit/${subjectId}/${unitId}/cheatsheet",
  //   ),
  //   headers: {"Authorization": "Bearer $token"},
  // ).then((response) {
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     try {
  //       final result = json.decode(response.body);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(result["message"])));
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(e.toString())));
  //     }
  //     return null;
  //   }
  // });
  // Map<String, dynamic>? roadmap = await get(
  //   Uri.parse(
  //     "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/unit/${subjectId}/${unitId}/roadmap",
  //   ),
  //   headers: {"Authorization": "Bearer $token"},
  // ).then((response) {
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     try {
  //       final result = json.decode(response.body);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(result["message"])));
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(e.toString())));
  //     }
  //     return null;
  //   }
  // });
  // Map<String, dynamic>? video = await get(
  //   Uri.parse(
  //     "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/unit/${subjectId}/${unitId}/video",
  //   ),
  //   headers: {"Authorization": "Bearer $token"},
  // ).then((response) {
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     try {
  //       final result = json.decode(response.body);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(result["message"])));
  //     } catch (e) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(e.toString())));
  //     }
  //     return null;
  //   }
  // });
  // print(roadmap);
  // return (roadmap, video, notes, cheatsheet);
  var (roadmap, videos, notes, cheatsheet) = (
    Roadmap(
      roadmapItems:
          (data?["roadmap"] as List<dynamic>? ?? []).map((e) {
            return RoadmapItem(
              name: e["name"],
              difficulty: e["difficulty"],
              id: e["roadId"],
            );
          }).toList(),
    ),
    (data?["videos"] as List<dynamic>? ?? [])
        .map(
          (e) => Video(
            name: e["name"],
            url: e["url"],
            id: e["videoId"],
            thumbnail: e["thumbnail"],
          ),
        )
        .toList(),
    (data?["notes"] as List<dynamic>? ?? [])
        .map((e) => Notes(name: e["name"], url: e["url"], id: e["notesId"]))
        .toList(),
    (data?["cheatsheets"] as List<dynamic>? ?? [])
        .map(
          (e) => Cheatsheet(name: e["name"], url: e["url"], id: e["cheatId"]),
        )
        .toList(),
  );
  //TODO: HANDLE ERRORS FROM API LIKE FORBIDDEN
  return (roadmap, videos, notes, cheatsheet);
}

Future<String> addCompletedResource(
  BuildContext context,
  CompletedResources res,
) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);

  Map<String, dynamic>? result = await post(
    Uri.parse(
      "https://asia-south1-chitti-ananta.cloudfunctions.net/webApi/add-completed",
    ),
    body: json.encode({"resourceId": res.toJson()}),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  ).then((response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        final result = json.decode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result["message"])));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
      return null;
    }
  });
  return result?["message"];
}
