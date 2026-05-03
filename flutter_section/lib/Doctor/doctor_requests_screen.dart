import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Doctor/doctor_profile_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';
import '../Doctor/doctor_donation.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ── Date/Time formatters ───────────────────────────────────────────────────
String _formatDate(String raw) {
  try {
    final clean = raw.contains('+') ? raw.split('+').first.trim() : raw.trim();
    final dt = DateTime.parse(clean);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw.split(' ').first;
  }
}

String _formatTime(String raw) {
  try {
    final clean = raw.split('+').first.trim();
    final parts = clean.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1].padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour:$m $period';
  } catch (_) {
    return raw;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
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
        Map<String, dynamic>? _profileData;

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
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final res = await ApiService.getDoctorDashboard();
    if (res.success) {
      setState(() {
        _profileData = res.data;
      });
    }
  }

  Future<void> _loadCurrentTab() async {
    setState(() => _isLoading = true);
    switch (_tab.index) {
      case 0:
        final r = await ApiService.getDoctorRequests('pending');
        if (r.success) {
          setState(() {
            _pending = r.data['pending'] ?? [];
            _edited  = r.data['edited']  ?? [];
          });
        }
        break;
      case 1:
        final r = await ApiService.getDoctorRequests('accepted');
        if (r.success) setState(() => _accepted = r.data['accepted'] ?? []);
        break;
      case 2:
        final r = await ApiService.getDoctorRequests('completed');
        if (r.success) setState(() => _done = r.data['completed'] ?? []);
        break;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Container(
            color: kBgLight,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Requests',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
                      SizedBox(height: 2),
                      Text('Manage incoming consultation requests',
                          style: TextStyle(fontSize: 13, color: kTextGray)),
                    ]),
                    OutlinedButton.icon(
                      onPressed: _loadCurrentTab,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextGray,
                        side: const BorderSide(color: kBorderColor),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : TabBarView(
                    controller: _tab,
                    children: [
                      _buildPendingTab(),
                      _buildSimpleTab(_accepted, _buildAcceptedCard),
                      _buildSimpleTab(_done, _buildDoneCard),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── PENDING TAB ────────────────────────────────────────────────────────────
  Widget _buildPendingTab() {
    if (_pending.isEmpty && _edited.isEmpty) return _emptyState();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ..._pending.map((r) => _buildPendingCard(r, isEdited: false)),
        ..._edited.map((r) => _buildPendingCard(r, isEdited: true)),
      ],
    );
  }

  Widget _buildPendingCard(Map r, {required bool isEdited}) {
    final id    = r['id'] as int;
    final slots = List<String>.from(r['available_slots'] ?? []);

    // init selected slot once
    if (!_selectedSlots.containsKey(id) && slots.isNotEmpty) {
      _selectedSlots[id] = slots.first;
    }
    final selectedSlot = _selectedSlots[id];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBgLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: kPrimary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r['requester_name'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isEdited ? const Color(0xFFFEE2E2) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    isEdited ? 'EDITED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: isEdited ? kRed : kAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info row ──────────────────────────────────────
                Row(children: [
                  Expanded(child: _infoTile(Icons.calendar_today_outlined, 'DATE', _formatDate(r['date'] ?? ''))),
                  const SizedBox(width: 12),
                  Expanded(child: _infoTile(Icons.access_time_rounded, 'TIME', _formatTime(r['time'] ?? ''))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _infoTile(Icons.location_city_outlined, 'GOVERNORATE', r['governorate'] ?? '')),
                  const SizedBox(width: 12),
                  Expanded(child: _infoTile(Icons.payments_outlined, 'TOTAL PRICE', '${r['total_price'] ?? ''} EGP')),
                ]),
                const SizedBox(height: 14),

                // ── Address ───────────────────────────────────────
                // Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //   const Icon(Icons.location_on_outlined, size: 16, color: kTextGray),
                //   const SizedBox(width: 6),
                //   Expanded(child: Text(r['address'] ?? '',
                //       style: const TextStyle(fontSize: 13, color: kTextGray, height: 1.4))),
                // ]),
                // const SizedBox(height: 14),

                // ── Description ───────────────────────────────────
                if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
                  _sectionLabel('DESCRIPTION'),
                  const SizedBox(height: 6),
                  Text(r['disease_description'] ?? '',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
                  const SizedBox(height: 14),
                ],

                // ── Time slots ────────────────────────────────────
                _sectionLabel('SELECT TIME SLOT'),
                const SizedBox(height: 10),
                slots.isEmpty
                    ? const Text('No slots available',
                        style: TextStyle(fontSize: 13, color: kTextGray))
                    : Wrap(
                        spacing: 8, runSpacing: 8,
                        children: slots.map((s) {
                          final active = selectedSlot == s;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSlots[id] = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: active ? kPrimary : const Color(0xFFF0F4F8),
                                border: Border.all(color: active ? kPrimary : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: active ? [
                                  BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))
                                ] : [],
                              ),
                              child: Text(_formatTime(s),
                                  style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : const Color(0xFF4B5563),
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 16),

                // ── Actions ───────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _actionBtn('Reject', kRed, const Color(0xFFFEE2E2), () => _rejectRequest(id)),
                  const SizedBox(width: 10),
                  _actionBtn(
                    isEdited ? 'Edited' : 'Accept',
                    Colors.white, kPrimary,
                    () => _acceptRequest(id, selectedSlot, isEdited: isEdited),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACCEPTED TAB ───────────────────────────────────────────────────────────
  Widget _buildSimpleTab(List<dynamic> items, Widget Function(Map) builder) {
    if (items.isEmpty) return _emptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => builder(items[i] as Map),
    );
  }

  Widget _buildAcceptedCard(Map r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline_rounded, color: kPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['requester_name'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
                const SizedBox(height: 2),
                Text('${_formatDate(r['date'] ?? '')}  •  ${_formatTime(r['time'] ?? '')}',
                    style: const TextStyle(fontSize: 12, color: kTextGray)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('Accepted',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kPrimary)),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Address
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 15, color: kPrimary),
              const SizedBox(width: 4),
              Expanded(child: Text('${r['governorate'] ?? ''} / ${r['address'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: kTextGray))),
            ]),
            const SizedBox(height: 2),
            const Divider(color: Color(0xFFF0F4F8), thickness: 1),
            const SizedBox(height: 2),

            // Description
            if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
              _sectionLabel('DESCRIPTION'),
              const SizedBox(height: 6),
              Text(r['disease_description'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
              const SizedBox(height: 12),
            ],

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Price', style: TextStyle(fontSize: 13, color: kTextGray)),
                Text('${r['total_price'] ?? ''} EGP',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimary)),
              ]),
            ),

            // Patient confirmed banner
            if (r['patient_done'] == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Patient has confirmed appointment',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 14),

            // Footer — phone + Done button
            Row(children: [
              const Icon(Icons.phone_outlined, size: 18, color: kTextGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text('0${r['requester_phone'] ?? ''}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kDarkText),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _markDone(r['id'] as int),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── DONE TAB ───────────────────────────────────────────────────────────
  Widget _buildDoneCard(Map r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: kGreen.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline_rounded, color: kGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['requester_name'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
                const SizedBox(height: 2),
                Text('${_formatDate(r['date'] ?? '')}  •  ${_formatTime(r['time'] ?? '')}',
                    style: const TextStyle(fontSize: 12, color: kTextGray)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFE6F7E6), borderRadius: BorderRadius.circular(30)),
              child: const Text('DONE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Address
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 15, color: kPrimary),
              const SizedBox(width: 4),
              Expanded(child: Text('${r['governorate'] ?? ''} / ${r['address'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: kTextGray))),
            ]),
            const SizedBox(height: 2),
            const Divider(color: Color(0xFFF0F4F8), thickness: 1),
            const SizedBox(height: 2),

            // Description
            if ((r['disease_description'] ?? '').toString().isNotEmpty) ...[
              _sectionLabel('DESCRIPTION'),
              const SizedBox(height: 6),
              Text(r['disease_description'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
              const SizedBox(height: 12),
            ],

            // Financial summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('TOTAL PRICE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text('${r['total_price'] ?? ''} EGP',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('NET INCOME',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text('${r['net_income'] ?? ''} EGP',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
                ]),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── API Actions ────────────────────────────────────────────────────────────
  Future<void> _acceptRequest(int id, String? slot, {required bool isEdited}) async {
    final result = await ApiService.requestActionDoctor(
      id,
      isEdited ? 'reschedule' : 'accept',
      time: slot,
    );
    if (result.success) {
      _loadCurrentTab();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectRequest(int id) async {
    final result = await ApiService.requestActionDoctor(id, 'reject');
    if (result.success) {
      _loadCurrentTab();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markDone(int id) async {
    final result = await ApiService.markDoneDoctor(id);
    if (result.success) {
      _loadCurrentTab();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kBgLight, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: kPrimary),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimary, letterSpacing: 0.5));

  Widget _actionBtn(String label, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 64, color: kTextGray.withOpacity(0.3)),
      const SizedBox(height: 12),
      const Text('No requests here', style: TextStyle(fontSize: 15, color: kTextGray)),
    ]));
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final profilePic = _profileData?['profile_pic'];
    final picUrl = ApiService.buildMediaUrl(profilePic);
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
            Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
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
              : const NetworkImage(
                  'https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
      {'icon': Icons.list_alt_rounded, 'label': 'Requests'},
      {'icon': Icons.local_hospital_outlined, 'label': 'Donation'},
      {'icon': Icons.notifications_none_rounded, 'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded, 'label': 'Complaints'},
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
                  Text('Medical Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorProfileScreen()));
        break;
      case 'Notifications':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorWalletScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorComplaintsScreen()));
        break;
      case 'Donation':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorDonationScreen()));
        break;
      default: break;
    }
  }
}