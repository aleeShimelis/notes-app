class Note {
  String id;
  String title;
  String content; // Rich text content (JSON)
  DateTime date;
  String category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.category = 'Uncategorized',
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'Uncategorized',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}
