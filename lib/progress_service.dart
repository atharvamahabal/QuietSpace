import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keySessions = 'completed_sessions';

  // Save a completed session
  static Future<void> saveSession(int durationInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList(_keySessions) ?? [];
    
    final sessionData = {
      'duration': durationInSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    sessions.add(jsonEncode(sessionData));
    await prefs.setStringList(_keySessions, sessions);
  }

  // Get all sessions
  static Future<List<Map<String, dynamic>>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList(_keySessions) ?? [];
    
    return sessions.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  // Get stats for UI
  static Future<Map<String, int>> getStats() async {
    final sessions = await getSessions();
    
    int secondsCount = 0; // < 60 seconds
    int minutesCount = 0; // 60s <= d < 3600s
    int hoursCount = 0;   // >= 3600s
    
    for (var session in sessions) {
      final duration = session['duration'] as int;
      if (duration < 60) {
        secondsCount++;
      } else if (duration < 3600) {
        minutesCount++;
      } else {
        hoursCount++;
      }
    }
    
    return {
      'seconds': secondsCount,
      'minutes': minutesCount,
      'hours': hoursCount,
      'total': sessions.length,
    };
  }
}
