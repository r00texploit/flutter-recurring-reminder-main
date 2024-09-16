const String tableTasks = 'tasktable';

class TaskFields {
  static final List<String> values = [
    id,
    title,
    body,
    user,
    recurrence,
    dateTime,
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String body = 'body';
  static const String user = 'user';
  static const String recurrence = 'recurrence';
  static const String dateTime = 'datetime';
}

class Task {
  final String id;
  final String title;
  final String body;
  final String recurrence;
  final int dateTime;
  final String user;
  const Task({
    required this.id,
    required this.title,
    required this.body,
    required this.recurrence,
    required this.dateTime,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      TaskFields.id: id,
      TaskFields.title: title,
      TaskFields.body: body,
      TaskFields.user: user,
      TaskFields.recurrence: recurrence,
      TaskFields.dateTime: dateTime,
    };
  }
}
