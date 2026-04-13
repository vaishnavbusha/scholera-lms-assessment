import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_role.dart';

final selectedPreviewRoleProvider =
    NotifierProvider<SelectedPreviewRoleController, AppRole?>(
      SelectedPreviewRoleController.new,
    );

class SelectedPreviewRoleController extends Notifier<AppRole?> {
  @override
  AppRole? build() => null;

  void select(AppRole role) {
    state = role;
  }
}
