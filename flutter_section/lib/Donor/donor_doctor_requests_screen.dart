import 'package:flutter/material.dart';
import '../Donor/donor_profile_screen.dart';
import '../Donor/donor_notifications_screen.dart';
import '../Donor/donor_wallet_screen.dart';
import '../Donor/donor_complaints_screen.dart';
import '../Donor/donor_donation_screen.dart';
import '../Donor/donor_nurse_requests_screen.dart';
import '../Donor/donor_donation_requests_screen.dart';
import '../Donor/donor_doctor_book_appointment_screen.dart';


const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);
const Color kBlood       = Color(0xFFDC2626);

// ── Helpers ───────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
class DonorDoctorRequestsScreen extends StatefulWidget {
  const DonorDoctorRequestsScreen({super.key});

  @override
  State<DonorDoctorRequestsScreen> createState() => _DonorDoctorRequestsScreenState();
}

class _DonorDoctorRequestsScreenState extends State<DonorDoctorRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _statusTab;
  bool _isLoading = false;

  List<dynamic> _doctors  = [
    {'id': 1,'name': 'Dr. Ahmed Ali', 'specification': 'Cardiologist', 'governorate': 'Cairo', 'address': 'Nasr City', 'avg_rating': 4.8, 'price': '300'},
    {'id': 2,'name': 'Dr. Sarah Hassan', 'specification': 'Dermatologist', 'governorate': 'Alexandria', 'address': 'Smouha', 'avg_rating': 4.5, 'price': '250'}
  ];
  List<dynamic> _pending  = [
    {'doctor': {'id': 1,'name': 'Dr. Ahmed Ali', 'specification': 'Cardiologist'}, 'date': '2024-05-05', 'time': '14:30:00', 'disease_description': 'Patient experiencing chest pain.', 'governorate': 'Cairo', 'address': 'Nasr City', 'total_price': '300'}
  ];
  List<dynamic> _accepted = [
    {'doctor': {'id': 3,'name': 'Dr. Mahmoud Zaki', 'specification': 'Neurologist'}, 'date': '2024-05-04', 'time': '18:00:00', 'disease_description': 'Frequent headaches.', 'governorate': 'Giza', 'address': 'Dokki', 'total_price': '400'}
  ];
  List<dynamic> _done     = [
    {'doctor': {'id': 4,'name': 'Dr. Youssef Omar', 'specification': 'Pediatrician'}, 'date': '2024-04-20', 'time': '09:00:00', 'disease_description': 'Routine checkup.', 'governorate': 'Cairo', 'address': 'Maadi', 'total_price': '200'}
  ];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statusTab = TabController(length: 4, vsync: this);
    _statusTab.addListener(() {
      if (!_statusTab.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: Column(children: [
        // ── Category bar: Doctor | Nurse | Donations ──────────────
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
        // ── Status tabs ───────────────────────────────────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _statusTab,
            labelColor: kPrimary,
            unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            indicatorColor: kPrimary,
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
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
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

  // ── APPBAR ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      )),
      title: const Text('Doctor Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2,
                child: CircleAvatar(radius: 5, backgroundColor: kRed)),
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

  // ── DRAWER ─────────────────────────────────────────────────────────────────
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


  // ── Category tab ───────────────────────────────────────────────────────────
  Widget _catTab(int idx, IconData icon, String label) {
    final active = idx == 0; // Doctor page
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (idx == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonorNurseRequestsScreen())); 
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

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKING TAB
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBookingTab() {
    if (_doctors.isEmpty) return _emptyState('No doctors available');
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
              hintText: 'Search by doctor...',
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
        itemCount: _doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _doctorBookingCard(_doctors[i] as Map),
      )),
    ]);
  }

  Widget _doctorBookingCard(Map doc) {
    final picUrl = doc['profile_pic'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kBgLight,
            backgroundImage: picUrl.isNotEmpty
                ? NetworkImage(picUrl) as ImageProvider
                : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
            const SizedBox(height: 2),
            Text(doc['specification'] ?? '', style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
              const SizedBox(width: 3),
              Expanded(child: Text('${doc['governorate'] ?? ''}, ${doc['address'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: kTextGray), overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded, color: kAmber, size: 15),
              const SizedBox(width: 3),
              Text('${doc['avg_rating'] ?? 0}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
            ]),
            const SizedBox(height: 4),
            Text('${doc['price'] ?? ''} EGP',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPrimary)),
          ]),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DonorDoctorBookAppointmentScreen(doctorId: doc['id'] ?? 0,)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
            ),
            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENDING TAB
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPendingTab() {
    if (_pending.isEmpty) return _emptyState('No pending requests');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._pending.map((r) => _pendingCard(r as Map)),
      ],
    );
  }


  Widget _pendingCard(Map r) {
    final name   = _docName(r);
    final picUrl = _docPic(r);
    final dateStr = '${_fmtDate(r['date'] ?? '')} | ${_fmtTime(r['time'] ?? '')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                picUrl.isNotEmpty ? picUrl
                    : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=1D89E4&color=fff&size=72',
                width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PENDING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100))),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: kTextGray),
                const SizedBox(width: 5),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: kTextGray)),
              ]),
              if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(8)),
                  child: Text('"${r['disease_description']}"',
                      style: const TextStyle(fontSize: 12, color: kDarkText, fontStyle: FontStyle.italic, height: 1.4)),
                ),
              ],
            ])),
          ]),
        ),
        const Divider(height: 1, color: kBorderColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if ((r['governorate'] ?? '').toString().isNotEmpty) ...[
                const Text('LOCATION DETAILS',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: kPrimary),
                  const SizedBox(width: 4),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['governorate'] ?? '',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
                    if ((r['address'] ?? '').toString().isNotEmpty)
                      Text(r['address'] ?? '', style: const TextStyle(fontSize: 11, color: kTextGray)),
                  ])),
                ]),
                const SizedBox(height: 10),
              ],
              if (r['total_price'] != null) ...[
                const Text('TOTAL PRICE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
                const SizedBox(height: 3),
                Text('${r['total_price']} EGP',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
              ],
            ])),
            Row(
              children: [
                _solidBtn('Accept', kPrimary, () {
                  // TODO: accept logic
                }),
                const SizedBox(width: 8),
                _outlineBtn('Cancel', kRed, () {
                  // TODO: cancel logic
                }),
              ],
            ),
          ]),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCEPTED TAB
  // ══════════════════════════════════════════════════════════════════════════
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
    final name   = _docName(r);
    final picUrl = _docPic(r);
    final spec   = _docSpec(r);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 30, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty
                  ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
              if (spec.isNotEmpty)
                Text(spec, style: const TextStyle(fontSize: 12, color: kTextGray)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPrimary.withOpacity(0.2)),
              ),
              child: const Text('Accepted',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary)),
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
            if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: kBorderColor),
              const SizedBox(height: 12),
              const Text('DESCRIPTION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(r['disease_description'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.4)),
            ],
            if (r['total_price'] != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('FINANCIAL TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
                  Text('${r['total_price']} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimary)),
                ]),
              ),
            ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // DONE TAB
  // ══════════════════════════════════════════════════════════════════════════
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
    final name   = _docName(r);
    final picUrl = _docPic(r);
    final spec   = _docSpec(r);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 22, backgroundColor: kBgLight,
              backgroundImage: picUrl.isNotEmpty
                  ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=10B981&color=fff'),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText)),
              if (spec.isNotEmpty)
                Text(spec, style: const TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE6F7E6), borderRadius: BorderRadius.circular(20)),
              child: const Text('DONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kGreen)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _miniInfo(Icons.calendar_today_outlined, _fmtDate(r['date'] ?? '')),
              const SizedBox(width: 16),
              _miniInfo(Icons.access_time_rounded, _fmtTime(r['time'] ?? '')),
            ]),
            if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(color: kBorderColor, height: 1),
              const SizedBox(height: 10),
              const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kPrimary, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(r['disease_description'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.4)),
            ],
            if (r['total_price'] != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('TOTAL PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
                  Text('${r['total_price']} EGP', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDarkText)),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String _docName(Map r) {
    final obj = r['doctor'];
    if (obj is Map) return obj['name'] as String? ?? '';
    return '';
  }
  String _docPic(Map r) {
    final obj = r['doctor'];
    if (obj is Map) return obj['profile_pic'] as String? ?? '';
    return '';
  }
  String _docSpec(Map r) {
    final obj = r['doctor'];
    if (obj is Map) return obj['specification'] as String? ?? '';
    return '';
  }

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

  Widget _solidBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _outlineBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 13, color: kTextGray),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: kTextGray, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _emptyState(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 60, color: kTextGray.withOpacity(0.3)),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(fontSize: 15, color: kTextGray)),
    ]));
  }

}