// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/login/login_handler.dart';

class LoginWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  const LoginWidget({super.key, required this.cloudStorageManager});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late LoginHandler loginHandler;

  late double _titleFontSize;
  late double _textFieldFontSize;
  late double _textButtonFontSize;
  late double _logoScalingFactor;
  late double _spacingHeight;
  late double _horizontalPadding;
  late double _elevatedButtonWidth;

  @override
  void initState() {
    loginHandler = LoginHandler(widget.cloudStorageManager);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _titleFontSize = MediaQuery.of(context).size.width * 0.05;
    _logoScalingFactor = MediaQuery.of(context).size.width * 0.0075;
    _textFieldFontSize = MediaQuery.of(context).size.width * 0.03;
    _textButtonFontSize = MediaQuery.of(context).size.width * 0.045;
    _spacingHeight = MediaQuery.of(context).size.height * 0.02;
    _horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    _elevatedButtonWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blue,
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  right: _horizontalPadding, left: _horizontalPadding),
              child: Column(
                children: [
                  LogoSection(),
                  WelcomeTextSection(),
                  SizedBox(height: _spacingHeight),
                  UsernameTextSection(),
                  UsernameInputSection(),
                  SizedBox(height: _spacingHeight),
                  PasswordTextSection(),
                  PasswordInputSection(),
                  SizedBox(height: _spacingHeight * 2),
                  LoginButtonSection(),
                  SizedBox(height: _spacingHeight * 2),
                  CreateAccount_ForgotPasswordSection(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget LogoSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Image.asset(
        'assets/images/logo1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget WelcomeTextSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        'Welcome to Budget 365',
        style: TextStyle(
            color: Colors.white,
            fontSize: _titleFontSize,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget UsernameTextSection() {
    return Container(
      alignment: Alignment.topLeft,
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

  Widget UsernameInputSection() {
    return Container(
      child: TextField(
        controller: usernameController,
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

  Widget PasswordTextSection() {
    return Container(
      alignment: Alignment.topLeft,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: _onCreateAccountPressed,
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              child: Text(
                "Don't have an account?",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: _textButtonFontSize,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white),
              )),
        ],
      ),
    );
  }

  Widget LoginButtonSection() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
          onPressed: _onLoginPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            fixedSize: WidgetStatePropertyAll(Size(_elevatedButtonWidth, 60)),
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
      MaterialPageRoute(
          builder: (context) => CreateAccountWidget(
                cloudStorageManager: widget.cloudStorageManager,
              )),
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
    String? result = await loginHandler.login(
        usernameController.text, passwordController.text);

    if (!mounted) return;

    if (int.tryParse(result!) != null) {
      return Navigator.pop(context, int.parse(result));
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(result),
            );
          });
    }
  }
}

class CreateAccountWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  const CreateAccountWidget({super.key, required this.cloudStorageManager});

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double _titleFontSize;
  late double _textFieldFontSize;
  late double _textButtonFontSize;
  late double _logoScalingFactor;
  late double _spacingHeight;
  late double _horizontalPadding;
  late double _elevatedButtonWidth;

  @override
  Widget build(BuildContext context) {
    _titleFontSize = MediaQuery.of(context).size.width * 0.05;
    _logoScalingFactor = MediaQuery.of(context).size.width * 0.0075;
    _textFieldFontSize = MediaQuery.of(context).size.width * 0.03;
    _textButtonFontSize = MediaQuery.of(context).size.width * 0.045;
    _spacingHeight = MediaQuery.of(context).size.height * 0.02;
    _horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    _elevatedButtonWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blue,
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                  right: _horizontalPadding, left: _horizontalPadding),
              child: Column(
                children: [
                  LogoSection(),
                  WelcomeTextSection(),
                  SizedBox(height: _spacingHeight),
                  EmailTextSection(),
                  EmailInputSection(),
                  SizedBox(height: _spacingHeight),
                  UsernameTextSection(),
                  UsernameInputSection(),
                  PasswordTextSection(),
                  PasswordInputSection(),
                  ConfirmPasswordInputSection(),
                  SizedBox(height: _spacingHeight * 2),
                  CreateAccountButtonSection(),
                ],
              ),
            ),
          ),
        ));
  }

  Future<String?> _onCreatePressed() async {
    if (passwordController.text != confirmPasswordController.text) {
      print('Passwords do not match');
      return 'Passwords do not match';
    }
    if (passwordController.text.length < 6) {
      print('Password must be at least 6 characters long');
      return 'Password must be at least 6 characters long';
    }

    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      print('All fields must be filled');
      return 'All fields must be filled';
    }
    if (usernameController.text.split(' ').length < 2) {
      return 'Username must be at least 2 words eg. Firstname Lastname';
    }

    return await LoginHandler(widget.cloudStorageManager).register(
        emailController.text, usernameController.text, passwordController.text);
  }

  Widget LogoSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Image.asset(
        'assets/images/logo1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget WelcomeTextSection() {
    return Container(
      child: Text(
        'Create Budget365 Account',
        style: TextStyle(
            color: Colors.white,
            fontSize: _titleFontSize,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget EmailTextSection() {
    return Container(
      alignment: Alignment.topLeft,
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
      child: TextField(
        controller: usernameController,
        maxLength: 15,
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
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
          onPressed: () async {
            final result = await _onCreatePressed();
            if (int.tryParse(result!) != null) {
              if (!mounted) return;
              Navigator.pop(context, int.parse(result));
            } else {
              if (!mounted) return;
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text(result),
                    );
                  });
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            fixedSize: WidgetStatePropertyAll(Size(_elevatedButtonWidth, 60)),
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
