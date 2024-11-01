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
      print('Group created successfully');
    } catch (error) {
      print('Error creating group: $error');
    }
  }

  //method to get a report of all groups
  Future<List<Map<String, dynamic>>> getGroupReport() async {
    try {
      final response = await _supabase.from('group').select();

      if (response == null || response.isEmpty) {
        print('No groups found.');
        return [];
      }

      return response as List<Map<String, dynamic>>;
    } catch (error) {
      print('Error fetching group report: $error');
      return [];
    }
  }
}
