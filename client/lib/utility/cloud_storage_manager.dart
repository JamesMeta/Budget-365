import 'package:supabase_flutter/supabase_flutter.dart';

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

      final response = await _supabase
          .from('account')
          .select('id')
          .eq('email', email)
          .single();

      if (response == null) {
        print('Invalid email or password');
        return -1;
      }

      print('Login successful');
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

  //method to get a report of all accounts
  Future<List<Map<String, dynamic>>> getAccountReport() async {
    try {
      final response = await _supabase.from('account').select();

      if (response.isEmpty) {
        print('No accounts found.');
        return [];
      }

      return response as List<Map<String, dynamic>>;
    } catch (error) {
      print('Error fetching account report: $error');
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

  //method to get a report of all groups
  Future<List<Map<String, dynamic>>> getGroupReport() async {
    try {
      final response = await _supabase.from('group').select();

      if (response.isEmpty) {
        print('No groups found.');
        return [];
      }

      return response;
    } catch (error) {
      print('Error fetching group report: $error');
      return [];
    }
  }
}
