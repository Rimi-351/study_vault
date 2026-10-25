class ExtractedFile {
  final String id;
  final String originalName;
  final String extractedText;
  final String? generatedContent;  // MCQs/Summary
  final DateTime createdAt;

  ExtractedFile({
    required this.id,
    required this.originalName,
    required this.extractedText,
    this.generatedContent,
    required this.createdAt,
  });

  // Add this copyWith method
  ExtractedFile copyWith({
    String? id,
    String? originalName,
    String? extractedText,
    String? generatedContent,
    DateTime? createdAt,
  }) {
    return ExtractedFile(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      extractedText: extractedText ?? this.extractedText,
      generatedContent: generatedContent ?? this.generatedContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'originalName': originalName,
    'extractedText': extractedText,
    'generatedContent': generatedContent,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ExtractedFile.fromJson(Map<String, dynamic> json) => ExtractedFile(
    id: json['id'],
    originalName: json['originalName'],
    extractedText: json['extractedText'],
    generatedContent: json['generatedContent'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}