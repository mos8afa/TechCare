import 'package:flutter/material.dart';
import '../Patient/patient_profile_screen.dart';
import '../Patient/patient_doctor_requests_screen.dart';
import '../Patient/patient_wallet.dart';
import '../Patient/patient_complaints.dart';
import '../Patient/patient_donation.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kGreen = Color(0xFF10B981);

class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends State<PatientNotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'name': 'Dr. Ahmed Ali',
      'message': 'Appointment Confirmed — Tomorrow 10:00 AM',
      'time': '2 min ago',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'read': false,
    },
    {
      'name': 'Nurse Sara Mohamed',
      'message': 'Care instructions updated for your last visit',
      'time': '15 min ago',
      'avatar': 'https://randomuser.me/api/portraits/women/12.jpg',
      'read': false,
    },
    {
      'name': 'Pharmacy',
      'message': 'Your prescription is ready for pickup',
      'time': '1 hr ago',
      'avatar': 'https://randomuser.me/api/portraits/women/65.jpg',
      'read': true,
    },
    {
      'name': 'Dr. Karim Hassan',
      'message': 'Consultation summary available',
      'time': '3 hr ago',
      'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      'read': true,
    },
    {
      'name': 'TechCare Support',
      'message': 'Your complaint has been received',
      'time': 'Yesterday',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _notifications.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _buildNotificationCard(_notifications[i], i),
            ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !(n['read'] as bool)).length;
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
      title: const Text('Notifications',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: () => setState(() {
              for (final n in _notifications) {
                n['read'] = true;
              }
            }),
            child: const Text('Mark all read',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary)),
          ),
        const SizedBox(width: 4),
        const VerticalDivider(
            width: 1,
            thickness: 1,
            color: kBorderColor,
            indent: 16,
            endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/1.jpg'), // patient avatar
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'active': false
      },
      {
        'icon': Icons.list_alt_rounded,
        'label': 'Requests',
        'active': false
      },
      {
        'icon': Icons.local_hospital_outlined,
        'label': 'Donation',
        'active': false
      },
      {
        'icon': Icons.notifications_none_rounded,
        'label': 'Notifications',
        'active': true
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'active': false
      },
      {
        'icon': Icons.warning_amber_rounded,
        'label': 'Complaints',
        'active': false
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
                      Text('Patient Portal',
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
                      onTap: () {
                        Navigator.pop(context);
                        _handleNav(context, item['label'] as String);
                      },
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

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Profile':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
        );
        break;
      case 'Requests':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDoctorRequestsScreen()),
        );
        break;
      case 'Wallet':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientWalletScreen()),
        );
        break;
      case 'Complaints':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientComplaintsScreen()),
        );
        break;
      case 'Donation':
        Navigator.pushReplacement(
          context,
            MaterialPageRoute(builder: (_) => const PatientDonationScreen()),
        );
        break;
      default:
        break;
    }
  }

  // ── Notification Card ─────────────────────────────────────────────────────
  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    final isUnread = !(notif['read'] as bool);
    return GestureDetector(
      onTap: () => setState(() => notif['read'] = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? kPrimary.withOpacity(0.25) : kBorderColor,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? kPrimary.withOpacity(0.06)
                  : const Color(0x05000000),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + unread dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notif['avatar'] as String),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notif['name'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: kDarkText)),
                      Text(notif['time'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: kTextGray)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif['message'] as String,
                      style: TextStyle(
                          fontSize: 13,
                          color: isUnread
                              ? const Color(0xFF374151)
                              : kTextGray,
                          height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: kTextGray.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextGray)),
        ],
      ),
    );
  }
}