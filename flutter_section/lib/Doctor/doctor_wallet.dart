import 'package:flutter/material.dart';
import '../Doctor/doctor_profile_screen.dart';
import '../Doctor/doctor_requests_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_complaints.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kGreen = Color(0xFF10B981);
const Color kAmber = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);

class DoctorWalletScreen extends StatefulWidget {
  const DoctorWalletScreen({super.key});

  @override
  State<DoctorWalletScreen> createState() => _DoctorWalletScreenState();
}

class _DoctorWalletScreenState extends State<DoctorWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _transactions = [
    {
      'name': 'Ahmed Ali',
      'type': 'Consultation Fee',
      'amount': 500,
      'incoming': true,
      'date': 'Today, 10:30 AM',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'name': 'Sara Mohamed',
      'type': 'Consultation Fee',
      'amount': 500,
      'incoming': true,
      'date': 'Today, 09:00 AM',
      'avatar': 'https://randomuser.me/api/portraits/women/12.jpg',
    },
    {
      'name': 'Withdrawal',
      'type': 'Bank Transfer',
      'amount': 2000,
      'incoming': false,
      'date': 'Yesterday, 03:00 PM',
      'avatar': null,
    },
    {
      'name': 'Karim Hassan',
      'type': 'Consultation Fee',
      'amount': 500,
      'incoming': true,
      'date': 'Apr 4, 11:00 AM',
      'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
    },
    {
      'name': 'Nour El-Din',
      'type': 'Consultation Fee',
      'amount': 500,
      'incoming': true,
      'date': 'Apr 3, 02:00 PM',
      'avatar': 'https://randomuser.me/api/portraits/men/67.jpg',
    },
    {
      'name': 'Withdrawal',
      'type': 'Bank Transfer',
      'amount': 1500,
      'incoming': false,
      'date': 'Apr 2, 12:00 PM',
      'avatar': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final tab = _tabController.index;
    if (tab == 0) return _transactions;
    if (tab == 1) return _transactions.where((t) => t['incoming'] == true).toList();
    return _transactions.where((t) => t['incoming'] == false).toList();
  }

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
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildHistoryCard(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
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
      title: const Text('Wallet',
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
                      radius: 5, backgroundColor: Color(0xFFEF4444))),
            ],
          ),
          onPressed: () {},
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
              'https://randomuser.me/api/portraits/women/44.jpg'),
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
      {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'active': false},
      {'icon': Icons.list_alt_rounded, 'label': 'Requests', 'active': false},
      {'icon': Icons.notifications_none_rounded, 'label': 'Notifications', 'active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet', 'active': true},
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
        );
        break;
      case 'Requests':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorRequestsScreen()),
        );
        break;
      case 'Notifications':
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const DoctorNotificationsScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DoctorComplaintsScreen()));
        break;
      default:
        break;
    }
  }

  // ── Balance Card ──────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D89E4), Color(0xFF2179C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Wallet Balance',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('EGP',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('12,450.00',
              style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _balanceAction(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Withdraw',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _balanceAction(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceAction(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Total Earned',
            value: '14,450 EGP',
            icon: Icons.trending_up_rounded,
            color: kGreen,
            bg: const Color(0xFFE6F7E6),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            label: 'Withdrawn',
            value: '2,000 EGP',
            icon: Icons.trending_down_rounded,
            color: kRed,
            bg: const Color(0xFFFEE2E2),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextGray)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kDarkText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction History Card ───────────────────────────────────────────────
  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction History',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 16),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: kPrimary,
            unselectedLabelColor: kTextGray,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            indicatorColor: kPrimary,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Income'),
              Tab(text: 'Withdrawals'),
            ],
          ),
          const SizedBox(height: 16),
          // Transaction list
          ..._filtered.map((t) => _transactionRow(t)),
        ],
      ),
    );
  }

  Widget _transactionRow(Map<String, dynamic> t) {
    final isIncoming = t['incoming'] as bool;
    final amount = t['amount'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar or icon
          t['avatar'] != null
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(t['avatar'] as String),
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_outlined,
                      color: kRed, size: 20),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['name'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kDarkText)),
                const SizedBox(height: 2),
                Text(t['type'] as String,
                    style:
                        const TextStyle(fontSize: 12, color: kTextGray)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncoming ? '+' : '-'} $amount EGP',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isIncoming ? kGreen : kRed),
              ),
              const SizedBox(height: 2),
              Text(t['date'] as String,
                  style:
                      const TextStyle(fontSize: 11, color: kTextGray)),
            ],
          ),
        ],
      ),
    );
  }
}