import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

// ==================== Step 1 ====================
class PharmacyFormScreen extends StatelessWidget {
  const PharmacyFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: const PharmacyFormStep1(),
          ),
        ),
      ),
    );
  }
}

class PharmacyFormStep1 extends StatefulWidget {
  const PharmacyFormStep1({super.key});

  @override
  State<PharmacyFormStep1> createState() => _PharmacyFormStep1State();
}

class _PharmacyFormStep1State extends State<PharmacyFormStep1> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  File? _profilePic;
  File? _nationalIdFront;
  File? _nationalIdBack;
  final bool _isLoading = false;
  String? _phoneError;
  String? _dobError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        if (type == 'profile') _profilePic = File(img.path);
        if (type == 'front') _nationalIdFront = File(img.path);
        if (type == 'back') _nationalIdBack = File(img.path);
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
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFEBF8FF), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.local_pharmacy_outlined, color: Color(0xFF1D89E4), size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Create Pharmacist Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
          const SizedBox(height: 20),
          _buildProgressBar(0.5, 'PROGRESS', '50%'),
          const SizedBox(height: 30),

          // Gender + DOB
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _buildDropdown(
              label: 'GENDER', icon: Icons.wc_outlined, hint: 'Select',
              items: [const DropdownMenuItem(value: 'male', child: Text('Male')), const DropdownMenuItem(value: 'female', child: Text('Female'))],
              value: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v),
              validator: (v) => v == null ? 'Required' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildDateField()),
          ]),
          const SizedBox(height: 16),

          // Phone
          _buildPhoneField(),
          const SizedBox(height: 16),

          // Profile Pic
          _buildFileUpload(label: 'Profile Picture', icon: Icons.camera_alt_outlined, file: _profilePic, defaultText: 'Click to upload photo', onTap: () => _pickImage('profile')),
          const SizedBox(height: 16),

          // National ID
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _buildFileUpload(label: 'National ID (Front)', icon: Icons.credit_card, file: _nationalIdFront, defaultText: 'Upload Front', onTap: () => _pickImage('front'))),
            const SizedBox(width: 12),
            Expanded(child: _buildFileUpload(label: 'National ID (Back)', icon: Icons.credit_card, file: _nationalIdBack, defaultText: 'Upload Back', onTap: () => _pickImage('back'))),
          ]),
          const SizedBox(height: 24),

          // Buttons
          Row(children: [
            Expanded(flex: 3, child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D89E4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ]),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: GestureDetector(
              onTap: _isLoading ? null : _handleReset,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: const Center(child: Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF718096)))),
              ),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value, String label, String percent) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D89E4))),
        Text(percent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D89E4))),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value, minHeight: 6, backgroundColor: const Color(0xFFEDF2F7), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D89E4)))),
    ]);
  }

  Widget _buildDropdown({required String label, required IconData icon, required String hint, required List<DropdownMenuItem<String>> items, required String? value, required void Function(String?) onChanged, required String? Function(String?) validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: DropdownButtonFormField<String>(initialValue: value, hint: Text(hint, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)), isExpanded: true, decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20), contentPadding: const EdgeInsets.symmetric(vertical: 8)), items: items, onChanged: onChanged, validator: validator),
      ),
    ]);
  }

  Widget _buildDateField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DATE OF BIRTH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextFormField(
          controller: _dobController, readOnly: true,
          decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFFA0AEC0), size: 20), hintText: 'YYYY-MM-DD', hintStyle: TextStyle(color: Color(0xFFA0AEC0)), contentPadding: EdgeInsets.symmetric(vertical: 16)),
          onTap: () async {
            final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(1990), firstDate: DateTime(1940), lastDate: DateTime.now());
            if (picked != null) setState(() => _dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
          },
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ),
      if (_dobError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_dobError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
    ]);
  }

  Widget _buildPhoneField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PHONE NUMBER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextFormField(
          controller: _phoneController, keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Padding(padding: EdgeInsets.only(left: 15, right: 4), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('+20', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)))])), hintText: '1XXXXXXXXX', hintStyle: TextStyle(color: Color(0xFFA0AEC0)), contentPadding: EdgeInsets.symmetric(vertical: 16)),
          validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v.length != 10) return 'Invalid phone'; return null; },
        ),
      ),
      if (_phoneError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_phoneError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
    ]);
  }

  Widget _buildFileUpload({required String label, required IconData icon, required File? file, required String defaultText, required VoidCallback onTap}) {
    final bool uploaded = file != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      GestureDetector(onTap: onTap, child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: uploaded ? const Color(0xFFF0F7FF) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFFE2E8F0), width: uploaded ? 1.5 : 1)),
        child: Column(children: [
          Icon(uploaded ? Icons.check_circle : icon, color: const Color(0xFF1D89E4), size: 24),
          const SizedBox(height: 8),
          Text(uploaded ? file.path.split('/').last : defaultText, style: TextStyle(fontSize: 13, color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFF718096), fontWeight: uploaded ? FontWeight.w600 : FontWeight.normal), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
        ]),
      )),
    ]);
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_profilePic == null || _nationalIdFront == null || _nationalIdBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required files'), backgroundColor: Color(0xFFE53E3E)));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PharmacyFormStep2Screen(
      gender: _selectedGender!,
      phone: '0${_phoneController.text.trim()}',
      dateOfBirth: _dobController.text,
      profilePic: _profilePic!,
      nationalIdFront: _nationalIdFront!,
      nationalIdBack: _nationalIdBack!,
    )));
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() { _selectedGender = null; _profilePic = null; _nationalIdFront = null; _nationalIdBack = null; _phoneError = null; _dobError = null; });
    _phoneController.clear();
    _dobController.clear();
  }

  @override
  void dispose() { _phoneController.dispose(); _dobController.dispose(); super.dispose(); }
}

// ==================== Step 2 ====================
class PharmacyFormStep2Screen extends StatelessWidget {
  final String gender, phone, dateOfBirth;
  final File profilePic, nationalIdFront, nationalIdBack;

  const PharmacyFormStep2Screen({super.key, required this.gender, required this.phone, required this.dateOfBirth, required this.profilePic, required this.nationalIdFront, required this.nationalIdBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: PharmacyFormStep2(gender: gender, phone: phone, dateOfBirth: dateOfBirth, profilePic: profilePic, nationalIdFront: nationalIdFront, nationalIdBack: nationalIdBack),
          ),
        ),
      ),
    );
  }
}

class PharmacyFormStep2 extends StatefulWidget {
  final String gender, phone, dateOfBirth;
  final File profilePic, nationalIdFront, nationalIdBack;

  const PharmacyFormStep2({super.key, required this.gender, required this.phone, required this.dateOfBirth, required this.profilePic, required this.nationalIdFront, required this.nationalIdBack});

  @override
  State<PharmacyFormStep2> createState() => _PharmacyFormStep2State();
}

class _PharmacyFormStep2State extends State<PharmacyFormStep2> {
  final _formKey = GlobalKey<FormState>();
  final _pharmacyNameController = TextEditingController();
  final _pharmacyAddressController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedUniversity;
  File? _syndicateCard;
  File? _practicePerm;
  File? _graduationCert;
  bool _isLoading = false;
  String? _nameError;
  String? _addressError;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _governorates = [
    {'value': 'alexandria', 'label': 'Alexandria'}, {'value': 'aswan', 'label': 'Aswan'},
    {'value': 'asyut', 'label': 'Assiut'}, {'value': 'beheira', 'label': 'Beheira'},
    {'value': 'beni_suef', 'label': 'Beni Suef'}, {'value': 'cairo', 'label': 'Cairo'},
    {'value': 'dakahlia', 'label': 'Dakahlia'}, {'value': 'damietta', 'label': 'Damietta'},
    {'value': 'fayoum', 'label': 'Faiyum'}, {'value': 'gharbia', 'label': 'Gharbia'},
    {'value': 'giza', 'label': 'Giza'}, {'value': 'ismailia', 'label': 'Ismailia'},
    {'value': 'kafr_el_sheikh', 'label': 'Kafr El Sheikh'}, {'value': 'luxor', 'label': 'Luxor'},
    {'value': 'matrouh', 'label': 'Matrouh'}, {'value': 'minya', 'label': 'Minya'},
    {'value': 'monufia', 'label': 'Monufia'}, {'value': 'new_valley', 'label': 'New Valley'},
    {'value': 'north_sinai', 'label': 'North Sinai'}, {'value': 'port_said', 'label': 'Port Said'},
    {'value': 'qalyubia', 'label': 'Qalyubia'}, {'value': 'qena', 'label': 'Qena'},
    {'value': 'red_sea', 'label': 'Red Sea'}, {'value': 'sharqia', 'label': 'Sharqia'},
    {'value': 'sohag', 'label': 'Sohag'}, {'value': 'south_sinai', 'label': 'South Sinai'},
    {'value': 'suez', 'label': 'Suez'},
  ];

  final List<Map<String, String>> _universities = [
    {'value': 'cairo_university', 'label': 'Cairo University'},
    {'value': 'ain_shams_university', 'label': 'Ain Shams University'},
    {'value': 'alexandria_university', 'label': 'Alexandria University'},
    {'value': 'mansoura_university', 'label': 'Mansoura University'},
    {'value': 'zagazig_university', 'label': 'Zagazig University'},
    {'value': 'al_azhar_university', 'label': 'Al-Azhar University'},
    {'value': 'assiut_university', 'label': 'Assiut University'},
    {'value': 'tanta_university', 'label': 'Tanta University'},
    {'value': 'helwan_university', 'label': 'Helwan University'},
    {'value': 'future_university', 'label': 'Future University in Egypt'},
    {'value': 'nile_university', 'label': 'Nile University'},
    {'value': 'german_university_cairo', 'label': 'German University in Cairo'},
    {'value': 'beni_suef_university', 'label': 'Beni-Suef University'},
    {'value': 'fayoum_university', 'label': 'Fayoum University'},
    {'value': 'suez_canal_university', 'label': 'Suez Canal University'},
  ];

  Future<void> _pickFile(String type) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (type == 'syndicate') _syndicateCard = File(file.path);
        if (type == 'practice') _practicePerm = File(file.path);
        if (type == 'graduation') _graduationCert = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFEBF8FF), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.medical_information_outlined, color: Color(0xFF1D89E4), size: 28)),
        const SizedBox(height: 16),
        const Text('Pharmacy Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
        const SizedBox(height: 20),

        // Progress
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('FINAL STEP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D89E4))),
            const Text('100%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D89E4))),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 1.0, minHeight: 6, backgroundColor: Color(0xFFEDF2F7), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D89E4)))),
        ]),
        const SizedBox(height: 30),

        // Pharmacy Name
        _buildTextField(label: 'PHARMACY NAME', controller: _pharmacyNameController, hint: 'Enter pharmacy name', icon: Icons.local_pharmacy_outlined, errorText: _nameError, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),

        // Governorate
        _buildDropdown(label: 'GOVERNORATE', icon: Icons.location_on_outlined, hint: 'Select governorate',
          items: _governorates.map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!))).toList(),
          value: _selectedGovernorate, onChanged: (v) => setState(() => _selectedGovernorate = v),
          validator: (v) => v == null ? 'Required' : null),
        const SizedBox(height: 16),

        // Pharmacy Address
        _buildAddressField(),
        const SizedBox(height: 16),

        // Syndicate + Practice
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildFileUpload(label: 'Syndicate Card', icon: Icons.badge_outlined, file: _syndicateCard, defaultText: 'Upload', onTap: () => _pickFile('syndicate'))),
          const SizedBox(width: 12),
          Expanded(child: _buildFileUpload(label: 'Practice Permit', icon: Icons.assignment_outlined, file: _practicePerm, defaultText: 'Upload', onTap: () => _pickFile('practice'))),
        ]),
        const SizedBox(height: 16),

        // Graduation
        _buildFileUpload(label: 'Graduation Cert.', icon: Icons.school_outlined, file: _graduationCert, defaultText: 'Upload', onTap: () => _pickFile('graduation')),
        const SizedBox(height: 16),

        // University
        _buildDropdown(label: 'UNIVERSITY', icon: Icons.school_outlined, hint: 'Select university',
          items: _universities.map((u) => DropdownMenuItem(value: u['value'], child: Text(u['label']!))).toList(),
          value: _selectedUniversity, onChanged: (v) => setState(() => _selectedUniversity = v),
          validator: (v) => v == null ? 'Required' : null),
        const SizedBox(height: 24),

        // Buttons
        Row(children: [
          Expanded(flex: 1, child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))), child: const Center(child: Icon(Icons.arrow_back, color: Color(0xFF1D89E4)))),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D89E4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, required IconData icon, String? errorText, required String? Function(String?) validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextFormField(controller: controller, decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20), hintText: hint, hintStyle: const TextStyle(color: Color(0xFFA0AEC0)), contentPadding: const EdgeInsets.symmetric(vertical: 16)), validator: validator),
      ),
      if (errorText != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(errorText, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
    ]);
  }

  Widget _buildDropdown({required String label, required IconData icon, required String hint, required List<DropdownMenuItem<String>> items, required String? value, required void Function(String?) onChanged, required String? Function(String?) validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: DropdownButtonFormField<String>(initialValue: value, hint: Text(hint, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)), isExpanded: true, decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20), contentPadding: const EdgeInsets.symmetric(vertical: 8)), items: items, onChanged: onChanged, validator: validator),
      ),
    ]);
  }

  Widget _buildAddressField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PHARMACY ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextFormField(controller: _pharmacyAddressController, maxLines: 2, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Street, Building, Apartment', hintStyle: TextStyle(color: Color(0xFFA0AEC0)), contentPadding: EdgeInsets.all(16)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      ),
      if (_addressError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_addressError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
    ]);
  }

  Widget _buildFileUpload({required String label, required IconData icon, required File? file, required String defaultText, required VoidCallback onTap}) {
    final bool uploaded = file != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      GestureDetector(onTap: onTap, child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: uploaded ? const Color(0xFFF0F7FF) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFFE2E8F0), width: uploaded ? 1.5 : 1)),
        child: Column(children: [
          Icon(uploaded ? Icons.check_circle : icon, color: const Color(0xFF1D89E4), size: 22),
          const SizedBox(height: 6),
          Text(uploaded ? file.path.split('/').last : defaultText, style: TextStyle(fontSize: 12, color: uploaded ? const Color(0xFF1D89E4) : const Color(0xFF718096), fontWeight: uploaded ? FontWeight.w600 : FontWeight.normal), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
        ]),
      )),
    ]);
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_syndicateCard == null || _practicePerm == null || _graduationCert == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required files'), backgroundColor: Color(0xFFE53E3E)));
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.pharmacistRegister(
      gender: widget.gender,
      phoneNumber: widget.phone,
      dateOfBirth: widget.dateOfBirth,
      profilePic: widget.profilePic,
      nationalIdFront: widget.nationalIdFront,
      nationalIdBack: widget.nationalIdBack,
      pharmacyName: _pharmacyNameController.text.trim(),
      pharmacyAddress: _pharmacyAddressController.text.trim(),
      governorate: _selectedGovernorate!,
      university: _selectedUniversity!,
      syndicateCard: _syndicateCard!,
      practicePerm: _practicePerm!,
      graduationCert: _graduationCert!,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) {
        final error = result.error ?? '';
        setState(() {
          if (error.contains('name')) {
            _nameError = error;
          } else if (error.contains('address')) {
            _addressError = error;
          }
        });
        if (!error.contains('name') && !error.contains('address')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: const Color(0xFFE53E3E)),
          );
        }
      }
    }
  }

  @override
  void dispose() { _pharmacyNameController.dispose(); _pharmacyAddressController.dispose(); super.dispose(); }
}