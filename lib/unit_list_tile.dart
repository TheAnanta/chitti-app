import 'package:chitti/animated_image.dart';
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/unit_resource_page.dart';
import 'package:flutter/material.dart';

class UnitListTile extends StatelessWidget {
  const UnitListTile({
    super.key,
    required this.units,
    required this.subjectName,
    required this.subjectId,
    required this.subjectCoverImage,
    required this.courseId,
    this.onUnitTap,
  });
  final String subjectName;
  final String subjectId;
  final String courseId;
  final List<Unit> units;
  final String subjectCoverImage;
  final Function(Unit)? onUnitTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Units",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          separatorBuilder: (_, __) {
            return Divider();
          },
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () async {
                if (units[index].isUnlocked) {
                  final selectedUnit = units[index];
                  if (onUnitTap != null) {
                    onUnitTap!(selectedUnit);
                    return;
                  }
                  // Fetch all the data

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return FutureBuilder(
                          future: Injector.unitRepository.fetchUnit(
                            context,
                            subjectId,
                            selectedUnit,
                          ),
                          builder: (context, futureValue) {
                            if (futureValue.hasData) {
                              final unit = futureValue.data!;
                              return UnitResourcePage(
                                unit: unit,
                                subjectName: subjectName,
                                unitIndex: index + 1,
                                subjectCoverImage: subjectCoverImage,
                                courseId: courseId,
                              );
                            }
                            return Scaffold(
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 128),
                                    CircularProgressIndicator(
                                      color: Colors.grey.shade800,
                                    ),
                                    SizedBox(height: 24),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedImageEntry(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Transform.flip(
                                              flipX: true,
                                              child: Transform.translate(
                                                offset: Offset(0, 48),
                                                child: ColorFiltered(
                                                  colorFilter:
                                                      ColorFilters.matrix(
                                                        saturation: -1,
                                                        brightness: 0.5,
                                                      ),
                                                  child: Image.asset(
                                                    "assets/images/ghost_blue.png",
                                                    height: 180,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              width: 264,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey.shade400,
                                              ),
                                              child: Opacity(
                                                opacity: 0.6,
                                                child: Text(
                                                  "Go grab a break while we sneak into the server.",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheet(
                        onClosing: () {
                          Navigator.of(context).pop();
                        },
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Subscribe",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Choose from a wide range of plans that we offer.",
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Opacity(
                                              opacity: 0.6,
                                              child: Text(
                                                "₹",
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "20",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(height: 1),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text("Notes"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Opacity(
                                              opacity: 0.6,
                                              child: Text(
                                                "₹",
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "70",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(height: 1),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text("Videos"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Opacity(
                                              opacity: 0.6,
                                              child: Text(
                                                "₹",
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "120",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(height: 1),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text("All Access"),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {},
                                  child: Text("Pay Now"),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
              title: Text(
                "${index + 1}. ${units[index].name}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                units[index].isUnlocked
                    ? Icons.chevron_right_outlined
                    : Icons.lock_outline,
              ),
            );
          },
          itemCount: units.length,
          shrinkWrap: true,
        ),
      ],
    );
  }
}
