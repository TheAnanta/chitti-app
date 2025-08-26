import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'markers_view.dart';
import 'outline_view.dart';
import 'search_view.dart';
import 'thumbnails_view.dart';

class PDFViewPage extends StatefulWidget {
  final Function onAddResource;
  final PdfDocumentRef documentRef;
  final String pdfName;
  const PDFViewPage({
    super.key,
    required this.documentRef,
    required this.pdfName,
    required this.onAddResource,
  });

  @override
  State<PDFViewPage> createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> with WidgetsBindingObserver {
  final controller = PdfViewerController();
  final showLeftPane = ValueNotifier<bool>(false);
  final outline = ValueNotifier<List<PdfOutlineNode>?>(null);
  final textSearcher = ValueNotifier<PdfTextSearcher?>(null);

  final _markers = <int, List<Marker>>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_pageTracker);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    textSearcher.value?.dispose();
    textSearcher.dispose();
    showLeftPane.dispose();
    outline.dispose();
    controller.removeListener(_pageTracker);
    super.dispose();
  }

  void _pageTracker() {
    if (controller.isReady &&
        controller.pageCount > 0 &&
        controller.pageNumber == controller.pageCount) {
      widget.onAddResource();
    }
  }

  static bool _isMobileDevice() {
    final data = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.single,
    );
    return data.size.shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => showLeftPane.value = !showLeftPane.value,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(widget.pdfName)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                if (controller.isReady) controller.zoomUp();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                if (controller.isReady) controller.zoomDown();
              },
            ),
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: () {
                if (controller.isReady) controller.goToPage(pageNumber: 1);
              },
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: () {
                if (controller.isReady) {
                  controller.goToPage(pageNumber: controller.pageCount);
                }
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder(
              valueListenable: showLeftPane,
              builder: (context, isLeftPaneShown, child) {
                return SizedBox(
                  width: isLeftPaneShown ? 300 : 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1, 0, 4, 0),
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          if (_isMobileDevice())
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.pdfName,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const ClipRect(
                            child: TabBar(
                              tabs: [
                                Tab(icon: Icon(Icons.search), text: 'Search'),
                                Tab(icon: Icon(Icons.menu_book), text: 'TOC'),
                                Tab(icon: Icon(Icons.image), text: 'Pages'),
                                Tab(
                                  icon: Icon(Icons.bookmark),
                                  text: 'Markers',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // ValueListenableBuilder(
                                //   valueListenable: textSearcher,
                                //   builder: (context, textSearcher, child) {
                                //     if (textSearcher == null) {
                                //       return const SizedBox();
                                //     }
                                //     return TextSearchView(
                                //       textSearcher: textSearcher,
                                //     );
                                //   },
                                // ),
                                ValueListenableBuilder(
                                  valueListenable: outline,
                                  builder:
                                      (context, outline, child) => OutlineView(
                                        outline: outline,
                                        controller: controller,
                                      ),
                                ),
                                ThumbnailsView(
                                  documentRef: widget.documentRef,
                                  controller: controller,
                                ),
                                // MarkersView(
                                //   markers:
                                //       _markers.values.expand((e) => e).toList(),
                                //   onTap: (marker) {
                                //     final rect = controller
                                //         .calcRectForRectInsidePage(
                                //           pageNumber:
                                //               marker.ranges.pageText.pageNumber,
                                //           rect: marker.ranges.bounds,
                                //         );
                                //     controller.ensureVisible(rect);
                                //   },
                                //   onDeleteTap: (marker) {
                                //     _markers[marker.ranges.pageNumber]!.remove(
                                //       marker,
                                //     );
                                //     setState(() {});
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PdfViewer(
                  widget.documentRef,
                  controller: controller,
                  params: PdfViewerParams(
                    textSelectionParams: const PdfTextSelectionParams(
                      enabled: false,
                    ),
                    maxScale: 8,
                    onViewSizeChanged: (viewSize, oldViewSize, controller) {
                      if (oldViewSize != null) {
                        final centerPosition = controller.value.calcPosition(
                          oldViewSize,
                        );
                        final newMatrix = controller.calcMatrixFor(
                          centerPosition,
                        );
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () => controller.goTo(newMatrix),
                        );
                      }
                    },
                    viewerOverlayBuilder:
                        (context, size, handleLinkTap) => [
                          PdfViewerScrollThumb(
                            controller: controller,
                            orientation: ScrollbarOrientation.right,
                            thumbSize: const Size(40, 25),
                            thumbBuilder:
                                (
                                  context,
                                  thumbSize,
                                  pageNumber,
                                  controller,
                                ) => Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: Text(
                                      '$pageNumber / ${controller.pageCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                          PdfViewerScrollThumb(
                            controller: controller,
                            orientation: ScrollbarOrientation.bottom,
                            thumbSize: const Size(80, 30),
                            thumbBuilder:
                                (context, thumbSize, pageNumber, controller) =>
                                    Container(color: Colors.red),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: FilledButton(
                                onPressed: () {
                                  widget.onAddResource();
                                },
                                child: Text("Next"),
                              ),
                            ),
                          ),
                        ],
                    loadingBannerBuilder:
                        (context, bytesDownloaded, totalBytes) => Center(
                          child: CircularProgressIndicator(
                            value:
                                totalBytes != null
                                    ? bytesDownloaded / totalBytes
                                    : null,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                    linkHandlerParams: PdfLinkHandlerParams(
                      onLinkTap: (link) {
                        if (link.url != null) {
                          _navigateToUrl(link.url!);
                        } else if (link.dest != null) {
                          controller.goToDest(link.dest);
                        }
                      },
                    ),
                    pagePaintCallbacks: [
                      if (textSearcher.value != null)
                        textSearcher.value!.pageTextMatchPaintCallback,
                    ],
                    onDocumentChanged: (document) {
                      if (document == null) {
                        textSearcher.value?.dispose();
                        textSearcher.value = null;
                        outline.value = null;
                        _markers.clear();
                      }
                    },
                    onViewerReady: (document, controller) async {
                      outline.value = await document.loadOutline();
                      textSearcher.value = PdfTextSearcher(controller);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToUrl(Uri url) async {
    if (await _shouldOpenUrl(context, url)) {
      await launchUrl(url);
    }
  }

  Future<bool> _shouldOpenUrl(BuildContext context, Uri url) async {
    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Navigate to URL?'),
          content: SelectionArea(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Do you want to navigate to the following location?\n',
                  ),
                  TextSpan(
                    text: url.toString(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
