import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(); // ← غير من email لـ username
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _loginError;

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
                  // Logo
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
                    'TechCare',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Empowering your wellness journey',
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                  ),
                  const SizedBox(height: 48),

                  // Username Label ← غير من EMAIL ADDRESS
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'USERNAME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _usernameController, // ← غير
                    hint: 'Enter your username',     // ← غير
                    icon: Icons.person_outline,       // ← غير
                    keyboardType: TextInputType.text, // ← غير
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Username is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Label
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5568),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/forget-password'),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // خطأ الـ Backend
                  if (_loginError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _loginError!,
                        style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13),
                      ),
                    ),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                                Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Security Verification
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'SECURITY VERIFICATION',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFA0AEC0), letterSpacing: 0.6),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google + Apple Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Google',
                          icon: _googleIcon(),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Apple',
                          icon: const Icon(Icons.apple, size: 20, color: Colors.black),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('New to techCare? ', style: TextStyle(color: Color(0xFF718096), fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(color: Color(0xFF1D89E4), fontSize: 14, fontWeight: FontWeight.w700),
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
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
          prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFFA0AEC0),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password is required';
          return null;
        },
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2D3748))),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    final result = await ApiService.login(
      username: _usernameController.text.trim(), // ← غير
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      await AuthStorage.saveLoginSession(
        username: _usernameController.text.trim(), // ← غير
      );
      if (mounted) Navigator.pushNamed(context, '/otp-login');
    } else {
      setState(() => _loginError = result.error);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose(); // ← غير
    _passwordController.dispose();
    super.dispose();
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.3, 1.9, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 1.6, 1.6, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.2, 0.8, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 4.0, 0.6, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}