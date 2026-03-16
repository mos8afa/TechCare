import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/language_dropdown.dart';

class PatientFormScreen extends StatelessWidget {
  const PatientFormScreen({super.key});

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
                child: PatientForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  String? _selectedGovernorate;

  // ملفات الصور
  File? _nationalIdFront;
  File? _nationalIdBack;
  File? _profilePic;

  // أخطاء الـ Backend
  String? _phoneError;
  String? _addressError;

  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female'];

  final List<Map<String, String>> _governorates = [
    {'value': 'alexandria', 'label': 'Alexandria'},
    {'value': 'aswan', 'label': 'Aswan'},
    {'value': 'asyut', 'label': 'Assiut'},
    {'value': 'beheira', 'label': 'Beheira'},
    {'value': 'beni_suef', 'label': 'Beni Suef'},
    {'value': 'cairo', 'label': 'Cairo'},
    {'value': 'dakahlia', 'label': 'Dakahlia'},
    {'value': 'damietta', 'label': 'Damietta'},
    {'value': 'fayoum', 'label': 'Faiyum'},
    {'value': 'gharbia', 'label': 'Gharbia'},
    {'value': 'giza', 'label': 'Giza'},
    {'value': 'ismailia', 'label': 'Ismailia'},
    {'value': 'kafr_el_sheikh', 'label': 'Kafr El Sheikh'},
    {'value': 'luxor', 'label': 'Luxor'},
    {'value': 'matrouh', 'label': 'Matrouh'},
    {'value': 'minya', 'label': 'Minya'},
    {'value': 'monufia', 'label': 'Monufia'},
    {'value': 'new_valley', 'label': 'New Valley'},
    {'value': 'north_sinai', 'label': 'North Sinai'},
    {'value': 'port_said', 'label': 'Port Said'},
    {'value': 'qalyubia', 'label': 'Qalyubia'},
    {'value': 'qena', 'label': 'Qena'},
    {'value': 'red_sea', 'label': 'Red Sea'},
    {'value': 'sharqia', 'label': 'Sharqia'},
    {'value': 'sohag', 'label': 'Sohag'},
    {'value': 'south_sinai', 'label': 'South Sinai'},
    {'value': 'suez', 'label': 'Suez'},
  ];

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == 'front') _nationalIdFront = File(image.path);
        if (type == 'back') _nationalIdBack = File(image.path);
        if (type == 'profile') _profilePic = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 15),
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

            // Header Section
            _buildHeader(),
            const SizedBox(height: 30),

            // Gender + Phone Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGenderDropdown()),
                const SizedBox(width: 15),
                Expanded(child: _buildPhoneField()),
              ],
            ),

            // Governorate
            _buildGovernorateDropdown(),
            const SizedBox(height: 18),

            // Full Address
            _buildAddressField(),
            const SizedBox(height: 18),

            // National ID Front + Back Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFileUpload(
                    label: 'National ID (Front)',
                    icon: Icons.credit_card,
                    file: _nationalIdFront,
                    defaultText: 'Upload Front',
                    onTap: () => _pickImage('front'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildFileUpload(
                    label: 'National ID (Back)',
                    icon: Icons.credit_card,
                    file: _nationalIdBack,
                    defaultText: 'Upload Back',
                    onTap: () => _pickImage('back'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Profile Picture
            _buildFileUpload(
              label: 'Profile Picture',
              icon: Icons.camera_alt_outlined,
              file: _profilePic,
              defaultText: 'Click to upload photo',
              onTap: () => _pickImage('profile'),
            ),
            const SizedBox(height: 25),

            // Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D89E4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Complete Registration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Header ====================
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFEBF8FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.personal_injury_outlined,
            color: Color(0xFF1D89E4),
            size: 22,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Create Patient Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  // ==================== Gender Dropdown ====================
  Widget _buildGenderDropdown() {
    return _FormField(
      label: 'Gender',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        hint: const Text('Select', style: TextStyle(color: Color(0xFFA0AEC0))),
        icon: const Icon(Icons.arrow_drop_down),
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.wc_outlined, color: Color(0xFFA0AEC0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 12),
        ),
        items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _selectedGender = v),
        validator: (v) => v == null ? 'Please select gender' : null,
      ),
    );
  }

  // ==================== Phone Field ====================
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+20',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
              hintText: '1XXXXXXXXX',
              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone is required';
              if (v.length != 10) return 'Enter valid phone number';
              return null;
            },
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_phoneError!,
                style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
          ),
      ],
    );
  }

  // ==================== Governorate Dropdown ====================
  Widget _buildGovernorateDropdown() {
    return _FormField(
      label: 'Governorate',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGovernorate,
        hint: const Text('Select governorate',
            style: TextStyle(color: Color(0xFFA0AEC0))),
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFFA0AEC0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 8),
        ),
        items: _governorates
            .map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!)))
            .toList(),
        onChanged: (v) => setState(() => _selectedGovernorate = v),
        validator: (v) => v == null ? 'Please select governorate' : null,
      ),
    );
  }

  // ==================== Address Field ====================
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Street, Building, Apartment',
              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
              contentPadding: EdgeInsets.all(15),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Address is required';
              return null;
            },
          ),
        ),
        if (_addressError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_addressError!,
                style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
          ),
      ],
    );
  }

  // ==================== File Upload ====================
  Widget _buildFileUpload({
    required String label,
    required IconData icon,
    required File? file,
    required String defaultText,
    required VoidCallback onTap,
  }) {
    final bool uploaded = file != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: uploaded ? const Color(0xFFF0F7FF) : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFFE2E8F0),
                width: uploaded ? 1.5 : 1,
                style: uploaded ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  uploaded ? Icons.check_circle : icon,
                  color: const Color(0xFF1D89E4),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  uploaded
                      ? file.path.split('/').last
                      : defaultText,
                  style: TextStyle(
                    fontSize: 13,
                    color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFF718096),
                    fontWeight: uploaded ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Handlers ====================
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_nationalIdFront == null || _nationalIdBack == null || _profilePic == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload all required files'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
        return;
      }
      setState(() {
        _phoneError = null;
        _addressError = null;
      });
      print('Gender: $_selectedGender');
      print('Phone: +20${_phoneController.text}');
      print('Governorate: $_selectedGovernorate');
      print('Address: ${_addressController.text}');

      // لو الـ Backend رجع خطأ:
      // setState(() => _phoneError = 'Invalid phone number');
    }
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedGender = null;
      _selectedGovernorate = null;
      _nationalIdFront = null;
      _nationalIdBack = null;
      _profilePic = null;
      _phoneError = null;
      _addressError = null;
    });
    _phoneController.clear();
    _addressController.clear();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// ==================== Helper Widget ====================
class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}