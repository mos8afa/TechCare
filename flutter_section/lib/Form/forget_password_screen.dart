import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ForgetPasswordForm(),
          ),
        ),
      ),
    );
  }
}

class ForgetPasswordForm extends StatefulWidget {
  const ForgetPasswordForm({super.key});

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _emailExistError;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1D89E4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.email_outlined, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Forgot Password',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your email to receive OTP code',
            style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Email Label
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EMAIL ADDRESS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFA0AEC0), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
          ),

          if (_emailExistError != null)
            Container(
              margin: const EdgeInsets.only(top: 6),
              alignment: Alignment.centerLeft,
              child: Text(_emailExistError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13)),
            ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
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
                      child: Text('Back', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF718096))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D89E4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                  : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _emailExistError = null;
    });
    final result = await ApiService.forgetPassword(
      email: _emailController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (result.success) {
      // حفظ الـ email عشان نبعته في الـ OTP screen
      await AuthStorage.saveForgetSession(
        email: _emailController.text.trim(),
      );
      if (mounted) Navigator.pushNamed(context, '/otp');
    } else {
      setState(() => _emailExistError = result.error);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}