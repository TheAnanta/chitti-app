import 'dart:math';

import 'package:chitti/color_filters.dart';
import 'package:chitti/data/important_questions.dart';
import 'package:chitti/data/semester.dart';
import 'package:chitti/domain/fetch_semester.dart';
import 'package:chitti/firebase_options.dart';
import 'package:chitti/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChittiMaterialApp();
  }
}

class ChittiCupertinoApp extends StatelessWidget {
  const ChittiCupertinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
      home: CupertinoTabView(
        builder: (context) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(middle: Text("Chitti.")),
            child: Container(
              child: Center(
                child: CupertinoButton.filled(
                  child: Text("This is a cupertino app."),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChittiMaterialApp extends StatelessWidget {
  const ChittiMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chitti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () async {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fetching details")));
        //TODO: Fetch details from server
        FirebaseAuth.instance.currentUser!.getIdToken(true).then((token) {
          if (token == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Unable to create token.")));
            return;
          }
          try {
            fetchSemester(token).then((semester) {
              SharedPreferences.getInstance().then((sharedPreferences) {
                final name =
                    FirebaseAuth.instance.currentUser?.displayName?.split(
                      " ",
                    )[0];
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MyHomePage(
                          name: name ?? "User",
                          semester: semester,
                        ),
                  ),
                );
              });
            });
          } on Exception catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        });
      }
    });
    return Scaffold(body: Center(child: Text("Chitti.")));
  }
}

class MyHomePage extends StatefulWidget {
  final String name;
  final Semester semester;
  const MyHomePage({super.key, required this.name, required this.semester});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(
      length: widget.semester.courses.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "CHITTI.",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Color(0xFFF27F0C),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Welcome back, ${widget.name.split(" ").first}",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text("Here’s a quick overview of your exam preparation"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Card(
                color: Color(0xFF429EBD),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Just checking up on you.",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Hope you’re motivated enough to prepare for you exam?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          overlayColor: Color(0xFF053F5C),
                        ),
                        child: Text(
                          "Explore More".toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF053F5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TabBar(
              isScrollable: true,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              tabs:
                  widget.semester.courses.keys
                      .map(
                        (e) => Tab(
                          text: e
                              .split("-")
                              .map(
                                (f) => "${f[0].toUpperCase()}${f.substring(1)}",
                              )
                              .join(" "),
                        ),
                      )
                      .toList(),
              controller: _controller,
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children:
                    widget.semester.courses.values.toList().map((subjects) {
                      return ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (_, __) {
                          return Divider();
                        },
                        itemBuilder: (_, index) {
                          final subject = subjects[index];
                          return ListTile(
                            title: Text(
                              subject.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              children: [
                                Text(
                                  subject.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: subject.progress,
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right_outlined),
                            leading: Icon(subject.icon),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          SubjectPage(subject: subject),
                                ),
                              );
                            },
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 6,
                            ).copyWith(bottom: 6),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectPage extends StatelessWidget {
  final Subject subject;
  const SubjectPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: Colors.white,
            expandedHeight: 312,
            flexibleSpace: Stack(
              children: [
                Image.network(
                  subject.image,
                  height: 372,
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
                  height: 234,
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
                      onPressed: () {},
                      icon: Icon(Icons.account_circle_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0).copyWith(top: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${subject.courseId} • ${subject.courseCategory.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")}",
                        ),
                        SizedBox(height: 8),
                        Text(
                          subject.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(value: subject.progress),
                        SizedBox(height: 8),
                        Opacity(
                          opacity: 0.3,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "${(subject.progress * 100).toInt()}% completed",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        UnitListTile(
                          units: subject.units,
                          subjectName: subject.title,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnitListTile extends StatelessWidget {
  const UnitListTile({
    super.key,
    required this.units,
    required this.subjectName,
  });
  final String subjectName;
  final List<Unit> units;

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
              onTap: () {
                if (units[index].isUnlocked) {
                  final selectedUnit = units[index];
                  // Fetch all the data
                  final unit = UnitWithResources(
                    unitId: selectedUnit.unitId,
                    name: selectedUnit.name,
                    description: selectedUnit.description,
                    difficulty: selectedUnit.difficulty,
                    isUnlocked: selectedUnit.isUnlocked,
                    importantQuestions: null,
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return UnitResourcePage(
                          unit: unit,
                          subjectName: subjectName,
                          unitIndex: index + 1,
                        );
                      },
                    ),
                  );
                } else {
                  //TODO: Show error or purchase screen
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

class UnitResourcePage extends StatefulWidget {
  final UnitWithResources unit;
  final String subjectName;
  final int unitIndex;
  const UnitResourcePage({
    super.key,
    required this.unit,
    required this.subjectName,
    required this.unitIndex,
  });

  @override
  State<UnitResourcePage> createState() => _UnitResourcePageState();
}

class _UnitResourcePageState extends State<UnitResourcePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  var _scrollOffset = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController(
      onAttach: (scrollPosition) {
        _scrollController.addListener(() {
          _scrollOffset = max(0, min(_scrollController.offset, 134));
          setState(() {});
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            snap: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            expandedHeight: 448,
            collapsedHeight: 206,
            floating: true,
            pinned: true,
            flexibleSpace: Wrap(
              clipBehavior: Clip.antiAlias,
              children: [
                Stack(
                  children: [
                    Image.network(
                      "https://images.ctfassets.net/3njn2qm7rrbs/1oOVjHudhSeipsABIO5khY/4e1e6811fdb93b62aad64879c3f34a3c/compiler.png?w=1000",
                      height: 258,
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
                      height: 234,
                    ),
                    Opacity(
                      opacity: _scrollOffset / 140,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.account_circle_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
                ColorFiltered(
                  colorFilter: ColorFilters.matrix(
                    brightness: _scrollOffset * 5 / 140,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, -_scrollOffset),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0).copyWith(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UNIT ${widget.unitIndex}",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black38,
                            ),
                          ),
                          Text(
                            widget.unit.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${widget.unit.difficulty.split("-").map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}").join(" ")} • ${widget.subjectName}",
                          ),
                          SizedBox(height: 8),
                          Opacity(
                            opacity: 1 - (_scrollOffset / 144),
                            child: Text(
                              widget.unit.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kTextTabBarHeight),
              child: Container(
                padding: EdgeInsets.only(top: 8),
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  tabs: [
                    Tab(text: "Roadmap"),
                    Tab(text: "Videos"),
                    Tab(text: "Notes"),
                    Tab(text: "Cheatsheets"),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoadmapView(widget.unit.roadmap),
                _buildVideoView(widget.unit.videos),
                _buildNotesView(widget.unit.notes),
                _buildIQView(widget.unit.importantQuestions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView(List<Notes>? notes) {
    return notes == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : Center(child: Text("Notes"));
  }

  Widget _buildVideoView(List<Video>? videos) {
    return videos == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : Center(child: Text("Videos"));
  }

  Widget _buildRoadmapView(Roadmap? roadmap) {
    return roadmap == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : Center(child: Text("Roadmap"));
  }

  Widget _buildIQView(List<ImportantQuestion>? iqs) {
    return iqs == null
        ? Center(child: Text("You haven't purchased a valid subscription."))
        : ListView.separated(
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            final iq = iqs[index];
            var showAnswer = false;
            return StatefulBuilder(
              builder: (context, setTileState) {
                return InkWell(
                  onTap: () {
                    showAnswer = !showAnswer;
                    setTileState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            iq.tag.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                iq.question,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(width: 24),
                            AnimatedRotation(
                              turns: showAnswer ? 0.25 : 0,
                              duration: Duration(milliseconds: 500),
                              child: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          child: showAnswer ? Text(iq.answer) : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: iqs.length,
        );
  }
}
