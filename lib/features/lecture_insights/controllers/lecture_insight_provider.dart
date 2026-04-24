import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/supabase/supabase_client_provider.dart';
import '../../roadmap/models/roadmap_item.dart';
import '../data/gemini_service.dart';
import '../models/lecture_insight.dart';

/// Input bundle for the insight provider: the item id (for caching) plus the
/// properties we need to fetch + analyze. We can't look these up by id alone
/// without re-querying the roadmap, so the caller passes them in.
class LectureInsightRequest {
  const LectureInsightRequest({
    required this.itemId,
    required this.title,
    required this.storagePath,
    required this.topics,
  });

  factory LectureInsightRequest.fromRoadmapItem(RoadmapItem item) {
    return LectureInsightRequest(
      itemId: item.id,
      title: item.title,
      storagePath: item.storagePath,
      topics: item.topics.map((t) => t.title).toList(),
    );
  }

  final String itemId;
  final String title;
  final String? storagePath;
  final List<String> topics;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LectureInsightRequest && other.itemId == itemId;

  @override
  int get hashCode => itemId.hashCode;
}

/// Fetches and caches a lecture insight for one item. Results are kept alive
/// for the session (no autoDispose), so re-opening the sheet on the same
/// item is instant and doesn't re-call Gemini.
final lectureInsightProvider =
    FutureProvider.family<LectureInsight, LectureInsightRequest>((
  ref,
  request,
) async {
  ref.keepAlive();

  final gemini = ref.watch(geminiServiceProvider);
  final client = ref.watch(supabaseClientProvider);

  final storagePath = request.storagePath;
  if (storagePath == null || storagePath.isEmpty) {
    return LectureInsight(
      summary:
          'No file is attached to this item, so there\u2019s nothing to analyze.',
      topics: request.topics,
      source: LectureInsightSource.fallback,
    );
  }

  // `storagePath` is stored as `{bucket}/{object}`. Split them for the
  // storage client API.
  final slash = storagePath.indexOf('/');
  if (slash <= 0) {
    throw StateError('Malformed storage path: $storagePath');
  }
  final bucket = storagePath.substring(0, slash);
  final objectPath = storagePath.substring(slash + 1);

  if (gemini == null) {
    // Graceful fallback — surface file info + pre-extracted topics so the
    // roadmap insights view is still useful without an API key.
    return LectureInsight(
      summary:
          'AI-generated summaries are off because no Gemini API key is set. '
          'This file (${_fileNameFrom(objectPath)}) contains the topics listed below, '
          'extracted earlier during upload. Configure GEMINI_API_KEY to enable '
          'AI-powered summaries.',
      topics: request.topics,
      source: LectureInsightSource.fallback,
    );
  }

  final bytes = await client.storage.from(bucket).download(objectPath);
  final mimeType = _contentTypeFor(objectPath);
  final fileName = _fileNameFrom(objectPath);

  return gemini.analyze(
    bytes: bytes,
    mimeType: mimeType,
    fileName: fileName,
  );
});

String _fileNameFrom(String path) {
  final i = path.lastIndexOf('/');
  return i < 0 ? path : path.substring(i + 1);
}

String _contentTypeFor(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.ppt')) return 'application/vnd.ms-powerpoint';
  if (lower.endsWith('.pptx')) {
    return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
  }
  if (lower.endsWith('.txt')) return 'text/plain';
  if (lower.endsWith('.md')) return 'text/markdown';
  return 'application/octet-stream';
}
