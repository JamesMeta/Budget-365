// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:budget_365/login/login_handler.dart';

void main() {
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LogoSection(),
                WelcomeTextSection(),
                UsernameTextSection(),
                UsernameInputSection(),
                PasswordTextSection(),
                PasswordInputSection(),
                CreateAccount_ForgotPasswordSection(),
                LoginButtonSection(),
              ],
            ),
          ),
        ));
  }

  Widget LogoSection() {
    return Image.asset(
      'assets/images/logo1.png',
      scale: 3,
    );
  }

  Widget WelcomeTextSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        'Welcome to Budget 365',
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget UsernameTextSection() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 40, left: 20),
      child: Text(
        'Username',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget UsernameInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        controller: usernameController,
        decoration: InputDecoration(
          hintText: "Enter Your Username",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget PasswordTextSection() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 30, left: 20),
      child: Text(
        'Password',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget PasswordInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
      child: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Enter Your Password",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget CreateAccount_ForgotPasswordSection() {
    return Container(
      margin: EdgeInsets.only(top: 0, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: _onCreateAccountPressed,
              child: const Text(
                'Create Account',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.normal),
              )),
          SizedBox(
            width: 100,
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget LoginButtonSection() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
          onPressed: _onLoginPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            fixedSize: WidgetStatePropertyAll(Size(400, 60)),
          ),
          child: Text(
            'Login',
            style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold),
          )),
    );
  }

  void _onCreateAccountPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountWidget()),
    );

    if (!mounted) return;
    if (result == null || result < 0) {
      // handle errors more robustly
      print('Error creating account');
    } else {
      Navigator.pop(context, result);
    }
  }

  Future<dynamic> _onLoginPressed() async {
    Map<String, dynamic> result = await LoginHandler.login(
        usernameController.text, passwordController.text);

    if (!mounted) return;

    if (result['success']) {
      return Navigator.pop(context, result['account']['id']);
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(result['message']),
            );
          });
    }
  }
}

class CreateAccountWidget extends StatefulWidget {
  const CreateAccountWidget({super.key});

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          toolbarHeight: 30,
        ),
        backgroundColor: Colors.blue,
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LogoSection(),
                WelcomeTextSection(),
                EmailTextSection(),
                EmailInputSection(),
                UsernameTextSection(),
                UsernameInputSection(),
                PasswordTextSection(),
                PasswordInputSection(),
                ConfirmPasswordInputSection(),
                CreateAccountButtonSection(),
              ],
            ),
          ),
        ));
  }

  Future<int> _onCreatePressed() async {
    if (passwordController.text != confirmPasswordController.text) {
      print('Passwords do not match');
      return -1;
    }

    return await LoginHandler.register(
        emailController.text, usernameController.text, passwordController.text);
  }

  Widget LogoSection() {
    return Image.asset(
      'assets/images/logo1.png',
      scale: 3,
    );
  }

  Widget WelcomeTextSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        'Create Your Budget 365 Account',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget EmailTextSection() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 10, left: 20),
      child: Text(
        'Email',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget EmailInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        controller: emailController,
        decoration: InputDecoration(
          hintText: "Enter Your Email",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget UsernameTextSection() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 10, left: 20),
      child: Text(
        'Username',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget UsernameInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        controller: usernameController,
        decoration: InputDecoration(
          hintText: "Enter Your Username",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget PasswordTextSection() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 10, left: 20),
      child: Text(
        'Password',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Arial',
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget PasswordInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
      child: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Enter Your Password",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget ConfirmPasswordInputSection() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
      child: TextField(
        controller: confirmPasswordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Confirm Your Password",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget CreateAccountButtonSection() {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
          onPressed: () async {
            int result = await _onCreatePressed();
            if (result != -1) {
              if (!mounted) return;
              Navigator.pop(context, result);
            } else {
              if (!mounted) return;
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text(
                          'Passwords do not match or account already exists'),
                    );
                  });
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            fixedSize: WidgetStatePropertyAll(Size(400, 60)),
          ),
          child: Text(
            'Create Account',
            style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold),
          )),
    );
  }
}
