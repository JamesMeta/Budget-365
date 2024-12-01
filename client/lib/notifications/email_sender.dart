import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:mailer/smtp_server/gmail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailSender {
  final String username;
  final String appPassword;

  EmailSender({
    required this.username,
    required this.appPassword,
  });

  /// Sends an email
  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    // Configure the SMTP server using the gmail helper
    final smtpServer = gmail(username, appPassword);

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

  /// Sends a test email to the sender's email address
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
