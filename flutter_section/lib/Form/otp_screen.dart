import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/language_dropdown.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/BG.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: const SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: OtpForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  // 6 controllers و 6 focusNodes للخانات
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _otpError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language Dropdown
          const LanguageDropdown(),
          const SizedBox(height: 20),

          // Logo Section
          const _OtpLogoSection(),
          const SizedBox(height: 30),

          // OTP Inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _buildOtpBox(index)),
          ),
          const SizedBox(height: 20),

          // Resend OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Didn't receive OTP? ",
                style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
              GestureDetector(
                onTap: _handleResend,
                child: const Text(
                  'Click here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1D89E4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // رسالة خطأ الـ OTP
          if (_otpError != null)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                _otpError!,
                style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 15),
              ),
            ),

          // Buttons
          Row(
            children: [
              // Continue
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _handleContinue,                                 //Navigator.pushReplacementNamed(context, '/too-many-attempts');
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D89E4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Back
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/forget-password');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF718096),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          maxLength: 6, // خلينا 6 عشان يلتقط الـ paste
          autofocus: index == 0,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1D89E4), width: 2),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isEmpty) return;

            // Paste: لو جه أكتر من رقم في خانة واحدة
            if (value.length > 1) {
              _handlePaste(value, index);
              return;
            }

            // تايب عادي: انتقل للخانة التالية
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
        _controllers[i].selection = TextSelection.fromPosition(
          TextPosition(offset: 1),
        );
      } else {
        _controllers[i].clear();
      }
    }

    // focus على الخانة التالية بعد آخر رقم
    final nextIndex = digits.length >= 6 ? 5 : digits.length;
    _focusNodes[nextIndex].requestFocus();
    setState(() {});
  }

  void _handleContinue() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _otpError = 'Please enter the complete 6-digit code');
      return;
    }
    setState(() => _otpError = null);
    print('OTP: $otp');

    // لو الـ Backend رجع إن الكود غلط:
    // setState(() => _otpError = 'Invalid OTP code');

    // لو نجح، تنقل لصفحة reset password:
    Navigator.pushNamed(context, '/reset-password');
  }

  void _handleResend() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() => _otpError = null);
    print('OTP Resent');
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}

class _OtpLogoSection extends StatelessWidget {
  const _OtpLogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1D89E4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter the 6-digit code sent to your email',
          style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
