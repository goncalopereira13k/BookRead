import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:bookread/components/timer_finish_dialog.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/services/notification.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';

class TimerProvider extends ChangeNotifier {
  TimerProvider() {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await player.setSource(AssetSource('sounds/alarm.mp3'));
      } catch (e) {
        debugPrint('Error loading audio source: $e');
      }
    });
  }

  Duration _duration = Duration.zero;
  late AudioPlayer player;
  int _time = 0;
  bool _isRunning = false;
  Timer? _timer;

  int get time => _time;
  double get progress => (_duration.inSeconds - _time) / _duration.inSeconds;
  bool get isRunning => _isRunning;
  bool get hasStarted => _time < _duration.inSeconds;
  Duration get duration => _duration;

  void startTimer() {
    if (_time <= 0) return;
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_time <= 0) {
        resetTimer();
        await player.resume();

        await _showFinishDialog();
      } else {
        _time--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  /// Resets the timer to the initial duration.
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _time = _duration.inSeconds;
    notifyListeners();
  }

  /// Sets the duration of the timer.
  void setDuration(Duration duration) {
    if (_isRunning) return;
    _duration = duration;
    _time = duration.inSeconds;
    notifyListeners();
  }

  String formatTime() {
    final min = _time ~/ 60;
    final sec = _time % 60;
    return '$min:${sec < 10 ? "0" : ""}$sec';
  }

  Future<void> _showFinishDialog() async {
    NotificationService.instance.show('Temporizador', 'O tempo acabou!');

    final context = navigatorKey.currentContext;
    if (context != null) {
      final (BookStatus? selectedBook, int? numberOfPages) = await showDialog(
        context: context,
        builder: (context) => TimerFinishDialog(),
      );

      if (selectedBook == null || numberOfPages == null) return;

      final TaskResponse response = await ReadingLogApi.createReadingLog(
        selectedBook,
        numberOfPages,
        duration: _duration.inSeconds,
      );

      if (!context.mounted) return;

      if (response is TaskOkResponse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading log created'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create reading log'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
