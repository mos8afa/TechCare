import 'package:flutter/material.dart';

class TooManyAttemptsScreen extends StatelessWidget {
  const TooManyAttemptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة التحذير
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Too Many Attempts',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You have exceeded the maximum number of attempts.\nPlease try again or create a new account.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096), height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/otp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D89E4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Try Again?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text('Back to Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF718096))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}