class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
