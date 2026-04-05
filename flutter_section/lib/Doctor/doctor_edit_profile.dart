import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─── Color Palette ────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF1D89E4);
const Color kSecondary = Color(0xFF2179C2);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kError = Color(0xFFE53E3E);

// ─── Egypt Governorates ───────────────────────────────────────────────────
const List<String> kGovernorates = [
  'Alexandria', 'Aswan', 'Assiut', 'Beheira', 'Beni Suef', 'Cairo',
  'Dakahlia', 'Damietta', 'Faiyum', 'Gharbia', 'Giza', 'Ismailia',
  'Kafr El Sheikh', 'Luxor', 'Matrouh', 'Minya', 'Monufia', 'New Valley',
  'North Sinai', 'Port Said', 'Qalyubia', 'Qena', 'Red Sea', 'Sharqia',
  'Sohag', 'South Sinai', 'Suez',
];

// ─── Edit Profile Screen ──────────────────────────────────────────────────
class DoctorEditProfileScreen extends StatefulWidget {
  const DoctorEditProfileScreen({super.key});

  @override
  State<DoctorEditProfileScreen> createState() =>
      _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState extends State<DoctorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl =
      TextEditingController(text: 'Dr. Sarah Mansour');
  final _phoneCtrl = TextEditingController(text: '1001234567');
  final _bioCtrl = TextEditingController(
      text:
          'Experienced cardiologist with over 10 years of practice in interventional cardiology and preventive heart care. Committed to providing personalized patient treatment plans.');
  final _priceCtrl = TextEditingController(text: '500');
  final _addressCtrl = TextEditingController();

  String? _selectedGovernorate;
  File? _pickedImage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 14,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardHeader(),
                    const SizedBox(height: 24),
                    _buildPhotoSection(),
                    const Divider(height: 36, color: kBorderColor),
                    _buildFormGrid(),
                    const SizedBox(height: 28),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text('Edit Profile',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: const [
              Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF4B5563), size: 24),
              Positioned(
                right: -2,
                top: -2,
                child: CircleAvatar(
                    radius: 5, backgroundColor: Color(0xFFEF4444)),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(
            width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {},
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/women/44.jpg'),
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'active': true},
      {'icon': Icons.list_alt_rounded, 'label': 'Requests', 'active': false},
      {'icon': Icons.notifications_none_rounded, 'label': 'Notifications', 'active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet', 'active': false},
      {'icon': Icons.warning_amber_rounded, 'label': 'Complaints', 'active': false},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('img/logo.png',
                        width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('TechCare',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kPrimary)),
                      Text('Medical Portal',
                          style: TextStyle(fontSize: 12, color: kTextGray)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ...items.map((item) {
                final isActive = item['active'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isActive ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Icon(item['icon'] as IconData,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                                size: 22),
                            const SizedBox(width: 12),
                            Text(item['label'] as String,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card Header ───────────────────────────────────────────────────────────
  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Edit Profile',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: kDarkText)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text('Doctor Profile',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPrimary)),
        ),
      ],
    );
  }

  // ── Photo Section ─────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        CircleAvatar(
          radius: 52,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!) as ImageProvider
              : const NetworkImage(
                  'https://randomuser.me/api/portraits/women/44.jpg'),
          backgroundColor: kBgLight,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile Photo',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDarkText)),
              const SizedBox(height: 6),
              const Text(
                'New profile pictures require admin approval and verification.\nRecommended size: 400×400px.',
                style: TextStyle(
                    fontSize: 13, color: kTextGray, height: 1.5),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: const Text('Change Photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Form Grid ─────────────────────────────────────────────────────────────
  Widget _buildFormGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      final fields = [
        _buildTextField(
          label: 'Username',
          controller: _usernameCtrl,
          validator: (v) =>
              v == null || v.isEmpty ? 'Username is required' : null,
        ),
        _buildPhoneField(),
        _buildTextField(
          label: 'Bio / Professional Summary',
          controller: _bioCtrl,
          maxLines: 4,
          fullWidth: true,
          validator: (v) => null,
        ),
        _buildPriceField(),
        _buildGovernorateField(),
        _buildAddressField(),
      ];

      if (isWide) {
        // Build two-column layout manually
        final List<Widget> rows = [];
        int i = 0;
        while (i < fields.length) {
          final f = fields[i];
          // Check if field is full-width (Bio, Address)
          if (i == 2 || i == 5) {
            rows.add(f);
            rows.add(const SizedBox(height: 20));
            i++;
          } else {
            final next = i + 1 < fields.length &&
                    (i + 1 != 2 && i + 1 != 5)
                ? fields[i + 1]
                : null;
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: f),
                if (next != null) ...[
                  const SizedBox(width: 20),
                  Expanded(child: next),
                ],
              ],
            ));
            rows.add(const SizedBox(height: 20));
            i += next != null ? 2 : 1;
          }
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: rows);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields
            .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 20), child: f))
            .toList(),
      );
    });
  }

  // ── Individual Form Fields ─────────────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool fullWidth = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Contact Phone Number'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: kBorderColor, width: 1)),
                ),
                child: const Text('+20',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563))),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    hintText: '1001234567',
                    hintStyle: TextStyle(color: kTextGray, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Consultation Price'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(suffixText: 'EGP'),
        ),
      ],
    );
  }

  Widget _buildGovernorateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Governorate / Location'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          hint: const Text('Select governorate',
              style: TextStyle(fontSize: 14, color: kTextGray)),
          items: kGovernorates
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGovernorate = v),
          decoration: _inputDecoration(),
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
        _fieldLabel('Clinic Address'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressCtrl,
          decoration: _inputDecoration(
            hintText: 'Street, Building, Apartment',
            prefixIcon: const Icon(Icons.location_on_outlined,
                color: kTextGray, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151)));
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? suffixText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
      suffixText: suffixText,
      suffixStyle: const TextStyle(color: kTextGray, fontSize: 12),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kError),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4B5563),
            side: const BorderSide(color: kBorderColor),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Cancel Changes',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 14),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: call API
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Save Changes',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}