import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class NurseFormScreen extends StatelessWidget {
  const NurseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: const NurseFormStep1(),
          ),
        ),
      ),
    );
  }
}

class NurseFormStep1 extends StatefulWidget {
  const NurseFormStep1({super.key});

  @override
  State<NurseFormStep1> createState() => _NurseFormStep1State();
}

class _NurseFormStep1State extends State<NurseFormStep1> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  String? _selectedGovernorate;
  File? _profilePic;
  bool _isLoading = false;
  bool _isPickingImage = false;
  String? _phoneError;
  String? _dobError;
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFEBF8FF), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.medical_services_outlined, color: Color(0xFF1D89E4), size: 28)),
        const SizedBox(height: 16),
        const Text('Create Nurse Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
        const SizedBox(height: 20),
        _buildProgressBar(0.5, 'PROGRESS', '50%'),
        const SizedBox(height: 30),

        // Gender + DOB
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildDropdown(
            label: 'GENDER', icon: Icons.wc_outlined, hint: 'Select',
            items: [const DropdownMenuItem(value: 'male', child: Text('Male')), const DropdownMenuItem(value: 'female', child: Text('Female'))],
            value: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v),
            validator: (v) => v == null ? 'Required' : null,
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildDateField()),
        ]),
        const SizedBox(height: 16),

        _buildPhoneField(),
        const SizedBox(height: 16),

        _buildDropdown(
          label: 'GOVERNORATE', icon: Icons.location_on_outlined, hint: 'Select governorate',
          items: _governorates.map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!))).toList(),
          value: _selectedGovernorate, onChanged: (v) => setState(() => _selectedGovernorate = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),

        _buildAddressField(),
        const SizedBox(height: 16),

        _buildFileUpload(label: 'Profile Picture', icon: Icons.camera_alt_outlined, file: _profilePic, defaultText: 'Click to upload photo', onTap: () 
        async {
          if (_isPickingImage) return;
            _isPickingImage = true;
            try {
              final XFile? img = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (img != null) {
                setState(() {
                  _profilePic = File(img.path);
                });
              }
            } catch (e) {
              debugPrint(e.toString());
            }
            _isPickingImage = false;
        }),
        const SizedBox(height: 24),

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
            onTap: _handleReset,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Center(child: Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF718096)))),
            ),
          )),
        ]),
      ]),
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
        child: DropdownButtonFormField<String>(value: value, hint: Text(hint, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14)), isExpanded: true, decoration: InputDecoration(border: InputBorder.none, prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0), size: 20), contentPadding: const EdgeInsets.symmetric(vertical: 8)), items: items, onChanged: onChanged, validator: validator),
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
        child: TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Padding(padding: EdgeInsets.only(left: 15, right: 4), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('+20', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)))])), hintText: '1XXXXXXXXX', hintStyle: TextStyle(color: Color(0xFFA0AEC0)), contentPadding: EdgeInsets.symmetric(vertical: 16)), validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v.length != 10) return 'Invalid'; return null; }),
      ),
      if (_phoneError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_phoneError!, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
    ]);
  }

  Widget _buildAddressField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FULL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A5568), letterSpacing: 0.8)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextFormField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Street, Building, Apartment', hintStyle: TextStyle(color: Color(0xFFA0AEC0)), contentPadding: EdgeInsets.all(16)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
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
    if (_profilePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload profile picture'), backgroundColor: Color(0xFFE53E3E)));
      return;
    }
    if (_dobController.text.isEmpty) {
      setState(() {
        _dobError = 'Required';
        });
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => NurseFormStep2Screen(
      gender: _selectedGender!, phone: '0${_phoneController.text.trim()}',
      address: _addressController.text.trim(), governorate: _selectedGovernorate!,
      profilePic: _profilePic!, dateOfBirth: _dobController.text,
    )));
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() { _selectedGender = null; _selectedGovernorate = null; _profilePic = null; });
    _phoneController.clear(); _addressController.clear(); _dobController.clear();
  }

  @override
  void dispose() { _phoneController.dispose(); _addressController.dispose(); _dobController.dispose(); super.dispose(); }
}

// ==================== Nurse Step 2 ====================
class NurseFormStep2Screen extends StatelessWidget {
  final String gender, phone, address, governorate, dateOfBirth;
  final File profilePic;

  const NurseFormStep2Screen({super.key, required this.gender, required this.phone, required this.address, required this.governorate, required this.profilePic, required this.dateOfBirth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: NurseFormStep2(gender: gender, phone: phone, address: address, governorate: governorate, profilePic: profilePic, dateOfBirth: dateOfBirth),
          ),
        ),
      ),
    );
  }
}

class NurseFormStep2 extends StatefulWidget {
  final String gender, phone, address, governorate, dateOfBirth;
  final File profilePic;

  const NurseFormStep2({super.key, required this.gender, required this.phone, required this.address, required this.governorate, required this.profilePic, required this.dateOfBirth});

  @override
  State<NurseFormStep2> createState() => _NurseFormStep2State();
}

class _NurseFormStep2State extends State<NurseFormStep2> {
  File? _nationalIdFront, _nationalIdBack, _excellenceCert, _graduationCert, _syndicateCard, _practicePerm;
  bool _isLoading = false;
  bool _isPickingImage = false;
  final ImagePicker _picker = ImagePicker();


  Future<void> _pickFile(String type) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          switch (type) {
            case 'front':
              _nationalIdFront = File(file.path);
              break;
            case 'back':
              _nationalIdBack = File(file.path);
              break;
            case 'excellence':
              _excellenceCert = File(file.path);
              break;
            case 'graduation':
              _graduationCert = File(file.path);
              break;
            case 'syndicate':
              _syndicateCard = File(file.path);
              break;
            case 'practice':
              _practicePerm = File(file.path);
              break;
          }
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

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(width: 60, height: 60,
        decoration: BoxDecoration(color: const Color(0xFFEBF8FF), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.school_outlined, color: Color(0xFF1D89E4), size: 28)),
      const SizedBox(height: 16),
      const Text('Professional Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
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

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _buildFileUpload(label: 'National ID (Front)', icon: Icons.credit_card, file: _nationalIdFront, defaultText: 'Upload Front', onTap: () => _pickFile('front'))),
        const SizedBox(width: 12),
        Expanded(child: _buildFileUpload(label: 'National ID (Back)', icon: Icons.credit_card, file: _nationalIdBack, defaultText: 'Upload Back', onTap: () => _pickFile('back'))),
      ]),
      const SizedBox(height: 16),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _buildFileUpload(label: 'Excellence Cert.', icon: Icons.workspace_premium_outlined, file: _excellenceCert, defaultText: 'Upload', onTap: () => _pickFile('excellence'))),
        const SizedBox(width: 12),
        Expanded(child: _buildFileUpload(label: 'Graduation Cert.', icon: Icons.school_outlined, file: _graduationCert, defaultText: 'Upload', onTap: () => _pickFile('graduation'))),
      ]),
      const SizedBox(height: 16),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _buildFileUpload(label: 'Syndicate Card', icon: Icons.badge_outlined, file: _syndicateCard, defaultText: 'Upload', onTap: () => _pickFile('syndicate'))),
        const SizedBox(width: 12),
        Expanded(child: _buildFileUpload(label: 'Practice Permit', icon: Icons.assignment_outlined, file: _practicePerm, defaultText: 'Upload', onTap: () => _pickFile('practice'))),
      ]),
      const SizedBox(height: 24),

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
    if (_nationalIdFront == null || _nationalIdBack == null || _excellenceCert == null || _graduationCert == null || _syndicateCard == null || _practicePerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required files'), backgroundColor: Color(0xFFE53E3E)));
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.nurseRegister(
      gender: widget.gender, phoneNumber: widget.phone,
      address: widget.address, governorate: widget.governorate,
      profilePic: widget.profilePic, nationalIdFront: _nationalIdFront!,
      nationalIdBack: _nationalIdBack!, dateOfBirth: widget.dateOfBirth,
      excellenceCert: _excellenceCert!, syndicateCard: _syndicateCard!,
      practicePerm: _practicePerm!, graduationCert: _graduationCert!,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Error'), backgroundColor: const Color(0xFFE53E3E)),
        );
      }
    }
  }
}