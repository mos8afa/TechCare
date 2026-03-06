import 'package:flutter/material.dart';
import 'Form/login_screen.dart';
import 'Form/register_screen.dart';
import 'Form/forget_password_screen.dart';
import 'Form/otp_screen.dart';
import 'Form/reset_password_screen.dart';
import 'Form/too_many_attempts_screen.dart';
import 'Form/patient_form_screen.dart';
import 'Test.dart';

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
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          error: const Color(0xFFE53E3E),
        ),
      ),
      initialRoute: '/home', // تحديد الصفحة الأولى
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forget-password': (context) => const ForgetPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/too-many-attempts': (context) => const TooManyAttemptsScreen(),
        '/patient-form': (context) => const PatientFormScreen(),
        '/home': (context) => const Home(),
      },
    );
  }
}
