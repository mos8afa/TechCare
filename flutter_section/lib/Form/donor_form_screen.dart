import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class DonorFormScreen extends StatelessWidget {
  const DonorFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: const DonorForm(),
          ),
        ),
      ),
    );
  }
}

class DonorForm extends StatefulWidget {
  const DonorForm({super.key});

  @override
  State<DonorForm> createState() => _DonorFormState();
}

class _DonorFormState extends State<DonorForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _lastDonationController = TextEditingController();

  bool _isLoading = false;
  bool _isPickingImage = false;

  String? _selectedBloodType;
  String? _selectedGovernorate;
  File? _nationalIdFront;
  File? _nationalIdBack;
  File? _profilePic;
  String? _phoneError;
  String? _addressError;

  final ImagePicker _picker = ImagePicker();
  final List<String> _bloodTypes = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];
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
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (type == 'front') _nationalIdFront = File(image.path);
          if (type == 'back') _nationalIdBack = File(image.path);
          if (type == 'profile') _profilePic = File(image.path);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_outlined,
              color: Color(0xFF1D89E4),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Become a Blood Donor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          _buildProgressBar(1.0, '100%'),
          const SizedBox(height: 30),

          // Blood Type + Date of Birth
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'BLOOD TYPE',
                  icon: Icons.bloodtype,
                  hint: 'Select',
                  items: _bloodTypes
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  value: _selectedBloodType,
                  onChanged: (v) => setState(() => _selectedBloodType = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField('Date of Birth', _dateOfBirthController),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone
          _buildPhoneField(),
          const SizedBox(height: 16),

          // Last Donation
          _buildDateField(
            'Last Donation Date',
            _lastDonationController,
            isRequired: false,
          ),
          const SizedBox(height: 16),

          // Governorate
          _buildDropdown(
            label: 'GOVERNORATE',
            icon: Icons.location_on_outlined,
            hint: 'Select governorate',
            items: _governorates
                .map(
                  (g) => DropdownMenuItem(
                    value: g['value'],
                    child: Text(g['label']!),
                  ),
                )
                .toList(),
            value: _selectedGovernorate,
            onChanged: (v) => setState(() => _selectedGovernorate = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Address
          _buildAddressField(),
          const SizedBox(height: 16),

          // National ID
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
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),

          // Profile Pic
          _buildFileUpload(
            label: 'Profile Picture',
            icon: Icons.camera_alt_outlined,
            file: _profilePic,
            defaultText: 'Click to upload photo',
            onTap: () => _pickImage('profile'),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D89E4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value, String percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PROGRESS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D89E4),
              ),
            ),
            Text(
              percent,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D89E4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: const Color(0xFFEDF2F7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D89E4)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
            ),
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            items: items,
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHONE NUMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.8,
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
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15, right: 4),
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
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length != 10) return 'Invalid phone';
              return null;
            },
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _phoneError!,
              style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.8,
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
            controller: controller,
            readOnly: true,
            onTap: () => _selectDate(controller),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: Color(0xFFA0AEC0),
                size: 20,
              ),
              hintText: 'YYYY-MM-DD',
              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
            ),
            validator: (v) {
              if (isRequired && (v == null || v.isEmpty)) return 'Required';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FULL ADDRESS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.8,
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
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Street, Building, Apartment',
              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
        if (_addressError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _addressError!,
              style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12),
            ),
          ),
      ],
    );
  }

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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isPickingImage ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: uploaded ? const Color(0xFFF0F7FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: uploaded
                    ? const Color(0xFF1D89E4)
                    : const Color(0xFFE2E8F0),
                width: uploaded ? 1.5 : 1,
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
                  uploaded ? file.path.split('/').last : defaultText,
                  style: TextStyle(
                    fontSize: 13,
                    color: uploaded
                        ? const Color(0xFF1D89E4)
                        : const Color(0xFF718096),
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nationalIdFront == null ||
        _nationalIdBack == null ||
        _profilePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required files'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.donorRegister(
      bloodType: _selectedBloodType!,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      governorate: _selectedGovernorate!,
      dateOfBirth: _dateOfBirthController.text.trim(),
      lastDonationDate: _lastDonationController.text.trim().isEmpty
          ? null
          : _lastDonationController.text.trim(),
      profilePic: _profilePic!,
      nationalIdFront: _nationalIdFront!,
      nationalIdBack: _nationalIdBack!,
    );

    setState(() => _isLoading = false);
    
    if (result.success) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) {
        final error = result.error ?? 'Registration failed';
        if (error.contains('phone')) {
          setState(() => _phoneError = error);
        } else if (error.contains('address')) {
          setState(() => _addressError = error);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: const Color(0xFFE53E3E),
            ),
          );
        }
      }
    }
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedBloodType = null;
      _selectedGovernorate = null;
      _nationalIdFront = null;
      _nationalIdBack = null;
      _profilePic = null;
      _phoneError = null;
      _addressError = null;
    });
    _phoneController.clear();
    _addressController.clear();
    _dateOfBirthController.clear();
    _lastDonationController.clear();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _lastDonationController.dispose();
    super.dispose();
  }
}
