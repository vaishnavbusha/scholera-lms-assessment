import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/modules/models/course_module.dart';
import '../../features/modules/models/module_item.dart';
import '../../features/modules/models/module_item_type.dart';
import '../supabase/supabase_client_provider.dart';

final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository(ref.watch(supabaseClientProvider));
});

/// Reads + writes for modules and module items, including file uploads for
/// `file`-typed items. Storage path convention: `course-content/{sectionId}/...`
/// — the storage policies enforce this, so uploads must follow it.
class ModuleRepository {
  const ModuleRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'course-content';

  /// Fetch every module for a section with its items embedded via PostgREST's
  /// implicit FK relationship.
  Future<List<CourseModule>> fetchModulesWithItems(String sectionId) async {
    final rows = await _client
        .from('modules')
        .select('*, module_items(*)')
        .eq('section_id', sectionId)
        .order('position');
    return rows.map(CourseModule.fromJson).toList();
  }

  /// Create a module at the end of the current list. Position is computed
  /// by counting existing modules — adequate for a single-user create flow.
  Future<CourseModule> createModule({
    required String sectionId,
    required String title,
  }) async {
    final existing = await _client
        .from('modules')
        .select('id')
        .eq('section_id', sectionId);
    final nextPosition = existing.length;

    final row = await _client
        .from('modules')
        .insert({
          'section_id': sectionId,
          'title': title,
          'position': nextPosition,
        })
        .select('*, module_items(*)')
        .single();
    return CourseModule.fromJson(row);
  }

  /// Create a module item (link / note / file).
  ///
  /// For `file` items: uploads the bytes to
  /// `course-content/{sectionId}/{timestamp}_{filename}` first, then inserts
  /// the row with the storage path. If the row insert fails, we attempt to
  /// remove the uploaded object so we don't leak storage.
  Future<ModuleItem> createItem({
    required String moduleId,
    required String sectionId,
    required String title,
    required ModuleItemType type,
    String? url,
    String? body,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final existing = await _client
        .from('module_items')
        .select('id')
        .eq('module_id', moduleId);
    final nextPosition = existing.length;

    String? storagePath;
    if (type == ModuleItemType.file) {
      if (fileBytes == null || fileName == null) {
        throw ArgumentError('File items require fileBytes and fileName.');
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = _sanitizeFileName(fileName);
      final objectPath = '$sectionId/${timestamp}_$safeName';
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            objectPath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: _contentTypeFor(safeName),
              upsert: false,
            ),
          );
      storagePath = '$_bucket/$objectPath';
    }

    try {
      final row = await _client
          .from('module_items')
          .insert({
            'module_id': moduleId,
            'section_id': sectionId,
            'title': title,
            'item_type': type.databaseValue,
            'position': nextPosition,
            if (url != null) 'url': url,
            if (body != null) 'body': body,
            if (storagePath != null) 'storage_path': storagePath,
          })
          .select()
          .single();
      return ModuleItem.fromJson(row);
    } catch (_) {
      if (storagePath != null) {
        final objectPath = storagePath.substring(_bucket.length + 1);
        try {
          await _client.storage.from(_bucket).remove([objectPath]);
        } catch (_) {
          // Best-effort cleanup; ignore cleanup failures.
        }
      }
      rethrow;
    }
  }

  /// Generates a short-lived signed URL for a file stored under
  /// [storagePath] (e.g. `course-content/{sectionId}/lecture.pdf`).
  /// The bucket is private so downloads need a signed URL rather than a
  /// public link.
  Future<String> createSignedUrlFor(String storagePath) async {
    if (!storagePath.startsWith('$_bucket/')) {
      throw ArgumentError(
        'Storage path must start with "$_bucket/": $storagePath',
      );
    }
    final objectPath = storagePath.substring(_bucket.length + 1);
    return _client.storage.from(_bucket).createSignedUrl(objectPath, 60 * 10);
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.ppt')) return 'application/vnd.ms-powerpoint';
    if (lower.endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }
    return 'application/octet-stream';
  }
}
