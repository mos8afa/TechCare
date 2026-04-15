import 'package:flutter/material.dart';
import '../Doctor/doctor_profile_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';

// ─── Colors ───────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ─── Data model ───────────────────────────────────────────────────────────
enum RequestStatus { pending, accepted, done }

class ConsultationRequest {
  final String id;
  final String patientName;
  final String date;
  final String time;
  final String governorate;
  final String address;
  final String description;
  final int totalPrice;
  final int netIncome;
  final String phone;
  final bool userConfirmed;
  RequestStatus status;
  String? selectedSlot;

  ConsultationRequest({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
    required this.governorate,
    required this.address,
    required this.description,
    required this.totalPrice,
    required this.netIncome,
    required this.phone,
    required this.userConfirmed,
    required this.status,
    this.selectedSlot,
  });
}

// ─── Requests Screen ──────────────────────────────────────────────────────
class DoctorRequestsScreen extends StatefulWidget {
  const DoctorRequestsScreen({super.key});

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<String> _availableSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM',
    '10:30 AM', '11:00 AM', '11:30 AM',
    '04:00 PM', '04:30 PM', '05:00 PM',
  ];

  final List<ConsultationRequest> _requests = [
    ConsultationRequest(
      id: '1',
      patientName: 'Ahmed Mansour',
      date: 'Oct 24, 2023',
      time: '10:00 AM',
      governorate: 'Cairo',
      address: 'Cairo / Maadi, Street 250, Building 14, 4th Floor',
      description:
          'Patient reports persistent lower back pain for 3 days with difficulty walking. Requires home visit for assessment and potential therapy.',
      totalPrice: 500,
      netIncome: 400,
      phone: '+20 102 345 6789',
      userConfirmed: false,
      status: RequestStatus.pending,
      selectedSlot: '10:00 AM',
    ),
    ConsultationRequest(
      id: '2',
      patientName: 'Sara Mohamed',
      date: 'Oct 25, 2023',
      time: '09:30 AM',
      governorate: 'Giza',
      address: 'Giza / Dokki, Street 12, Building 3, 2nd Floor',
      description:
          'Patient reports severe chest pain and shortness of breath since early morning. Previous history of hypertension noted.',
      totalPrice: 500,
      netIncome: 400,
      phone: '+20 111 234 5678',
      userConfirmed: true,
      status: RequestStatus.accepted,
      selectedSlot: '09:30 AM',
    ),
    ConsultationRequest(
      id: '3',
      patientName: 'Karim Hassan',
      date: 'Oct 22, 2023',
      time: '11:00 AM',
      governorate: 'Alexandria',
      address: 'Alexandria / Smouha, Street 5, Building 9, Ground Floor',
      description:
          'Follow-up visit for diabetes management. Patient requests blood sugar monitoring and medication review.',
      totalPrice: 500,
      netIncome: 400,
      phone: '+20 100 987 6543',
      userConfirmed: true,
      status: RequestStatus.done,
      selectedSlot: '11:00 AM',
    ),
  ];

  List<ConsultationRequest> get _pending =>
      _requests.where((r) => r.status == RequestStatus.pending).toList();
  List<ConsultationRequest> get _accepted =>
      _requests.where((r) => r.status == RequestStatus.accepted).toList();
  List<ConsultationRequest> get _done =>
      _requests.where((r) => r.status == RequestStatus.done).toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // ── Sticky header ─────────────────────────────────────────
          Container(
            color: kBgLight,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
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
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: 'Pending (${_pending.length})'),
                    Tab(text: 'Accepted (${_accepted.length})'),
                    Tab(text: 'Done (${_done.length})'),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab content ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildList(_pending, _buildPendingCard),
                _buildList(_accepted, _buildAcceptedCard),
                _buildList(_done, _buildDoneCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic list builder ──────────────────────────────────────────────
  Widget _buildList(
    List<ConsultationRequest> items,
    Widget Function(ConsultationRequest) builder,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 60, color: kTextGray.withOpacity(0.35)),
            const SizedBox(height: 12),
            const Text('No requests here',
                style: TextStyle(fontSize: 15, color: kTextGray)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }

  // ── PENDING card ──────────────────────────────────────────────────────
  Widget _buildPendingCard(ConsultationRequest r) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTopRow(
            name: r.patientName,
            statusLabel: 'PENDING',
            statusColor: kAmber,
            statusBg: const Color(0xFFFFFBEB),
          ),
          const SizedBox(height: 16),
          _InfoGrid(items: [
            _InfoCell(label: 'Date', value: r.date),
            _InfoCell(label: 'Time', value: r.time),
            _InfoCell(label: 'Governorate', value: r.governorate),
            _InfoCell(label: 'Total Price', value: '${r.totalPrice} EGP'),
          ]),
          const SizedBox(height: 14),
          _DescriptionBox(label: 'DESCRIPTION', text: r.description),
          const SizedBox(height: 14),
          const Text('Time Slots',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimary)),
          const SizedBox(height: 8),
          _TimeSlotsCarousel(
            slots: _availableSlots,
            selected: r.selectedSlot,
            onSelect: (s) => setState(() => r.selectedSlot = s),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionBtn(
                label: 'Reject',
                color: kRed,
                bg: const Color(0xFFFEE2E2),
                onTap: () => setState(() => _requests.remove(r)),
              ),
              const SizedBox(width: 10),
              _ActionBtn(
                label: 'Accept',
                color: Colors.white,
                bg: kPrimary,
                onTap: () =>
                    setState(() => r.status = RequestStatus.accepted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ACCEPTED card ─────────────────────────────────────────────────────
  Widget _buildAcceptedCard(ConsultationRequest r) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTopRow(
            name: r.patientName,
            subtitle: '${r.date}  •  ${r.selectedSlot ?? r.time}',
            statusLabel: 'Accepted',
            statusColor: kPrimary,
            statusBg: kPrimary.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 15, color: kTextGray),
            const SizedBox(width: 4),
            Expanded(
                child: Text(r.address,
                    style: const TextStyle(
                        fontSize: 13, color: kTextGray))),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF0F4F8), thickness: 1),
          ),
          _DescriptionBox(label: 'DESCRIPTION', text: r.description),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Price',
                  style: TextStyle(fontSize: 13, color: kTextGray)),
              Text('${r.totalPrice} EGP',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          if (r.userConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF16A34A), size: 20),
                SizedBox(width: 8),
                Text('USER HAS CONFIRMED APPOINTMENT',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A))),
              ]),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: kTextGray),
                const SizedBox(width: 6),
                Text(r.phone,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kDarkText)),
              ]),
              ElevatedButton(
                onPressed: () =>
                    setState(() => r.status = RequestStatus.done),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 10),
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

  // ── DONE card ─────────────────────────────────────────────────────────
  Widget _buildDoneCard(ConsultationRequest r) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTopRow(
            name: r.patientName,
            subtitle: '${r.date}  •  ${r.selectedSlot ?? r.time}',
            statusLabel: 'DONE',
            statusColor: kGreen,
            statusBg: const Color(0xFFE6F7E6),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 15, color: kTextGray),
            const SizedBox(width: 4),
            Expanded(
                child: Text(r.address,
                    style: const TextStyle(
                        fontSize: 13, color: kTextGray))),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF0F4F8), thickness: 1),
          ),
          _DescriptionBox(label: 'DESCRIPTION', text: r.description),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kBgLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL PRICE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kTextGray,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text('${r.totalPrice} EGP',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kDarkText)),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('NET INCOME',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: kTextGray,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text('${r.netIncome} EGP',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kPrimary)),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────
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
                  top: -2,
                  child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFFEF4444))),
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

  // ── Drawer ────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
      {'icon': Icons.list_alt_rounded, 'label': 'Requests'},
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: Row(children: [
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DoctorProfileScreen()));
        break;
      case 'Notifications':
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const DoctorNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DoctorWalletScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const DoctorComplaintsScreen()));
        break;
      default:
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reusable sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F4F8)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x07000000),
                blurRadius: 12,
                offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

class _CardTopRow extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;

  const _CardTopRow({
    required this.name,
    this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: kPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kDarkText)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(fontSize: 12, color: kTextGray)),
          ]),
        ]),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: statusBg, borderRadius: BorderRadius.circular(30)),
          child: Text(statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor)),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoCell> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: kBgLight, borderRadius: BorderRadius.circular(14)),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.5,
        children: items,
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: kTextGray,
              letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kDarkText)),
    ]);
  }
}

class _DescriptionBox extends StatelessWidget {
  final String label;
  final String text;
  const _DescriptionBox({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kPrimary,
              letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Text(text,
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A5568),
              height: 1.5)),
    ]);
  }
}

class _TimeSlotsCarousel extends StatelessWidget {
  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _TimeSlotsCarousel(
      {required this.slots,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                        fontSize: 13,
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      ),
    );
  }
}