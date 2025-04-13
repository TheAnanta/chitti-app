import 'dart:math' show max, min;

import 'package:chitti/animated_image.dart';
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/important_questions.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/unit_list_tile.dart';
import 'package:chitti/unit_resource_page.dart';
import 'package:chitti/watermark_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class UnitWithResourcesAndIndex {
  final UnitWithResources unit;
  final int index;
  final String roadmapName;
  UnitWithResourcesAndIndex(this.unit, this.index, this.roadmapName);
}

class UnitResourcePageExtended extends StatefulWidget {
  final Subject subject;
  final String courseId;
  final String subjectName;
  final String subjectCoverImage;
  const UnitResourcePageExtended({
    super.key,
    required this.subjectName,
    required this.subjectCoverImage,
    required this.courseId,
    required this.subject,
  });

  @override
  State<UnitResourcePageExtended> createState() =>
      _UnitResourcePageExtendedState();
}

class _UnitResourcePageExtendedState extends State<UnitResourcePageExtended>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  // Use ValueNotifier to hold and notify about scroll offset changes
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );

  final ValueNotifier<UnitWithResourcesAndIndex?> _unit = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    // _unit.value = UnitWithResourcesAndIndex(
    //   widget.initialUnit,
    //   widget.initialUnitIndex,
    // );
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(
      onAttach: (scrollPosition) {
        _scrollController.addListener(() {
          double _newScrollOffset = max(0, min(_scrollController.offset, 134));
          if (_scrollOffsetNotifier.value != _newScrollOffset) {
            _scrollOffsetNotifier.value = _newScrollOffset;
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollOffsetNotifier.value = max(
            0,
            min(_scrollController.offset, 134),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollOffsetNotifier.dispose(); // Dispose the ValueNotifier
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              ClipRect(
                child: Stack(
                  children: [
                    Image.network(
                      widget.subjectCoverImage,
                      height: 208,
                      width: double.infinity,
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      height: 184,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _scrollOffsetNotifier,
                      builder: (context, _scrollOffset, _) {
                        return Opacity(
                          opacity: _scrollOffset / 134,
                          child: Container(
                            margin: EdgeInsets.only(top: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            height: 184,
                          ),
                        );
                      },
                    ),
                    AppBar(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      title: Text(
                        "CHITTI.",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            );
                          },
                          icon: ClipOval(
                            child: CircleAvatar(
                              child: Image.network(
                                "https://doeresults.gitam.edu/photo/img.aspx?id=${FirebaseAuth.instance.currentUser!.uid}",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 208,
                      child: Column(
                        children: [
                          Spacer(),
                          ValueListenableBuilder(
                            valueListenable: _unit,
                            builder: (context, _unitWithValue, _) {
                              final unit = _unitWithValue?.unit;
                              final unitIndex = _unitWithValue?.index;
                              if (unit == null) {
                                return SizedBox();
                              }
                              return ValueListenableBuilder(
                                valueListenable: _scrollOffsetNotifier,
                                builder: (context, _scrollOffset, _) {
                                  return Opacity(
                                    opacity: (_scrollOffset / 134),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilters.matrix(
                                        brightness: _scrollOffset * 5 / 134,
                                      ),
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          134 - ((-_scrollOffset / 134) * -134),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            16.0,
                                          ).copyWith(top: 32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "UNIT $unitIndex",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black38,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                unit.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                    ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: UnitListTile(
                            units: widget.subject.units,
                            subjectName: widget.subject.title,
                            subjectId: widget.subject.courseId,
                            subjectCoverImage: widget.subject.image,
                            courseId: widget.subject.courseId,
                            onUnitTap: (
                              selectedUnit,
                              roadmapId,
                              roadmapName,
                            ) async {
                              _unit.value = null;
                              //TODO: roadmapItems and expansiontile
                              final newUnit = await Injector.unitRepository
                                  .fetchUnit(
                                    context,
                                    widget.courseId,
                                    selectedUnit,
                                    roadmapId,
                                  );
                              _unit.value = UnitWithResourcesAndIndex(
                                newUnit,
                                widget.subject.units.indexOf(selectedUnit) + 1,
                                roadmapName,
                              );
                              _tabController.animateTo(0);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(),
                    ValueListenableBuilder(
                      valueListenable: _unit,
                      builder: (context, _unitWithIndex, _) {
                        final unit = _unitWithIndex?.unit;
                        final unitIndex = _unitWithIndex?.index;
                        if (unit == null) {
                          return Expanded(
                            flex: 2,
                            child: Center(child: Text("No unit selected.")),
                          );
                        }
                        return Expanded(
                          flex: 2,
                          child: NestedScrollView(
                            controller: _scrollController,
                            headerSliverBuilder: (context, innerBoxIsScrolled) {
                              return [
                                SliverAppBar(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.white,
                                  expandedHeight:
                                      242 -
                                      ((AppBar().preferredSize.height +
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.top +
                                                  MediaQuery.of(
                                                    context,
                                                  ).padding.bottom) >
                                              100
                                          ? 54
                                          : 0),
                                  toolbarHeight: 0,
                                  collapsedHeight: 8,
                                  floating: true,
                                  pinned: true,
                                  flexibleSpace: ValueListenableBuilder(
                                    valueListenable: _scrollOffsetNotifier,
                                    builder: (context, _scrollOffset, _) {
                                      return Wrap(
                                        clipBehavior: Clip.antiAlias,
                                        children: [
                                          ColorFiltered(
                                            colorFilter: ColorFilters.matrix(
                                              brightness:
                                                  _scrollOffset * 5 / 134,
                                            ),
                                            child: Transform.translate(
                                              offset: Offset(0, -_scrollOffset),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ).copyWith(top: 32),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      unit.name.toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black38,
                                                            fontSize: 16,
                                                          ),
                                                    ),
                                                    Text(
                                                      _unitWithIndex
                                                              ?.roadmapName ??
                                                          "Roadmap Name",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 22,
                                                          ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "${unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                                                    ),
                                                    SizedBox(height: 8),
                                                    Opacity(
                                                      opacity:
                                                          1 -
                                                          (_scrollOffset / 134),
                                                      child: Text(
                                                        unit.description,
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  bottom: PreferredSize(
                                    preferredSize: Size.fromHeight(
                                      kTextTabBarHeight,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 8),
                                      color: Colors.white,
                                      child: TabBar(
                                        isScrollable: true,
                                        controller: _tabController,
                                        tabs: [
                                          Tab(text: "Videos"),
                                          Tab(text: "Notes"),
                                          Tab(text: "Cheatsheets"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ];
                            },
                            body: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildVideoView(unit.videos, widget.courseId),
                                  _buildNotesView(unit.notes, widget.courseId),
                                  _buildCheatsheetView(
                                    unit.cheatsheets,
                                    widget.courseId,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesView(List<Notes>? notes, String courseId) {
    return notes == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : notes.isEmpty
        ? Center(child: Text("No notes available."))
        : ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          itemBuilder: (context, index) {
            final notesItem = notes[index];
            return ListTile(
              onTap: () {
                addCompletedResource(
                  context,
                  CompletedResources(
                    courseId: courseId,
                    resourceId: notesItem.id,
                    resourceName: notesItem.name,
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          appBar: AppBar(title: Text(notesItem.name)),
                          body: Center(
                            child: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: Builder(
                                builder: (context) {
                                  final viewController = PdfViewerController();
                                  if (viewController.isReady) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!notesItem.url.endsWith(".pdf")) {
                                    return Center(
                                      child: Text("Invalid resource."),
                                    );
                                  }
                                  return PdfViewer.uri(
                                    Uri.tryParse(notesItem.url) ??
                                        Uri.parse(
                                          "https://pdfobject.com/pdf/sample.pdf",
                                        ),
                                    controller: viewController,
                                    params: PdfViewerParams(
                                      enableTextSelection: false,
                                      loadingBannerBuilder: (
                                        context,
                                        bytesDownloaded,
                                        totalBytes,
                                      ) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                  ),
                );
              },
              title: Text(
                notesItem.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right_outlined),
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: notes.length,
          shrinkWrap: true,
        );
  }

  Widget _buildVideoView(List<Video>? videos, String courseId) {
    return videos == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : videos.isEmpty
        ? Center(child: Text("No videos available."))
        : GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        videos[index].thumbnail,
                        height: 116,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => VideoPlayerWidget(
                                        video: videos[index],
                                        onPlayedVideo: () {
                                          Navigator.of(context).pop();
                                          addCompletedResource(
                                            context,
                                            CompletedResources(
                                              courseId: courseId,
                                              resourceId: videos[index].id,
                                              resourceName: videos[index].name,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                            child:
                                (Injector.semesterRepository.semester?.completed
                                            .contains(
                                              CompletedResources(
                                                courseId: widget.courseId,
                                                resourceId: videos[index].id,
                                                resourceName:
                                                    videos[index].name,
                                              ),
                                            ) ??
                                        false)
                                    ? Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        "Watched",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : Center(
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  videos[index].name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   "Compiler design is a complex process that involves multiple stages and requires a deep understanding of both the programming language and the target platform.",
                //   maxLines: 2,
                //   style: Theme.of(context).textTheme.bodySmall,
                // ),
              ],
            );
          },
          itemCount: videos.length,
          shrinkWrap: true,
        );
  }

  Widget _buildRoadmapView(Roadmap? roadmap) {
    return roadmap == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : roadmap.roadmapItems.isEmpty
        ? Center(child: Text("No roadmap available."))
        : ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          itemBuilder: (context, index) {
            final roadmapItem = roadmap.roadmapItems[index];
            return ListTile(
              title: Text(
                roadmapItem.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Text(roadmapItem.difficulty),
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: roadmap.roadmapItems.length,
          shrinkWrap: true,
        );
  }

  Widget _buildCheatsheetView(List<Cheatsheet>? cheatsheets, String courseId) {
    return cheatsheets == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : cheatsheets.isEmpty
        ? Center(child: Text("No cheatsheets available."))
        : ListView.separated(
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            final cheatsheet = cheatsheets[index];
            var showCheatsheet = false;
            return StatefulBuilder(
              key: ValueKey(cheatsheet.name),
              builder: (context, setTileState) {
                return InkWell(
                  onTap: () {
                    if (!showCheatsheet) {
                      addCompletedResource(
                        context,
                        CompletedResources(
                          courseId: courseId,
                          resourceId: cheatsheet.id,
                          resourceName: cheatsheet.name,
                        ),
                      );
                    }
                    showCheatsheet = !showCheatsheet;
                    setTileState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cheatsheet.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 24),
                            AnimatedRotation(
                              turns: showCheatsheet ? 0.25 : 0,
                              duration: Duration(milliseconds: 500),
                              child: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          child:
                              showCheatsheet
                                  ? Image.network(cheatsheet.url)
                                  : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: cheatsheets.length,
          shrinkWrap: true,
        );
  }

  // Widget _buildIQView(List<ImportantQuestion>? iqs, String courseId) {
  //   return iqs == null
  //       ? Center(child: Text("You haven't purchased a valid subscription."))
  //       : iqs.isEmpty
  //       ? Center(child: Text("No important questions available."))
  //       : ListView.separated(
  //         padding: EdgeInsets.all(0),
  //         itemBuilder: (context, index) {
  //           final iq = iqs[index];
  //           var showAnswer = false;
  //           return StatefulBuilder(
  //             builder: (context, setTileState) {
  //               return InkWell(
  //                 onTap: () {
  //                   if (!showAnswer) {
  //                     addCompletedResource(
  //                       context,
  //                       CompletedResources(
  //                         courseId: courseId,
  //                         resourceId: iq.id,
  //                         resourceName: iq.question,
  //                       ),
  //                     );
  //                   }
  //                   showAnswer = !showAnswer;
  //                   setTileState(() {});
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Opacity(
  //                         opacity: 0.5,
  //                         child: Text(
  //                           iq.tag.toUpperCase(),
  //                           style: Theme.of(context).textTheme.bodySmall
  //                               ?.copyWith(fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                       SizedBox(height: 4),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               iq.question,
  //                               style: Theme.of(context).textTheme.bodyLarge
  //                                   ?.copyWith(fontWeight: FontWeight.w600),
  //                             ),
  //                           ),
  //                           SizedBox(width: 24),
  //                           AnimatedRotation(
  //                             turns: showAnswer ? 0.25 : 0,
  //                             duration: Duration(milliseconds: 500),
  //                             child: Icon(Icons.chevron_right),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 8),
  //                       AnimatedContainer(
  //                         duration: Duration(milliseconds: 500),
  //                         child: showAnswer ? Text(iq.answer) : SizedBox(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         separatorBuilder: (_, __) => Divider(),
  //         itemCount: iqs.length,
  //         shrinkWrap: true,
  //       );
  // }
}
