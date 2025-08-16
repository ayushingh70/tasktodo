class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }
}