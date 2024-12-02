import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:convert';

import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/notifications/local_notifications.dart';
import 'package:file_picker/file_picker.dart';

class CloudStorageManager {
  final SupabaseClient _supabase; //supabase client connection
  final LocalNotificationsManager
      _notificationsManager; //notification manager connection for report notifications etc

  //constructor takes the Supabase client as a parameter
  CloudStorageManager(this._supabase, this._notificationsManager);

  //method to create a new account
  Future<String?> createAccount(
      String password, String accountName, String email) async {
    try {
      final creationResponse =
          await _supabase.auth.signUp(password: password, email: email);

      if (creationResponse.user == null) {
        print(
            'Error creating account: ${creationResponse.session?.toString()}');
        return creationResponse.session?.toString();
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
      return tableResponse['id'].toString();
    } catch (error) {
      print('Error creating account: $error');
      return error.toString();
    }
  }

  //login method
  Future<String?> login(String email, String password) async {
    try {
      final loginResponse = await _supabase.auth
          .signInWithPassword(password: password, email: email);

      if (loginResponse.user == null) {
        return "Server responded with no user for given credentials";
      }

      final response = await _supabase
          .from('account')
          .select('id')
          .eq('email', email)
          .single();

      if (response.isEmpty) {
        return "No user found with the given email";
      }

      //notify the user that they have successfully logged-in
      await _notificationsManager.showNotification(
          title: 'Login Successful',
          body: 'Welcome! You are now signed-in with Budget-365.',
          channelId: 'auth_channel',
          channelName: 'Authentication Notifications',
          channelDescription: 'Notificatons for Login/Logout');

      return response['id'].toString();
    } catch (error) {
      print('Error logging in: $error');
      return error.toString();
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

  Future<Group?> getGroup(int groupID) async {
    try {
      // Fetch group data with associated group ID in one query
      final response = await _supabase
          .from('group')
          .select('group_name')
          .eq('id', groupID)
          .single();

      final group = Group(
        id: groupID,
        code: '',
        name: response['group_name'] as String,
        userIDs: [],
      );

      return group;
    } catch (error) {
      print('Error fetching groups: $error');
      return null;
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

  Future<List<Map<String, dynamic>>> getReportDots(groupID) async {
    try {
      final response = await _supabase
        .from('report')
        .select('amount, date, type',)
        .eq('id_group', groupID)
        .order('date', ascending: true);

      if (response is List) {
        return response.map((report) {
          return {
            'amount': report['amount'],
            'date': DateTime.parse(report['date']),
            'type': report['type'],
          };
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (error) {
      print('Error fetching reports: $error');
      return [];
    }
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
  Future<Map<String, List<String>>> getCategoryList(int GroupID) async {
    try {
      final response = await _supabase
          .from('category')
          .select('name, type')
          .eq('id_group', GroupID);

      final Map<String, List<String>> categories = {
        'income': [],
        'expense': [],
      };
      for (var row in response) {
        categories[row['type'] == 0 ? 'income' : 'expense']?.add(row['name']);
      }
      return categories;
    } catch (error) {
      print('Error fetching categories: $error');
      return {'income': [], 'expense': []};
    }
  }

  //method to create a new group
  Future<void> createGroup(
      String groupCode,
      String groupName,
      List<String> Users,
      List<String> incomeCategories,
      List<String> expenseCategories) async {
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

      // Create income categories
      for (String category in incomeCategories) {
        try {
          await _supabase.from('category').insert({
            'name': category,
            'id_group': groupId,
            'type': 0,
          });
        } catch (error) {
          print('Error creating income category: $error');
        }
      }

      //create expense categories
      for (String category in expenseCategories) {
        try {
          await _supabase.from('category').insert({
            'name': category,
            'id_group': groupId,
            'type': 1,
          });
        } catch (error) {
          print('Error creating expense category: $error');
        }
      }

      // Create user groups
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

      //check if user wants notifications
      bool receiveNotifications =
          await LocalStorageManager.getNotificationSetting();
      if (receiveNotifications) {
        //if the user wants report notifications,
        await _notificationsManager.showNotification(
          title: 'Report Created',
          body: 'Your report has been uploaded!',
          channelId: 'report_channel',
          channelName: 'Report Notifications',
          channelDescription: 'Notifications for report-related updates',
        );
      }
    } catch (error) {
      print('Error creating report: $error');
    }
  }

  Future<void> deleteReport(int reportID) async {
    try {
      await _supabase.from('report').delete().eq('id', reportID);
      print('Report deleted successfully');
    } catch (error) {
      print('Error deleting report: $error');
    }
  }

  Future<void> editReport({
    required int reportID,
    required double amount,
    required String description,
    required String Category,
    required int groupID,
    required int userID,
    required DateTime date,
    required int type,
  }) async {
    //method to edit a report
    try {
      await _supabase.from('report').update({
        'amount': amount,
        'description': description,
        'category': Category,
        'id_group': groupID,
        'id_user': userID,
        'date': date.toIso8601String(),
        'type': type,
      }).eq('id', reportID);
      print('Report edited successfully');
    } catch (error) {
      print('Error editing report: $error');
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

  Future<Map<String, double>> getReportTotals(groupID, days) async {
    try {
      final response = await _supabase
          .from('report')
          .select('amount, type, date')
          .eq('id_group', groupID);
      double totalIncome = 0;
      double totalExpense = 0;
      for (var row in response) {
        final date = DateTime.parse(row['date'] as String);
        if (date.isBefore(DateTime.now().subtract(Duration(days: days))) ||
            date.isAfter(DateTime.now())) {
          continue;
        }
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

  //method specifically for retrieving report data for the export function
  // (this method maps the supabase response with added error handling in case of null values)
  Future<List<Report>> getReportsForExport(int groupID) async {
    try {
      final response = await _supabase //supabase call
          .from('report')
          .select()
          .eq('id_group', groupID)
          .order('date', ascending: false);

      //definition of the reports object
      final reports = response.map<Report>((row) {
        return Report(
          id: row['id'] as int? ??
              0, //error handling, values are set to 0 in the case of NULL
          amount: (row['amount'] as num?)?.toDouble() ??
              0.0, //int value casting from int to double
          description: row['description'] as String? ??
              'No description', //error handling
          category: row['category'] as String? ?? 'Uncategorized',
          groupID: row['id_group'] as int? ?? 0,
          userID: row['id_user'] as int? ?? 0,
          date: row['date'] != null
              ? DateTime.parse(row['date'] as String)
              : DateTime.now(),
          type: row['type'] as int? ?? 0,
        );
      }).toList();

      return reports;
    } catch (error) {
      print('Error fetching reports for export: $error');
      return [];
    }
  }

  //this method will retrieve all report data from groups the user is in,
  //and exports that data to the local device.

  Future<void> exportUserReports() async {
    try {
      //the LocalStorageManager has the method to retrieve the userID of the person logged-in to the local instance of the app
      final userID = await LocalStorageManager.getCurrentUserID();
      if (userID == null) {
        print('No user is currently logged in.');
        return;
      }

      //by assigning the user's ID to the userID variable, that can then be passed to the getGroups() method
      //This then retuns a set of groupIDs that the user is associated with
      final groups = await getGroups(userID);
      if (groups.isEmpty) {
        print('No groups found for the user.');
        return;
      }

      //the list of reports is compiled by iteratively sending group IDs to report getter method
      List<Report> allReports = [];
      for (final group in groups) {
        final reports = await getReportsForExport(group.id);
        allReports.addAll(reports);
      }

      if (allReports.isEmpty) {
        print('No reports found for user groups.');
        return;
      }

      //flutter filepicker allows the user to select where they want to savethe file
      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        print('No directory selected.');
        return;
      }

      //toJson() is in the report.dart file, as an associated method to the report class
      final reportsData = allReports.map((report) => report.toJson()).toList();
      final file = File('$directoryPath/user_reports.json');
      await file.writeAsString(jsonEncode(reportsData), flush: true);

      print('Reports saved successfully to ${file.path}');
    } catch (error) {
      print('Error exporting reports: $error');
    }
  }

  Future<String> formatReportsForEmail() async {
    try {
      //gets the current user's ID
      final userID = await LocalStorageManager.getCurrentUserID();
      if (userID == null) {
        return 'No user is currently logged in.';
      }

      final groups = await getGroups(userID);
      if (groups.isEmpty) {
        return 'No groups found for the user.';
      }

      List<Report> allReports = [];
      for (final group in groups) {
        final reports = await getReportsForExport(group.id);
        allReports.addAll(reports);
      }

      if (allReports.isEmpty) {
        return 'No reports found for user groups.';
      }

      //creates a formatted string for email body
      final buffer = StringBuffer();
      buffer.writeln('User Report Summary');
      buffer.writeln('--------------------');
      buffer.writeln();

      for (final report in allReports) {
        buffer.writeln('Date: ${report.date}');
        buffer.writeln('Description: ${report.description}');
        buffer.writeln('Amount: \$${report.amount.toStringAsFixed(2)}');
        buffer.writeln('Category: ${report.category}');
        buffer.writeln('Type: ${report.type == 0 ? "Income" : "Expense"}');
        buffer.writeln('--------------------');
      }

      return buffer.toString();
    } catch (error) {
      print('Error formatting reports for email: $error');
      return 'An error occurred while generating the report.';
    }
  }

  Future<String> joinExistingGroup(String groupCode, userID) async {
    try {
      final response = await _supabase
          .from('group')
          .select('id')
          .eq('group_code', groupCode)
          .single();
      final groupID = response['id'] as int;

      if (userID == null) {
        return 'No user is currently logged in.';
      }

      await createUserGroup(userID, groupID);
      return '0';
    } catch (error) {
      print('Error joining group: $error');
      return 'Error joining group check the group code and connection before trying again';
    }
  }

  Future<String> leaveGroup(int groupID, int userID) async {
    try {
      await _supabase
          .from('user_groups')
          .delete()
          .eq('id_group', groupID)
          .eq('id_account', userID);
      return '0';
    } catch (error) {
      print('Error leaving group: $error');
      return 'Error leaving group';
    }
  }

  Future<String> UpdateExistingGroup(
      int groupID,
      String groupCode,
      String groupName,
      List<String> Users,
      List<String> incomeCategories,
      List<String> expenseCategories) async {
    try {
      await _supabase.from('group').update({
        'group_name': groupName,
      }).eq('id', groupID);

      //Delete existing categories
      try {
        await _supabase
            .from('category')
            .delete()
            .eq('id_group', groupID)
            .eq('type', 0);
        await _supabase
            .from('category')
            .delete()
            .eq('id_group', groupID)
            .eq('type', 1);
      } catch (e) {
        return 'Error updating group: $e';
      }

      // Create income categories
      for (String category in incomeCategories) {
        try {
          await _supabase.from('category').insert({
            'name': category,
            'id_group': groupID,
            'type': 0,
          });
        } catch (error) {
          print('Error creating income category: $error');
        }
      }

      // Create expense categories
      for (String category in expenseCategories) {
        try {
          await _supabase.from('category').insert({
            'name': category,
            'id_group': groupID,
            'type': 1,
          });
        } catch (error) {
          print('Error creating expense category: $error');
        }
      }

      // Delete existing user groups
      try {
        await _supabase.from('user_groups').delete().eq('id_group', groupID);
      } catch (error) {
        print('Error deleting user groups: $error');
        return 'Error updating group: $error';
      }

      // Create user groups
      for (String user in Users) {
        try {
          final userID = await _supabase
              .from('account')
              .select('id')
              .eq('email', user)
              .single();

          await createUserGroup(userID['id'], groupID);
        } catch (error) {
          print('Error creating user group: $error');
        }
      }

      return 'Group updated successfully';
    } catch (error) {
      print('Error updating group: $error');
      return 'Error updating group';
    }
  }

  Future<List<String>> getGroupUsers(int groupID) async {
    try {
      final response = await _supabase
          .from('user_groups')
          .select('id_account')
          .eq('id_group', groupID);
      List<String> users = [];
      for (var row in response) {
        final user = await _supabase
            .from('account')
            .select('email')
            .eq('id', row['id_account'] as int)
            .single();
        users.add(user['email'] as String);
      }
      return users;
    } catch (error) {
      print('Error fetching group users: $error');
      return [];
    }
  }

  Future<List<String>> getGroupIncomeCategories(int groupID) async {
    try {
      final response = await _supabase
          .from('category')
          .select('name')
          .eq('id_group', groupID)
          .eq('type', 0);
      List<String> categories = [];
      for (var row in response) {
        categories.add(row['name'] as String);
      }
      return categories;
    } catch (error) {
      print('Error fetching group income categories: $error');
      return [];
    }
  }

  Future<List<String>> getGroupExpenseCategories(int groupID) async {
    try {
      final response = await _supabase
          .from('category')
          .select('name')
          .eq('id_group', groupID)
          .eq('type', 1);
      List<String> categories = [];
      for (var row in response) {
        categories.add(row['name'] as String);
      }
      return categories;
    } catch (error) {
      print('Error fetching group expense categories: $error');
      return [];
    }
  }

  Future<void> sendBalanceEmail() async {
    try {
      //calls the functio to fetch the current user ID
      int? target = await LocalStorageManager.getCurrentUserID();
      String userEmail =
          await getEmail(target!); // Make sure getEmail is correct

      //gets the formatted body
      String emailBody = await formatReportsForEmail();

      await sendEmail(
        recipient: userEmail,
        subject: "Budget-365 Balance Report",
        body: emailBody,
      );

      print('Balance email sent to $userEmail');
    } catch (e) {
      print('Failed to send balance email: $e');
    }
  }

  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    // Configure the SMTP server using the gmail helper
    String? username = dotenv.env['EMAIL_USER'];
    String? appPassword = dotenv.env['EMAIL_KEY'];

    final smtpServer = gmail(username!, appPassword!);

    // Create the email message
    final message = Message()
      ..from = Address(username, 'Budget 365 Notifications') // Sender's name
      ..recipients.add(recipient) // Recipient's email
      ..subject = subject // Email subject
      ..text = body; // Plain-text body
    // Optionally, add an HTML body or attachments

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: $sendReport');
    } on MailerException catch (e) {
      print('Failed to send email: ${e.message}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow; // Optionally rethrow the error
    }
  }
}
