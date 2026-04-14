import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);
const Color kError      = Color(0xFFE53E3E);

const List<String> kGovernorates = [
  'Alexandria','Aswan','Assiut','Beheira','Beni Suef','Cairo','Dakahlia',
  'Damietta','Faiyum','Gharbia','Giza','Ismailia','Kafr El Sheikh','Luxor',
  'Matrouh','Minya','Monufia','New Valley','North Sinai','Port Said',
  'Qalyubia','Qena','Red Sea','Sharqia','Sohag','South Sinai','Suez',
];

class NurseEditProfileScreen extends StatefulWidget {
  const NurseEditProfileScreen({super.key});
  @override
  State<NurseEditProfileScreen> createState() => _NurseEditProfileScreenState();
}

class _NurseEditProfileScreenState extends State<NurseEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _briefCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  String? _selectedGov;
  File? _pickedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _initialData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ApiService.getNurseProfile();
    if (result.success) {
      final data = result.data;
      String? govFromServer = data['governorate'];
      String? matchedGov;
      if (govFromServer != null) {
        try {
          matchedGov = kGovernorates.firstWhere(
            (g) => g.toLowerCase() == govFromServer.toLowerCase(),
          );
        } catch (_) {
          matchedGov = null;
        }
      }
      setState(() {
        _initialData = data;
        _usernameCtrl.text = data['username'] ?? '';
        _phoneCtrl.text = data['phone_number'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _briefCtrl.text = data['brief'] ?? '';
        _selectedGov = matchedGov;
        _isLoading = false;
      });
    } else {
      if (result.error == 'Session expired') {
        await ApiService.clearTokens();
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        return;
      }
      setState(() {
        _error = result.error ?? 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) setState(() => _pickedImage = File(p.path));
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final result = await ApiService.updateNurseProfile(
      username: _usernameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      brief: _briefCtrl.text.trim(),
      governorate: _selectedGov ?? '',
      profilePic: _pickedImage,
    );
    setState(() => _isSaving = false);
    if (result.success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to save changes')),
      );
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose(); _addressCtrl.dispose();
    _briefCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 4))]),
                      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Header
                        const Text('Edit Professional Profile',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kDarkText)),
                        const SizedBox(height: 24),

                        // Photo
                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          CircleAvatar(radius: 48,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!) as ImageProvider
                                : (_initialData?['profile_pic'] != null
                                    ? NetworkImage(ApiService.buildMediaUrl(_initialData!['profile_pic']))
                                    : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=1D89E4&color=fff')),
                            backgroundColor: kBgLight),
                          const SizedBox(width: 20),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Profile Photo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
                            const SizedBox(height: 4),
                            const Text('Requires admin approval. Recommended: 400×400px.',
                                style: TextStyle(fontSize: 12, color: kTextGray)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_rounded, size: 15),
                              label: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11), elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ])),
                        ]),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: kBorderColor)),

                        // Form fields
                        LayoutBuilder(builder: (_, cons) {
                          final isWide = cons.maxWidth > 500;
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            isWide
                              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(child: _field('Username', _usernameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _phoneField()),
                                ])
                              : Column(children: [
                                  _field('Username', _usernameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null),
                                  const SizedBox(height: 16),
                                  _phoneField(),
                                ]),
                            const SizedBox(height: 16),
                            _field('Bio / Professional Summary', _briefCtrl, maxLines: 4),
                            const SizedBox(height: 16),
                            isWide
                              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(child: _governorateField()),
                                  const SizedBox(width: 20),
                                  Expanded(child: _addressField()),
                                ])
                              : Column(children: [
                                  _governorateField(),
                                  const SizedBox(height: 16),
                                  _addressField(),
                                ]),
                          ]);
                        }),
                        const SizedBox(height: 28),

                        // Footer
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4B5563),
                                side: const BorderSide(color: kBorderColor),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Cancel Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13), elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ])),
                    ),
                  )),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: kDarkText),
          onPressed: () => Navigator.pop(context)),
      title: const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(color: kBorderColor, height: 1)),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl(label), const SizedBox(height: 6),
      TextFormField(controller: ctrl, maxLines: maxLines, validator: validator, decoration: _dec()),
    ]);
  }

  Widget _phoneField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _lbl('Contact Phone Number'), const SizedBox(height: 6),
    Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor)),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: kBorderColor))),
            child: const Text('+20', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)))),
        Expanded(child: TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(border: InputBorder.none, hintText: '1001234567',
                hintStyle: TextStyle(color: kTextGray), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)))),
      ]),
    ),
  ]);

  Widget _governorateField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _lbl('Governorate / Location'), const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      value: _selectedGov,
      hint: const Text('Select governorate', style: TextStyle(fontSize: 14, color: kTextGray)),
      items: kGovernorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _selectedGov = v),
      decoration: _dec(), borderRadius: BorderRadius.circular(12), dropdownColor: Colors.white,
    ),
  ]);

  Widget _addressField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _lbl('Address'), const SizedBox(height: 6),
    TextFormField(controller: _addressCtrl,
        decoration: _dec(hint: 'Street, Building, Apartment',
            prefix: const Icon(Icons.location_on_outlined, color: kTextGray, size: 18))),
  ]);

  Widget _lbl(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)));

  InputDecoration _dec({String? hint, Widget? prefix}) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
    prefixIcon: prefix, filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kError)),
  );
}