import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/notifications/local_notifications.dart';

class CloudStorageManager {
  final SupabaseClient _supabase;
  final LocalNotificationsManager _notificationsManager;

  //constructor takes the Supabase client as a parameter
  CloudStorageManager(this._supabase, this._notificationsManager);

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

  //login method
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

      //notify the user that they have successfully logged-in
      await _notificationsManager.showNotification(
          title: 'Login Successful',
          body: 'Welcome! You are now signed-in with Budget-365.',
          channelId: 'auth_channel',
          channelName: 'Authentication Notifications',
          channelDescription: 'Notificatons for Login/Logout');

      return response['id'] as int;
    } catch (error) {
      print('Error logging in: $error');
      return -1;
    }
  }

  //method for logging-out the user
  Future<bool> logout() async {
    try {
      await _supabase.auth.signOut();

      //sends the user a push notification to let them know they have logged-out
      //Important! This only occurs if the user is signed-out from the Supabase cloud storage

      await _notificationsManager.showNotification(
          title: 'Logout Successful',
          body: 'You are now signed out of Budget-365',
          channelId: 'auth_channel',
          channelName: 'Authentication Notifications',
          channelDescription: 'Notificatons for Login/Logout');

      //once the user has been logged-out from cloud storage, the function can return
      return true;
    } catch (error) {
      print('Error logging out: $error');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final response = _supabase.auth.currentSession;
      if (response != null && response.user.id.isNotEmpty) {
        print("user is logged in");
        return true;
      }
      return false;
    } catch (error) {
      print('Error checking if user is logged in: $error');
      return false;
    }
  }

  //this method checks if an email is already used
  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await _supabase
          .from('account')
          .select()
          .eq('email', email)
          .maybeSingle(); //fetches a single matching record, or na if none

      return response != null;
    } catch (error) {
      print('Error checking if email is registered: $error');
      return false;
    }
  }

  //method to retrieve user groups by user ID
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

  //method to get groups by user ID
  Future<List<Group>> getGroups(int userID) async {
    try {
      // Fetch group data with associated user IDs in one query
      final response = await _supabase
          .from('group')
          .select('id, group_code, group_name, user_groups!inner(id_account)')
          .eq('user_groups.id_account', userID);

      // Parse the data into a list of Group objects
      final groups = response.map<Group>((row) {
        return Group(
          id: row['id'] as int,
          code: row['group_code'] as String,
          name: row['group_name'] as String,
          userIDs: (row['user_groups'] as List)
              .map<int>((userGroup) => userGroup['id_account'] as int)
              .toList(),
        );
      }).toList();

      return groups;
    } catch (error) {
      print('Error fetching groups: $error');
      return [];
    }
  }

  Future<List<Report>> getReports(int groupID) async {
    try {
      final response = await _supabase
        .from('report')
        .select('id, type, amount, description, category, id_group, id_user, date')
        .eq('id_group', groupID);

      final reports = response.map<Report>((row) {
        return Report(
          id: row['id'] as int,
          type: row['type'] as int,
          amount: row['amount'] as double,
          description: row['description'] as String,
          category: row['category'] as String,
          groupID: row['id_group'] as int,
          userID: row['id_user'] as int,
          date: row['date'] as DateTime,
        );
      }).toList();

      return reports;
    } catch (error) {
      print('Error fetching reports: $error');
      return [];
    }
  }

  SupabaseStreamBuilder getGroupsStream(int userID) {
    final controller = _supabase.from('group').stream(primaryKey: ['id']);
    return controller;
  }

  //method to get a stream of reports by group ID
  SupabaseStreamBuilder getReportsStream(int groupID) {
    final controller = _supabase
        .from('report')
        .stream(primaryKey: ['id'])
        .eq('id_group', groupID)
        .order('date', ascending: false);
    return controller;
  }

  Future<List<Report>> getReports(int groupID) async {
    try {
      final response = await _supabase
          .from('report')
          .select()
          .eq('id_group', groupID)
          .order('date', ascending: false);

      final reports = response.map<Report>((row) {
        return Report(
          id: row['id'] as int,
          amount: row['amount'] as double,
          description: row['description'] as String,
          category: row['category'] as String,
          groupID: row['id_group'] as int,
          userID: row['id_user'] as int,
          date: DateTime.parse(row['date'] as String),
          type: row['type'] as int,
        );
      }).toList();

      return reports;
    } catch (error) {
      print('Error fetching reports: $error');
      return [];
    }
  }

  //method to get username by user ID
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

  //medthod to get email by user ID
  Future<String> getEmail(int userID) async {
    try {
      final response = await _supabase
          .from('account')
          .select('email')
          .eq('id', userID)
          .single();
      return response['email'] as String;
    } catch (error) {
      print('Error fetching email: $error');
      return '';
    }
  }

  //method to fetch all users
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final response =
          await _supabase.from('account').select('id, account_name');
      return response
          .map<Map<String, dynamic>>((user) => {
                'id': user['id'],
                'name': user['account_name'],
              })
          .toList();
    } catch (error) {
      print('Error fetching users: $error');
      return [];
    }
  }

  //method to get a list of categories by group ID
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
  Future<void> createGroup(
      String groupCode, String groupName, List<String> Users) async {
    try {
      final response = await _supabase
          .from('group')
          .insert({
            'group_code': groupCode,
            'group_name': groupName,
          })
          .select('id')
          .single();

      final groupId = response['id'] as int;
      print('Group created successfully with ID: $groupId');

      //connection with notifications/local_notifications.dart to alert the user that the group creation was successful
      await _notificationsManager.showNotification(
        title: 'Group Created',
        body: 'The group $groupName has been created!',
      );

      for (String user in Users) {
        try {
          final response = await _supabase
              .from('account')
              .select('id')
              .eq('email', user)
              .single();
          final userId = response['id'] as int;
          await createUserGroup(userId, groupId);
        } catch (error) {
          print('Error creating user group: $error');
        }
      }
    } catch (error) {
      print('Error creating group: $error');
    }
  }

  //method to create a user group
  Future<bool> createUserGroup(int userId, int groupId) async {
    try {
      final response = await _supabase.from('user_groups').insert({
        'id_account': userId,
        'id_group': groupId,
      });

      print(
          'User group created successfully for user: $userId and group: $groupId');
      return response != null;
    } catch (error) {
      print('Error creating user group: $error');
      return false;
    }
  }

  //method to create a report
  Future<void> createReport({
    required double amount,
    required String description,
    required String Category,
    required int groupID,
    required int userID,
    required DateTime date,
    required int type,
  }) async {
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

      //alert user that the report was uploaded
      await _notificationsManager.showNotification(
        title: 'Report Created',
        body: 'Your report has been uploaded!',
        channelId: 'report_channel',
        channelName: 'Report Notifications',
        channelDescription: 'Notifications for report-related updates',
      );
    } catch (error) {
      print('Error creating report: $error');
    }
  }

  Future<String> generateUniqueGroupCode() async {
    final random = Random();
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final code =
        List.generate(5, (index) => alphabet[random.nextInt(26)]).join();
    final response = await _supabase
        .from('group')
        .select()
        .eq('group_code', code)
        .maybeSingle();
    if (response == null) {
      print("Generated group code: $code");
      return code;
    }
    return generateUniqueGroupCode();
  }

  Future<Map<String, double>> getReportTotals(groupID) async {
    try {
      final response = await _supabase
          .from('report')
          .select('amount, type')
          .eq('id_group', groupID);
      double totalIncome = 0;
      double totalExpense = 0;
      for (var row in response) {
        if (row['type'] == 0) {
          totalIncome += row['amount'];
        } else {
          totalExpense += row['amount'];
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense
      };
    } catch (error) {
      print('Error fetching report totals: $error');
      return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
    }
  }

  Future<void> logOut() async {
    _supabase.dispose();
    await _supabase.auth.signOut();
  }
}
