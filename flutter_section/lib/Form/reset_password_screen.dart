import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ResetPasswordForm(),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1D89E4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.key_outlined, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
          const SizedBox(height: 6),
          const Text('Enter your new password below', style: TextStyle(fontSize: 14, color: Color(0xFF718096))),
          const SizedBox(height: 48),

          // New Password
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('NEW PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
          ),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _newPasswordController,
            hint: 'Enter new password',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'At least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
          ),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hint: 'Confirm new password',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),

          if (_passwordError != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              alignment: Alignment.centerLeft,
              child: Text(_passwordError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13)),
            ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFA0AEC0), size: 20),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFA0AEC0), size: 20),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _passwordError = null;
    });

    // جيب الـ email من الـ storage
    final email = await AuthStorage.getEmail() ?? '';

    final result = await ApiService.resetPassword(
      email: email,
      password: _newPasswordController.text,
      confirm: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      await AuthStorage.clearSession();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => _passwordError = result.error);
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}