import 'package:flutter/material.dart';
import '../Doctor/doctor_profile_screen.dart';
import '../Doctor/doctor_requests_screen.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';
import '../Doctor/doctor_donation.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kGreen = Color(0xFF10B981);
const Color kAmber = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);

// ── Notification types ────────────────────────────────────────────────────
enum _NotifType {
  newRequest,
  accepted,
  confirmation,
  modified,
  approved,
  commission,
}

extension _NotifTypeExt on _NotifType {
  IconData get icon {
    switch (this) {
      case _NotifType.newRequest:
        return Icons.person_add_outlined;
      case _NotifType.accepted:
        return Icons.check_circle_outline_rounded;
      case _NotifType.confirmation:
        return Icons.receipt_long_outlined;
      case _NotifType.modified:
        return Icons.edit_outlined;
      case _NotifType.approved:
        return Icons.verified_outlined;
      case _NotifType.commission:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color get color {
    switch (this) {
      case _NotifType.newRequest:
        return kPrimary;
      case _NotifType.accepted:
        return kGreen;
      case _NotifType.confirmation:
        return kAmber;
      case _NotifType.modified:
        return kGreen;
      case _NotifType.approved:
        return const Color(0xFF6366F1);
      case _NotifType.commission:
        return kRed;
    }
  }
}

class _Notif {
  final String title;
  final String body;
  final String time;
  final String group;
  final _NotifType type;
  bool read;

  _Notif({
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.type,
    this.read = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  final List<_Notif> _all = [
    _Notif(
      title: 'New Request Received',
      body:
          'You have received a new consultation request from patient Sarah Jenkins.',
      time: '15 mins ago',
      group: 'Today',
      type: _NotifType.newRequest,
    ),
    _Notif(
      title: 'Request Accepted',
      body: 'Request accepted for Consultation #4492. Check your schedule.',
      time: '2 hours ago',
      group: 'Today',
      type: _NotifType.accepted,
      read: true,
    ),
    _Notif(
      title: 'Request Confirmation',
      body:
          'The patient has confirmed the consultation appointment for order #1234.',
      time: '5 hours ago',
      group: 'Today',
      type: _NotifType.confirmation,
      read: true,
    ),
    _Notif(
      title: 'Request Modified',
      body: 'Order details for #5678 have been modified by administration.',
      time: 'Yesterday, 4:20 PM',
      group: 'Yesterday',
      type: _NotifType.modified,
      read: true,
    ),
    _Notif(
      title: 'Request Approved',
      body:
          'Your account verification documents have been approved successfully.',
      time: 'Yesterday, 9:00 AM',
      group: 'Yesterday',
      type: _NotifType.approved,
      read: true,
    ),
    _Notif(
      title: 'Wallet Commission Deducted',
      body: 'Commission deducted for Transaction #8821.',
      time: '2 days ago',
      group: 'Earlier',
      type: _NotifType.commission,
      read: true,
    ),
  ];

  List<String> get _groups {
    final seen = <String>{};
    return _all.map((n) => n.group).where(seen.add).toList();
  }

  List<_Notif> _forGroup(String g) => _all.where((n) => n.group == g).toList();
  int get _unreadCount => _all.where((n) => !n.read).length;

  Widget _buildGroup(String group) {
    final items = _forGroup(group);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            group.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kTextGray,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final notif = entry.value;
              return Column(
                children: [
                  _buildNotifTile(notif),
                  if (i < items.length - 1)
                    const Divider(
                      height: 1,
                      color: kBorderColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNotifTile(_Notif notif) {
    final isUnread = !notif.read;
    return GestureDetector(
      onTap: () => setState(() => notif.read = true),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Container(
                width: 3,
                height: 48,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              const SizedBox(width: 15),

            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: notif.type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.type.icon, color: notif.type.color, size: 20),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kDarkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.time,
                        style: const TextStyle(fontSize: 11, color: kTextGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextGray,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _all.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                /// ✅ NEW TOP ACTIONS ROW (يمين)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_unreadCount > 0)
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          for (final n in _all) n.read = true;
                        }),
                        icon: const Icon(Icons.done_all_rounded, size: 14),
                        label: const Text(
                          'Mark All as Read',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(() => _all.clear()),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: kTextGray,
                        size: 22,
                      ),
                      tooltip: 'Clear All',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ..._groups.map((group) => _buildGroup(group)),

                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Load older notifications',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── AppBar NEW ───────────────────────────────────────────────────────────
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
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: kDarkText,
        ),
      ),
      actions: [
        const _AppBarNotification(),
        const SizedBox(width: 12),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: kBorderColor,
          indent: 16,
          endIndent: 16,
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 20,
          backgroundColor: kBgLight,
          backgroundImage: NetworkImage(
            'https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff',
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

  // ── Notification Icon ────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'active': false,
      },
      {'icon': Icons.list_alt_rounded, 'label': 'Requests', 'active': false},
      {'icon': Icons.local_hospital_outlined,'label': 'Donation','active': false,},
      {'icon': Icons.notifications_none_rounded,'label': 'Notifications','active': true,},
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        Navigator.pop(context);
                        _handleNav(context, item['label'] as String);
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

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Profile':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
        );
        break;
      case 'Requests':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorRequestsScreen()),
        );
        break;
      case 'Wallet':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorWalletScreen()),
        );
        break;
      case 'Complaints':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorComplaintsScreen()),
        );
        break;
      case 'Donation':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDonationScreen()),
        );
        break;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: kTextGray.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextGray,
            ),
          ),
        ],
      ),
    );
  }
}

// 🔔 Notification icon widget
class _AppBarNotification extends StatelessWidget {
  const _AppBarNotification();

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
