import 'package:supabase_flutter/supabase_flutter.dart';

class GroupReportHelper {
  final SupabaseClient _supabase;

  //constructor that takes the Supabase client as a parameter
  GroupReportHelper(this._supabase);

  //method to create a new group
  Future<void> createGroup(int id, String groupCode, String groupName) async {
    try {
      await _supabase.from('group').insert({
        'id': id,
        'group_code': groupCode,
        'group_name': groupName,
      });
      // ignore: empty_catches
    } catch (error) {}
  }

  //method to get a report of all groups
  Future<List<Map<String, dynamic>>> getGroupReport() async {
    try {
      final response = await _supabase.from('group').select();

      if (response.isEmpty) {
        return [];
      }

      return response;
    } catch (error) {
      return [];
    }
  }
}
