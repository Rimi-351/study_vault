import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _defaultApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static String? _testApiKeyOverride;
  static GenerativeModel? _cachedModel;

  /// Allows test injection to verify missing/empty key validation
  @visibleForTesting
  static void setApiKeyForTesting(String? key) {
    _testApiKeyOverride = key;
    _cachedModel = null;
  }

  /// Resets test injection state back to compile-time environment
  @visibleForTesting
  static void resetTestingState() {
    _testApiKeyOverride = null;
    _cachedModel = null;
  }

  static String get _effectiveApiKey => (_testApiKeyOverride ?? _defaultApiKey).trim();

  static GenerativeModel get _model {
    if (_cachedModel != null) return _cachedModel!;

    final apiKey = _effectiveApiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        'Gemini API key is not configured. Please supply GEMINI_API_KEY using --dart-define or --dart-define-from-file=.env.',
      );
    }

    _cachedModel = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: apiKey,
    );
    return _cachedModel!;
  }

  static Future<String> generateMCQs(String text, {int numQuestions = 30}) async {
    final prompt = '''
    From the following text, generate exactly $numQuestions high-quality multiple-choice questions (MCQs) for students.
    Each MCQ should have:
    - A clear question
    - 4 options (A, B, C, D)
    - One correct answer marked with **(Correct)**
    - A short explanation why it's correct

    Focus on key concepts. Make them challenging but fair.

    Text: $text

    Format output as numbered list, e.g.:
    1. Question here?
       A) Option
       B) Option
       C) Option **(Correct)**
       D) Option
       Explanation: ...
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Error generating MCQs";
  }

  static Future<String> summarizeText(String text) async {
    final prompt = 'Summarize the key points from this text in bullet points, suitable for study notes: $text';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Error summarizing";
  }

  // For chat (reuse from before)
  static Future<String> sendMessage(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "No response";
  }
}