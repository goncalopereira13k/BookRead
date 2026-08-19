import 'package:flutter/material.dart';
import 'package:bookread/components/arc_progress_bar.dart';
import 'package:bookread/components/bar.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:bookread/app_localizations.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  static const String id = 'goals_screen';

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Map<DateTime, int> weekDailyReads = {};
  Map<int, int> yearlyReads = {};
  List<Widget> weekDailyReadsTiles = [];
  List<Widget> yearlyReadsTiles = [];
  Map<String, int> genreReads = {};
  List<Widget> genreReadsTiles = [];

  int totalDailyReads = 0;
  int totalYearlyReads = 0;
  int dailyValue = 0;
  int yearlyValue = 0;

  final List<String> weekDays = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  @override
  void initState() {
    super.initState();
    setupGoals();
    setupDailyReads();
    setupThisYearlyReads();
    setupWeekDailyReads();
    setupYearlyReads();
    setupGenreReadsThisYear();
  }

  void setupGoals() {
    if (!mounted) return;
    setState(() {
      dailyValue = System.instance.dailyGoal?.value ?? 0;
      yearlyValue = System.instance.yearlyGoal?.value ?? 0;
    });
  }

  Future<void> setupDailyReads() async {
    final TaskResponse response = await ReadingLogApi.countReadedPagesByDate(
      DateTime.now(),
    );

    if (response is TaskOkResponse && mounted) {
      setState(() {
        totalDailyReads = response.result as int;
      });
    }
  }

  Future<void> setupWeekDailyReads() async {
    weekDailyReadsTiles.clear();

    int maxValue = 0;

    for (int i = 6; i >= 0; i--) {
      final DateTime date = DateTime.now().subtract(Duration(days: i))
        ..copyWith(hour: 0, minute: 0, millisecond: 0, microsecond: 0);

      final TaskResponse response = await ReadingLogApi.countReadedPagesByDate(
        date,
      );

      if (response is TaskOkResponse) {
        final int value = response.result as int;
        weekDailyReads[date] = value;
        if (maxValue < value) maxValue = value;
      } else {
        weekDailyReads[date] = 0;
      }
    }
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    for (final MapEntry entry in weekDailyReads.entries) {
      final local = entry.key.toLocal();
      weekDailyReadsTiles.add(
        Bar(
          label: t.translate(weekDays[local.weekday - 1]),
          value: entry.value,
          maxValue: maxValue,
        ),
      );
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> setupYearlyReads() async {
    yearlyReadsTiles.clear();

    int maxValue = 0;

    final DateTime? userCreation = System.instance.activeUser?.createdAt;
    if (userCreation == null) {
      System.instance.logout();
      return;
    }

    final int creationYear = userCreation.year;
    final int currentYear = DateTime.now().year;

    for (int i = creationYear; i <= currentYear; i++) {
      final DateTime date = DateTime(i);

      final TaskResponse response = await BookStatusApi.countReadedBooksByYear(
        date,
      );

      if (response is TaskOkResponse) {
        final int value = response.result as int;
        yearlyReads[i] = value;
        if (maxValue < value) maxValue = value;
      } else {
        yearlyReads[i] = 0;
      }
    }

    final List sortedEntries =
        yearlyReads.entries.toList()
          ..sort((e1, e2) => e1.key.compareTo(e2.key));

    if (!mounted) return;
    for (final MapEntry<int, int> entry in sortedEntries.sublist(0, 5)) {
      yearlyReadsTiles.add(
        Bar(
          label: entry.key.toString(),
          value: entry.value,
          maxValue: maxValue,
        ),
      );
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> setupThisYearlyReads() async {
    final TaskResponse response = await BookStatusApi.countReadedBooksByYear(
      DateTime.now(),
    );

    if (response is TaskOkResponse && mounted) {
      setState(() {
        totalYearlyReads = response.result as int;
      });
    }
  }

  void changeDailyGoal() async {
    final t = AppLocalizations.of(context)!;
    final int? dailyGoal = await Helper.askNumber(
      context,
      t.translate('changeDailyGoal'),
      initialValue: System.instance.dailyGoal?.value,
    );

    if (dailyGoal == null) return;

    final TaskResponse response = await GoalApi.setDailyGoal(dailyGoal);
    if (response is TaskOkResponse) {
      System.instance.dailyGoal = response.result as Goal;
      setupGoals();
    }
  }

  Future<void> changeYearlyGoal() async {
    final t = AppLocalizations.of(context)!;
    final int? yearlyGoal = await Helper.askNumber(
      context,
      t.translate('changeYearlyGoal'),
      initialValue: System.instance.yearlyGoal?.value,
    );

    if (yearlyGoal == null) return;

    final TaskResponse response = await GoalApi.setYearlyGoal(yearlyGoal);
    if (response is TaskOkResponse) {
      System.instance.yearlyGoal = response.result as Goal;
      setupGoals();
    }
  }

  Future<void> setupGenreReadsThisYear() async {
    genreReads.clear();
    genreReadsTiles.clear();

    final now = DateTime.now();
    final currentYear = now.year;

    final List<BookStatus> books = await BookStatusApi.getReadedBooks();

    for (final bookStatus in books) {
      // Verifica se o livro foi lido este ano
      if (bookStatus.endDate?.year != currentYear) continue;

      try {
        final List<String> categories = bookStatus.book.categories;

        for (final genre in categories) {
          genreReads[genre] = (genreReads[genre] ?? 0) + 1;
        }
      } catch (e) {
        // In case of error, ignores the book
        continue;
      }
    }

    int maxValue =
        genreReads.values.isEmpty
            ? 1
            : genreReads.values.reduce((a, b) => a > b ? a : b);

    final sortedEntries =
        genreReads.entries.toList()..sort((e1, e2) {
          final e1Value = e1.value;
          final e2Value = e2.value;

          return e2Value.compareTo(e1Value);
        });

    genreReadsTiles.add(
      Bar(
        label: sortedEntries.first.key,
        value: sortedEntries.first.value,
        maxValue: maxValue,
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  t.translate('dailyPageGoal'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                ArcProgressBar(progress: totalDailyReads / dailyValue),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                Text(
                  '$totalDailyReads / $dailyValue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: changeDailyGoal,
                  child: Text(t.translate('changeGoal')),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(kRadiusLarge),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        t.translate('yourWeeklyProgress'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      SizedBox(
                        height: 110,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: weekDailyReadsTiles,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(kRadiusLarge),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        t.translate('yearlyBookGoal'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      ArcProgressBar(progress: totalYearlyReads / yearlyValue),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      Text(
                        '$totalYearlyReads / $yearlyValue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: changeYearlyGoal,
                        child: Text(t.translate('changeGoal')),
                      ),
                    ],
                  ),
                ),
                if (yearlyReadsTiles.isNotEmpty)
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                if (yearlyReadsTiles.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(kRadiusLarge),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          t.translate('booksReadPerYear'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kSpaceSizeBetweenWidgets),
                        SizedBox(
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: yearlyReadsTiles,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (genreReadsTiles.isNotEmpty)
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                if (genreReadsTiles.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(kRadiusLarge),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          t.translate('mostReadGenresThisYear'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kSpaceSizeBetweenWidgets),
                        SizedBox(
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: genreReadsTiles,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
