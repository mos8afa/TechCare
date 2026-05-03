import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Nurse/nurse_profile_screen.dart';
import '../Nurse/nurse_notifications.dart';
import '../Nurse/nurse_wallet.dart';
import '../Nurse/nurse_complaints.dart';
import '../Nurse/nurse_donation.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ─── Screen ───────────────────────────────────────────────────────────────
class NurseRequestsScreen extends StatefulWidget {
  const NurseRequestsScreen({super.key});
  @override
  State<NurseRequestsScreen> createState() => _NurseRequestsScreenState();
}

class _NurseRequestsScreenState extends State<NurseRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  bool _isLoading = false;
  String picUrl = '';
  List<dynamic> _pending  = [];
  List<dynamic> _edited   = [];
  List<dynamic> _accepted = [];
  List<dynamic> _done     = [];

  // selected reschedule slot per request id
  final Map<int, String> _selectedSlots = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _loadCurrentTab();
    });
    _loadCurrentTab();
    _loadProfile();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  // ── helpers ────────────────────────────────────────────────────────────
  String _fmtDate(dynamic s) {
    if (s == null) return '';
    final str = s.toString();
    final m = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(str);
    return m != null ? m.group(0)! : str;
  }

  String _fmtTime(dynamic s) {
    if (s == null) return '';
    final str = s.toString();
    final m = RegExp(r'(\d{2}:\d{2})').firstMatch(str);
    return m != null ? m.group(1)! : str;
  }

  int _calcTotal(dynamic services) {
    if (services == null) return 0;
    return (services as List).fold<int>(
      0, (sum, s) => sum + (double.tryParse(s['price'].toString())?.toInt() ?? 0));
  }

  // ── API calls ──────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getNurseProfile(); // نفس اللي عندك في profile screen
      if (res.success) {
        setState(() {
          picUrl = res.data['profile_image'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCurrentTab() async {
    setState(() => _isLoading = true);
    try {
      if (_tab.index == 0) {
        final r = await ApiService.getNurseRequests('pending');
        if (r.success) {
          setState(() {
            _pending = List.from(r.data['pending'] ?? []);
            _edited  = List.from(r.data['edited']  ?? []);
          });
        }
      } else if (_tab.index == 1) {
        final r = await ApiService.getNurseRequests('accepted');
        if (r.success) {
          setState(() => _accepted = List.from(r.data['accepted'] ?? []));
        }
      } else {
        final r = await ApiService.getNurseRequests('completed');
        if (r.success) {
          setState(() => _done = List.from(r.data['completed'] ?? []));
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _acceptRequest(int id) async {
    setState(() => _isLoading = true);
    try {
      final slot = _selectedSlots[id];
      final action = slot != null ? 'reschedule' : 'accept';
      final res = await ApiService.requestActionNurse(id, action,
          time: slot != null ? _fmtTime(slot) : null);
      if (res.success) {
        _selectedSlots.remove(id);
        await _loadCurrentTab();
      } else {
        _showSnack(res.error ?? 'Failed');
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _rejectRequest(int id) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.requestActionNurse(id, 'reject');
      if (res.success) {
        await _loadCurrentTab();
      } else {
        _showSnack(res.error ?? 'Failed');
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _markDone(int id) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.markDoneNurse(id);
      if (res.success) {
        await _loadCurrentTab();
      } else {
        _showSnack(res.error ?? 'Failed');
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(children: [
        // Sticky header
        Container(
          color: kBgLight,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Requests',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
                SizedBox(height: 2),
                Text('Manage incoming consultation requests',
                    style: TextStyle(fontSize: 13, color: kTextGray)),
              ]),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: const Text('Filter',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextGray,
                  side: const BorderSide(color: kBorderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            TabBar(
              controller: _tab,
              labelColor: kPrimary,
              unselectedLabelColor: kTextGray,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              indicatorColor: kPrimary,
              indicatorWeight: 2,
              tabs: [
                Tab(text: 'Pending (${_pending.length + _edited.length})'),
                Tab(text: 'Accepted (${_accepted.length})'),
                Tab(text: 'Done (${_done.length})'),
              ],
            ),
          ]),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : TabBarView(controller: _tab, children: [
                  _buildList([..._pending, ..._edited], _buildPendingCard),
                  _buildList(_accepted, _buildAcceptedCard),
                  _buildList(_done,     _buildDoneCard),
                ]),
        ),
      ]),
    );
  }

  Widget _buildList(List items, Widget Function(dynamic) builder) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox_outlined, size: 60, color: kTextGray.withOpacity(0.35)),
        const SizedBox(height: 12),
        const Text('No requests here', style: TextStyle(fontSize: 15, color: kTextGray)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }

  // ── PENDING card ────────────────────────────────────────────────────────
  Widget _buildPendingCard(dynamic r) {
    final id       = r['id'] is int ? r['id'] as int : int.tryParse('${r['id']}') ?? 0;
    final date     = _fmtDate(r['date']);
    final time     = _fmtTime(r['time']);
    final name     = r['requester_name'] ?? 'Unknown';
    final address  = r['address'] ?? '';
    final desc     = r['disease_description'] ?? '';
    final gov      = r['governorate'] ?? '';
    final services = (r['services'] as List? ?? []);
    final total    = _calcTotal(r['services']);
    final slots    = (r['available_slots'] as List? ?? []).map((e) => e.toString()).toList();
    final selected = _selectedSlots[id];
    final isEdited = r['status'] == 'edited';

    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Top
      _TopRow(
        name: name,
        subtitle: Row(children: [
          const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
          const SizedBox(width: 3),
          Flexible(child: Text('$gov${address.isNotEmpty ? ' — $address' : ''}',
              style: const TextStyle(fontSize: 12, color: kTextGray))),
        ]),
        statusLabel: isEdited ? 'EDITED' : 'PENDING',
        statusColor: kAmber,
        statusBg: const Color(0xFFFFFBEB),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: kBorderColor, thickness: 1)),

      // Date + Time
      Row(children: [
        _dateTimeChip(Icons.calendar_today_outlined, 'Date', date),
        const SizedBox(width: 16),
        _dateTimeChip(Icons.access_time_rounded, 'Time', time),
      ]),
      const SizedBox(height: 14),
      const Padding(padding: EdgeInsets.symmetric(vertical: 4),
          child: Divider(color: kBorderColor, thickness: 1)),

      // Description
      if (desc.isNotEmpty) ...[
        const Text('Diabetes Management & Care',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
        const SizedBox(height: 14),
      ],

      // Services
      if (services.isNotEmpty) ...[
        _ServicesBox(
          services: services.map((s) => _SvcItem(
            name: s['name'] ?? '',
            price: (double.tryParse(s['price'].toString()) ?? 0).toInt(),
          )).toList(),
          total: total,
        ),
        const SizedBox(height: 14),
        const Padding(padding: EdgeInsets.symmetric(vertical: 2),
            child: Divider(color: kBorderColor, thickness: 1)),
      ],

      // Time slots
      const Text('Time Slots',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
      const SizedBox(height: 8),
      if (slots.isEmpty)
        Text('No available slots', style: TextStyle(fontSize: 12, color: kTextGray))
      else
        _SlotsCarousel(
          slots: slots,
          selected: selected,
          onSelect: (s) => setState(() => _selectedSlots[id] = s),
        ),
      const SizedBox(height: 16),

      // Actions
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _Btn(label: 'Reject', color: kRed, bg: const Color(0xFFFEE2E2),
            onTap: () => _rejectRequest(id)),
        const SizedBox(width: 10),
        _Btn(
          label: selected != null ? 'Reschedule' : 'Accept',
          color: Colors.white,
          bg: kPrimary,
          onTap: () => _acceptRequest(id),
        ),
      ]),
    ]));
  }

  // ── ACCEPTED card ────────────────────────────────────────────────────────
  Widget _buildAcceptedCard(dynamic r) {
    final id       = r['id'] is int ? r['id'] as int : int.tryParse('${r['id']}') ?? 0;
    final date     = _fmtDate(r['date']);
    final time     = _fmtTime(r['time']);
    final name     = r['requester_name'] ?? 'Unknown';
    final phone    = '0${r['requester_phone'] ?? ''}';
    final address  = r['address'] ?? '';
    final gov      = r['governorate'] ?? '';
    final desc     = r['disease_description'] ?? '';
    final services = (r['services'] as List? ?? []);
    final total    = _calcTotal(r['services']);

    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TopRow(
        name: name,
        subtitle: Text('$date  •  $time',
            style: const TextStyle(fontSize: 12, color: kTextGray)),
        statusLabel: 'Accepted',
        statusColor: kPrimary,
        statusBg: kPrimary.withOpacity(0.1),
      ),
      const SizedBox(height: 10),
      Row(children: [
        const Icon(Icons.location_on_outlined, size: 14, color: kPrimary),
        const SizedBox(width: 4),
        Expanded(child: Text('$gov${address.isNotEmpty ? ' — $address' : ''}',
            style: const TextStyle(fontSize: 13, color: kTextGray))),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: kBorderColor)),

      // Description
      if (desc.isNotEmpty) ...[
        const Text('Description',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: kPrimary, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(desc,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
        const SizedBox(height: 14),
        const Padding(padding: EdgeInsets.symmetric(vertical: 2),
            child: Divider(color: kBorderColor)),
      ],

      // Services
      if (services.isNotEmpty) ...[
        const Text('Services',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ...services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s['name'] ?? '', style: const TextStyle(fontSize: 13, color: kDarkText)),
            Text('${double.tryParse(s['price'].toString())?.toStringAsFixed(0) ?? s['price']} EGP',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
        )),
        const Divider(color: kBorderColor),
      ],

      // Total
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price',
            style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600, color: Color.fromARGB(255, 28, 28, 28))),
        Text('$total EGP',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
      ]),
      const SizedBox(height: 14),

      // Footer
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (phone.isNotEmpty)
          Row(children: [
            const Icon(Icons.phone_outlined, size: 18, color: kTextGray),
            const SizedBox(width: 6),
            Text(phone,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kDarkText)),
          ])
        else
          const SizedBox(),
        ElevatedButton(
          onPressed: () => _markDone(id),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    ]));
  }

  // ── DONE card ────────────────────────────────────────────────────────────
  Widget _buildDoneCard(dynamic r) {
    final date     = _fmtDate(r['date']);
    final time     = _fmtTime(r['time']);
    final name     = r['requester_name'] ?? 'Unknown';
    final address  = r['address'] ?? '';
    final gov      = r['governorate'] ?? '';
    final desc     = r['disease_description'] ?? '';
    final services = (r['services'] as List? ?? []);
    final total    = _calcTotal(r['services']);
    // net_income ≈ 80% — الـ backend مش بيرجعهولنا للـ nurse requests
    final earning  = (total * 0.80).toInt();

    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TopRow(
        name: name,
        subtitle: Row(children: [
          const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
          const SizedBox(width: 3),
          Flexible(child: Text('$gov${address.isNotEmpty ? ' — $address' : ''}',
              style: const TextStyle(fontSize: 12, color: kTextGray))),
        ]),
        statusLabel: 'DONE',
        statusColor: kGreen,
        statusBg: const Color(0xFFE6F7E6),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: kBorderColor)),

      // Info row
      Row(children: [
        _infoBlock('DATE & TIME', '$date | $time'),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: kBorderColor)),

      if (desc.isNotEmpty) ...[
        const Text('DISEASE DESCRIPTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(desc,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
        const SizedBox(height: 14),
      ],

      // Services
      if (services.isNotEmpty) ...[
        const Text('SERVICES REQUESTED',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ...services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s['name'] ?? '',
                style: const TextStyle(fontSize: 13, color: kDarkText)),
            Text('${double.tryParse(s['price'].toString())?.toStringAsFixed(0) ?? s['price']} EGP',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
        )),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: kBorderColor)),
      ],

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        Text('$total EGP',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDarkText)),
      ]),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your Earning',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
        Text('$earning EGP',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kGreen)),
      ]),
    ]));
  }

  // ── helpers ────────────────────────────────────────────────────────────
  Widget _dateTimeChip(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 15, color: kPrimary),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kTextGray)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
      ]),
    ]);
  }

  Widget _infoBlock(String label, String value) =>
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
            color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
      ]));

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: Builder(builder: (ctx) => IconButton(
      icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
      onPressed: () => Scaffold.of(ctx).openDrawer(),
    )),
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
      CircleAvatar(
        radius: 20,
        backgroundColor: kBgLight,
        backgroundImage: picUrl.isNotEmpty
            ? NetworkImage(picUrl)
            : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=1D89E4&color=fff'),
      ),
      const SizedBox(width: 16),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: kBorderColor, height: 1),
    ),
  );

  // ── Drawer ────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
      {'icon': Icons.local_hospital_outlined,         'label': 'Donation'},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('TechCare',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
              Text('Medical Portal',
                  style: TextStyle(fontSize: 12, color: kTextGray)),
            ]),
          ]),
          const SizedBox(height: 32),
          ...items.map((item) {
            final isActive = item['label'] == 'Requests';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isActive ? kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () { Navigator.pop(context); _handleNav(context, item['label'] as String); },
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
            MaterialPageRoute(builder: (_) => const NurseProfileScreen())); break;
      case 'Notifications':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const NurseNotificationsScreen())); break;
      case 'Wallet':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const NurseWalletScreen())); break;
      case 'Complaints':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const NurseComplaintsScreen())); break;
      case 'Donation':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const NurseDonationScreen())); break;
      default: break;
    }
  }
}

// ─── Sub-widgets (same as original, no UI change) ─────────────────────────

class _SvcItem {
  final String name;
  final int price;
  const _SvcItem({required this.name, required this.price});
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF0F4F8)),
      boxShadow: const [
        BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

class _TopRow extends StatelessWidget {
  final String name;
  final Widget subtitle;
  final String statusLabel;
  final Color  statusColor, statusBg;
  const _TopRow({
    required this.name, required this.subtitle,
    required this.statusLabel, required this.statusColor, required this.statusBg,
  });
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
            const SizedBox(height: 2),
            subtitle,
          ])),
        ])),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(30)),
          child: Text(statusLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]);
}

class _ServicesBox extends StatelessWidget {
  final List<_SvcItem> services;
  final int total;
  const _ServicesBox({required this.services, required this.total});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Services Requested',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kDarkText, letterSpacing: 0.3)),
      const SizedBox(height: 10),
      ...services.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.name, style: const TextStyle(fontSize: 13, color: kDarkText)),
          Text('${s.price} EGP',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
      )),
      const Divider(color: kBorderColor, thickness: 1),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDarkText)),
        Text('$total EGP',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPrimary)),
      ]),
    ]),
  );
}

class _SlotsCarousel extends StatelessWidget {
  final List<String> slots;
  final String?      selected;
  final ValueChanged<String> onSelect;
  const _SlotsCarousel({required this.slots, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final isActive = slots[i] == selected;
        return GestureDetector(
          onTap: () => onSelect(slots[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isActive ? kPrimary : const Color(0xFFF0F4F8),
              border: Border.all(color: isActive ? kPrimary : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isActive
                  ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Center(child: Text(slots[i],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF4B5563)))),
          ),
        );
      },
    ),
  );
}

class _Btn extends StatelessWidget {
  final String label;
  final Color  color, bg;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.color, required this.bg, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}