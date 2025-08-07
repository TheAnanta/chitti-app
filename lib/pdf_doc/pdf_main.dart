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
  List<PdfTextRanges>? textSelections;

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    textSearcher.value?.dispose();
    textSearcher.dispose();
    showLeftPane.dispose();
    outline.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) setState(() {});
  }

  static bool determineWhetherMobileDeviceOrNot() {
    final data = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.single,
    );
    return data.size.shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 80,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  showLeftPane.value = !showLeftPane.value;
                },
              ),
            ],
          ),
          title: Builder(
            builder: (context) {
              final isMobileDevice = determineWhetherMobileDeviceOrNot();
              final visualDensity =
                  isMobileDevice ? VisualDensity.compact : null;
              return Row(
                children: [
                  if (!isMobileDevice) ...[
                    Expanded(child: Text(widget.pdfName)),
                    Spacer(),
                  ],
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.circle, color: Colors.red),
                    onPressed: () => _addCurrentSelectionToMarkers(Colors.red),
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.circle, color: Colors.green),
                    onPressed:
                        () => _addCurrentSelectionToMarkers(Colors.green),
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.circle, color: Colors.orangeAccent),
                    onPressed:
                        () =>
                            _addCurrentSelectionToMarkers(Colors.orangeAccent),
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      if (controller.isReady) controller.zoomUp();
                    },
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      if (controller.isReady) controller.zoomDown();
                    },
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.first_page),
                    onPressed: () {
                      if (controller.isReady) {
                        controller.goToPage(pageNumber: 1);
                      }
                    },
                  ),
                  IconButton(
                    visualDensity: visualDensity,
                    icon: const Icon(Icons.last_page),
                    onPressed: () {
                      if (controller.isReady) {
                        controller.goToPage(pageNumber: controller.pageCount);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: Row(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: ValueListenableBuilder(
                valueListenable: showLeftPane,
                builder: (context, isLeftPaneShown, child) {
                  final isMobileDevice = determineWhetherMobileDeviceOrNot();
                  return SizedBox(
                    width: isLeftPaneShown ? 300 : 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(1, 0, 4, 0),
                      child: DefaultTabController(
                        length: 4,
                        child: Column(
                          children: [
                            if (isMobileDevice)
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
                            ClipRect(
                              // NOTE: without ClipRect, TabBar shown even if the width is 0
                              child: const TabBar(
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
                                  ValueListenableBuilder(
                                    valueListenable: textSearcher,
                                    builder: (context, textSearcher, child) {
                                      if (textSearcher == null) {
                                        return SizedBox();
                                      }
                                      return TextSearchView(
                                        textSearcher: textSearcher,
                                      );
                                    },
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: outline,
                                    builder:
                                        (context, outline, child) =>
                                            OutlineView(
                                              outline: outline,
                                              controller: controller,
                                            ),
                                  ),
                                  ThumbnailsView(
                                    documentRef: widget.documentRef,
                                    controller: controller,
                                  ),
                                  MarkersView(
                                    markers:
                                        _markers.values
                                            .expand((e) => e)
                                            .toList(),
                                    onTap: (marker) {
                                      final rect = controller
                                          .calcRectForRectInsidePage(
                                            pageNumber:
                                                marker
                                                    .ranges
                                                    .pageText
                                                    .pageNumber,
                                            rect: marker.ranges.bounds,
                                          );
                                      controller.ensureVisible(rect);
                                    },
                                    onDeleteTap: (marker) {
                                      _markers[marker.ranges.pageNumber]!
                                          .remove(marker);
                                      setState(() {});
                                    },
                                  ),
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
                  Builder(
                    builder: (context) {
                      return PdfViewer(
                        widget.documentRef,
                        // PdfViewer.asset(
                        //   'assets/hello.pdf',
                        // PdfViewer.file(
                        //   r"D:\pdfrx\example\assets\hello.pdf",
                        // PdfViewer.uri(
                        //   Uri.parse(
                        //       'https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf'),
                        // Set password provider to show password dialog
                        //passwordProvider: () => passwordDialog(context),
                        controller: controller,
                        params: PdfViewerParams(
                          enableTextSelection: false,
                          maxScale: 8,
                          // facing pages algorithm
                          // layoutPages: (pages, params) {
                          //   // They should be moved outside function
                          //   const isRightToLeftReadingOrder = false;
                          //   const needCoverPage = true;
                          //   final width = pages.fold(
                          //       0.0, (prev, page) => max(prev, page.width));

                          //   final pageLayouts = <Rect>[];
                          //   double y = params.margin;
                          //   for (int i = 0; i < pages.length; i++) {
                          //     const offset = needCoverPage ? 1 : 0;
                          //     final page = pages[i];
                          //     final pos = i + offset;
                          //     final isLeft = isRightToLeftReadingOrder
                          //         ? (pos & 1) == 1
                          //         : (pos & 1) == 0;

                          //     final otherSide = (pos ^ 1) - offset;
                          //     final h = 0 <= otherSide && otherSide < pages.length
                          //         ? max(page.height, pages[otherSide].height)
                          //         : page.height;

                          //     pageLayouts.add(
                          //       Rect.fromLTWH(
                          //         isLeft
                          //             ? width + params.margin - page.width
                          //             : params.margin * 2 + width,
                          //         y + (h - page.height) / 2,
                          //         page.width,
                          //         page.height,
                          //       ),
                          //     );
                          //     if (pos & 1 == 1 || i + 1 == pages.length) {
                          //       y += h + params.margin;
                          //     }
                          //   }
                          //   return PdfPageLayout(
                          //     pageLayouts: pageLayouts,
                          //     documentSize: Size(
                          //       (params.margin + width) * 2 + params.margin,
                          //       y,
                          //     ),
                          //   );
                          // },
                          //
                          onViewSizeChanged: (
                            viewSize,
                            oldViewSize,
                            controller,
                          ) {
                            if (oldViewSize != null) {
                              //
                              // Calculate the matrix to keep the center position during device
                              // screen rotation
                              //
                              // The most important thing here is that the transformation matrix
                              // is not changed on the view change.
                              final centerPosition = controller.value
                                  .calcPosition(oldViewSize);
                              final newMatrix = controller.calcMatrixFor(
                                centerPosition,
                              );
                              // Don't change the matrix in sync; the callback might be called
                              // during widget-tree's build process.
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () => controller.goTo(newMatrix),
                              );
                            }
                          },
                          viewerOverlayBuilder:
                              (context, size, handleLinkTap) => [
                                //
                                // Example use of GestureDetector to handle custom gestures
                                //
                                // GestureDetector(
                                //   behavior: HitTestBehavior.translucent,
                                //   // If you use GestureDetector on viewerOverlayBuilder, it breaks link-tap handling
                                //   // and you should manually handle it using onTapUp callback
                                //   onTapUp: (details) {
                                //     handleLinkTap(details.localPosition);
                                //   },
                                //   onDoubleTap: () {
                                //     controller.zoomUp(loop: true);
                                //   },
                                //   // Make the GestureDetector covers all the viewer widget's area
                                //   // but also make the event go through to the viewer.
                                //   child: IgnorePointer(
                                //     child:
                                //         SizedBox(width: size.width, height: size.height),
                                //   ),
                                // ),
                                //
                                // Scroll-thumbs example
                                //
                                // Show vertical scroll thumb on the right; it has page number on it
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
                                // Just a simple horizontal scroll thumb on the bottom
                                PdfViewerScrollThumb(
                                  controller: controller,
                                  orientation: ScrollbarOrientation.bottom,
                                  thumbSize: const Size(80, 30),
                                  thumbBuilder:
                                      (
                                        context,
                                        thumbSize,
                                        pageNumber,
                                        controller,
                                      ) => Container(color: Colors.red),
                                ),
                              ],
                          //
                          // Loading progress indicator example
                          //
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
                          //
                          // Link handling example
                          //
                          linkHandlerParams: PdfLinkHandlerParams(
                            onLinkTap: (link) {
                              if (link.url != null) {
                                navigateToUrl(link.url!);
                              } else if (link.dest != null) {
                                controller.goToDest(link.dest);
                              }
                            },
                          ),
                          pagePaintCallbacks: [
                            if (textSearcher.value != null)
                              textSearcher.value!.pageTextMatchPaintCallback,
                            _paintMarkers,
                          ],
                          onDocumentChanged: (document) async {
                            if (document == null) {
                              textSearcher.value?.dispose();
                              textSearcher.value = null;
                              outline.value = null;
                              textSelections = null;
                              _markers.clear();
                            }
                          },
                          onViewerReady: (document, controller) async {
                            outline.value = await document.loadOutline();
                            textSearcher.value = PdfTextSearcher(controller)
                              ..addListener(_update);
                            // Check if the user has scrolled to the bottom of the document
                            controller.addListener(() {
                              if (controller.isReady &&
                                  controller.pageCount > 0 &&
                                  controller.pageNumber ==
                                      controller.pageCount) {
                                widget.onAddResource();
                              }
                            });
                          },
                          onTextSelectionChange: (selections) {
                            textSelections = selections;
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _paintMarkers(Canvas canvas, Rect pageRect, PdfPage page) {
    final markers = _markers[page.pageNumber];
    if (markers == null) {
      return;
    }
    for (final marker in markers) {
      final paint =
          Paint()
            ..color = marker.color.withAlpha(100)
            ..style = PaintingStyle.fill;

      for (final range in marker.ranges.ranges) {
        final f = PdfTextRangeWithFragments.fromTextRange(
          marker.ranges.pageText,
          range.start,
          range.end,
        );
        if (f != null) {
          canvas.drawRect(
            f.bounds.toRectInPageRect(page: page, pageRect: pageRect),
            paint,
          );
        }
      }
    }
  }

  void _addCurrentSelectionToMarkers(Color color) {
    if (controller.isReady && textSelections != null) {
      for (final selectedText in textSelections!) {
        _markers
            .putIfAbsent(selectedText.pageNumber, () => [])
            .add(Marker(color, selectedText));
      }
      setState(() {});
    }
  }

  Future<void> navigateToUrl(Uri url) async {
    if (await shouldOpenUrl(context, url)) {
      await launchUrl(url);
    }
  }

  Future<bool> shouldOpenUrl(BuildContext context, Uri url) async {
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
