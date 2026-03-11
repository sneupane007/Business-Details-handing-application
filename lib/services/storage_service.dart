import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadAvatar(String userId, File file) async {
    final path = '$userId/avatar.jpg';
    await _supabase.storage.from('avatars').upload(path, file);
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<String> uploadDocument(String userId, File file, String fileName) async {
    final path = '$userId/$fileName';
    await _supabase.storage.from('documents').upload(path, file);
    return _supabase.storage.from('documents').getPublicUrl(path);
  }
}
