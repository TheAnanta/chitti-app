import 'dart:math' show max, min;
import 'package:chitti/color_filters.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_resources.dart';
import 'package:chitti/injector.dart';
import 'package:chitti/pdf_doc/pdf_main.dart';
import 'package:chitti/profile_page.dart';
import 'package:chitti/watermark_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:video_player/video_player.dart';

class UnitResourcePage extends StatefulWidget {
  final UnitWithResources unit;
  final String courseId;
  final String subjectName;
  final int unitIndex;
  final String subjectCoverImage;
  final String roadmapName;

  const UnitResourcePage({
    super.key,
    required this.unit,
    required this.subjectName,
    required this.unitIndex,
    required this.subjectCoverImage,
    required this.courseId,
    required this.roadmapName,
  });

  @override
  State<UnitResourcePage> createState() => _UnitResourcePageState();
}

class _UnitResourcePageState extends State<UnitResourcePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  // Use ValueNotifier to hold and notify about scroll offset changes
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          backgroundColor:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                  foregroundColor: Colors.white,
                  expandedHeight:
                      500 -
                      ((AppBar().preferredSize.height +
                                  MediaQuery.of(context).padding.top +
                                  MediaQuery.of(context).padding.bottom) >
                              100
                          ? 54
                          : 0),
                  collapsedHeight:
                      266 -
                      ((AppBar().preferredSize.height +
                                  MediaQuery.of(context).padding.top +
                                  MediaQuery.of(context).padding.bottom) >
                              100
                          ? 54
                          : 0),
                  floating: true,
                  pinned: true,
                  flexibleSpace: ValueListenableBuilder(
                    valueListenable: _scrollOffsetNotifier,
                    builder: (context, _scrollOffset, _) {
                      return Wrap(
                        clipBehavior: Clip.antiAlias,
                        children: [
                          Stack(
                            children: [
                              ColorFiltered(
                                colorFilter:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const ColorFilter.matrix(<double>[
                                          -1.0, 0.0, 0.0, 0.0, 255.0, //
                                          0.0, -1.0, 0.0, 0.0, 255.0, //
                                          0.0, 0.0, -1.0, 0.0, 255.0, //
                                          0.0, 0.0, 0.0, 1.0, 0.0, //
                                        ])
                                        : const ColorFilter.matrix(<double>[
                                          1.0, 0.0, 0.0, 0.0, 0.0, //
                                          0.0, 1.0, 0.0, 0.0, 0.0, //
                                          0.0, 0.0, 1.0, 0.0, 0.0, //
                                          0.0, 0.0, 0.0, 1.0, 0.0, //
                                        ]),
                                child: Image.network(
                                  widget.subjectCoverImage,
                                  height: 258,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ),
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
                                height: 234,
                              ),
                              Opacity(
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
                                  height: 234,
                                ),
                              ),
                              AppBar(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                title: Text(
                                  "CHITTI.",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
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
                            ],
                          ),
                          ColorFiltered(
                            colorFilter: ColorFilters.matrix(
                              brightness: _scrollOffset * 5 / 134,
                            ),
                            child: Transform.translate(
                              offset: Offset(0, -_scrollOffset),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  16.0,
                                ).copyWith(top: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.unit.name.toUpperCase(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black38,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      widget.roadmapName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${widget.unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                                    ),
                                    SizedBox(height: 8),
                                    Opacity(
                                      opacity: 1 - (_scrollOffset / 134),
                                      child: Text(
                                        widget.unit.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontSize: 14),
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
                    preferredSize: Size.fromHeight(kTextTabBarHeight),
                    child: Container(
                      padding: EdgeInsets.only(top: 8),
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      child: TabBar(
                        // isScrollable: true,
                        controller: _tabController,
                        tabs: [
                          // Tab(text: "Roadmap"),
                          Tab(text: "Videos"),
                          Tab(text: "Notes"),
                          // Tab(text: "Cheatsheets"),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: WatermarkWidget(
              text: FirebaseAuth.instance.currentUser?.uid ?? "Anonymous",
              opacity: 0.05,
              fontSize: 18,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // _buildRoadmapView(widget.unit.roadmap),
                  _buildVideoView(widget.unit.videos, widget.courseId),
                  _buildNotesView(widget.unit.notes, widget.courseId),
                  // _buildCheatsheetView(
                  //   widget.unit.cheatsheets,
                  //   widget.courseId,
                  // ),
                ],
              ),
            ),
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
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          itemBuilder: (context, index) {
            final notesItem = notes[index];
            return ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          body: Center(
                            child: WatermarkWidget(
                              text:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  "Anonymous",
                              opacity: 0.05,
                              fontSize: 18,
                              child: Builder(
                                builder: (context) {
                                  final uri =
                                      Uri.tryParse(notesItem.url) ??
                                      Uri.parse(
                                        "https://pdfobject.com/pdf/sample.pdf",
                                      );
                                  final pdfDocumentRef = PdfDocumentRefUri(uri);
                                  return PDFViewPage(
                                    documentRef: pdfDocumentRef,
                                    pdfName: notesItem.name,
                                    onAddResource: () {
                                      addCompletedResource(
                                        context,
                                        CompletedResources(
                                          courseId: courseId,
                                          resourceId: notesItem.id,
                                          resourceName: notesItem.name,
                                          unitId: widget.unit.unitId,
                                          resourceType: "notes",
                                        ),
                                      );
                                    },
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
                      VideoThumbnailWidget(
                        url: videos[index].thumbnail,
                        index: index,
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
                                          print("Hello World");
                                          // Navigator.of(context).pop();
                                          addCompletedResource(
                                            context,
                                            CompletedResources(
                                              courseId: courseId,
                                              resourceId: videos[index].id,
                                              resourceName: videos[index].name,
                                              unitId: widget.unit.unitId,
                                              resourceType: "video",
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
                                                unitId: widget.unit.unitId,
                                                resourceType: "video",
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
                //   // videos[index].,
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
                    if (cheatsheet.url.contains(".pdf")) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => Scaffold(
                                body: Center(
                                  child: WatermarkWidget(
                                    text:
                                        FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid ??
                                        "Anonymous",
                                    opacity: 0.05,
                                    fontSize: 18,
                                    child: Builder(
                                      builder: (context) {
                                        final uri =
                                            Uri.tryParse(cheatsheet.url) ??
                                            Uri.parse(
                                              "https://pdfobject.com/pdf/sample.pdf",
                                            );
                                        final pdfDocumentRef =
                                            PdfDocumentRefUri(uri);
                                        return PDFViewPage(
                                          documentRef: pdfDocumentRef,
                                          pdfName: cheatsheet.name,
                                          onAddResource: () {
                                            addCompletedResource(
                                              context,
                                              CompletedResources(
                                                courseId: courseId,
                                                resourceId: cheatsheet.id,
                                                resourceName: cheatsheet.name,
                                                unitId: widget.unit.unitId,
                                                resourceType: "cheatsheet",
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                      return;
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

  //   Widget _buildIQView(List<ImportantQuestion>? iqs, String courseId) {
  //     return iqs == null
  //         ? Center(child: Text("You haven't purchased a valid subscription."))
  //         : iqs.isEmpty
  //         ? Center(child: Text("No important questions available."))
  //         : ListView.separated(
  //           padding: EdgeInsets.all(0),
  //           itemBuilder: (context, index) {
  //             final iq = iqs[index];
  //             var showAnswer = false;
  //             return StatefulBuilder(
  //               builder: (context, setTileState) {
  //                 return InkWell(
  //                   onTap: () {
  //                     if (!showAnswer) {
  //                       addCompletedResource(
  //                         context,
  //                         CompletedResources(
  //                           courseId: courseId,
  //                           resourceId: iq.id,
  //                           resourceName: iq.question,
  //                         ),
  //                       );
  //                     }
  //                     showAnswer = !showAnswer;
  //                     setTileState(() {});
  //                   },
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Opacity(
  //                           opacity: 0.5,
  //                           child: Text(
  //                             iq.tag.toUpperCase(),
  //                             style: Theme.of(context).textTheme.bodySmall
  //                                 ?.copyWith(fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         SizedBox(height: 4),
  //                         Row(
  //                           children: [
  //                             Expanded(
  //                               child: Text(
  //                                 iq.question,
  //                                 style: Theme.of(context).textTheme.bodyLarge
  //                                     ?.copyWith(fontWeight: FontWeight.w600),
  //                               ),
  //                             ),
  //                             SizedBox(width: 24),
  //                             AnimatedRotation(
  //                               turns: showAnswer ? 0.25 : 0,
  //                               duration: Duration(milliseconds: 500),
  //                               child: Icon(Icons.chevron_right),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(height: 8),
  //                         AnimatedContainer(
  //                           duration: Duration(milliseconds: 500),
  //                           child: showAnswer ? (Text(iq.answer)) : SizedBox(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //           separatorBuilder: (_, __) => Divider(),
  //           itemCount: iqs.length,
  //           shrinkWrap: true,
  //         );
  //   }
}

class VideoThumbnailWidget extends StatelessWidget {
  final String url;
  final int index;
  const VideoThumbnailWidget({
    super.key,
    required this.url,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          "https://firebasestorage.googleapis.com/v0/b/chitti-ananta.firebasestorage.app/o/thumbnails%2FTHUMBNAIL-CHITTI.jpg?alt=media&token=39150028-303b-4d33-ae92-f791a90eaa4f",
          height: 116,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.4),
          width: double.infinity,
          height: 116,
          // alignment: Alignment.center,
          // child: Text(
          //   "CHITTI.",
          //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //     fontWeight: FontWeight.w800,
          //     color: Color(0xFFFFBD59),
          //     fontSize: 30,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8),
              child: Text((index + 1).toString()),
            ),
          ),
        ),
      ],
    );
  }
}

// class IQAnswerWidget extends StatelessWidget {
//   const IQAnswerWidget({super.key, required this.iq});

//   final ImportantQuestion iq;

//   @override
//   Widget build(BuildContext context) {
//     final answer = iq.answer;
//     final regex = RegExp(
//       r"^(.*?)\s*\[(https?:\/\/[^\s\]]+)\].*?\)\s*(.*?)$",
//       multiLine: true,
//     );
//     final matches = regex.allMatches(answer);

//     List<Map<String, String>> extractedData = [];

//     for (final match in matches) {
//       extractedData.add({
//         "textBefore": match.group(1) ?? "",
//         "url": match.group(2) ?? "",
//         "textAfter": match.group(3) ?? "",
//       });
//     }
//     print(extractedData);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: extractedData
//           .map((e) {
//             return [
//               ...(e["textBefore"] == ""
//                   ? [SizedBox()]
//                   : [
//                     Text(
//                       e["textBefore"] ?? "",
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodyMedium?.copyWith(fontSize: 14),
//                     ),
//                     SizedBox(height: 4),
//                   ]),
//               Image.network(
//                 e["url"] ?? "",
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               SizedBox(height: 4),
//               Text(
//                 e["textAfter"] ?? "",
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyMedium?.copyWith(fontSize: 14),
//               ),
//               SizedBox(height: 4),
//             ];
//           })
//           .reduce((value, element) {
//             return [...value, ...element];
//           }),
//     );
//   }
// }

class VideoPlayerWidget extends StatefulWidget {
  final Video video;
  final onPlayedVideo;
  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.onPlayedVideo,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  ValueNotifier<bool> isVolumeOn = ValueNotifier<bool>(
    true,
  ); // Use ValueNotifier to hold volume state
  // valuenotifiers for 2x, normal and 1x
  ValueNotifier<double> currentSpeed = ValueNotifier<double>(1);
  // show appbar or not
  ValueNotifier<bool> showAppBar = ValueNotifier<bool>(true);
  ValueNotifier<bool> showControls = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isCompletedPlaying = ValueNotifier<bool>(false);

  ValueNotifier<double> zoomScale = ValueNotifier<double>(1.0);
  ValueNotifier<Offset> panOffset = ValueNotifier<Offset>(Offset(0, 0));
  ValueNotifier<bool> calledOnSubmitProgress = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url));

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.addListener(() {
      if (_controller.value.position >=
              _controller.value.duration - Duration(seconds: 5) &&
          !calledOnSubmitProgress.value) {
        widget.onPlayedVideo();
      }
      if (_controller.value.isCompleted) {
        _isCompletedPlaying.value = true;
      }
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();

    super.dispose();
  }

  var jumpGestureOverlays = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            WatermarkWidget(
              text: FirebaseAuth.instance.currentUser?.uid ?? "Anonymous",
              opacity: 0.05,
              fontSize: 18,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // _controller.play();
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: GestureDetector(
                                    onDoubleTapDown: (details) {
                                      if (details.localPosition.dx >
                                          _controller.value.size.width *
                                              2 /
                                              3) {
                                        _controller.seekTo(
                                          _controller.value.position +
                                              Duration(seconds: 10),
                                        );
                                        if (jumpGestureOverlays.isNotEmpty) {
                                          jumpGestureOverlays.clear();
                                        }
                                        jumpGestureOverlays.add(
                                          IgnorePointer(
                                            child: Transform.translate(
                                              offset: Offset(
                                                _controller.value.size.width /
                                                    4,
                                                0,
                                              ),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Container(
                                                  width: 1080,
                                                  height: 1080,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                        .withValues(alpha: 0.3),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.only(
                                                    left: 36,
                                                    right: 36,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .fast_forward,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .surface,
                                                              size: 32,
                                                            ),
                                                            Text(
                                                              "10 seconds",
                                                              style: Theme.of(
                                                                    context,
                                                                  )
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).colorScheme.surface,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          Future.delayed(
                                            Duration(milliseconds: 400),
                                            () {
                                              jumpGestureOverlays.clear();
                                              setState(() {});
                                            },
                                          );
                                        });
                                      } else if (details.localPosition.dx <
                                          _controller.value.size.width / 3) {
                                        _controller.seekTo(
                                          _controller.value.position -
                                              Duration(seconds: 10),
                                        );
                                        if (jumpGestureOverlays.isNotEmpty) {
                                          jumpGestureOverlays.clear();
                                        }
                                        jumpGestureOverlays.add(
                                          IgnorePointer(
                                            child: Transform.translate(
                                              offset: Offset(
                                                -_controller.value.size.width /
                                                    4,
                                                0,
                                              ),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Container(
                                                  width: 1080,
                                                  height: 1080,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                        .withValues(alpha: 0.3),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.only(
                                                    left: 36,
                                                    right: 36,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Row(
                                                      children: [
                                                        Spacer(),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.fast_rewind,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .surface,
                                                              size: 32,
                                                            ),
                                                            Text(
                                                              "10 seconds",
                                                              style: Theme.of(
                                                                    context,
                                                                  )
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).colorScheme.surface,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          Future.delayed(
                                            Duration(milliseconds: 400),
                                            () {
                                              jumpGestureOverlays.clear();
                                              setState(() {});
                                            },
                                          );
                                        });
                                      }
                                    },
                                    onScaleUpdate: (details) {
                                      if (details.scale < 1) {
                                        zoomScale.value = 1;
                                      } else {
                                        zoomScale.value = details.scale;
                                      }
                                    },
                                    // onPanUpdate: (details) {
                                    //   panOffset.value = Offset(
                                    //     panOffset.value.dx + details.delta.dx,
                                    //     panOffset.value.dy + details.delta.dy,
                                    //   );
                                    // },
                                    child: InkWell(
                                      onTap: () {
                                        showAppBar.value = !showAppBar.value;
                                        showControls.value =
                                            !showControls.value;
                                      },
                                      child: ValueListenableBuilder<double>(
                                        valueListenable: zoomScale,
                                        builder: (context, _zoomScale, child) {
                                          return Transform.scale(
                                            scale: _zoomScale,
                                            child: VideoPlayer(_controller),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        ValueListenableBuilder<bool>(
                          valueListenable: showAppBar,
                          builder: (context, showControlsValue, child) {
                            return AnimatedOpacity(
                              opacity: showControlsValue ? 1 : 0,
                              duration: Duration(milliseconds: 500),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.75),
                                      Colors.black.withValues(alpha: 0),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      //Add minus10 plus10 and seekbar
                                      IconButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          _controller.seekTo(
                                            _controller.value.position -
                                                Duration(seconds: 10),
                                          );
                                        },
                                        icon: Icon(Icons.replay_10),
                                      ),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: _isCompletedPlaying,
                                        builder: (
                                          context,
                                          isCompletedPlaying,
                                          child,
                                        ) {
                                          return IconButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              if (isCompletedPlaying) {
                                                _controller.play();
                                                setState(() {});
                                                return;
                                              }
                                              // Wrap the play or pause in a call to `setState`. This ensures the
                                              // correct icon is shown.
                                              setState(() {
                                                // If the video is playing, pause it.
                                                if (_controller
                                                    .value
                                                    .isPlaying) {
                                                  _controller.pause();
                                                  showAppBar.value = true;
                                                  showControls.value = true;
                                                } else {
                                                  // If the video is paused, play it.
                                                  _controller.play();
                                                  // Hide the app bar after 3 seconds
                                                  Future.delayed(
                                                    Duration(seconds: 3),
                                                    () {
                                                      showAppBar.value = false;
                                                      showControls.value =
                                                          false;
                                                    },
                                                  );
                                                }
                                              });
                                            },
                                            // Display the correct icon depending on the state of the player.
                                            icon: Icon(
                                              isCompletedPlaying
                                                  ? Icons.replay
                                                  : _controller.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                            ),
                                          );
                                        },
                                      ),

                                      Expanded(
                                        child: VideoProgressIndicator(
                                          _controller,
                                          allowScrubbing: true,
                                          padding: EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          _controller.seekTo(
                                            _controller.value.position +
                                                Duration(seconds: 10),
                                          );
                                        },
                                        icon: Icon(Icons.forward_10),
                                      ),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: isVolumeOn,
                                        builder: (context, _isVolumeOn, child) {
                                          return IconButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              _controller.setVolume(
                                                _controller.value.volume == 0
                                                    ? 1
                                                    : 0,
                                              );
                                              isVolumeOn.value =
                                                  !isVolumeOn.value;
                                            },
                                            icon: Icon(
                                              !_isVolumeOn
                                                  ? Icons.volume_off
                                                  : Icons.volume_up,
                                            ),
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder<double>(
                                        valueListenable: currentSpeed,
                                        builder: (context, _speed, child) {
                                          return IconButton(
                                            color:
                                                _speed == 0.5
                                                    ? Colors.amber
                                                    : Colors.white,
                                            onPressed: () {
                                              _controller.setPlaybackSpeed(0.5);
                                              currentSpeed.value = 0.5;
                                            },
                                            icon: Icon(
                                              Icons.slow_motion_video_outlined,
                                            ),
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder<double>(
                                        valueListenable: currentSpeed,
                                        builder: (context, _speed, child) {
                                          return IconButton(
                                            color:
                                                _speed == 1.0
                                                    ? Colors.amber
                                                    : Colors.white,
                                            onPressed: () {
                                              _controller.setPlaybackSpeed(1);
                                              currentSpeed.value = 1.0;
                                            },
                                            icon: Text(
                                              "1X",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color:
                                                    _speed == 1.0
                                                        ? Colors.amber
                                                        : Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder<double>(
                                        valueListenable: currentSpeed,
                                        builder: (context, _speed, child) {
                                          return IconButton(
                                            color:
                                                _speed == 2.0
                                                    ? Colors.amber
                                                    : Colors.white,
                                            onPressed: () {
                                              _controller.setPlaybackSpeed(2.0);
                                              currentSpeed.value = 2.0;
                                            },
                                            icon: Icon(
                                              Icons.rocket_launch_outlined,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          child:
                              jumpGestureOverlays.isNotEmpty
                                  ? jumpGestureOverlays[0]
                                  : SizedBox(),
                        ),
                      ],
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            // AppBar with fade-in effect
            ValueListenableBuilder(
              valueListenable: showAppBar,
              builder: (context, showAppBarValue, child) {
                return AnimatedOpacity(
                  opacity: showAppBarValue ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isCompletedPlaying,
                          builder: (context, isCompletedPlaying, child) {
                            return IconButton(
                              color: Colors.white,
                              iconSize: 48,
                              padding: EdgeInsets.all(16),
                              onPressed: () {
                                if (isCompletedPlaying) {
                                  _controller.play();
                                  setState(() {});
                                  return;
                                }
                                // Wrap the play or pause in a call to `setState`. This ensures the
                                // correct icon is shown.
                                setState(() {
                                  // If the video is playing, pause it.
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                    showAppBar.value = true;
                                    showControls.value = true;
                                  } else {
                                    // If the video is paused, play it.
                                    _controller.play();
                                    // Hide the app bar after 3 seconds
                                    Future.delayed(Duration(seconds: 3), () {
                                      showAppBar.value = false;
                                      showControls.value = false;
                                    });
                                  }
                                });
                              },
                              // Display the correct icon depending on the state of the player.
                              icon: Icon(
                                isCompletedPlaying
                                    ? Icons.replay
                                    : _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: showAppBar,
              builder: (context, showAppBarValue, child) {
                return AnimatedOpacity(
                  opacity: showAppBarValue ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 24),
                        height: kToolbarHeight * 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: AppBar(
                          automaticallyImplyLeading: false,
                          leading: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.chevron_left),
                          ),
                          foregroundColor: Colors.white,
                          title: Text(widget.video.name),
                          backgroundColor: Colors.transparent,
                          toolbarHeight: kToolbarHeight,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
