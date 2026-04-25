import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kError       = Color(0xFFE53E3E);

const List<Map<String, String>> kGovernorates = [
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

class PatientEditProfileScreen extends StatefulWidget {
  const PatientEditProfileScreen({super.key});

  @override
  State<PatientEditProfileScreen> createState() => _PatientEditProfileScreenState();
}

class _PatientEditProfileScreenState extends State<PatientEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _addressCtrl   = TextEditingController();

  String? _selectedGovernorate;
  String? _profilePicUrl;
  File?   _pickedImage;
  bool    _isLoading = true;
  bool    _isSaving  = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getPatientProfile();
    if (result.success) {
      final data = result.data;
      _usernameCtrl.text = data['username'] ?? '';
      final phone = data['phone_number'] ?? '';
      _phoneCtrl.text = phone.startsWith('0') ? phone.substring(1) : phone;
      _addressCtrl.text = data['address'] ?? '';
      _profilePicUrl = data['profile_pic'];
      final gov = data['governorate']?.toString().toLowerCase().replaceAll(' ', '_');
      _selectedGovernorate = kGovernorates.any((g) => g['value'] == gov) ? gov : null;
      setState(() { _isLoading = false; _error = null; });
    } else {
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kBorderColor, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 4))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text('Edit Profile',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kDarkText)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(30)),
                                  child: const Text('Patient Profile',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary)),
                                ),
                              ]),
                              const SizedBox(height: 24),

                              // Photo
                              _buildPhotoSection(),
                              const Divider(height: 36, color: kBorderColor),

                              // Fields
                              _buildField('Username', _usernameCtrl,
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                              const SizedBox(height: 16),
                              _buildPhoneField(),
                              const SizedBox(height: 16),
                              _buildGovernorateField(),
                              const SizedBox(height: 16),
                              _buildAddressField(),
                              const SizedBox(height: 28),

                              // Footer
                              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4B5563),
                                    side: const BorderSide(color: kBorderColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Cancel Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 14),
                                ElevatedButton(
                                  onPressed: _isSaving ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary, foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(width: 20, height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildPhotoSection() {
    ImageProvider img;
    if (_pickedImage != null) {
      img = FileImage(_pickedImage!);
    } else if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
      img = NetworkImage(ApiService.buildMediaUrl(_profilePicUrl));
    } else {
      img = const NetworkImage('https://ui-avatars.com/api/?name=Patient&background=1D89E4&color=fff&size=200');
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(radius: 48, backgroundImage: img, backgroundColor: kBgLight),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile Photo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
              const SizedBox(height: 6),
              const Text('New profile pictures require admin approval.',
                  style: TextStyle(fontSize: 13, color: kTextGray, height: 1.5)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String? Function(String?)? validator, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl, maxLines: maxLines, validator: validator,
          decoration: _inputDec(),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Phone Number'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: kBorderColor, width: 1)),
              ),
              child: const Text('+20',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
            ),
            Expanded(
              child: TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: '1XXXXXXXXX',
                  hintStyle: TextStyle(color: kTextGray, fontSize: 14),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildGovernorateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Governorate'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGovernorate,
          hint: const Text('Select governorate', style: TextStyle(fontSize: 14, color: kTextGray)),
          items: kGovernorates
              .map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGovernorate = v),
          decoration: _inputDec(),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Full Address'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressCtrl,
          decoration: _inputDec(
            hintText: 'Street, Building, Apartment',
            prefixIcon: const Icon(Icons.location_on_outlined, color: kTextGray, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)));

  InputDecoration _inputDec({String? hintText, Widget? prefixIcon}) => InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
    prefixIcon: prefixIcon,
    filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kError)),
  );

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final result = await ApiService.updatePatientProfile(
      username: _usernameCtrl.text.trim(),
      phoneNumber: '0${_phoneCtrl.text.trim()}',
      address: _addressCtrl.text.trim(),
      // brief: '',
      governorate: _selectedGovernorate ?? '',
      profilePic: _pickedImage,
    );
    setState(() => _isSaving = false);
    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Update failed'), backgroundColor: Colors.red),
        );
      }
    }
  }
}