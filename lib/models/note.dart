class Note {
  String id;
  String title;
  String content;
  DateTime date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // Convert JSON to Note
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
    );
  }

  // Convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}