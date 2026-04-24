import 'dart:io' show SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Turn a raw Supabase / Dart exception into a short user-facing message.
///
/// The goal is to keep error notices polished — `AuthException: Invalid login
/// credentials` is useful in a log, but "That email and password combination
/// didn't match" is what a student should actually read.
String friendlyErrorMessage(Object error) {
  if (error is AuthException) {
    return _friendlyAuthMessage(error);
  }
  if (error is PostgrestException) {
    return _friendlyPostgrestMessage(error);
  }
  if (error is StorageException) {
    return 'Couldn\u2019t upload the file: ${error.message}.';
  }
  if (error is SocketException) {
    return 'Can\u2019t reach the server. Check your connection and try again.';
  }

  final raw = error.toString();
  // Strip leading "FooException: " / "_FooError: " prefixes so the message
  // reads like a sentence, not a stack trace.
  return raw.replaceFirst(RegExp(r'^_?[A-Za-z]+(Exception|Error): '), '');
}

String _friendlyAuthMessage(AuthException error) {
  final message = error.message.toLowerCase();
  if (message.contains('invalid login credentials') ||
      message.contains('invalid email or password')) {
    return 'That email and password combination didn\u2019t match. Double-check and try again.';
  }
  if (message.contains('email not confirmed')) {
    return 'Your email isn\u2019t confirmed yet. Check your inbox for the confirmation link.';
  }
  if (message.contains('rate limit') || message.contains('too many')) {
    return 'Too many attempts. Wait a minute and try again.';
  }
  if (message.contains('network') || message.contains('failed host lookup')) {
    return 'Can\u2019t reach the server. Check your connection and try again.';
  }
  return error.message;
}

String _friendlyPostgrestMessage(PostgrestException error) {
  final code = error.code;
  if (code == '42501' || error.message.toLowerCase().contains('permission')) {
    return 'You don\u2019t have permission to do that.';
  }
  if (code == '23505') {
    return 'That entry already exists.';
  }
  return error.message;
}
