class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  // Constructeur principal pour initialiser une Note
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Méthode d'usine pour créer une instance de Note à partir d'un objet JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? '', // Convertir l'ID en String pour plus de sécurité
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      // Analyser la date ou utiliser la date actuelle en cas d'erreur
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convertir l'objet Note en dictionnaire JSON pour le stockage ou le transfert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(), // Format standard ISO-8601
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
