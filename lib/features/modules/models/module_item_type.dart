import 'package:flutter/material.dart';

/// Mirrors the `public.module_item_type` enum in the database.
/// The UI exposes only [link], [note], and [file] for creation; [lecture]
/// and [video] are rendered if they appear in seed data but there's no
/// create path for them in this prototype.
enum ModuleItemType {
  link,
  note,
  file,
  lecture,
  video;

  static ModuleItemType fromDatabase(String value) {
    return switch (value) {
      'link' => ModuleItemType.link,
      'note' => ModuleItemType.note,
      'file' => ModuleItemType.file,
      'lecture' => ModuleItemType.lecture,
      'video' => ModuleItemType.video,
      _ => ModuleItemType.note,
    };
  }

  String get databaseValue => switch (this) {
        ModuleItemType.link => 'link',
        ModuleItemType.note => 'note',
        ModuleItemType.file => 'file',
        ModuleItemType.lecture => 'lecture',
        ModuleItemType.video => 'video',
      };

  String get label => switch (this) {
        ModuleItemType.link => 'Link',
        ModuleItemType.note => 'Note',
        ModuleItemType.file => 'File',
        ModuleItemType.lecture => 'Lecture',
        ModuleItemType.video => 'Video',
      };

  IconData get icon => switch (this) {
        ModuleItemType.link => Icons.link,
        ModuleItemType.note => Icons.description_outlined,
        ModuleItemType.file => Icons.picture_as_pdf_outlined,
        ModuleItemType.lecture => Icons.menu_book_outlined,
        ModuleItemType.video => Icons.play_circle_outlined,
      };
}
