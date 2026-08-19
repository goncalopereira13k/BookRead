import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/arc_progress_bar.dart';
import 'package:bookread/components/book_progress.dart';
import 'package:bookread/components/timer_widget.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/models/streak.dart';
import 'package:bookread/screens/create_book.dart';
import 'package:bookread/screens/goals_screen.dart';
import 'package:bookread/screens/library_screen.dart';
import 'package:bookread/screens/search_screen.dart';
import 'package:bookread/screens/settings_screen.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static final String id = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(
    initialPage: MainScreenPage.home.index,
  );
  MainScreenPage _currentPage = MainScreenPage.home;
  MainScreenPage _previousPage = MainScreenPage.home;
  String searchQuery = '';
  Timer? _checkTypingTimer;
  int totalDailyReads = 0;
  int dailyValue = 0;
  Future<List<BookStatus>> futureReadingBooks = Future.value([]);

  Streak? streak;

  @override
  void initState() {
    super.initState();
    setupGoal();
    setupStreak();
    setupDailyReads();
    setupReadingBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _checkTypingTimer?.cancel();
    super.dispose();
  }

  void setupGoal() {
    dailyValue = System.instance.dailyGoal?.value ?? 0;
  }

  Future<void> setupStreak() async {
    streak = await StreakApi.getStreak();
    setState(() {});
  }

  Future<void> setupDailyReads() async {
    final TaskResponse response = await ReadingLogApi.countReadedPagesByDate(
      DateTime.now(),
    );

    if (response is TaskOkResponse) {
      setState(() {
        totalDailyReads = response.result as int;
      });
    }
  }

  void setupReadingBooks() {
    setState(() {
      futureReadingBooks = BookStatusApi.getReadingBooks();
    });
  }

  void _onItemTapped(int index) {
    if (index == MainScreenPage.settings.index) {
      Navigator.pushNamed(context, SettingsScreen.id);
    } else {
      setState(() {
        _currentPage = MainScreenPage.values[index];
        _pageController.jumpToPage(index);
      });

      if (_currentPage == MainScreenPage.home) {
        setupDailyReads();
      }
    }
  }

  void resetTimer(String value) {
    _checkTypingTimer?.cancel();
    _checkTypingTimer = Timer(kTypingDelay, () {
      setState(() {
        searchQuery = value;
      });
    });
  }

  void _onSearchQueryChanged(String value) {
    if (_currentPage != MainScreenPage.search) {
      _previousPage = _currentPage;
      _onItemTapped(MainScreenPage.search.index);
    } else if (value.isEmpty && searchQuery.isNotEmpty) {
      _onItemTapped(_previousPage.index);
    }

    resetTimer(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: t.translate('searchHint'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: _onSearchQueryChanged,
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
          ),
          actions: [
            if (_currentPage != MainScreenPage.search)
              Padding(
                padding: const EdgeInsets.only(right: kPadding),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department),
                    const SizedBox(width: 2),
                    Text(
                      streak?.length.toString() ?? '0',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = MainScreenPage.values[index];
                    });

                    if (_currentPage == MainScreenPage.home) {
                      setupDailyReads();
                    }
                  },
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(kPadding),
                      child: Column(
                        children: [
                          const TimerWidget(),
                          const SizedBox(height: kSpaceSizeBetweenWidgets),
                          GestureDetector(
                            onTap: () {
                              _onItemTapped(MainScreenPage.goals.index);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  kRadiusLarge,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    t.translate('dailyGoal'),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: kSpaceSizeBetweenWidgets,
                                  ),
                                  ArcProgressBar(
                                    progress:
                                        dailyValue == 0
                                            ? 0
                                            : totalDailyReads / dailyValue,
                                  ),
                                  const SizedBox(
                                    height: kSpaceSizeBetweenWidgets,
                                  ),
                                  Text('$totalDailyReads / $dailyValue'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: kSpaceSizeBetweenWidgets),
                          FutureBuilder(
                            future: futureReadingBooks,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot snapshot,
                            ) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                final readingBooks = snapshot.data!;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(8.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, // 2 columns
                                        mainAxisSpacing:
                                            kSpaceSizeBetweenWidgets,
                                        crossAxisSpacing:
                                            kSpaceSizeBetweenWidgets,
                                        childAspectRatio: 0.75,
                                      ),
                                  itemCount: readingBooks.length,
                                  itemBuilder: (context, index) {
                                    final bStatus = readingBooks[index];
                                    return BookProgress(
                                      key: ValueKey(bStatus.id),
                                      bStatus: bStatus,
                                      onCreatedReadingLog: () {
                                        setupStreak();
                                        setupDailyReads();
                                      },
                                      onStatusChanged: setupReadingBooks,
                                    );
                                  },
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const GoalsScreen(),
                    LibraryScreen(
                      onCreatedReadingLog: setupStreak,
                      onStatusChanged: setupReadingBooks,
                    ),
                    SearchScreen(
                      searchQuery: searchQuery,
                      onCreatedReadingLog: setupStreak,
                      onStatusChanged: setupReadingBooks,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage.index,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: t.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag),
              label: t.translate('goals'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.newsstand),
              label: t.translate('library'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: t.translate('search'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: t.translate('settings'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final bool? saved = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateBookScreen()),
            );

            if (saved == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.translate('createdBook'))),
              );
            }
          },
        ),
      ),
    );
  }
}

enum MainScreenPage { home, goals, library, search, settings }
