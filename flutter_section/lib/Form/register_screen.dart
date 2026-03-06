import 'package:flutter/material.dart';
import '../widgets/language_dropdown.dart';
import '../Form/login_screen.dart';  

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

  // متغيرات للأخطاء (هتجيلك من الـ Backend)
  String? _nameError;
  String? _usernameError;
  String? _usernameExistError;
  String? _emailError;
  String? _emailExistError;
  String? _passwordError;

  final List<String> _roles = [
    'Patient',
    'Doctor',
    'Nurse',
    'Donor',
    'Pharmacist'
  ];

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
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Language Dropdown
                        const LanguageDropdown(),
                        const SizedBox(height: 20),

                        // Logo Section
                        const RegisterLogoSection(),
                        const SizedBox(height: 30),

                        // اسم الأول والأخير في صف واحد
                        Row(
                          children: [
                            Expanded(
                              child: RegisterInputField(
                                label: 'First Name',
                                controller: _firstNameController,
                                prefixIcon: null, // مفيش أيقونة
                                errorText: _nameError,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'First name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: RegisterInputField(
                                label: 'Last Name',
                                controller: _lastNameController,
                                prefixIcon: null, // مفيش أيقونة
                                errorText: _nameError,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Last name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Username
                        RegisterInputField(
                          label: 'Username',
                          controller: _usernameController,
                          prefixIcon: Icons.person_outline,
                          errorText: _usernameExistError ?? _usernameError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 5),

                        // Email
                        RegisterInputField(
                          label: 'Email',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailExistError ?? _emailError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 5),

                        // Password
                        RegisterPasswordField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          errorText: _passwordError,
                        ),
                        const SizedBox(height: 5),

                        // Role Dropdown
                        RegisterRoleDropdown(
                          selectedRole: _selectedRole,
                          roles: _roles,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Terms and Conditions
                        RegisterTermsCheckbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D89E4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: _handleReset,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF718096),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Color(0xFF1D89E4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      // هنا هتبعت البيانات للـ Backend
      print('First Name: ${_firstNameController.text}');
      print('Last Name: ${_lastNameController.text}');
      print('Username: ${_usernameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Role: $_selectedRole');
      
      // لو الـ Backend رجع أخطاء، هتحدثها هنا
      // setState(() {
      //   _usernameExistError = 'Username already exists';
      // });
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Conditions'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }

  void _handleReset() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _selectedRole = null;
      _agreeToTerms = false;
      
      // مسح الأخطاء
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

// ==================== Widgets مساعدة ====================

class RegisterLogoSection extends StatelessWidget {
  const RegisterLogoSection({super.key});

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
            Icons.favorite,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Create an Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure access to your healthcare services',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RegisterInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const RegisterInputField({
    super.key,
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.errorText,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFFA0AEC0))
                  : null,
              contentPadding: EdgeInsets.only(
                left: prefixIcon != null ? 45 : 15,
                right: 15,
                top: 12,
                bottom: 12,
              ),
              hintText: 'Enter your $label'.toLowerCase(),
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            ),
            validator: validator,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class RegisterPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? errorText;

  const RegisterPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFA0AEC0)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFA0AEC0),
                ),
                onPressed: onToggleVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class RegisterRoleDropdown extends StatelessWidget {
  final String? selectedRole;
  final List<String> roles;
  final void Function(String?) onChanged;

  const RegisterRoleDropdown({
    super.key,
    required this.selectedRole,
    required this.roles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRole,
            hint: const Text('Select your role'),
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFFA0AEC0)),
              contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 8),
            ),
            items: roles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return 'Please select a role';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class RegisterTermsCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;

  const RegisterTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1D89E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onChanged(!value);
            },
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(
                      color: Color(0xFF1D89E4),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: null, // هنضيف navigation بعدين
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}