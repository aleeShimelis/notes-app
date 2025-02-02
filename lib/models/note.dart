class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> tags;
  bool isPinned;
  DateTime? reminder; // New field for reminders

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tags,
    this.isPinned = false,
    this.reminder, // Nullable reminder
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'reminder': reminder?.toIso8601String(), // Save reminder
    };
  }

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']), // Fixed typo: json instead of ison
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
      reminder: json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
    );
  }
}