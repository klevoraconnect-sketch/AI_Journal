import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';
import '../models/journal_entry.dart';

final journalServiceProvider = Provider((ref) => JournalService());

class JournalService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Fetch all entries for the current user
  Future<List<JournalEntry>> fetchEntries() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((entryMap) => JournalEntry.fromMap(entryMap)).toList();
    } on PostgrestException catch (e) {
      if (e.message.contains('relation') &&
          e.message.contains('does not exist')) {
        throw Exception(
            'Journal database table not found. Did you run the SQL script in Supabase? Dashboard > SQL Editor');
      }
      throw Exception('Database error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('[V2-UNENCRYPTED] Failed to fetch entries: $e');
    }
  }

  Future<JournalEntry> createEntry(JournalEntry entry) async {
    try {
      final entryMap = entry.toMap();

      final response = await _supabase
          .from('journal_entries')
          .insert(entryMap)
          .select()
          .single();

      return JournalEntry.fromMap(response);
    } catch (e) {
      throw Exception('[V2-UNENCRYPTED] Failed to create entry: $e');
    }
  }

  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    try {
      final entryMap = entry.toMap();

      // Update updated_at
      entryMap['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('journal_entries')
          .update(entryMap)
          .eq('id', entry.id)
          .select()
          .single();

      return JournalEntry.fromMap(response);
    } catch (e) {
      throw Exception('[V2-UNENCRYPTED] Failed to update entry: $e');
    }
  }

  /// Delete a journal entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _supabase.from('journal_entries').delete().eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  /// Upload an image to Supabase Storage and return the public URL
  Future<String> uploadImage(File file) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final path = '$userId/$fileName';

      await _supabase.storage.from('journal-images').upload(path, file);

      final String publicUrl =
          _supabase.storage.from('journal-images').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
