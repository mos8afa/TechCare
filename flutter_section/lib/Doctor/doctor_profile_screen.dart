import 'package:flutter/material.dart';
import '../Doctor/doctor_edit_profile.dart';
import '../Doctor/doctor_edit_slots.dart';
import '../Doctor/doctor_requests_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';

// ─── Color Palette (matching the web CSS variables) ───────────────────────
const Color kPrimary = Color(0xFF1D89E4);
const Color kSecondary = Color(0xFF2179C2);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kGreen = Color(0xFF10B981);
const Color kAmber = Color(0xFFF59E0B);
const Color kDarkText = Color(0xFF1A1C1E);

// ─── Doctor Profile Screen ─────────────────────────────────────────────────
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedDayIndex = 0;

  final List<Map<String, String>> _days = [
    {'name': 'MON', 'num': '14'},
    {'name': 'TUE', 'num': '15'},
    {'name': 'WED', 'num': '16'},
    {'name': 'THU', 'num': '17'},
    {'name': 'FRI', 'num': '18'},
    {'name': 'SAT', 'num': '19'},
  ];

  final List<String> _morningSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
  ];

  final List<String> _eveningSlots = [
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:30 PM',
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
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildBottomGrid(context),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: kDarkText,
        ),
      ),
      actions: [
        _AppBarNotification(),
        const SizedBox(width: 12),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: kBorderColor,
          indent: 16,
          endIndent: 16,
        ),
        const SizedBox(width: 12),
        // Avatar only — no name/specialty
        GestureDetector(
          onTap: () {},
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/44.jpg',
            ),
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
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'active': true,
      },
      {'icon': Icons.list_alt_rounded, 'label': 'Requests', 'active': false},
      {
        'icon': Icons.notifications_none_rounded,
        'label': 'Notifications',
        'active': false,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'active': false,
      },
      {
        'icon': Icons.warning_amber_rounded,
        'label': 'Complaints',
        'active': false,
      },
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
                    child: Image.asset(
                      'img/logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TechCare',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                      Text(
                        'Medical Portal',
                        style: TextStyle(fontSize: 12, color: kTextGray),
                      ),
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
                      onTap: () {
                        final label = item['label'] as String;
                        Navigator.pop(context);
                        _navigateToPage(context, label);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                            ),
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

  // ── Profile Card ─────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar (left) + Rating (right) ────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: const NetworkImage(
                      'https://randomuser.me/api/portraits/women/44.jpg',
                    ),
                    backgroundColor: kBgLight,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Rating — top right
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFBDC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(
                      5,
                      (_) => const Icon(
                        Icons.star_border_rounded,
                        color: kAmber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '0 Reviews',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Name + Verified tag ───────────────────────────────────────
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Dr. Sarah Mansour',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kDarkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 13, color: kPrimary),
                    SizedBox(width: 5),
                    Text(
                      'Verified Doctor',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Specialty ─────────────────────────────────────────────────
          const Text(
            'Senior Cardiologist | Heart Specialist',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // ── 4 Info items ──────────────────────────────────────────────
          Wrap(
            spacing: 32,
            runSpacing: 8,
            children: [
              _infoItem(Icons.payments_outlined, 'Consultation:', '500 EGP'),
              _infoItem(Icons.phone_outlined, 'Phone:', '+20 115 547 7057'),
              _infoItem(
                Icons.email_outlined,
                'Email:',
                'dr.sarah@techcare.com',
              ),
              _infoItem(
                Icons.location_on_outlined,
                'Location:',
                'New Cairo, Cairo Governorate',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Bio ───────────────────────────────────────────────────────
          const Text(
            'Dedicated cardiologist with over 12 years of clinical experience '
            'specializing in non-invasive cardiovascular imaging and preventive '
            'heart health. Committed to providing compassionate, evidence-based '
            'care to improve patients\' quality of life.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // ── Edit button — right aligned ────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorEditProfileScreen(),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kPrimary),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kDarkText,
          ),
        ),
      ],
    );
  }

  // ── Bottom Grid (Time Slots + Financials) ─────────────────────────────────
  Widget _buildBottomGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTimeSlotsCard()),
          const SizedBox(width: 20),
          Expanded(child: _buildFinancialsCard()),
        ],
      );
    }
    return Column(
      children: [
        _buildTimeSlotsCard(),
        const SizedBox(height: 20),
        _buildFinancialsCard(),
      ],
    );
  }

  // ── Time Slots Card ───────────────────────────────────────────────────────
  Widget _buildTimeSlotsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_rounded, color: kPrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kDarkText,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorEditTimeSlotsScreen(),
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined, size: 14),
                label: const Text(
                  'Edit Slots',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(
                    color: kPrimary,
                    style: BorderStyle.solid,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Days carousel (still interactive — selecting the day)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final active = _selectedDayIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: active ? kPrimary : kBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[i]['name']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : kTextGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _days[i]['num']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: active ? Colors.white : kDarkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Morning slots — display only, no interaction
          _sectionLabel('MORNING SLOTS'),
          const SizedBox(height: 10),
          _buildReadOnlySlots(_morningSlots),
          const SizedBox(height: 16),

          // Evening slots — display only, no interaction
          _sectionLabel('EVENING SLOTS'),
          const SizedBox(height: 10),
          _buildReadOnlySlots(_eveningSlots),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: kTextGray,
        letterSpacing: 1.2,
      ),
    );
  }

  // Read-only slots — no GestureDetector, no active state
  Widget _buildReadOnlySlots(List<String> slots) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots
          .map(
            (slot) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kBgLight,
                border: Border.all(color: kBorderColor),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                slot,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Financials Card ───────────────────────────────────────────────────────
  Widget _buildFinancialsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: kPrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Financials & Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kDarkText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorWalletScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View History',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: kBgLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text(
                  'Total Wallet Balance',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                SizedBox(height: 8),
                Text(
                  '12,450.00 EGP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Completed\nRequests',
                  value: '1,248',
                  icon: Icons.check_circle_outline_rounded,
                  color: kGreen,
                  bgColor: const Color(0xFFE6F7E6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  label: 'Pending\nRequests',
                  value: '14',
                  icon: Icons.article_outlined,
                  color: kAmber,
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kTextGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kDarkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Navigation Helper ───────────────────────────────────────────────────
  void _navigateToPage(BuildContext context, String pageLabel) {
    switch (pageLabel) {
      case 'Profile':
        // Already on Profile page
        break;
      case 'Requests':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorRequestsScreen()),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorNotificationsScreen()),
        );
        break;
      case 'Wallet':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorWalletScreen()),
        );
        break;
      case 'Complaints':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorComplaintsScreen()),
        );
        break;
    }
  }
}

// ─── AppBar Notification Widget ────────────────────────────────────────────
class _AppBarNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: const [
          Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF4B5563),
            size: 24,
          ),
          Positioned(
            right: -2,
            top: -2,
            child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444)),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}
