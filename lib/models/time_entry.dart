import 'dart:convert';

enum Activity { buero, pause, baustelle }

String activityLabel(Activity a) {
  switch (a) {
    case Activity.buero: return 'Büro';
    case Activity.pause: return 'Pause';
    case Activity.baustelle: return 'Baustelle';
  }
}

Activity activityFromString(String s) {
  switch (s) {
    case 'Büro': return Activity.buero;
    case 'Pause': return Activity.pause;
    case 'Baustelle': return Activity.baustelle;
    default: return Activity.buero;
  }
}

class TimeEntry {
  final DateTime date;
  final String start; // 'HH:mm'
  final String end;   // 'HH:mm'
  final Activity activity;

  TimeEntry({
    required this.date,
    required this.start,
    required this.end,
    required this.activity,
  });

  Duration get duration {
    final sp = start.split(':');
    final ep = end.split(':');
    final s = DateTime(date.year, date.month, date.day, int.parse(sp[0]), int.parse(sp[1]));
    final e = DateTime(date.year, date.month, date.day, int.parse(ep[0]), int.parse(ep[1]));
    return e.difference(s);
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'start': start,
    'end': end,
    'activity': activityLabel(activity),
  };

  static TimeEntry fromJson(Map<String, dynamic> j) => TimeEntry(
    date: DateTime.parse(j['date'] as String),
    start: j['start'] as String,
    end: j['end'] as String,
    activity: activityFromString(j['activity'] as String),
  );
}

List<TimeEntry> listFromJson(String src) {
  final raw = jsonDecode(src) as List<dynamic>;
  return raw.map((e) => TimeEntry.fromJson(e as Map<String,dynamic>)).toList();
}

String listToJson(List<TimeEntry> items) => jsonEncode(items.map((e) => e.toJson()).toList());
