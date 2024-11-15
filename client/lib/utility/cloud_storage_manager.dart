import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';
import 'package:budget_365/report/report.dart';

class CloudStorageManager {
  final SupabaseClient _supabase;

  //constructor that takes the Supabase client as a parameter
  CloudStorageManager(this._supabase);

  //method to create a new account
  Future<int> createAccount(
      String password, String accountName, String email) async {
    try {
      final creationResponse =
          await _supabase.auth.signUp(password: password, email: email);

      if (creationResponse.user == null) {
        print(
            'Error creating account: ${creationResponse.session?.toString()}');
        return -1;
      }

      final tableResponse = await _supabase
          .from('account')
          .insert({
            'account_name': accountName,
            'email': email,
          })
          .select('id')
          .single();
      print('Account created successfully');
      return tableResponse['id'] as int;
    } catch (error) {
      print('Error creating account: $error');
      return -1;
    }
  }

  Future<int> login(String email, String password) async {
    try {
      final loginResponse = await _supabase.auth
          .signInWithPassword(password: password, email: email);

      if (loginResponse.user == null) {
        return -1;
      }

      final response = await _supabase
          .from('account')
          .select('id')
          .eq('email', email)
          .single();

      if (response.isEmpty) {
        return -1;
      }

      return response['id'] as int;
    } catch (error) {
      print('Error logging in: $error');
      return -1;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await _supabase
          .from('account')
          .select()
          .eq('email', email)
          .maybeSingle(); // Fetches a single matching record, or null if none

      return response != null;
    } catch (error) {
      print('Error checking if email is registered: $error');
      return false;
    }
  }

  Future<List<UserGroups>?> getUserGroups(int userID) async {
    try {
      final response =
          await _supabase.from('user_groups').select().eq('id_account', userID);

      final List<UserGroups> userGroups = [];
      for (var row in response) {
        userGroups.add(UserGroups(
          id: row['id'] as int,
          userId: row['id_account'] as int,
          groupId: row['id_group'] as int,
        ));
      }
      return userGroups;
    } catch (error) {
      print('Error fetching user groups: $error');
      return null;
    }
  }

  Future<List<Group>> getGroups(int userID) async {
    try {
      final response = await _supabase
          .from('group')
          .select('*, user_groups!inner(id_account)')
          .eq('user_groups.id_account', userID);

      final List<Group> groups = [];
      for (var row in response) {
        groups.add(Group(
          id: row['id'] as int,
          code: row['group_code'] as String,
          name: row['group_name'] as String,
        ));
      }
      return groups;
    } catch (error) {
      print('Error fetching groups: $error');
      return [];
    }
  }

  Stream<List<Report>> getReportsStream(int groupID) {
    final controller = StreamController<List<Report>>();

    Future<void> fetchReports() async {
      try {
        final response =
            await _supabase.from('report').select().eq('id_group', groupID);

        final List<Report> reports = [];
        for (var row in response) {
          final username = await getUsername(row['id_user'] as int);

          reports.add(Report(
            id: row['id'] as int,
            groupID: row['id_group'] as int,
            username: username,
            type: row['type'] as int,
            amount: (row['amount'] as int).toDouble(),
            description: row['description'] as String,
            category: row['category'] as String,
            date: DateTime.parse(row['date']),
          ));
        }

        // Add the list of reports to the stream
        controller.add(reports);
      } catch (error) {
        print('Error fetching reports: $error');
        controller.addError(error);
      }
    }

    // Call fetchReports initially and set it to repeat if needed
    fetchReports();

    return controller.stream;
  }

  Future<String> getUsername(int userID) async {
    try {
      final response = await _supabase
          .from('account')
          .select('account_name')
          .eq('id', userID)
          .single();
      return response['account_name'] as String;
    } catch (error) {
      print('Error fetching username: $error');
      return '';
    }
  }

  Future<List<String>> getCategoryList(int GroupID) async {
    try {
      final response = await _supabase
          .from('category')
          .select('name')
          .eq('id_group', GroupID);

      final List<String> categories = [];
      for (var row in response) {
        categories.add(row['name'] as String);
      }
      return categories;
    } catch (error) {
      print('Error fetching categories: $error');
      return [];
    }
  }

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

  Future<void> createReport(
      {required double amount,
      required String description,
      required String Category,
      required int groupID,
      required int userID,
      required DateTime date,
      required int type}) async {
    try {
      await _supabase.from('report').insert({
        'amount': amount,
        'description': description,
        'category': Category,
        'id_group': groupID,
        'id_user': userID,
        'date': date.toIso8601String(),
        'type': type,
      });
      print('Report created successfully');
    } catch (error) {
      print('Error creating report: $error');
    }
  }

  //method to update group details (used in group editing ui popups)
  Future<bool> updateGroup(
      int groupId, String newGroupCode, String newGroupName) async {
    try {
      final response = await _supabase.from('group').update({
        'group_code': newGroupCode,
        'group_name': newGroupName,
      }).eq('id', groupId);
      print('Group updated successfully');
      return response != null;
    } catch (error) {
      print('Error updating group: $error');
      return false;
    }
  }

//method to delete a group
  Future<bool> deleteGroup(int groupId) async {
    try {
      final response = await _supabase.from('group').delete().eq('id', groupId);
      print('Group deleted successfully');
      return response != null;
    } catch (error) {
      print('Error deleting group: $error');
      return false;
    }
  }
}
