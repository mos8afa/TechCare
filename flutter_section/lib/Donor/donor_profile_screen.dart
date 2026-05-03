import 'package:flutter/material.dart';
import '../Donor/donor_doctor_requests_screen.dart';
import '../Donor/donor_notifications_screen.dart';
import '../Donor/donor_wallet_screen.dart';
import '../Donor/donor_complaints_screen.dart';
import '../Donor/donor_edit_profile_screen.dart';
import '../Donor/donor_donation_screen.dart';

// ─── Colors ───────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ─── Dashboard Screen ─────────────────────────────────────────────────────
class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key});

  // ── Static mock data (replace with API later) ──────────────────────────
  static const _name        = 'Adham Ali';
  static const _email       = 'adam.j@techcare.com';
  static const _phone       = '+1 (555) 234-5678';
  static const _governorate = 'Cairo';
  static const _address     = '123 Medical Drive, Suite 400';
  static const _balance     = '\$1,240.50';
  static const _bloodType   = 'O+';
  static const _lastDate    = 'Oct 12, 2023';
  static const _totalDon    = '5 Times';

  static const _stats = [
    {'label': 'Doctor Requests',   'count': '12', 'pct': 0.60, 'color': kPrimary},
    {'label': 'Nurse Requests',    'count': '8',  'pct': 0.40, 'color': kGreen},
    {'label': 'Pharmacy Requests', 'count': '15', 'pct': 0.75, 'color': kAmber},
    {'label': 'Donation Requests', 'count': '8',  'pct': 0.40, 'color': kRed},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile card ──────────────────────────────────────
            _ProfileCard(
              name:        _name,
              email:       _email,
              phone:       _phone,
              governorate: _governorate,
              address:     _address,
              onEdit: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonorEditProfileScreen())),
            ),
            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:    2,
                mainAxisSpacing:   16,
                crossAxisSpacing:  16,
                childAspectRatio:  1.55,
              ),
              itemBuilder: (_, i) {
                final s = _stats[i];
                return _StatCard(
                  label: s['label'] as String,
                  count: s['count'] as String,
                  pct:   s['pct']   as double,
                  color: s['color'] as Color,
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Wallet + Donor info row ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet - تقليل المرونة لتقليل الحجم
                Expanded(
                  flex: 2,
                  child: _WalletCard(balance: _balance),
                ),
                const SizedBox(width: 16),
                // Blood type / Last date / Total
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _DonorInfoTile(
                        icon:    Icons.water_drop_outlined,
                        iconBg:  kPrimary.withOpacity(0.10),
                        iconColor: kPrimary,
                        label:   'BLOOD TYPE',
                        value:   _bloodType,
                        valueSz: 20,
                      ),
                      const SizedBox(height: 12),
                      _DonorInfoTile(
                        icon:    Icons.calendar_today_outlined,
                        iconBg:  kAmber.withOpacity(0.10),
                        iconColor: kAmber,
                        label:   'LAST DATE',
                        value:   _lastDate,
                        valueSz: 12,
                      ),
                      const SizedBox(height: 12),
                      _DonorInfoTile(
                        icon:    Icons.emoji_events_outlined,
                        iconBg:  kGreen.withOpacity(0.10),
                        iconColor: kGreen,
                        label:   'TOTAL',
                        value:   _totalDon,
                        valueSz: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────
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
      title: const Text('Donor Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2,
                child: CircleAvatar(radius: 5, backgroundColor: kRed)),
          ]),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DonorNotificationsScreen())),
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────────────────
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
              // Logo
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('TechCare',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
                  Text('Medical Portal',
                      style: TextStyle(fontSize: 12, color: kTextGray)),
                ]),
              ]),
              const SizedBox(height: 32),
              ...items.map((item) {
                final isActive = item['label'] == 'Profile';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isActive ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context);
                        _handleNav(context, item['label'] as String);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(children: [
                          Icon(item['icon'] as IconData,
                              color: isActive ? Colors.white : const Color(0xFF4B5563), size: 22),
                          const SizedBox(width: 12),
                          Text(item['label'] as String,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600,
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

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Requests':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorDoctorRequestsScreen()));
        break;
      case 'Notifications':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorWalletScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorComplaintsScreen()));
        break;
      case 'Donation':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorDonationScreen()));
      default:
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

// ── Profile card ──────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name, email, phone, governorate, address;
  final VoidCallback onEdit;
  const _ProfileCard({
    required this.name, required this.email, required this.phone,
    required this.governorate, required this.address, required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorderColor, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: kPrimary.withOpacity(0.08),
                      child: const Icon(Icons.person_outline_rounded, color: kPrimary, size: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kDarkText)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 20, runSpacing: 10,
                      children: [
                        _InfoItem(icon: Icons.email_outlined,    text: email),
                        _InfoItem(icon: Icons.phone_outlined,    text: phone),
                        _InfoItem(icon: Icons.location_on_outlined, text: governorate),
                        _InfoItem(icon: Icons.home_outlined,     text: address),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // زر Edit Profile في أسفل اليمين
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: kTextGray),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 13, color: kTextGray)),
    ]);
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, count;
  final double pct;
  final Color  color;
  const _StatCard({required this.label, required this.count, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextGray)),
              ),
              Text(count,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(pct * 100).toInt()}% of monthly average',
              style: const TextStyle(fontSize: 11, color: kTextGray)),
        ],
      ),
    );
  }
}

// ── Wallet card (تم تقليل الحجم) ───────────────────────────────────────────
class _WalletCard extends StatelessWidget {
  final String balance;
  const _WalletCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('TechCare Wallet',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText)),
                SizedBox(height: 2),
                Text('Manage payments',
                    style: TextStyle(fontSize: 10, color: kTextGray)),
              ]),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: kPrimary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('AVAILABLE BALANCE',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                  color: kTextGray, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(balance,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kPrimary)),
        ],
      ),
    );
  }
}

// ── Donor info tile (تم تقليل الحجم أيضاً) ─────────────────────────────────
class _DonorInfoTile extends StatelessWidget {
  final IconData icon;
  final Color    iconBg, iconColor;
  final String   label, value;
  final double   valueSz;
  const _DonorInfoTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.value, required this.valueSz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800,
                  color: kTextGray, letterSpacing: 0.6)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(fontSize: valueSz, fontWeight: FontWeight.w800, color: kDarkText)),
        ]),
      ]),
    );
  }
}