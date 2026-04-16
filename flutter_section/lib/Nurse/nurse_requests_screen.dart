import 'package:flutter/material.dart';
import '../Nurse/nurse_profile_screen.dart';
import '../Nurse/nurse_notifications.dart';
import '../Nurse/nurse_wallet.dart';
import '../Nurse/nurse_complaints.dart';

const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);
const Color kGreen      = Color(0xFF10B981);
const Color kAmber      = Color(0xFFF59E0B);
const Color kRed        = Color(0xFFEF4444);

// ─── Models ───────────────────────────────────────────────────────────────
enum NurseReqStatus { pending, accepted, done }

class ServiceItem {
  final String name;
  final int price;
  const ServiceItem({required this.name, required this.price});
}

class NurseRequest {
  final String id;
  final String patientName;
  final String address;
  final String date;
  final String time;
  final String description;
  final String condition;
  final List<ServiceItem> services;
  final int totalPrice;
  final int earning;
  final String phone;
  final bool userConfirmed;
  NurseReqStatus status;
  String? selectedSlot;

  NurseRequest({
    required this.id, required this.patientName, required this.address,
    required this.date, required this.time, required this.description,
    required this.condition, required this.services,
    required this.totalPrice, required this.earning, required this.phone,
    required this.userConfirmed, required this.status, this.selectedSlot,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────
class NurseRequestsScreen extends StatefulWidget {
  const NurseRequestsScreen({super.key});
  @override
  State<NurseRequestsScreen> createState() => _NurseRequestsScreenState();
}

class _NurseRequestsScreenState extends State<NurseRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<String> _availableSlots = [
    '04:30 PM','11:30 AM','02:00 PM','04:30 PM','06:00 PM',
    '09:00 AM','10:30 AM','05:00 PM',
  ];

  final List<NurseRequest> _requests = [
    NurseRequest(
      id: '1', patientName: 'Ahmed Mansour',
      address: 'Cairo — 123 Nile St, Maadi',
      date: '12 Oct 2023', time: '10:00 AM',
      description: 'Patient requires regular glucose monitoring and insulin administration assistance. Occasional foot care and wound inspection needed.',
      condition: 'Diabetes Management & Care',
      services: [
        const ServiceItem(name: 'Home Visit Consultation', price: 200),
        const ServiceItem(name: 'Wound Dressing (Small)', price: 100),
        const ServiceItem(name: 'Glucose Check', price: 50),
      ],
      totalPrice: 350, earning: 280, phone: '+20 123 456 789',
      userConfirmed: true, status: NurseReqStatus.pending, selectedSlot: '11:30 AM',
    ),
    NurseRequest(
      id: '2', patientName: 'Sara Mohamed',
      address: 'Cairo / Maadi, Street 250, Building 14, 4th Floor',
      date: 'Oct 24, 2023', time: '10:30 AM',
      description: 'Patient reports severe chest pain and shortness of breath since early morning. Previous history of hypertension noted.',
      condition: 'Hypertension Monitoring',
      services: [
        const ServiceItem(name: 'Home Visit Consultation', price: 200),
        const ServiceItem(name: 'Vitals Monitoring', price: 200),
        const ServiceItem(name: 'IV Drip (Basic)', price: 200),
      ],
      totalPrice: 600, earning: 480, phone: '+20 102 345 6789',
      userConfirmed: true, status: NurseReqStatus.accepted, selectedSlot: '10:30 AM',
    ),
    NurseRequest(
      id: '3', patientName: 'Fatma El-Sayed',
      address: 'Maadi, Cairo - St.15, Building 4',
      date: '22 Oct, 2023', time: '09:00 AM',
      description: 'Patient is recovering from hip replacement surgery. Requires daily wound dressing, vital signs monitoring, and assistance with prescribed physical therapy exercises.',
      condition: 'Post-Operative Recovery',
      services: [
        const ServiceItem(name: 'Wound Dressing (Major)', price: 450),
        const ServiceItem(name: 'Vitals Monitoring', price: 200),
        const ServiceItem(name: 'Home Visit Fee', price: 150),
      ],
      totalPrice: 800, earning: 680, phone: '+20 100 987 6543',
      userConfirmed: true, status: NurseReqStatus.done, selectedSlot: '09:00 AM',
    ),
  ];

  List<NurseRequest> get _pending  => _requests.where((r) => r.status == NurseReqStatus.pending).toList();
  List<NurseRequest> get _accepted => _requests.where((r) => r.status == NurseReqStatus.accepted).toList();
  List<NurseRequest> get _done     => _requests.where((r) => r.status == NurseReqStatus.done).toList();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(children: [
        // Sticky header
        Container(color: kBgLight, padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
              SizedBox(height: 2),
              Text('Manage incoming consultation requests', style: TextStyle(fontSize: 13, color: kTextGray)),
            ]),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_rounded, size: 16),
              label: const Text('Filter', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(foregroundColor: kTextGray, side: const BorderSide(color: kBorderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ]),
          const SizedBox(height: 14),
          TabBar(
            controller: _tab,
            labelColor: kPrimary, unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            indicatorColor: kPrimary, indicatorWeight: 2,
            tabs: [
              Tab(text: 'Pending (${_pending.length})'),
              Tab(text: 'Accepted (${_accepted.length})'),
              Tab(text: 'Done (${_done.length})'),
            ],
          ),
        ])),

        Expanded(child: TabBarView(controller: _tab, children: [
          _buildList(_pending,  _buildPendingCard),
          _buildList(_accepted, _buildAcceptedCard),
          _buildList(_done,     _buildDoneCard),
        ])),
      ]),
    );
  }

  Widget _buildList(List<NurseRequest> items, Widget Function(NurseRequest) builder) {
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

  // ── PENDING card ──────────────────────────────────────────────────────────
  Widget _buildPendingCard(NurseRequest r) {
    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Top
      _TopRow(name: r.patientName,
          subtitle: Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
            const SizedBox(width: 3),
            Flexible(child: Text(r.address, style: const TextStyle(fontSize: 12, color: kTextGray))),
          ]),
          statusLabel: 'PENDING', statusColor: kAmber, statusBg: const Color(0xFFFFFBEB)),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: kBorderColor, thickness: 1)),

      // Date + Time
      Row(children: [
        _dateTimeChip(Icons.calendar_today_outlined, 'Date', r.date),
        const SizedBox(width: 16),
        _dateTimeChip(Icons.access_time_rounded, 'Time', r.time),
      ]),
      const SizedBox(height: 14),
      const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider(color: kBorderColor, thickness: 1)),

      // Condition + Description
      Text(r.condition, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
      const SizedBox(height: 6),
      Text(r.description, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
      const SizedBox(height: 14),

      // Services
      _ServicesBox(services: r.services, total: r.totalPrice),
      const SizedBox(height: 14),
      const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Divider(color: kBorderColor, thickness: 1)),

      // Time slots
      const Text('Time Slots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
      const SizedBox(height: 8),
      _SlotsCarousel(slots: _availableSlots, selected: r.selectedSlot,
          onSelect: (s) => setState(() => r.selectedSlot = s)),
      const SizedBox(height: 16),

      // Actions
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _Btn(label: 'Reject', color: kRed, bg: const Color(0xFFFEE2E2),
            onTap: () => setState(() => _requests.remove(r))),
        const SizedBox(width: 10),
        _Btn(label: 'Accept', color: Colors.white, bg: kPrimary,
            onTap: () => setState(() => r.status = NurseReqStatus.accepted)),
      ]),
    ]));
  }

  // ── ACCEPTED card ─────────────────────────────────────────────────────────
  Widget _buildAcceptedCard(NurseRequest r) {
    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TopRow(name: r.patientName,
          subtitle: Text('${r.date}  •  ${r.selectedSlot ?? r.time}', style: const TextStyle(fontSize: 12, color: kTextGray)),
          statusLabel: 'Accepted', statusColor: kPrimary, statusBg: kPrimary.withOpacity(0.1)),
      const SizedBox(height: 10),
      Row(children: [
        const Icon(Icons.location_on_outlined, size: 14, color: kTextGray),
        const SizedBox(width: 4),
        Expanded(child: Text(r.address, style: const TextStyle(fontSize: 13, color: kTextGray))),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: kBorderColor)),

      // Description
      const Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimary, letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Text(r.description, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
      const SizedBox(height: 14),
      const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Divider(color: kBorderColor)),

      // Total
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price', style: TextStyle(fontSize: 13, color: kTextGray)),
        Text('${r.totalPrice} EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
      ]),
      const SizedBox(height: 12),

      // Confirmed banner
      if (r.userConfirmed)
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 18),
            SizedBox(width: 8),
            Text('User Has Confirmed Appointment',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
          ])),
      const SizedBox(height: 14),

      // Footer
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.phone_outlined, size: 16, color: kTextGray),
          const SizedBox(width: 6),
          Text(r.phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kDarkText)),
        ]),
        ElevatedButton(
          onPressed: () => setState(() => r.status = NurseReqStatus.done),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    ]));
  }

  // ── DONE card ─────────────────────────────────────────────────────────────
  Widget _buildDoneCard(NurseRequest r) {
    return _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _TopRow(name: r.patientName,
          subtitle: Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
            const SizedBox(width: 3),
            Flexible(child: Text(r.address, style: const TextStyle(fontSize: 12, color: kTextGray))),
          ]),
          statusLabel: 'DONE', statusColor: kGreen, statusBg: const Color(0xFFE6F7E6)),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: kBorderColor)),

      // Info row
      Row(children: [
        _infoBlock('DATE & TIME', '${r.date} | ${r.selectedSlot ?? r.time}'),
        const SizedBox(width: 20),
        _infoBlock('CONDITION', r.condition),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: kBorderColor)),

      const Text('DISEASE DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Text(r.description, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.5)),
      const SizedBox(height: 14),

      // Services + total + earning
      const Text('SERVICES REQUESTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      ...r.services.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.name, style: const TextStyle(fontSize: 13, color: kDarkText)),
          Text('${s.price} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
      )),
      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: kBorderColor)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        Text('${r.totalPrice} EGP', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDarkText)),
      ]),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your Earning', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
        Text('${r.earning} EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kGreen)),
      ]),
    ]));
  }

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

  Widget _infoBlock(String label, String value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
  ]));

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
    leading: Builder(builder: (ctx) => IconButton(
      icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
      onPressed: () => Scaffold.of(ctx).openDrawer())),
    title: const Text('Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
    actions: [
      IconButton(icon: Stack(clipBehavior: Clip.none, children: const [
        Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
        Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
      ]), onPressed: () {}),
      const SizedBox(width: 4),
      const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
      const SizedBox(width: 12),
      const CircleAvatar(radius: 20,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg')),
      const SizedBox(width: 16),
    ],
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: kBorderColor, height: 1)),
  );

  // ── Drawer ────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
    ];
    return Drawer(backgroundColor: Colors.white, child: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
            Text('Medical Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
          ]),
        ]),
        const SizedBox(height: 32),
        ...items.map((item) {
          final isActive = item['label'] == 'Requests';
          return Container(margin: const EdgeInsets.only(bottom: 8), child: Material(
            color: isActive ? kPrimary : Colors.transparent, borderRadius: BorderRadius.circular(15),
            child: InkWell(borderRadius: BorderRadius.circular(15),
              onTap: () { Navigator.pop(context); _handleNav(context, item['label'] as String); },
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Icon(item['icon'] as IconData, color: isActive ? Colors.white : const Color(0xFF4B5563), size: 22),
                  const SizedBox(width: 12),
                  Text(item['label'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF4B5563))),
                ])),
            ),
          ));
        }),
      ]),
    )));
  }

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Profile':       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseProfileScreen())); break;
      case 'Notifications': Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseNotificationsScreen())); break;
      case 'Wallet':        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseWalletScreen())); break;
      case 'Complaints':    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NurseComplaintsScreen())); break;
      default: break;
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────
class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4))]),
    child: child,
  );
}

class _TopRow extends StatelessWidget {
  final String name;
  final Widget subtitle;
  final String statusLabel;
  final Color statusColor, statusBg;
  const _TopRow({required this.name, required this.subtitle, required this.statusLabel,
      required this.statusColor, required this.statusBg});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Expanded(child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
          child: const Icon(Icons.person_outline_rounded, color: kPrimary, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 2), subtitle,
      ])),
    ])),
    const SizedBox(width: 10),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(30)),
        child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor))),
  ]);
}

class _ServicesBox extends StatelessWidget {
  final List<ServiceItem> services;
  final int total;
  const _ServicesBox({required this.services, required this.total});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Services Requested', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
          color: kDarkText, letterSpacing: 0.3)),
      const SizedBox(height: 10),
      ...services.map((s) => Padding(padding: const EdgeInsets.only(bottom: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.name, style: const TextStyle(fontSize: 13, color: kDarkText)),
          Text('${s.price} EGP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]))),
      const Divider(color: kBorderColor, thickness: 1),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Price', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDarkText)),
        Text('$total EGP', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPrimary)),
      ]),
    ]),
  );
}

class _SlotsCarousel extends StatelessWidget {
  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _SlotsCarousel({required this.slots, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => SizedBox(height: 38, child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: slots.length,
    separatorBuilder: (_, __) => const SizedBox(width: 8),
    itemBuilder: (_, i) {
      final isActive = slots[i] == selected;
      return GestureDetector(onTap: () => onSelect(slots[i]), child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? kPrimary : const Color(0xFFF0F4F8),
          border: Border.all(color: isActive ? kPrimary : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Center(child: Text(slots[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF4B5563)))),
      ));
    },
  ));
}

class _Btn extends StatelessWidget {
  final String label; final Color color, bg; final VoidCallback onTap;
  const _Btn({required this.label, required this.color, required this.bg, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))));
}