import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _nameError;
  String? _usernameError;
  String? _usernameExistError;
  String? _emailError;
  String? _emailExistError;
  String? _passwordError;

  final List<String> _roles = ['Patient', 'Doctor', 'Nurse', 'Donor', 'Pharmacist'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
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
                    child: const Icon(Icons.favorite, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create an Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Secure access to your healthcare services',
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildField(label: 'FIRST NAME', controller: _firstNameController, hint: 'First name', errorText: _nameError, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(label: 'LAST NAME', controller: _lastNameController, hint: 'Last name', errorText: _nameError, validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'USERNAME',
                    controller: _usernameController,
                    hint: 'Enter your username',
                    icon: Icons.person_outline,
                    errorText: _usernameExistError ?? _usernameError,
                    validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'EMAIL',
                    controller: _emailController,
                    hint: 'name@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailExistError ?? _emailError,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  _buildRoleDropdown(),
                  const SizedBox(height: 20),

                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D89E4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleReset,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF718096))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: Color(0xFF718096), fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Log in', style: TextStyle(color: Color(0xFF1D89E4), fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFA0AEC0), size: 20) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: icon != null ? 0 : 16,
                right: 16,
                top: 16,
                bottom: 16,
              ),
            ),
            validator: validator,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 18),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFA0AEC0), size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFA0AEC0), size: 20),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_passwordError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ROLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            hint: const Text('Select your role', style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)),
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFFA0AEC0), size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedRole = v),
            validator: (v) => v == null ? 'Please select a role' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          activeColor: const Color(0xFF1D89E4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(color: Color(0xFF718096), fontSize: 13),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                    child: const Text(
                      'Terms and Conditions',
                      style: TextStyle(color: Color(0xFF1D89E4), fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must agree to the Terms and Conditions'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      final pendingUserId = result.data['pending_user_id']?.toString() ?? '';
      await AuthStorage.saveRegisterSession(
        pendingUserId: pendingUserId,
        role: _selectedRole!,
      );
      if (mounted) Navigator.pushNamed(context, '/otp-signup');
    } else {
      final error = result.error ?? '';
      setState(() {
        if (error.contains('Username')) {_usernameExistError = error;}
        else if (error.contains('Email')) {_emailExistError = error;}
        else if (error.contains('Password')) {_passwordError = error;}
        else if (error.contains('Name')) { _nameError = error;}
      });
    }
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _selectedRole = null;
      _agreeToTerms = false;
      _nameError = null;
      _usernameError = null;
      _usernameExistError = null;
      _emailError = null;
      _emailExistError = null;
      _passwordError = null;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}