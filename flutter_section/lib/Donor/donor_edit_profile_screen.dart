import 'package:flutter/material.dart';
import '../Donor/donor_profile_screen.dart';
import '../Donor/donor_doctor_requests_screen.dart';
import '../Donor/donor_notifications_screen.dart';
import '../Donor/donor_wallet_screen.dart';
import '../Donor/donor_complaints_screen.dart';
import '../Donor/donor_donation_screen.dart';


const Color _kPrimary     = Color(0xFF1D89E4);
const Color _kBgLight     = Color(0xFFF4F7FC);
const Color _kTextGray    = Color(0xFF718096);
const Color _kBorderColor = Color(0xFFE1E6EC);
const Color _kDarkText    = Color(0xFF1A1C1E);
const Color _kRed         = Color(0xFFEF4444);

class DonorEditProfileScreen extends StatefulWidget {
  const DonorEditProfileScreen({super.key});

  @override
  State<DonorEditProfileScreen> createState() => _DonorEditProfileScreenState();
}

class _DonorEditProfileScreenState extends State<DonorEditProfileScreen> {
  final _nameCtrl    = TextEditingController(text: 'adham Ali');
  final _addressCtrl = TextEditingController(text: 'Maadi, Cairo, Egypt');
  final _phoneCtrl   = TextEditingController(text: '1001234567');
  final _dateCtrl    = TextEditingController(text: '11/12/2026');
  String _governorate = 'Cairo';

  static const _governorates = [
    'Alexandria','Aswan','Asyut','Beheira','Beni Suef','Cairo','Dakahlia','Damietta','Fayoum',
    'Gharbia','Giza','Ismailia','Kafr El Sheikh','Luxor','Matrouh','Menoufia','Minya','New Valley',
    'North Sinai','Port Said','Qalyubia','Qena','Red Sea','Sharqia','Sohag','South Sinai','Suez'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F4F8)),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit  Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kDarkText)),
              const SizedBox(height: 20),

              // ── Avatar section — Row مع Expanded لمنع overflow ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _kBorderColor, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://randomuser.me/api/portraits/men/32.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _kPrimary.withOpacity(0.08),
                              child: const Icon(Icons.person_outline_rounded, color: _kPrimary, size: 34),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 15, height: 15,
                          decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Profile Photo',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kDarkText)),
                        const SizedBox(height: 4),
                        const Text('New profile pictures require admin approval and verification.',
                            style: TextStyle(fontSize: 11, color: _kTextGray)),
                        const Text('Recommended size: 400×400px.',
                            style: TextStyle(fontSize: 11, color: _kTextGray)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Change Photo',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Form fields — كل field في سطر لوحده على موبايل ──
              _FormField(label: 'Full Name', controller: _nameCtrl),
              const SizedBox(height: 14),
              _FormField(label: 'Full Address', controller: _addressCtrl,
                  prefixIcon: Icons.location_on_outlined),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Governorate',
                value: _governorate,
                items: _governorates,
                onChanged: (v) => setState(() => _governorate = v!),
              ),
              const SizedBox(height: 14),
              _FormField(
                label: 'Last Donation Date',
                controller: _dateCtrl,
                suffixIcon: Icons.calendar_today_outlined,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateCtrl.text =
                        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                  }
                },
              ),
              const SizedBox(height: 14),
              _FormField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                prefixText: '+20',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // ── Buttons — Expanded لمنع overflow ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kTextGray,
                        side: const BorderSide(color: _kBorderColor),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel Changes',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: _kDarkText, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text('Donor Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2,
                child: CircleAvatar(radius: 5, backgroundColor: _kRed)),
          ]),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: _kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _kBorderColor, height: 1),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
      {'icon': Icons.local_hospital_outlined,         'label': 'Donation'},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kPrimary)),
                  Text('Medical Portal', style: TextStyle(fontSize: 12, color: _kTextGray)),
                ]),
              ]),
              const SizedBox(height: 32),
              ...items.map((item) {
                final isActive = item['label'] == 'Profile';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isActive ? _kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context);
                        switch (item['label']) {
                          case 'Requests':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorDoctorRequestsScreen())); break;
                          case 'Notifications':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorNotificationsScreen())); break;
                          case 'Wallet':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorWalletScreen())); break;
                          case 'Complaints':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorComplaintsScreen())); break;
                          case 'Profile':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorProfileScreen())); break;
                          case 'Donation':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorDonationScreen())); break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(children: [
                          Icon(item['icon'] as IconData,
                              color: isActive ? Colors.white : const Color(0xFF4B5563), size: 22),
                          const SizedBox(width: 12),
                          Text(item['label'] as String,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : const Color(0xFF4B5563))),
                        ]),
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
}

// ─── Form field ───────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const _FormField({
    required this.label, required this.controller,
    this.prefixIcon, this.suffixIcon, this.prefixText,
    this.keyboardType, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kDarkText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: onTap != null,
          onTap: onTap,
          style: const TextStyle(fontSize: 14, color: _kDarkText),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: _kTextGray)
                : prefixText != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(prefixText!, style: const TextStyle(fontSize: 14, color: _kTextGray, fontWeight: FontWeight.w600)),
                      )
                    : null,
            prefixIconConstraints: prefixText != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: _kTextGray) : null,
          ),
        ),
      ],
    );
  }
}

// ─── Dropdown field ───────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kDarkText)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          items: items.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          style: const TextStyle(fontSize: 14, color: _kDarkText),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}