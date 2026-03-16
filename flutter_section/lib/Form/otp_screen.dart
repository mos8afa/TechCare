import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class OtpScreen extends StatelessWidget {
  final String source;
  const OtpScreen({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: OtpForm(source: source),
          ),
        ),
      ),
    );
  }
}

class OtpForm extends StatefulWidget {
  final String source;
  const OtpForm({super.key, required this.source});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _otpError;
  bool _isLoading = false;

  // Back route حسب الـ source
  String get _backRoute {
    switch (widget.source) {
      case 'login':   return '/login';
      case 'signup':  return '/register';
      case 'forget':  return '/forget-password';
      default:        return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF1D89E4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        const Text(
          'Verify OTP',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter the 6-digit code sent to your email',
          style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
        const SizedBox(height: 24),

        // Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn't receive OTP? ", style: TextStyle(fontSize: 14, color: Color(0xFF718096))),
            GestureDetector(
              onTap: _isLoading ? null : _handleResend,
              child: const Text('Click here', style: TextStyle(fontSize: 14, color: Color(0xFF1D89E4), fontWeight: FontWeight.w700)),
            ),
          ],
        ),

        if (_otpError != null)
          Container(
            margin: const EdgeInsets.only(top: 12),
            alignment: Alignment.centerLeft,
            child: Text(_otpError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13)),
          ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            // Continue Button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
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
                          Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Back Button - بيرجع حسب الـ source
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _isLoading ? null : () => Navigator.pushReplacementNamed(context, _backRoute),
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
          ],
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _controllers[index - 1].clear();
            _focusNodes[index - 1].requestFocus();
          }
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: index == 0,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D89E4), width: 2),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isEmpty) return;
            if (value.length > 1) {
              _handlePaste(value, index);
              return;
            }
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          },
        ),
      ),
    );
  }

  void _handlePaste(String value, int startIndex) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
        _controllers[i].selection = TextSelection.fromPosition(const TextPosition(offset: 1));
      } else {
        _controllers[i].clear();
      }
    }
    final nextIndex = digits.length >= 6 ? 5 : digits.length;
    _focusNodes[nextIndex].requestFocus();
    setState(() {});
  }

  void _handleContinue() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _otpError = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    ApiResult result;

    if (widget.source == 'login') {
      final username = await AuthStorage.getUsername() ?? '';
      result = await ApiService.verifyOtpLogin(username: username, otp: otp);
      if (result.success) {
        await AuthStorage.clearSession();
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }

    } else if (widget.source == 'signup') {
      final pendingUserId = await AuthStorage.getPendingUserId() ?? '';
      result = await ApiService.verifyOtpRegister(userId: pendingUserId, otp: otp);
      if (result.success) {
        final role = await AuthStorage.getRole() ?? '';
        await AuthStorage.clearSession();
        if (mounted) {
          switch (role.toLowerCase()) {
            case 'patient':
              Navigator.pushReplacementNamed(context, '/patient-form');
              break;
            case 'doctor':
              Navigator.pushReplacementNamed(context, '/doctor-form');
              break;
            case 'nurse':
              Navigator.pushReplacementNamed(context, '/nurse-form');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }

    } else {
      final email = await AuthStorage.getEmail() ?? '';
      result = await ApiService.verifyOtpForgetPassword(email: email, otp: otp);
      if (result.success) {
        if (mounted) Navigator.pushNamed(context, '/reset-password');
      }
    }

    setState(() => _isLoading = false);

    if (!result.success) {
      final error = result.error ?? '';
      if (error.contains('Too many') || error.contains('too_many')) {
        if (mounted) Navigator.pushReplacementNamed(context, '/too-many-attempts');
      } else {
        setState(() => _otpError = error);
      }
    }
  }

  void _handleResend() async {
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    setState(() => _otpError = null);
    if (widget.source == 'login') {
      final username = await AuthStorage.getUsername() ?? '';
      await ApiService.resendOtp(source: 'login', username: username);
    } else if (widget.source == 'signup') {
      final pendingUserId = await AuthStorage.getPendingUserId() ?? '';
      await ApiService.resendOtp(source: 'signup', pendingUserId: pendingUserId);
    } else {
      final email = await AuthStorage.getEmail() ?? '';
      await ApiService.resendOtp(source: 'forget', email: email);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }
}