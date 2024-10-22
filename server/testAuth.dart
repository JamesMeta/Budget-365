import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(email, password);
    if (response.error != null) {
      print('Error: ${response.error!.message}');
    } else {
      print('User signed up: ${response.user!.email}');
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await supabase.auth
        .signInWithPassword(email: email, password: password);
    if (response.error != null) {
      print('Error: ${response.error!.message}');
    } else {
      print('User signed in: ${response.user!.email}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                await signUp('email@example.com', 'password123');
              },
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () async {
                await signIn('email@example.com', 'password123');
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
