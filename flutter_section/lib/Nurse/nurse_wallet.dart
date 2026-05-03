import 'package:flutter/material.dart';
import '../Nurse/nurse_profile_screen.dart';
import '../Nurse/nurse_requests_screen.dart';
import '../Nurse/nurse_notifications.dart';
import '../Nurse/nurse_complaints.dart';
import '../Nurse/nurse_donation.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kGreen = Color(0xFF10B981);
const Color kAmber = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);

class _Transaction {
  final String name;
  final String date;
  final String type;   // 'Care Service' | 'Commission'
  final double amount;
  final bool isDeduction;
  final String? initials;

  const _Transaction({
    required this.name,
    required this.date,
    required this.type,
    required this.amount,
    required this.isDeduction,
    this.initials,
  });
}

class NurseWalletScreen extends StatefulWidget {
  const NurseWalletScreen({super.key});

  @override
  State<NurseWalletScreen> createState() => _NurseWalletScreenState();
}

class _NurseWalletScreenState extends State<NurseWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _showAll = false;

  final List<_Transaction> _transactions = const [
    _Transaction(
      name: 'Layla Mahmoud',
      date: 'Oct 24, 2023',
      type: 'Care Service',
      amount: 350,
      isDeduction: false,
      initials: 'LM',
    ),
    _Transaction(
      name: 'Platform Commission',
      date: 'Oct 24, 2023',
      type: 'Commission',
      amount: 35,
      isDeduction: true,
    ),
    _Transaction(
      name: 'Omar Youssef',
      date: 'Oct 23, 2023',
      type: 'Care Service',
      amount: 350,
      isDeduction: false,
      initials: 'OY',
    ),
    _Transaction(
      name: 'Hassan Ibrahim',
      date: 'Oct 23, 2023',
      type: 'Care Service',
      amount: 350,
      isDeduction: false,
      initials: 'HI',
    ),
    _Transaction(
      name: 'Nadia Fathi',
      date: 'Oct 22, 2023',
      type: 'Care Service',
      amount: 350,
      isDeduction: false,
      initials: 'NF',
    ),
    _Transaction(
      name: 'Platform Commission',
      date: 'Oct 22, 2023',
      type: 'Commission',
      amount: 52.5,
      isDeduction: true,
    ),
    _Transaction(
      name: 'Sara Mahmoud',
      date: 'Oct 21, 2023',
      type: 'Care Service',
      amount: 350,
      isDeduction: false,
      initials: 'SM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<_Transaction> get _filtered {
    switch (_tab.index) {
      case 1:
        return _transactions.where((t) => !t.isDeduction).toList();
      case 2:
        return _transactions.where((t) => t.isDeduction).toList();
      default:
        return _transactions;
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income & Earnings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Overview of your professional earnings from care services.',
              style: TextStyle(fontSize: 13, color: kTextGray),
            ),
            const SizedBox(height: 24),
            _buildTopSection(),
            const SizedBox(height: 24),
            _buildTransactionsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 480;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 260, child: _buildBalanceCard()),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildMetricCard(
                      icon: Icons.medical_services_outlined,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: kPrimary,
                      label: 'CARE INCOME',
                      sublabel: 'This Month',
                      value: '8,750',
                      valueColor: kDarkText,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      icon: Icons.percent_rounded,
                      iconBg: const Color(0xFFFFF3E0),
                      iconColor: kAmber,
                      label: 'PLATFORM FEES (10%)',
                      sublabel: 'Standard Commission',
                      value: '-875',
                      valueColor: kRed,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      icon: Icons.savings_outlined,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: kPrimary,
                      label: 'NET PROFIT',
                      sublabel: 'Final Earnings',
                      value: '7,875',
                      valueColor: kPrimary,
                      valueLarge: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 12),
            _buildMetricCard(
              icon: Icons.medical_services_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: kPrimary,
              label: 'CARE INCOME',
              sublabel: 'This Month',
              value: '8,750',
              valueColor: kDarkText,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              icon: Icons.percent_rounded,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: kAmber,
              label: 'PLATFORM FEES (10%)',
              sublabel: 'Standard Commission',
              value: '-875',
              valueColor: kRed,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              icon: Icons.savings_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: kPrimary,
              label: 'NET PROFIT',
              sublabel: 'Final Earnings',
              value: '7,875',
              valueColor: kPrimary,
              valueLarge: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D89E4), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '7,875.00',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const Text(
            'EGP',
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          _walletBtn(Icons.account_balance_outlined, 'Withdraw to Bank', () {}),
          const SizedBox(height: 10),
          _walletBtn(Icons.add_rounded, 'Add Funds', _showAddFundsModal),
        ],
      ),
    );
  }

  Widget _walletBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String sublabel,
    required String value,
    required Color valueColor,
    bool valueLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kTextGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: const TextStyle(fontSize: 11, color: kTextGray),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: valueLarge ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    final shown = _showAll ? _filtered : _filtered.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
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
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kDarkText,
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _showAll = !_showAll),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _showAll ? 'Show Less' : 'View All',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tab,
            labelColor: kPrimary,
            unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            indicatorColor: kPrimary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Income'),
              Tab(text: 'Deductions'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kBgLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(width: 1),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text('PATIENT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: kTextGray, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('DATE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: kTextGray, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('SERVICE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: kTextGray, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('AMOUNT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: kTextGray, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('STATUS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: kTextGray, letterSpacing: 0.5))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...shown.map((t) => _buildRow(t)),
        ],
      ),
    );
  }

  Widget _buildRow(_Transaction t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          t.initials != null
              ? CircleAvatar(
                  radius: 18,
                  backgroundColor: kPrimary.withOpacity(0.1),
                  child: Text(
                    t.initials!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: kPrimary,
                    ),
                  ),
                )
              : Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: kAmber,
                    size: 18,
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              t.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              t.date,
              style: const TextStyle(fontSize: 9, color: kTextGray),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: t.isDeduction ? kAmber.withOpacity(0.1) : kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t.type,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: t.isDeduction ? kAmber : kPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${t.isDeduction ? '-' : ''}${t.amount.toStringAsFixed(2)} EGP',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: t.isDeduction ? kRed : kDarkText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: kGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFundsModal() {
    final amountCtrl = TextEditingController(text: '0.00');
    final nameCtrl = TextEditingController(text: 'Nurse Sarah');
    final cardCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Funds to Wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your card details to securely add funds.',
              style: TextStyle(fontSize: 13, color: kTextGray),
            ),
            const SizedBox(height: 24),
            _modalLabel('AMOUNT TO ADD (EGP)'),
            const SizedBox(height: 6),
            _modalField(
              ctrl: amountCtrl,
              hint: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _modalLabel('CARDHOLDER NAME'),
            const SizedBox(height: 6),
            _modalField(ctrl: nameCtrl, hint: 'Nurse Sarah'),
            const SizedBox(height: 14),
            _modalLabel('CARD NUMBER'),
            const SizedBox(height: 6),
            _modalField(
              ctrl: cardCtrl,
              hint: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              suffix: const Icon(Icons.credit_card_rounded, color: kTextGray, size: 20),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modalLabel('EXPIRY DATE (MM/YY)'),
                      const SizedBox(height: 6),
                      _modalField(ctrl: expiryCtrl, hint: 'MM/YY'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'CVV',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kTextGray,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.info_outline_rounded, size: 13, color: kTextGray),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _modalField(ctrl: cvvCtrl, hint: '•••', obscure: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm & Add Funds',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: kTextGray, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 12, color: kTextGray),
                SizedBox(width: 4),
                Text(
                  'PCI-DSS COMPLIANT SECURE PAYMENT',
                  style: TextStyle(
                    fontSize: 10,
                    color: kTextGray,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modalLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: kTextGray,
          letterSpacing: 0.5,
        ),
      );

  Widget _modalField({
    required TextEditingController ctrl,
    required String hint,
    TextInputType? keyboardType,
    Widget? suffix,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: kBgLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'Wallet',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: kDarkText,
        ),
      ),
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
                child: CircleAvatar(radius: 5, backgroundColor: kRed),
              ),
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
          endIndent: 16,
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://randomuser.me/api/portraits/women/44.jpg',
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

  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile',       'active': false},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests',      'active': false},
      {'icon': Icons.local_hospital_outlined,         'label': 'Donation',      'active': false},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications', 'active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet',        'active': true},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints',    'active': false},
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
                        'Nurse Portal',
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
          MaterialPageRoute(builder: (_) => const NurseProfileScreen()),
        );
        break;
      case 'Requests':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NurseRequestsScreen()),
        );
        break;
      case 'Notifications':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NurseNotificationsScreen()),
        );
        break;
      case 'Complaints':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NurseComplaintsScreen()),
        );
        break;
      case 'Donation':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NurseDonationScreen()),
        );
        break;
      default:
        break;
    }
  }
}