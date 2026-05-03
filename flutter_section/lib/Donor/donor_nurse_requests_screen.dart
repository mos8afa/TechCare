import 'package:flutter/material.dart';
import '../Donor/donor_profile_screen.dart';
import '../Donor/donor_notifications_screen.dart';
import '../Donor/donor_wallet_screen.dart';
import '../Donor/donor_complaints_screen.dart';
import '../Donor/donor_donation_screen.dart';
import '../Donor/donor_doctor_requests_screen.dart';
import '../Donor/donor_donation_requests_screen.dart';


const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

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

class DonorNurseRequestsScreen extends StatefulWidget {
  const DonorNurseRequestsScreen({super.key});

  @override
  State<DonorNurseRequestsScreen> createState() => _DonorNurseRequestsScreenState();
}

class _DonorNurseRequestsScreenState extends State<DonorNurseRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _statusTab;
  bool _isLoading = false;

  List<dynamic> _nurses   = [
    {
      'name': 'Nurse Mona', 'brief': 'Experienced in elder care', 'governorate': 'Cairo', 'address': 'Heliopolis', 'avg_rating': 4.9, 'min_price': '150',
      'services': [{'name': 'Injection', 'price': 50}, {'name': 'Wound Dressing', 'price': 100}]
    }
  ];
  List<dynamic> _pending  = [
    {
      'nurse': {'name': 'Nurse Mona'}, 'date': '2024-05-05', 'time': '10:00:00', 'governorate': 'Cairo', 'address': 'Heliopolis', 'phone_number': '01012345678', 'net_income': '150',
      'services': [{'name': 'Injection', 'price': 50}, {'name': 'Wound Dressing', 'price': 100}]
    }
  ];
  List<dynamic> _edited   = [
    {
      'nurse': {'name': 'Nurse Samira'}, 'date': '2024-05-06', 'time': '12:00:00', 'governorate': 'Alexandria', 'address': 'Smouha', 'phone_number': '01198765432', 'net_income': '250',
      'services': [{'name': 'IV Drip', 'price': 200}]
    }
  ];
  List<dynamic> _accepted = [
    {
      'nurse': {'name': 'Nurse Fatma'}, 'date': '2024-05-04', 'time': '11:30:00', 'governorate': 'Giza', 'address': 'Mohandeseen', 'net_income': '200',
      'services': [{'name': 'IV Drip', 'price': 200}]
    }
  ];
  List<dynamic> _done     = [
    {
      'nurse': {'name': 'Nurse Ali'}, 'date': '2024-04-15', 'time': '16:00:00', 'governorate': 'Alexandria', 'address': 'Miami', 'net_income': '100',
      'services': [{'name': 'Blood Pressure Check', 'price': 100}]
    }
  ];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statusTab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _statusTab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _nurseName(Map r) {
    final obj = r['nurse'];
    if (obj is Map) return obj['name'] as String? ?? '';
    return '';
  }

  String _nursePic(Map r) {
    final obj = r['nurse'];
    if (obj is Map) return obj['profile_pic'] as String? ?? '';
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
            labelColor: kGreen,
            unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            indicatorColor: kGreen,
            tabs: const [
              Tab(text: 'Booking'),
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        Container(height: 1, color: kBorderColor),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kGreen))
              : TabBarView(
                  controller: _statusTab,
                  children: [
                    _buildBookingTab(),
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
      title: const Text('Nurse Requests',
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
    final active = idx == 1; // Nurse page
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (idx == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonorDoctorRequestsScreen())); 
          } else if (idx == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonorDonationRequestsScreen())); 
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

  // ── BOOKING TAB ─────────────────────────────────────────────────────────
  Widget _buildBookingTab() {
    if (_nurses.isEmpty) return _emptyState('No nurses available');
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorderColor)),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search by nurse...',
              hintStyle: TextStyle(color: kTextGray, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: kTextGray, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _nurses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _nurseBookingCard(_nurses[i] as Map),
      )),
    ]);
  }

  Widget _nurseBookingCard(Map nurse) {
    final picUrl  = nurse['profile_pic'] as String? ?? '';
    final services = (nurse['services'] as List? ?? []);
    final rating   = nurse['avg_rating'] ?? 0;
    final minPrice = nurse['min_price'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              CircleAvatar(
                radius: 36, backgroundColor: kBgLight,
                backgroundImage: picUrl.isNotEmpty
                    ? NetworkImage(picUrl) as ImageProvider
                    : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff'),
              ),
              Positioned(bottom: 2, right: 2,
                child: Container(width: 12, height: 12,
                  decoration: BoxDecoration(color: kGreen, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2))),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(nurse['name'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kDarkText))),
                Row(children: [
                  ...List.generate(5, (i) => Icon(Icons.star_rounded,
                      size: 14, color: i < rating ? kAmber : const Color(0xFFD1D5DB))),
                  const SizedBox(width: 3),
                  Text('($rating/5)', style: const TextStyle(fontSize: 11, color: kTextGray)),
                ]),
              ]),
              const SizedBox(height: 4),
              if ((nurse['brief'] ?? '').toString().isNotEmpty)
                Text(nurse['brief'], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
                const SizedBox(width: 3),
                Expanded(child: Text(
                  '${nurse['governorate'] ?? ''}, ${nurse['address'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: kTextGray), overflow: TextOverflow.ellipsis,
                )),
              ]),
            ])),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        if (services.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s['name'] ?? '', style: const TextStyle(fontSize: 13, color: kDarkText)),
                  Text('${s['price']} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
                ]),
              )),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (minPrice != null)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('STARTING FROM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
                const SizedBox(height: 2),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$minPrice', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kPrimary)),
                  const SizedBox(width: 4),
                  const Padding(padding: EdgeInsets.only(bottom: 3),
                      child: Text('EGP', style: TextStyle(fontSize: 12, color: kTextGray, fontWeight: FontWeight.w600))),
                ]),
              ])
            else const SizedBox(),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigator.push to DonorNurseBookAppointmentScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
              ),
              child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── PENDING TAB ─────────────────────────────────────────────────────────
  Widget _buildPendingTab() {
    if (_pending.isEmpty && _edited.isEmpty) return _emptyState('No pending requests');
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
    final name     = _nurseName(r);
    final picUrl   = _nursePic(r);
    final services = (r['services'] as List? ?? []);
    final dateStr  = '${_fmtDate(r['date'] ?? '')} | ${_fmtTime(r['time'] ?? '')}';

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
            Stack(children: [
              CircleAvatar(
                radius: 32, backgroundColor: kBgLight,
                backgroundImage: picUrl.isNotEmpty
                    ? NetworkImage(picUrl) as ImageProvider
                    : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff'),
              ),
              Positioned(bottom: 2, right: 2,
                child: Container(width: 11, height: 11,
                  decoration: BoxDecoration(color: kGreen, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2))),
              ),
            ]),
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
        if (services.isNotEmpty) ...[
          const Divider(height: 1, color: kBorderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s['name'] ?? '', style: const TextStyle(fontSize: 13, color: kDarkText)),
                  Text('${s['price']} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
                ]),
              )),
            ]),
          ),
        ],
        const Divider(height: 20, color: kBorderColor, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('LOCATION DETAILS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
                const SizedBox(width: 4),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['governorate'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
                  if ((r['address'] ?? '').toString().isNotEmpty)
                    Text(r['address'] ?? '', style: const TextStyle(fontSize: 12, color: kTextGray)),
                ])),
              ]),
            ])),
            if ((r['phone_number'] ?? '').toString().isNotEmpty)
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CONTACT INFORMATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.phone_outlined, size: 13, color: kTextGray),
                  const SizedBox(width: 4),
                  Text(r['phone_number'] ?? '', style: const TextStyle(fontSize: 13, color: kDarkText, fontWeight: FontWeight.w600)),
                ]),
              ])),
          ]),
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TOTAL PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 3),
              if (r['net_income'] != null)
                Text('${r['net_income']} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimary)),
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

  // ── ACCEPTED TAB ─────────────────────────────────────────────────────────
  Widget _buildAcceptedTab() {
    if (_accepted.isEmpty) return _emptyState('No accepted requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _accepted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _acceptedCard(_accepted[i] as Map),
    );
  }

  Widget _acceptedCard(Map r) {
    final name     = _nurseName(r);
    final picUrl   = _nursePic(r);
    final services = (r['services'] as List? ?? []);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Stack(children: [
              CircleAvatar(radius: 28, backgroundColor: kBgLight,
                backgroundImage: picUrl.isNotEmpty ? NetworkImage(picUrl) as ImageProvider
                    : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff')),
              Positioned(bottom: 2, right: 2, child: Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: kGreen, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimary.withOpacity(0.2))),
              child: const Text('Accepted', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary)),
            ),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _infoBlock(Icons.calendar_today_outlined, 'DATE AND TIME',
                  '${_fmtDate(r['date'] ?? '')} • ${_fmtTime(r['time'] ?? '')}', valueBold: true)),
              Expanded(child: _infoBlock(Icons.location_on_outlined, 'REGION AND ADDRESS',
                  [r['governorate'], r['address']].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                  valueBold: true)),
            ]),
            if (services.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: kBorderColor),
              const SizedBox(height: 12),
              const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s['name'] ?? '', style: const TextStyle(fontSize: 13, color: kDarkText)),
                  Text('${s['price']} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
                ]),
              )),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('FINANCIAL TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
                Text('${r['net_income'] ?? ''} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimary)),
              ]),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {}, // TODO: mark done
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
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

  // ── DONE TAB ─────────────────────────────────────────────────────────────
  Widget _buildDoneTab() {
    if (_done.isEmpty) return _emptyState('No completed requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _done.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _doneCard(_done[i] as Map),
    );
  }

  Widget _doneCard(Map r) {
    final name     = _nurseName(r);
    final picUrl   = _nursePic(r);
    final services = (r['services'] as List? ?? []);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff')),
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
              _miniInfo(Icons.calendar_today_outlined, _fmtDate(r['date'] ?? '')),
              const SizedBox(width: 16),
              _miniInfo(Icons.access_time_rounded, _fmtTime(r['time'] ?? '')),
            ]),
            const SizedBox(height: 10),
            if ((r['governorate'] ?? '').toString().isNotEmpty)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_outlined, size: 14, color: kTextGray),
                const SizedBox(width: 4),
                Expanded(child: Text('${r['governorate'] ?? ''} / ${r['address'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: kTextGray))),
              ]),
            if (services.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: kBorderColor),
              const SizedBox(height: 12),
              const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s['name'] ?? '', style: const TextStyle(fontSize: 13, color: kTextGray)),
                  Text('${s['price']} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
                ]),
              )),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: kBorderColor),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
              Text('${r['net_income'] ?? ''} EGP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
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
        Icon(icon, size: 13, color: kPrimary),
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