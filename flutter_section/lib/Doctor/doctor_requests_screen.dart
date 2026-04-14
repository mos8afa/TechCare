import 'package:flutter/material.dart';
import '../Doctor/doctor_profile_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';
import '../services/api_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ─── Requests Screen ──────────────────────────────────────────────────────
class DoctorRequestsScreen extends StatefulWidget {
  const DoctorRequestsScreen({super.key});

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  bool _isLoading = false;
  List<dynamic> _pending  = [];
  List<dynamic> _edited   = [];
  List<dynamic> _accepted = [];
  List<dynamic> _done     = [];

  final Map<int, String> _selectedSlots = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _loadCurrentTab();
    });
    _loadCurrentTab();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _fmtDate(dynamic s) {
    if (s == null) return '';
    final str = s.toString();
    if (str.contains('T')) return str.split('T')[0];
    final m = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(str);
    return m != null ? m.group(0)! : str;
  }

  String _fmtTime(dynamic s) {
    if (s == null) return '';
    final str = s.toString();
    final m = RegExp(r'(\d{2}:\d{2})').firstMatch(str);
    if (m != null) return m.group(1)!;
    final m2 = RegExp(r'(\d{1,2}:\d{2})').firstMatch(str);
    return m2 != null ? m2.group(1)! : str;
  }

  // ─── BUILD ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Sticky header + tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Requests',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kDarkText)),
                        SizedBox(height: 2),
                        Text('Manage incoming consultation requests',
                            style: TextStyle(fontSize: 13, color: kTextGray)),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list_rounded, size: 16),
                      label: const Text('Filter',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextGray,
                        side: const BorderSide(color: kBorderColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tab,
                  labelColor: kPrimary,
                  unselectedLabelColor: kTextGray,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  indicatorColor: kPrimary,
                  indicatorWeight: 2.5,
                  tabs: [
                    Tab(text: 'Pending (${_pending.length + _edited.length})'),
                    Tab(text: 'Accepted (${_accepted.length})'),
                    Tab(text: 'Done (${_done.length})'),
                  ],
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _isLoading
                    ? const _LoadingView()
                    : _buildList(
                        [..._pending, ..._edited], _buildPendingCard),
                _isLoading
                    ? const _LoadingView()
                    : _buildList(_accepted, _buildAcceptedCard),
                _isLoading
                    ? const _LoadingView()
                    : _buildList(_done, _buildDoneCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List items, Widget Function(dynamic) builder) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64, color: kTextGray.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('No requests here',
                style: TextStyle(fontSize: 15, color: kTextGray)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // PENDING CARD  (matches web Requests.html)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildPendingCard(dynamic r) {
    final id = r['id'] is int
        ? r['id'] as int
        : int.tryParse('${r['id']}') ?? 0;
    final date      = _fmtDate(r['date']);
    final time      = _fmtTime(r['time']);
    final isEdited  = r['status'] == 'edited';
    final slots     = (r['available_slots'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final selected  = _selectedSlots[id];

    final patientName = _extractName(r);
    final avatarUrl   = ApiService.buildMediaUrl(_extractAvatar(r));
    final governorate = r['governorate'] ?? r['governorate_display'] ?? '';
    final rawPrice    = r['total_price'] ?? r['price'] ?? '';
    final totalPrice  = rawPrice == '' ? '' : '$rawPrice EGP';
    final description = r['disease_description'] ?? r['description'] ?? '';

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────
          _PatientRow(
            name:        patientName.isEmpty ? 'Request #$id' : patientName,
            avatarUrl:   avatarUrl,
            statusLabel: isEdited ? 'EDITED' : 'PENDING',
            statusColor: kAmber,
            statusBg:    const Color(0xFFFFFBEB),
          ),
          const SizedBox(height: 14),

          // ── Info grid ─────────────────────────────────────────────
          _InfoGrid(items: [
            _InfoCell(label: 'Date',        value: date),
            _InfoCell(label: 'Time',        value: time),
            _InfoCell(label: 'Governorate', value: governorate),
            _InfoCell(label: 'Total Price', value: totalPrice),
          ]),
          const SizedBox(height: 14),

          // ── Description ───────────────────────────────────────────
          if (description.isNotEmpty) ...[
            _DescriptionBox(label: 'DESCRIPTION', text: description),
            const SizedBox(height: 14),
          ],

          // ── Time slots ────────────────────────────────────────────
          const Text('Time Slots',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kPrimary)),
          const SizedBox(height: 8),
          if (slots.isEmpty)
            Text('No slots available',
                style: TextStyle(fontSize: 12, color: kTextGray))
          else
            _TimeSlotsRow(
              slots:    slots,
              selected: selected,
              onSelect: (s) => setState(() => _selectedSlots[id] = s),
            ),
          const SizedBox(height: 16),

          // ── Actions ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionBtn(
                label: 'Reject',
                color: kRed,
                bg:    const Color(0xFFFEE2E2),
                onTap: () => _rejectRequest(id),
              ),
              const SizedBox(width: 10),
              _ActionBtn(
                label: selected != null ? 'Edit' : 'Accept',
                color: Colors.white,
                bg:    kPrimary,
                onTap: () => _acceptRequest(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // ACCEPTED CARD  (matches web Accepted.html)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildAcceptedCard(dynamic r) {
    final id    = r['id'] is int
        ? r['id'] as int
        : int.tryParse('${r['id']}') ?? 0;
    final date  = _fmtDate(r['date']);
    final time  = _fmtTime(r['time']);

    final patientName  = _extractName(r);
    final avatarUrl    = ApiService.buildMediaUrl(_extractAvatar(r));
    final governorate  = r['governorate'] ?? r['governorate_display'] ?? '';
    final address      = r['address'] ?? '';
    final description  = r['disease_description'] ?? r['description'] ?? '';
    final rawPrice     = r['total_price'] ?? r['price'] ?? '';
    final totalPrice   = rawPrice == '' ? '' : '$rawPrice EGP';
    final phone        = r['patient'] is Map
        ? (r['patient']['phone'] ?? r['patient']['phone_number'] ?? '')
        : (r['patient_phone'] ?? '');
    final confirmed    = r['patient_done'] == true;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────
          _PatientRow(
            name:        patientName.isEmpty ? 'Request #$id' : patientName,
            subtitle:    '$date  •  $time',
            avatarUrl:   avatarUrl,
            statusLabel: 'Accepted',
            statusColor: kPrimary,
            statusBg:    kPrimary.withOpacity(0.10),
          ),
          const SizedBox(height: 12),

          // ── Location row ──────────────────────────────────────────
          if (governorate.isNotEmpty || address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: kTextGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [governorate, address]
                          .where((s) => s.isNotEmpty)
                          .join(' / '),
                      style: const TextStyle(
                          fontSize: 13, color: kTextGray),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Color(0xFFF0F4F8), thickness: 1, height: 24),

          // ── Description ───────────────────────────────────────────
          if (description.isNotEmpty) ...[
            _DescriptionBox(label: 'DESCRIPTION', text: description),
            const SizedBox(height: 14),
          ],

          // ── Total Price ───────────────────────────────────────────
          if (totalPrice.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price',
                    style: TextStyle(fontSize: 13, color: kTextGray)),
                Text(totalPrice,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kPrimary)),
              ],
            ),

          // ── Patient confirmed banner ───────────────────────────────
          if (confirmed) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGreen.withOpacity(0.25)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: kGreen),
                  SizedBox(width: 8),
                  Text('USER HAS CONFIRMED APPOINTMENT',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kGreen,
                          letterSpacing: 0.4)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Footer: phone + Done btn ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (phone.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 16, color: kTextGray),
                    const SizedBox(width: 6),
                    Text(phone,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kDarkText)),
                  ],
                )
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: () => _markDone(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DONE CARD  (matches web Done.html)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildDoneCard(dynamic r) {
    final id    = r['id'] is int
        ? r['id'] as int
        : int.tryParse('${r['id']}') ?? 0;
    final date  = _fmtDate(r['date']);
    final time  = _fmtTime(r['time']);

    final patientName  = _extractName(r);
    final avatarUrl    = ApiService.buildMediaUrl(_extractAvatar(r));
    final governorate  = r['governorate'] ?? r['governorate_display'] ?? '';
    final address      = r['address'] ?? '';
    final description  = r['disease_description'] ?? r['description'] ?? '';
    final rawPrice     = r['total_price'] ?? r['price'] ?? '';
    final totalPrice   = rawPrice == '' ? '' : '$rawPrice EGP';
    final rawNet       = r['net_income'] ?? '';
    final netIncome    = rawNet == '' ? '' : '$rawNet EGP';

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────
          _PatientRow(
            name:        patientName.isEmpty ? 'Request #$id' : patientName,
            subtitle:    '$date  •  $time',
            avatarUrl:   avatarUrl,
            statusLabel: 'DONE',
            statusColor: kGreen,
            statusBg:    const Color(0xFFE6F7F1),
          ),
          const SizedBox(height: 12),

          // ── Location ──────────────────────────────────────────────
          if (governorate.isNotEmpty || address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: kTextGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [governorate, address]
                          .where((s) => s.isNotEmpty)
                          .join(' / '),
                      style: const TextStyle(
                          fontSize: 13, color: kTextGray),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Color(0xFFF0F4F8), thickness: 1, height: 24),

          // ── Description ───────────────────────────────────────────
          if (description.isNotEmpty) ...[
            _DescriptionBox(label: 'DESCRIPTION', text: description),
            const SizedBox(height: 14),
          ],

          // ── Price summary row ─────────────────────────────────────
          if (totalPrice.isNotEmpty || netIncome.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (totalPrice.isNotEmpty)
                    _PriceTile(label: 'Total Price', value: totalPrice),
                  if (netIncome.isNotEmpty)
                    _PriceTile(
                      label: 'Net Income',
                      value: netIncome,
                      valueColor: kGreen,
                      bg:    kGreen.withOpacity(0.08),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────
  String _extractName(dynamic r) {
    if (r['patient'] is Map) {
      return r['patient']['name'] ??
          r['patient']['full_name'] ??
          r['patient']['first_name'] ??
          '';
    }
    return r['patient_name'] ?? '';
  }

  String? _extractAvatar(dynamic r) {
    if (r['patient'] is Map) {
      return r['patient']['profile_pic'] ??
          r['patient']['profile_pic_url'];
    }
    return r['patient_profile_pic'] ?? r['patient_profile_pic_url'];
  }

  // ─── API calls ────────────────────────────────────────────────────────
  Future<void> _loadCurrentTab() async {
    setState(() => _isLoading = true);
    try {
      if (_tab.index == 0) {
        final r = await ApiService.getDoctorRequests('pending');
        if (r.success) {
          setState(() {
            _pending = List.from(r.data['pending'] ?? []);
            _edited  = List.from(r.data['edited']  ?? []);
          });
        }
      } else if (_tab.index == 1) {
        final r = await ApiService.getDoctorRequests('accepted');
        if (r.success) {
          setState(() => _accepted = List.from(r.data['accepted'] ?? []));
        }
      } else {
        final r = await ApiService.getDoctorRequests('completed');
        if (r.success) {
          setState(() => _done = List.from(r.data['completed'] ?? []));
        }
      }
    } catch (_) {}

    final visibleIds = <int>{};
    for (var item in [..._pending, ..._edited, ..._accepted, ..._done]) {
      final id = item['id'] is int
          ? item['id'] as int
          : int.tryParse('${item['id']}');
      if (id != null) visibleIds.add(id);
    }
    _selectedSlots.removeWhere((k, _) => !visibleIds.contains(k));
    setState(() => _isLoading = false);
  }

  Future<void> _acceptRequest(int id) async {
    setState(() => _isLoading = true);
    try {
      final selected     = _selectedSlots[id];
      final selectedTime = selected != null ? _fmtTime(selected) : null;
      final action       = selectedTime != null ? 'reschedule' : 'accept';
      final res = await ApiService.requestActionDoctor(id, action,
          time: selectedTime);
      if (res.success) {
        _selectedSlots.remove(id);
        await _loadCurrentTab();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _rejectRequest(int id) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.requestActionDoctor(id, 'reject');
      if (res.success) {
        _selectedSlots.remove(id);
        await _loadCurrentTab();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _markDone(int id) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.markDoneDoctor(id);
      if (res.success) await _loadCurrentTab();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  // ─── AppBar ───────────────────────────────────────────────────────────
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
      title: const Text('Requests',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: const [
              Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF4B5563), size: 24),
              Positioned(
                right: -2,
                top:   -2,
                child: CircleAvatar(
                    radius: 5, backgroundColor: kRed),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(
            width: 1, thickness: 1, color: kBorderColor,
            indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
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

  // ─── Drawer ───────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,        'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,              'label': 'Requests'},
      {'icon': Icons.notifications_none_rounded,    'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined,'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,         'label': 'Complaints'},
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                          style:
                              TextStyle(fontSize: 12, color: kTextGray)),
                    ],
                  ),
                ],
              ),
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => const DoctorProfileScreen()));
        break;
      case 'Notifications':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => const DoctorNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => const DoctorWalletScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => const DoctorComplaintsScreen()));
        break;
      default:
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ── Shared sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: kPrimary));
}

// ── Card shell ────────────────────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F4F8)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x09000000),
                blurRadius: 14,
                offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

// ── Patient top row ───────────────────────────────────────────────────────
class _PatientRow extends StatelessWidget {
  final String  name;
  final String? subtitle;
  final String? avatarUrl;
  final String  statusLabel;
  final Color   statusColor;
  final Color   statusBg;

  const _PatientRow({
    required this.name,
    this.subtitle,
    this.avatarUrl,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(avatarUrl!,
                      width: 44, height: 44, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar())
                  : _defaultAvatar(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kDarkText)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12, color: kTextGray)),
                  ),
              ],
            ),
          ],
        ),
        // Status pill
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(30)),
          child: Text(statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor)),
        ),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
        child: const Icon(Icons.person_outline_rounded,
            color: kPrimary, size: 22),
      );
}

// ── Info grid (2 columns) ─────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final List<_InfoCell> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: kBgLight, borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(builder: (context, constraints) {
        const spacing  = 10.0;
        final cellWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing:    spacing,
          runSpacing: spacing,
          children: items
              .map((w) => SizedBox(width: cellWidth, child: w))
              .toList(),
        );
      }),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: kTextGray,
                letterSpacing: 0.6)),
        const SizedBox(height: 3),
        Text(value.isEmpty ? '—' : value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kDarkText)),
      ],
    );
  }
}

// ── Description box ───────────────────────────────────────────────────────
class _DescriptionBox extends StatelessWidget {
  final String label;
  final String text;
  const _DescriptionBox({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kPrimary,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kBgLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8EDF3)),
          ),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A5568),
                  height: 1.55)),
        ),
      ],
    );
  }
}

// ── Time slots horizontal row ─────────────────────────────────────────────
class _TimeSlotsRow extends StatelessWidget {
  final List<String> slots;
  final String?      selected;
  final ValueChanged<String> onSelect;
  const _TimeSlotsRow(
      {required this.slots,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount:       slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = slots[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(slots[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:  isActive ? kPrimary : const Color(0xFFF0F4F8),
                border: Border.all(
                    color: isActive
                        ? kPrimary
                        : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: kPrimary.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Center(
                child: Text(slots[i],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF4B5563))),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String   label;
  final Color    color;
  final Color    bg;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 11),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      ),
    );
  }
}

// ── Price tile (used in Done card) ────────────────────────────────────────
class _PriceTile extends StatelessWidget {
  final String label;
  final String value;
  final Color  valueColor;
  final Color? bg;
  const _PriceTile(
      {required this.label,
      required this.value,
      this.valueColor = kDarkText,
      this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: bg != null
          ? BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: kTextGray)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor)),
        ],
      ),
    );
  }
}