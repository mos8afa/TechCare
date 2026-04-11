import 'package:flutter/material.dart';
import '../Nurse/nurse_profile_screen.dart';
import '../Nurse/nurse_requests_screen.dart';
import '../Nurse/nurse_notifications.dart';
import '../Nurse/nurse_wallet.dart';

const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);

class NurseComplaintsScreen extends StatelessWidget {
  const NurseComplaintsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _appBar(context, 'Complaints'),
      drawer: _drawer(context, 'Complaints'),
      body: const SizedBox.expand(),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────
PreferredSizeWidget _appBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
    leading: Builder(builder: (ctx) => IconButton(
      icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
      onPressed: () => Scaffold.of(ctx).openDrawer())),
    title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
    actions: [
      IconButton(icon: Stack(clipBehavior: Clip.none, children: const [
        Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
        Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
      ]), onPressed: () {}),
      const SizedBox(width: 4),
      const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
      const SizedBox(width: 12),
      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg')),
      const SizedBox(width: 16),
    ],
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: kBorderColor, height: 1)),
  );
}

Widget _drawer(BuildContext context, String activePage) {
  final items = [
    {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
    {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
    {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
    {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
  ];
  return Drawer(backgroundColor: Colors.white, child: SafeArea(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12),
            child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
          Text('Medical Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
        ]),
      ]),
      const SizedBox(height: 32),
      ...items.map((item) {
        final isActive = item['label'] == activePage;
        return Container(margin: const EdgeInsets.only(bottom: 8), child: Material(
          color: isActive ? kPrimary : Colors.transparent, borderRadius: BorderRadius.circular(15),
          child: InkWell(borderRadius: BorderRadius.circular(15),
            onTap: () { Navigator.pop(context); _handleNav(context, item['label'] as String, activePage); },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(children: [
                Icon(item['icon'] as IconData, color: isActive ? Colors.white : const Color(0xFF4B5563), size: 22),
                const SizedBox(width: 12),
                Text(item['label'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF4B5563))),
              ])),
          ),
        ));
      }),
    ]),
  )));
}

void _handleNav(BuildContext context, String label, String currentPage) {
  if (label == currentPage) return;
  switch (label) {
    case 'Profile':       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseProfileScreen())); break;
    case 'Requests':      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseRequestsScreen())); break;
    case 'Notifications': Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseNotificationsScreen())); break;
    case 'Wallet':        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseWalletScreen())); break;
    case 'Complaints':    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseComplaintsScreen())); break;
    default: break;
  }
}