import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../app/env.dart';
import '../models/lecture_insight.dart';

/// Wraps the Gemini generative model for lecture-insight extraction.
/// Only active when [AppEnv.hasGeminiConfig] — otherwise the controller
/// falls back to metadata-only rendering without calling this service.
class GeminiService {
  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2,
            responseMimeType: 'application/json',
            responseSchema: Schema.object(
              properties: {
                'summary': Schema.string(
                  description:
                      'A 2–3 sentence summary of the lecture in plain prose.',
                ),
                'topics': Schema.array(
                  description:
                      'Up to 8 key topics covered, as short noun phrases.',
                  items: Schema.string(),
                ),
              },
              requiredProperties: ['summary', 'topics'],
            ),
          ),
        );

  final GenerativeModel _model;

  Future<LectureInsight> analyze({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {
    final prompt = '''
You are helping a university student decide whether to study this lecture next.
Read the attached lecture file titled "$fileName".

Return a JSON object with:
- "summary": 2-3 sentences, plain prose, no bullet points
- "topics": up to 8 key topics as short noun phrases (e.g. "Backpropagation", "Gradient descent")

Be specific. Skip generic filler like "introduction" or "course overview".
''';

    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, bytes),
      ]),
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw StateError('Gemini returned an empty response.');
    }

    try {
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      final summary = (decoded['summary'] as String?)?.trim() ?? '';
      final topicsList = (decoded['topics'] as List<dynamic>? ?? const [])
          .map((e) => (e as String).trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (summary.isEmpty) {
        throw StateError('Gemini returned an empty summary.');
      }
      return LectureInsight(
        summary: summary,
        topics: topicsList,
        source: LectureInsightSource.gemini,
      );
    } catch (e, st) {
      debugPrint('Gemini response parse failed: $e\n$st\nraw: $text');
      rethrow;
    }
  }
}

final geminiServiceProvider = Provider<GeminiService?>((ref) {
  final env = ref.watch(appEnvProvider);
  if (!env.hasGeminiConfig) return null;
  return GeminiService(env.geminiApiKey);
});
