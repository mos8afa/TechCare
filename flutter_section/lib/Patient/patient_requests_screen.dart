import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Patient/patient_book_appointment_screen.dart';
import '../Patient/patient_profile_screen.dart';
import '../Patient/patient_notifications.dart';
import '../Patient/patient_wallet.dart';
import '../Patient/patient_complaints.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

class PatientRequestsScreen extends StatefulWidget {
  const PatientRequestsScreen({super.key});

  @override
  State<PatientRequestsScreen> createState() => _PatientRequestsScreenState();
}

class _PatientRequestsScreenState extends State<PatientRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _statusTab;

  // 0=Doctor, 1=Nurse
  int _categoryIndex = 0;

  bool _isLoading = false;
  List<dynamic> _doctors = [];
  List<dynamic> _nurses  = [];
  List<dynamic> _pending  = [];
  List<dynamic> _edited   = [];
  List<dynamic> _accepted = [];
  List<dynamic> _done     = [];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statusTab = TabController(length: 4, vsync: this);
    _statusTab.addListener(() {
      if (!_statusTab.indexIsChanging) _loadCurrentTab();
    });
    _loadCurrentTab();
  }

  @override
  void dispose() {
    _statusTab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _category => _categoryIndex == 0 ? 'doctor' : 'nurse';

  Future<void> _loadCurrentTab() async {
    setState(() => _isLoading = true);
    final idx = _statusTab.index;
    if (idx == 0) {
      // Booking — load doctors or nurses list
      if (_categoryIndex == 0) {
        final r = await ApiService.getPatientRequests('doctor', 'booking');
        if (r.success) setState(() => _doctors = r.data['doctors'] ?? []);
      } else {
        final r = await ApiService.getPatientRequests('nurse', 'booking');
        if (r.success) setState(() => _nurses = r.data['nurses'] ?? []);
      }
    } else if (idx == 1) {
      final r = await ApiService.getPatientRequests(_category, 'pending');
      if (r.success) {
        setState(() {
          _pending = r.data['pending'] ?? [];
          _edited  = r.data['edited']  ?? [];
        });
      }
    } else if (idx == 2) {
      final r = await ApiService.getPatientRequests(_category, 'accepted');
      if (r.success) setState(() => _accepted = r.data['accepted'] ?? []);
    } else {
      final r = await ApiService.getPatientRequests(_category, 'done');
      if (r.success) setState(() => _done = r.data['completed'] ?? []);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Category tabs (Doctor / Nurse)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _catTab(0, Icons.medical_services_outlined, 'Doctor'),
              const SizedBox(width: 10),
              _catTab(1, Icons.person_outlined, 'Nurse'),
            ]),
          ),
          // Status tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _statusTab,
              labelColor: kPrimary,
              unselectedLabelColor: kTextGray,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: kPrimary,
              tabs: const [
                Tab(text: 'Booking'),
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Done'),
              ],
            ),
          ),
          // Content
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
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
      title: const Text('Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2,
                child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
          ]),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
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
      {'icon': Icons.person_outline_rounded,          'label': 'Profile',      'active': false},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests',     'active': true},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications','active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet',       'active': false},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints',   'active': false},
    ];

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
                  Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
                  Text('Patient Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
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
      case 'Notifications':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()),
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
      default:
        break;
    }
  }

  // ── CATEGORY TAB ───────────────────────────────────────────────────────────
  Widget _catTab(int idx, IconData icon, String label) {
    final active = _categoryIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _categoryIndex = idx);
          _loadCurrentTab();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? kPrimary : kBgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? Colors.white : kTextGray),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: active ? Colors.white : kTextGray)),
          ]),
        ),
      ),
    );
  }

  // ── BOOKING TAB ───────────────────────────────────────────────────────────
  Widget _buildBookingTab() {
    final list = _categoryIndex == 0 ? _doctors : _nurses;
    if (list.isEmpty) return _emptyState('No providers available');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _categoryIndex == 0 ? 'Search by doctor...' : 'Search by nurse...',
                hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: kTextGray, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filteredList(list).length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _categoryIndex == 0
                ? _doctorCard(_filteredList(list)[i])
                : _nurseCard(_filteredList(list)[i]),
          ),
        ),
      ],
    );
  }

  List _filteredList(List list) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((item) =>
        (item['name'] as String? ?? '').toLowerCase().contains(q)).toList();
  }

  Widget _doctorCard(Map doc) {
    final picUrl = ApiService.buildMediaUrl(doc['profile_pic']);
    final avgRating = doc['avg_rating'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: 30,
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
              Text('${doc['governorate'] ?? ''}, ${doc['address'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: kTextGray),
                  overflow: TextOverflow.ellipsis),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded, color: kAmber, size: 16),
              const SizedBox(width: 3),
              Text('$avgRating', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
            ]),
            const SizedBox(height: 4),
            Text('${doc['price'] ?? ''} EGP',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPrimary)),
          ]),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PatientBookAppointmentScreen(doctorId: doc['id'] as int))),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _nurseCard(Map nurse) {
    final picUrl = ApiService.buildMediaUrl(nurse['profile_pic']);
    final avgRating = nurse['avg_rating'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: kBgLight,
            backgroundImage: picUrl.isNotEmpty
                ? NetworkImage(picUrl) as ImageProvider
                : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff'),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nurse['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
              const SizedBox(width: 3),
              Text('${nurse['governorate'] ?? ''}, ${nurse['address'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: kTextGray),
                  overflow: TextOverflow.ellipsis),
            ]),
          ])),
          Row(children: [
            const Icon(Icons.star_rounded, color: kAmber, size: 16),
            const SizedBox(width: 3),
            Text('$avgRating', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {/* TODO: nurse booking screen */},
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  // ── PENDING TAB ───────────────────────────────────────────────────────────
  Widget _buildPendingTab() {
    if (_pending.isEmpty && _edited.isEmpty) return _emptyState('No pending requests');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_pending.isNotEmpty) ...[
          _sectionLabel('PENDING'),
          const SizedBox(height: 8),
          ..._pending.map((r) => _pendingCard(r, isEdited: false)),
        ],
        if (_edited.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionLabel('EDITED BY PROVIDER'),
          const SizedBox(height: 8),
          ..._edited.map((r) => _pendingCard(r, isEdited: true)),
        ],
      ],
    );
  }

  Widget _pendingCard(Map r, {required bool isEdited}) {
    final doctorOrNurse = r[_categoryIndex == 0 ? 'doctor' : 'nurse'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEdited ? kAmber.withOpacity(0.4) : kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(doctorOrNurse,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isEdited ? const Color(0xFFFFFBEB) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(isEdited ? 'EDITED' : 'PENDING',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: isEdited ? kAmber : const Color(0xFFE65100))),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: kTextGray),
          const SizedBox(width: 4),
          Text('${r['date'] ?? ''} • ${r['time'] ?? ''}',
              style: const TextStyle(fontSize: 13, color: kTextGray)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (isEdited) ...[
            _actionBtn('Accept', kGreen, () => _acceptReschedule(r['id'] as int)),
            const SizedBox(width: 8),
          ],
          _actionBtn('Cancel', kRed, () => _cancelRequest(r['id'] as int)),
        ]),
      ]),
    );
  }

  Future<void> _acceptReschedule(int id) async {
    final result = _categoryIndex == 0
        ? await ApiService.acceptDoctorReschedule(id)
        : await ApiService.acceptNurseReschedule(id);
    if (result.success) _loadCurrentTab();
  }

  Future<void> _cancelRequest(int id) async {
    final result = _categoryIndex == 0
        ? await ApiService.cancelDoctorRequest(id)
        : await ApiService.cancelNurseRequest(id);
    if (result.success) _loadCurrentTab();
  }

  // ── ACCEPTED TAB ──────────────────────────────────────────────────────────
  Widget _buildAcceptedTab() {
    if (_accepted.isEmpty) return _emptyState('No accepted requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _accepted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _acceptedCard(_accepted[i]),
    );
  }

  Widget _acceptedCard(Map r) {
    final name = r[_categoryIndex == 0 ? 'doctor' : 'nurse'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Accepted',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: kTextGray),
          const SizedBox(width: 4),
          Text('${r['date'] ?? ''} • ${r['time'] ?? ''}',
              style: const TextStyle(fontSize: 13, color: kTextGray)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _markDone(r['id'] as int),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Mark as Done', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Future<void> _markDone(int id) async {
    final result = _categoryIndex == 0
        ? await ApiService.markDoctorDone(id)
        : await ApiService.markNurseDone(id);
    if (result.success) _loadCurrentTab();
  }

  // ── DONE TAB ──────────────────────────────────────────────────────────────
  Widget _buildDoneTab() {
    if (_done.isEmpty) return _emptyState('No completed requests');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _done.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _doneCard(_done[i]),
    );
  }

  Widget _doneCard(Map r) {
    final name = r[_categoryIndex == 0 ? 'doctor' : 'nurse'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7E6), borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('DONE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: kTextGray),
          const SizedBox(width: 4),
          Text('${r['date'] ?? ''} • ${r['time'] ?? ''}',
              style: const TextStyle(fontSize: 13, color: kTextGray)),
        ]),
      ]),
    );
  }

  Widget _emptyState(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 60, color: kTextGray.withOpacity(0.3)),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(fontSize: 15, color: kTextGray)),
    ]));
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2));

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }
}