import 'package:flutter/material.dart';
import 'Form/login_screen.dart';
import 'Form/register_screen.dart';
import 'Form/forget_password_screen.dart';
import 'Form/otp_screen.dart';
import 'Form/reset_password_screen.dart';
import 'Form/too_many_attempts_screen.dart';
import 'Form/patient_form_screen.dart';
import 'Form/terms_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechCare',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: const Color(0xFF1D89E4),
        scaffoldBackgroundColor: const Color(0xFFEFF6FF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          error: const Color(0xFFE53E3E),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login':             (context) => const LoginScreen(),
        '/register':          (context) => const RegisterScreen(),
        '/forget-password':   (context) => const ForgetPasswordScreen(),
        '/reset-password':    (context) => const ResetPasswordScreen(),
        '/too-many-attempts': (context) => const TooManyAttemptsScreen(),
        '/patient-form':      (context) => const PatientFormScreen(),
        '/terms':             (context) => const TermsScreen(),

        '/otp-login':  (context) => const OtpScreen(source: 'login'),
        '/otp-signup': (context) => const OtpScreen(source: 'signup'),
        '/otp':        (context) => const OtpScreen(source: 'forget'),

        // ضيف دول ← 
        '/doctor-form':       (context) => const Scaffold(body: Center(child: Text('Doctor Form - Coming Soon'))),
        '/nurse-form':        (context) => const Scaffold(body: Center(child: Text('Nurse Form - Coming Soon'))),
        '/donor-form':        (context) => const Scaffold(body: Center(child: Text('Donor Form - Coming Soon'))),
        '/pharmacist-form':   (context) => const Scaffold(body: Center(child: Text('Pharmacist Form - Coming Soon'))),
        '/home':              (context) => const Scaffold(body: Center(child: Text('Home - Coming Soon'))),
      },
    );
  }
}