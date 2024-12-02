import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/main.dart';

class EmailSender {
  final String username;
  final String appPassword;

  EmailSender({
    required this.username,
    required this.appPassword,
  });

  //sends an email using the smtp server
  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    //smtp server is configured with gmail helper
    final smtpServer = gmail(username, appPassword);

    final message = Message()
      ..from = Address(username, 'Budget 365 Notifications')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    try {
      //sends the email
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: $sendReport');
    } on MailerException catch (e) {
      print('Failed to send email: ${e.message}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }

  //sends a test email to the targeted user
  Future<void> sendTestEmail() async {
    try {
      await sendEmail(
        recipient: username,
        subject: 'Test Email from Budget 365',
        body: 'This is a test email to verify the email sending functionality.',
      );
      print('Test email sent successfully!');
    } catch (e) {
      print('Failed to send test email: $e');
    }
  }
}
