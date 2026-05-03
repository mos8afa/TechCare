import 'package:flutter/material.dart';
import '../Patient/patient_profile_screen.dart';
import '../Patient/patient_doctor_requests_screen.dart';
import '../Patient/patient_wallet.dart';
import '../Patient/patient_complaints.dart';
import '../Patient/patient_notifications.dart';


const Color _kPrimary     = Color(0xFF1D89E4);
const Color _kBgLight     = Color(0xFFF4F7FC);
const Color _kTextGray    = Color(0xFF718096);
const Color _kBorderColor = Color(0xFFE1E6EC);
const Color _kDarkText    = Color(0xFF1A1C1E);
const Color _kRed         = Color(0xFFEF4444);

const List<Map<String, dynamic>> _navItems = [
  {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
  {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
  {'icon': Icons.local_hospital_outlined,         'label': 'Donation'},
  {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
  {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
  {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
];

class PatientDonationScreen extends StatelessWidget {
  const PatientDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: _kDarkText, size: 26),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Donation',
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
      ),

      drawer: _buildDrawer(context),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_hospital_outlined,
                  size: 52, color: _kPrimary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            const Text('Donation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kDarkText)),
            const SizedBox(height: 8),
            const Text('No donations yet',
                style: TextStyle(fontSize: 14, color: _kTextGray)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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

              ..._navItems.map((item) {
                final isActive = item['label'] == 'Donation';

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
                          case 'Profile':
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PatientProfileScreen()));
                            break;

                          case 'Requests':
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PatientDoctorRequestsScreen()));
                            break;

                          case 'Notifications':
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()));
                            break;

                          case 'Wallet':
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PatientWalletScreen()));
                            break;

                          case 'Complaints':
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PatientComplaintsScreen()));
                            break;
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