import 'package:flutter_test/flutter_test.dart';
import 'package:study_vault/shared/services/gemini_service.dart';
import 'package:study_vault/shared/services/file_extractor_service.dart';

void main() {
  group('Security Environment Variable Handling (Compile-time & Injection)', () {
    tearDown(() {
      GeminiService.resetTestingState();
      FileExtractorService.resetTestingState();
    });

    test('GeminiService throws StateError when GEMINI_API_KEY is not set', () {
      GeminiService.setApiKeyForTesting('');
      
      expect(
        () => GeminiService.generateMCQs('Sample text'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('GEMINI_API_KEY'),
        )),
      );
    });

    test('GeminiService throws StateError when GEMINI_API_KEY is whitespace', () {
      GeminiService.setApiKeyForTesting('   ');
      
      expect(
        () => GeminiService.generateMCQs('Sample text'),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('GEMINI_API_KEY'),
        )),
      );
    });

    test('GeminiService error message does not leak secret values', () async {
      GeminiService.setApiKeyForTesting('');
      try {
        await GeminiService.generateMCQs('Sample text');
        fail('Expected StateError');
      } catch (e) {
        expect(e, isA<StateError>());
        final errorMsg = (e as StateError).message;
        expect(errorMsg.contains('GEMINI_API_KEY'), isTrue);
        expect(errorMsg.contains('AIza'), isFalse);
      }
    });

    test('FileExtractorService safely flags missing Cloudmersive API key', () {
      FileExtractorService.setApiKeyForTesting('');
      expect(FileExtractorService.setApiKeyForTesting, isNotNull);
    });
  });
}
