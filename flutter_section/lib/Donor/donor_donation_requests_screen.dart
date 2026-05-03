import 'package:flutter/material.dart';
import '../Donor/donor_profile_screen.dart';
import '../Donor/donor_notifications_screen.dart';
import '../Donor/donor_wallet_screen.dart';
import '../Donor/donor_complaints_screen.dart';
import '../Donor/donor_donation_screen.dart';
import '../Donor/donor_doctor_requests_screen.dart';
import '../Donor/donor_nurse_requests_screen.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);
const Color kBlood       = Color(0xFFDC2626);

String _fmtDate(String raw) {
  try {
    final clean = raw.contains('+') ? raw.split('+').first.trim() : raw.trim();
    final dt = DateTime.parse(clean);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) { return raw.split(' ').first; }
}

String _fmtTime(String raw) {
  try {
    final clean = raw.split('+').first.trim();
    final parts = clean.split(':');
    final h = int.parse(parts[0]);
    final min = parts[1].padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour:$min $period';
  } catch (_) { return raw; }
}

class DonorDonationRequestsScreen extends StatefulWidget {
  const DonorDonationRequestsScreen({super.key});

  @override
  State<DonorDonationRequestsScreen> createState() => _DonorDonationRequestsScreenState();
}

class _DonorDonationRequestsScreenState extends State<DonorDonationRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _statusTab;
  bool _isLoading = false;

  List<dynamic> _pending  = [
    {'blood_bank': {'name': 'Life Blood Center'}, 'donation_date': '2024-05-06', 'donation_time': '10:00:00', 'blood_type': 'O+', 'quantity_ml': 450, 'address': '123 Main St', 'city': 'Cairo', 'medical_notes': 'No chronic diseases.', 'total_amount': '500'}
  ];
  List<dynamic> _edited   = [
    {'blood_bank': {'name': 'City Blood Bank'}, 'donation_date': '2024-05-07', 'donation_time': '11:00:00', 'blood_type': 'A-', 'quantity_ml': 500, 'address': '45 King St', 'city': 'Alexandria', 'medical_notes': 'Healthy', 'total_amount': '550'}
  ];
  List<dynamic> _accepted = [
    {'blood_bank': {'name': 'Hope Hospital'}, 'donation_date': '2024-05-05', 'donation_time': '12:00:00', 'blood_type': 'A+', 'quantity_ml': 400, 'address': '45 Health Ave', 'city': 'Giza', 'total_amount': '450'}
  ];
  List<dynamic> _done     = [
    {'blood_bank': {'name': 'Red Crescent'}, 'donation_date': '2024-04-10', 'donation_time': '09:30:00', 'blood_type': 'B+', 'quantity_ml': 500, 'address': '78 Care St', 'city': 'Alexandria', 'total_amount': '600'}
  ];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statusTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _statusTab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _centerName(Map r) {
    final obj = r['blood_bank'];
    if (obj is Map) return obj['name'] as String? ?? '';
    return '';
  }

  String _centerPic(Map r) {
    final obj = r['blood_bank'];
    if (obj is Map) return obj['logo'] as String? ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: Column(children: [
        // ── Category bar ──────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            _catTab(0, Icons.medical_services_outlined, 'Doctor'),
            const SizedBox(width: 8),
            _catTab(1, Icons.person_outlined, 'Nurse'),
            const SizedBox(width: 8),
            _catTab(2, Icons.bloodtype_outlined, 'Donations'),
          ]),
        ),
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _statusTab,
            labelColor: kBlood,
            unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            indicatorColor: kBlood,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        Container(height: 1, color: kBorderColor),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kBlood))
              : TabBarView(
                  controller: _statusTab,
                  children: [
                    _buildPendingTab(),
                    _buildAcceptedTab(),
                    _buildDoneTab(),
                  ],
                ),
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      )),
      title: const Text('Donation Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: kRed)),
          ]),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(radius: 20,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Donor&background=DC2626&color=fff')),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(color: kBorderColor, height: 1)),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile',       'active': false},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests',      'active': true},
      {'icon': Icons.local_hospital_outlined,         'label': 'Donation',      'active': false},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications', 'active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet',        'active': false},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints',    'active': false},
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
              Text('Donor Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
            ]),
          ]),
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
        ]),
      )),
    );
  }

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Profile':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorProfileScreen()));
        break;
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
        break;
    }
  }

  Widget _catTab(int idx, IconData icon, String label) {
    final active = idx == 2; // Donations page
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (idx == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonorDoctorRequestsScreen()));
          } else if (idx == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonorNurseRequestsScreen()));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? kPrimary : kBgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: active ? Colors.white : kTextGray),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: active ? Colors.white : kTextGray)),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENDING TAB - طلبات التبرع المعلقة
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPendingTab() {
    if (_pending.isEmpty && _edited.isEmpty) return _emptyState('No pending donation requests');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._pending.map((r) => _pendingCard(r as Map, isEdited: false)),
        if (_edited.isNotEmpty) ...[
          _sectionLabel('EDITED BY PROVIDER'),
          const SizedBox(height: 10),
          ..._edited.map((r) => _pendingCard(r as Map, isEdited: true)),
        ],
      ],
    );
  }

  Widget _pendingCard(Map r, {required bool isEdited}) {
    final name     = _centerName(r);
    final picUrl   = _centerPic(r);
    final dateStr  = '${_fmtDate(r['donation_date'] ?? '')} | ${_fmtTime(r['donation_time'] ?? '')}';
    final bloodType = (r['blood_type'] ?? 'Unknown').toString();
    final quantity = (r['quantity_ml'] ?? 0).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEdited ? kAmber.withOpacity(0.4) : kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 32, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty
                  ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Blood+Bank&background=DC2626&color=fff'),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEdited ? const Color(0xFFFEF3C7) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(isEdited ? 'EDITED' : 'PENDING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                          color: isEdited ? kAmber : const Color(0xFFE65100))),
                ),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: kTextGray),
                const SizedBox(width: 5),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: kTextGray)),
              ]),
            ])),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _infoBlock(Icons.bloodtype_outlined, 'BLOOD TYPE', bloodType, valueBold: true)),
              Expanded(child: _infoBlock(Icons.water_drop_outlined, 'QUANTITY (ml)', quantity, valueBold: true)),
            ]),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _infoBlock(Icons.location_on_outlined, 'CENTER ADDRESS',
                  '${r['address'] ?? ''}, ${r['city'] ?? ''}', valueBold: false)),
            ]),
            if ((r['medical_notes'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.healing, size: 16, color: kBlood),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r['medical_notes'], style: const TextStyle(fontSize: 12, color: kDarkText))),
                ]),
              ),
            ],
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 3),
              if (r['total_amount'] != null)
                Text('${r['total_amount']} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlood)),
            ]),
            Row(children: [
              if (isEdited) ...[
                _solidBtn('Accept', kPrimary, () {}),
                const SizedBox(width: 8),
              ],
              _outlineBtn('Cancel', kRed, () {}),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCEPTED TAB - طلبات التبرع المقبولة
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAcceptedTab() {
    if (_accepted.isEmpty) return _emptyState('No accepted donation requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _accepted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _acceptedCard(_accepted[i] as Map),
    );
  }

  Widget _acceptedCard(Map r) {
    final name     = _centerName(r);
    final picUrl   = _centerPic(r);
    final bloodType = (r['blood_type'] ?? 'Unknown').toString();
    final quantity = (r['quantity_ml'] ?? 0).toString();

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Blood+Bank&background=DC2626&color=fff')),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kBlood.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBlood.withOpacity(0.2))),
              child: const Text('Accepted', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kBlood)),
            ),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _infoBlock(Icons.calendar_today_outlined, 'DATE AND TIME',
                  '${_fmtDate(r['donation_date'] ?? '')} • ${_fmtTime(r['donation_time'] ?? '')}', valueBold: true)),
              Expanded(child: _infoBlock(Icons.location_on_outlined, 'CENTER ADDRESS',
                  '${r['address'] ?? ''}, ${r['city'] ?? ''}', valueBold: true)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _infoBlock(Icons.bloodtype_outlined, 'BLOOD TYPE', bloodType, valueBold: true)),
              Expanded(child: _infoBlock(Icons.water_drop_outlined, 'QUANTITY (ml)', quantity, valueBold: true)),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
                Text('${r['total_amount'] ?? ''} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlood)),
              ]),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {}, // TODO: mark done
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlood, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DONE TAB - طلبات التبرع المكتملة
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDoneTab() {
    if (_done.isEmpty) return _emptyState('No completed donation requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _done.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _doneCard(_done[i] as Map),
    );
  }

  Widget _doneCard(Map r) {
    final name     = _centerName(r);
    final picUrl   = _centerPic(r);
    final bloodType = (r['blood_type'] ?? 'Unknown').toString();
    final quantity = (r['quantity_ml'] ?? 0).toString();

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Blood+Bank&background=DC2626&color=fff')),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('DONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kGreen)),
            ),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _miniInfo(Icons.calendar_today_outlined, _fmtDate(r['donation_date'] ?? '')),
              const SizedBox(width: 16),
              _miniInfo(Icons.access_time_rounded, _fmtTime(r['donation_time'] ?? '')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _miniInfo(Icons.bloodtype_outlined, bloodType),
              const SizedBox(width: 16),
              _miniInfo(Icons.water_drop_outlined, '$quantity ml'),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.location_on_outlined, size: 14, color: kTextGray),
              const SizedBox(width: 4),
              Expanded(child: Text('${r['address'] ?? ''}, ${r['city'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: kTextGray))),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1, color: kBorderColor),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
              Text('${r['total_amount'] ?? ''} EGP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kBlood)),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _infoBlock(IconData icon, String label, String value, {bool valueBold = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 13, color: kBlood),
        const SizedBox(width: 5),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: kDarkText,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500))),
      ]),
    ]);
  }

  Widget _solidBtn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
    ),
  );

  Widget _outlineBtn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ),
  );

  Widget _miniInfo(IconData icon, String text) => Row(children: [
    Icon(icon, size: 13, color: kTextGray),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 12, color: kTextGray, fontWeight: FontWeight.w500)),
  ]);

  Widget _emptyState(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.inbox_outlined, size: 60, color: kTextGray.withOpacity(0.3)),
    const SizedBox(height: 12),
    Text(msg, style: const TextStyle(fontSize: 15, color: kTextGray)),
  ]));

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2));
}