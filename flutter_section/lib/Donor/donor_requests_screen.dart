import 'package:flutter/material.dart';
import 'donor_profile_screen.dart';
import 'donor_notifications_screen.dart';
import 'donor_wallet_screen.dart';
import 'donor_complaints_screen.dart';

// ─── Colors ───────────────────────────────────────────────────────────────
const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);
const Color kRed         = Color(0xFFEF4444);

// ═══════════════════════════════════════════════════════════════════════════
// MAIN REQUESTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class DonorRequestsScreen extends StatefulWidget {
  const DonorRequestsScreen({super.key});

  @override
  State<DonorRequestsScreen> createState() => _DonorRequestsScreenState();
}

class _DonorRequestsScreenState extends State<DonorRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTab;

  static const _categories = [
    {'icon': Icons.medical_services_outlined,  'label': 'Doctor'},
    {'icon': Icons.health_and_safety_outlined,  'label': 'Nurse'},
    {'icon': Icons.medication_outlined,         'label': 'Medicine'},
    {'icon': Icons.water_drop_outlined,         'label': 'Donations'},
  ];

  @override
  void initState() {
    super.initState();
    _categoryTab = TabController(length: 4, vsync: this);
    _categoryTab.addListener(() { if (!_categoryTab.indexIsChanging) setState(() {}); });
  }

  @override
  void dispose() { _categoryTab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // ── Category tabs ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderColor),
              ),
              child: TabBar(
                controller: _categoryTab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimary.withOpacity(0.3)),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: kPrimary,
                unselectedLabelColor: kTextGray,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(3),
                tabs: _categories.map((c) => Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c['icon'] as IconData, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          c['label'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _categoryTab,
              children: const [
                _DoctorTab(),
                _NurseTab(),
                _MedicineTab(),
                _DonationsTab(),
              ],
            ),
          ),
        ],
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
      title: const Text('Donor Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: kRed)),
          ]),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DonorNotificationsScreen())),
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
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
      {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
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
                        switch (item['label']) {
                          case 'Profile':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorProfileScreen())); break;
                          case 'Notifications':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorNotificationsScreen())); break;
                          case 'Wallet':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorWalletScreen())); break;
                          case 'Complaints':
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonorComplaintsScreen())); break;
                        }
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
}

// ═══════════════════════════════════════════════════════════════════════════
// DOCTOR TAB
// ═══════════════════════════════════════════════════════════════════════════

class _DoctorTab extends StatefulWidget {
  const _DoctorTab();
  @override
  State<_DoctorTab> createState() => _DoctorTabState();
}

class _DoctorTabState extends State<_DoctorTab> with SingleTickerProviderStateMixin {
  late TabController _sub;

  final _doctors = [
    {'id': 1, 'name': 'Dr. Ahmed Salem',   'spec': 'Senior Cardiologist', 'gov': 'Cairo, Maadi',      'rating': 4.9, 'fee': 450, 'img': 'https://randomuser.me/api/portraits/men/41.jpg'},
    {'id': 2, 'name': 'Dr. Sarah Hassan',  'spec': 'Pediatrician',         'gov': 'Alexandria, Smouha','rating': 4.2, 'fee': 350, 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'id': 3, 'name': 'Dr. Omar Farid',    'spec': 'Neurologist',          'gov': 'Giza, Dokki',       'rating': 5.0, 'fee': 600, 'img': 'https://randomuser.me/api/portraits/men/55.jpg'},
    {'id': 4, 'name': 'Dr. Laila Ibrahim', 'spec': 'Dermatologist',         'gov': 'Cairo, Heliopolis', 'rating': 4.7, 'fee': 400, 'img': 'https://randomuser.me/api/portraits/women/33.jpg'},
    {'id': 5, 'name': 'Dr. Khaled Nour',   'spec': 'Orthopedic',           'gov': 'Giza, 6th October', 'rating': 4.5, 'fee': 500, 'img': 'https://randomuser.me/api/portraits/men/22.jpg'},
    {'id': 6, 'name': 'Dr. Mona Zaki',     'spec': 'Psychiatrist',          'gov': 'Cairo, Nasr City',  'rating': 4.8, 'fee': 550, 'img': 'https://randomuser.me/api/portraits/women/65.jpg'},
  ];

  final _searchCtrl = TextEditingController();
  String _specFilter = 'All', _govFilter = 'All', _priceFilter = 'All';

  final _pending = [
    {'doctor': 'Dr. Michael Miller', 'date': 'Oct 28, 2023', 'time': '02:00 PM', 'status': 'pending',     'desc': "I've been feeling persistent headaches and fatigue for the past week.", 'gov': 'Manhattan Region', 'address': '123 Health Blvd, Suite 400, NY', 'phone': '+1 (555) 012-3456', 'price': '\$75.00'},
    {'doctor': 'Dr. Sarah Mansour',  'date': 'Oct 29, 2023', 'time': '09:30 AM', 'status': 'rescheduled', 'desc': '"Post-procedure checkup for heart rate monitoring results."',              'gov': 'Downtown Hub',      'address': '456 Oak Ave, Jersey City, NJ',  'phone': '+1 (555) 987-6543', 'price': '\$120.00'},
  ];
  final _accepted = [
    {'doctor': 'Dr. Sarah Miller',   'spec': 'Senior Cardiologist',  'date': 'Oct 24, 2023 • 10:30 AM', 'gov': 'Cairo, Maadi District', 'phone': '+20 100 234 5678', 'status': 'Confirmed by Provider', 'desc': 'Regular checkup for heart monitoring and ECG analysis.', 'total': '\$165.00', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'doctor': 'Dr. Michael Miller', 'spec': 'Specialized Home Care', 'date': 'Oct 26, 2023 • 02:00 PM', 'gov': 'Giza, Sheikh Zayed',    'phone': '+20 112 888 9900', 'status': 'Confirmed by Provider', 'desc': '"Post-procedure checkup for heart rate monitoring results."', 'total': '\$200.00', 'img': 'https://randomuser.me/api/portraits/men/41.jpg'},
  ];
  final _done = [
    {'doctor': 'Dr. Sarah Miller',   'spec': 'Cardiologist Specialist', 'location': 'Downtown Medical Hub, Floor 4', 'date': 'Oct 24, 2023 • 10:30 AM', 'region': 'Central District, Cairo', 'desc': 'Routine check-up to monitor blood pressure stability.', 'total': '165.00 EGP', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'doctor': 'Dr. Michael Miller', 'spec': 'Home Care Specialist',    'location': 'Home Visit - North District',   'date': 'Oct 21, 2023 • 02:15 PM', 'region': 'Maadi, South Cairo',      'desc': 'Administration of annual flu vaccine and vitamin B12 supplement.', 'total': '200.00 EGP', 'img': 'https://randomuser.me/api/portraits/men/41.jpg'},
  ];

  @override
  void initState() { super.initState(); _sub = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _sub.dispose(); _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filtered => _doctors.where((d) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty && !(d['name'] as String).toLowerCase().contains(q)) return false;
    if (_specFilter != 'All' && d['spec'] != _specFilter) return false;
    if (_govFilter  != 'All' && !(d['gov'] as String).contains(_govFilter)) return false;
    return true;
  }).cast<Map<String, dynamic>>().toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SubTabBar(controller: _sub, labels: const ['Booking', 'Pending', 'Accepted', 'Done']),
      Expanded(
        child: TabBarView(controller: _sub, children: [
          _buildBooking(),
          _buildList(_pending,  _buildPendingCard),
          _buildList(_accepted, _buildAcceptedCard),
          _buildList(_done,     _buildDoneCard),
        ]),
      ),
    ]);
  }

  // ── BOOKING ───────────────────────────────────────────────────────────
  Widget _buildBooking() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(children: [
          _SearchField(controller: _searchCtrl, hint: 'Search by doctor...', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _FilterDropdown(value: _specFilter, hint: 'Specialization',
                items: const ['All', 'Senior Cardiologist', 'Pediatrician', 'Neurologist', 'Dermatologist', 'Orthopedic', 'Psychiatrist'],
                onChanged: (v) => setState(() => _specFilter = v!))),
            const SizedBox(width: 8),
            Expanded(child: _FilterDropdown(value: _govFilter, hint: 'Governorate',
                items: const ['All', 'Cairo', 'Giza', 'Alexandria'],
                onChanged: (v) => setState(() => _govFilter = v!))),
            const SizedBox(width: 8),
            Expanded(child: _FilterDropdown(value: _priceFilter, hint: 'Price Range',
                items: const ['All', '< 400 EGP', '400–600 EGP', '> 600 EGP'],
                onChanged: (v) => setState(() => _priceFilter = v!))),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => _DoctorCard(
            doctor: _filtered[i],
            onBook: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _DoctorBookingPage(doctor: _filtered[i]))),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPendingCard(dynamic r) {
    final isRescheduled = r['status'] == 'rescheduled';
    return _CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(children: [
              _Avatar(url: null, size: 48),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['doctor'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 11, color: kTextGray),
                  const SizedBox(width: 3),
                  Flexible(child: Text('${r['date']} | ${r['time']}', style: const TextStyle(fontSize: 11, color: kTextGray), overflow: TextOverflow.ellipsis)),
                ]),
              ])),
            ]),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: isRescheduled ? 'Rescheduled' : 'PENDING',
            color: kAmber, bg: const Color(0xFFFFFBEB),
            icon: isRescheduled ? Icons.schedule_rounded : null,
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorderColor)),
          child: Text(r['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.5)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LOCATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(r['gov'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
            Text(r['address'], style: const TextStyle(fontSize: 10, color: kTextGray)),
          ])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CONTACT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(r['phone'], style: const TextStyle(fontSize: 11, color: kDarkText)),
          ])),
        ]),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFF0F4F8)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TOTAL PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray)),
            Text(r['price'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
          ]),
          Row(children: [
            _ActionBtn(label: 'Cancel', color: kDarkText, bg: const Color(0xFFF1F5F9), onTap: () {}),
            const SizedBox(width: 8),
            _ActionBtn(label: 'Accept', color: Colors.white, bg: kPrimary, onTap: () {}),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildAcceptedCard(dynamic r) {
    return _CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Row(children: [
            _Avatar(url: r['img'], size: 46),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['doctor'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis),
              Text(r['spec'],   style: const TextStyle(fontSize: 11, color: kTextGray)),
            ])),
          ])),
          _StatusPill(label: 'Accepted', color: kPrimary, bg: kPrimary.withOpacity(0.10)),
        ]),
        const SizedBox(height: 12),
        _MetaItem(icon: Icons.calendar_today_outlined, label: 'DATE AND TIME', value: r['date']),
        const SizedBox(height: 6),
        _MetaItem(icon: Icons.phone_outlined, label: 'CONTACT INFO', value: r['phone']),
        const SizedBox(height: 6),
        _MetaItem(icon: Icons.location_on_outlined, label: 'REGION AND ADDRESS', value: r['gov']),
        const SizedBox(height: 6),
        _MetaItem(icon: Icons.verified_outlined, label: 'STATUS', value: r['status'], valueColor: kPrimary),
        const SizedBox(height: 12),
        const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(r['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.4)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('FINANCIAL TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray)),
            Text(r['total'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
          ]),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildDoneCard(dynamic r) {
    return _CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Row(children: [
            _Avatar(url: r['img'], size: 46),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['doctor'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis),
              Text(r['spec'],   style: const TextStyle(fontSize: 11, color: kPrimary)),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 11, color: kTextGray),
                const SizedBox(width: 2),
                Flexible(child: Text(r['location'], style: const TextStyle(fontSize: 10, color: kTextGray), overflow: TextOverflow.ellipsis)),
              ]),
            ])),
          ])),
          _StatusPill(label: 'DONE', color: kGreen, bg: const Color(0xFFE6F7F1)),
        ]),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFF0F4F8)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Date & Time', style: TextStyle(fontSize: 11, color: kTextGray)),
          Flexible(child: Text(r['date'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Region', style: TextStyle(fontSize: 11, color: kTextGray)),
          Flexible(child: Text(r['region'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(r['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.4)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray)),
          Text(r['total'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimary)),
        ]),
      ]),
    );
  }

  Widget _buildList(List items, Widget Function(dynamic) builder) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NURSE TAB
// ═══════════════════════════════════════════════════════════════════════════

class _NurseTab extends StatefulWidget {
  const _NurseTab();
  @override
  State<_NurseTab> createState() => _NurseTabState();
}

class _NurseTabState extends State<_NurseTab> with SingleTickerProviderStateMixin {
  late TabController _sub;
  final _searchCtrl = TextEditingController();
  String _serviceFilter = 'All', _govFilter = 'All', _priceFilter = 'All';

  final _nurses = [
    {'id': 1, 'name': 'Sarah Ahmed, RN',  'spec': 'Wound Care & IV Therapy Specialist', 'gov': 'Cairo, Maadi',      'rating': 4.9, 'img': 'https://randomuser.me/api/portraits/women/44.jpg', 'services': [{'name': 'Blood Pressure Check', 'price': 100}, {'name': 'Nebulizer Session', 'price': 250}], 'starting': 350},
    {'id': 2, 'name': 'Omar Hassan',       'spec': 'Critical Care & Post-Op Nursing',   'gov': 'Giza, Sheikh Zayed','rating': 4.9, 'img': 'https://randomuser.me/api/portraits/men/55.jpg',  'services': [{'name': 'Insulin Injection (SC)', 'price': 150}, {'name': 'Vital Signs Monitoring', 'price': 200}], 'starting': 350},
    {'id': 3, 'name': 'Hana Mostafa, RN', 'spec': 'Home Care Specialist',               'gov': 'Cairo, Heliopolis', 'rating': 4.6, 'img': 'https://randomuser.me/api/portraits/women/33.jpg', 'services': [{'name': 'Wound Dressing', 'price': 200}, {'name': 'Blood Pressure Check', 'price': 100}], 'starting': 300},
    {'id': 4, 'name': 'Karim Sobhi, RN',  'spec': 'Pediatric Nursing',                  'gov': 'Alexandria',        'rating': 4.7, 'img': 'https://randomuser.me/api/portraits/men/22.jpg',  'services': [{'name': 'Vaccination', 'price': 180}, {'name': 'Nebulizer Session', 'price': 250}], 'starting': 430},
  ];

  final _pending = [
    {'nurse': 'Michael Miller', 'date': 'Oct 28, 2023', 'time': '02:00 PM', 'status': 'rescheduled', 'services': [{'name': 'Insulin Injection (SC)', 'price': '150 EGP'}, {'name': 'Vital Signs Monitoring', 'price': '200 EGP'}], 'gov': 'Manhattan Region', 'address': '123 Health Blvd, NY', 'phone': '+1 (555) 012-3456', 'total': '450 EGP', 'img': 'https://randomuser.me/api/portraits/men/55.jpg'},
    {'nurse': 'Sarah Mansour',  'date': 'Oct 29, 2023', 'time': '09:30 AM', 'status': 'pending',      'services': [{'name': 'Blood Pressure Check', 'price': '100 EGP'}, {'name': 'Nebulizer Session', 'price': '250 EGP'}],     'gov': 'Downtown Hub',      'address': '456 Oak Ave, Jersey City', 'phone': '+1 (555) 987-6543', 'total': '450 EGP', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
  ];
  final _accepted = [
    {'nurse': 'Sarah Mansour', 'date': 'Oct 24, 2023 • 10:30 AM', 'gov': 'Cairo, Maadi District', 'phone': '+20 100 234 5678', 'status': 'Confirmed by Provider', 'services': [{'name': 'Blood Pressure Check', 'price': '100 EGP'}, {'name': 'Nebulizer Session', 'price': '250 EGP'}], 'total': '\$165.00', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'nurse': 'Michael Miller','date': 'Oct 26, 2023 • 02:00 PM', 'gov': 'Giza, Sheikh Zayed',     'phone': '+20 112 888 9900', 'status': 'Confirmed by Provider', 'services': [{'name': 'Insulin Injection (SC)', 'price': '150 EGP'}, {'name': 'Vital Signs Monitoring', 'price': '200 EGP'}], 'total': '\$200.00', 'img': 'https://randomuser.me/api/portraits/men/55.jpg'},
  ];
  final _done = [
    {'nurse': 'Sarah Mansour', 'date': 'Oct 24, 2023 • 10:30 AM', 'region': 'Central District, Cairo', 'services': [{'name': 'Insulin Injection (SC)', 'price': '150 EGP'}, {'name': 'Vital Signs Monitoring', 'price': '200 EGP'}], 'total': '165.00 EGP', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'nurse': 'Michael Miller','date': 'Oct 21, 2023 • 02:15 PM', 'region': 'Maadi, South Cairo',      'services': [{'name': 'Insulin Injection (SC)', 'price': '150 EGP'}, {'name': 'Vital Signs Monitoring', 'price': '200 EGP'}], 'total': '200.00 EGP', 'img': 'https://randomuser.me/api/portraits/men/55.jpg'},
  ];

  @override
  void initState() { super.initState(); _sub = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _sub.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SubTabBar(controller: _sub, labels: const ['Booking', 'Pending', 'Accepted', 'Done']),
      Expanded(
        child: TabBarView(controller: _sub, children: [
          _buildBooking(),
          _buildNursePendingList(),
          _buildNurseAcceptedList(),
          _buildNurseDoneList(),
        ]),
      ),
    ]);
  }

  Widget _buildBooking() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(children: [
          _SearchField(controller: _searchCtrl, hint: 'Search by Nurse...', onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _FilterDropdown(value: _serviceFilter, hint: 'Service Type', items: const ['All', 'Wound Care', 'IV Therapy', 'Pediatric', 'Home Care'], onChanged: (v) => setState(() => _serviceFilter = v!))),
            const SizedBox(width: 8),
            Expanded(child: _FilterDropdown(value: _govFilter, hint: 'Governorate', items: const ['All', 'Cairo', 'Giza', 'Alexandria'], onChanged: (v) => setState(() => _govFilter = v!))),
            const SizedBox(width: 8),
            Expanded(child: _FilterDropdown(value: _priceFilter, hint: 'Price Range', items: const ['All', '< 300 EGP', '300–500 EGP', '> 500 EGP'], onChanged: (v) => setState(() => _priceFilter = v!))),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: _nurses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _NurseCard(
            nurse: _nurses[i],
            onBook: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _NurseBookingPage(nurse: _nurses[i]))),
          ),
        ),
      ),
    ]);
  }

  Widget _buildNursePendingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12), itemCount: _pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = _pending[i];
        final isRescheduled = r['status'] == 'rescheduled';
        return _CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [
                _Avatar(url: r['img'] as String?, size: 48),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['nurse'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: kTextGray),
                    const SizedBox(width: 3),
                    Flexible(child: Text('${r['date']} | ${r['time']}', style: const TextStyle(fontSize: 11, color: kTextGray), overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
              ])),
              _StatusPill(label: isRescheduled ? 'Rescheduled' : 'PENDING', color: kAmber, bg: const Color(0xFFFFFBEB), icon: isRescheduled ? Icons.schedule_rounded : null),
            ]),
            const SizedBox(height: 12),
            const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            ...(r['services'] as List).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(s['name'], style: const TextStyle(fontSize: 12, color: kDarkText))),
                Text(s['price'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
              ]),
            )),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('LOCATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray)),
                Text(r['gov'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
                Text(r['address'] as String, style: const TextStyle(fontSize: 10, color: kTextGray)),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CONTACT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray)),
                Text(r['phone'] as String, style: const TextStyle(fontSize: 11, color: kDarkText)),
              ])),
            ]),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF0F4F8)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray)),
                Text(r['total'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
              ]),
              Row(children: [
                _ActionBtn(label: 'Cancel', color: kDarkText, bg: const Color(0xFFF1F5F9), onTap: () {}),
                const SizedBox(width: 8),
                _ActionBtn(label: 'Accept', color: Colors.white, bg: kPrimary, onTap: () {}),
              ]),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildNurseAcceptedList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12), itemCount: _accepted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = _accepted[i];
        return _CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [
                _Avatar(url: r['img'] as String?, size: 46),
                const SizedBox(width: 10),
                Expanded(child: Text(r['nurse'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis)),
              ])),
              _StatusPill(label: 'Accepted', color: kPrimary, bg: kPrimary.withOpacity(0.10)),
            ]),
            const SizedBox(height: 12),
            _MetaItem(icon: Icons.calendar_today_outlined, label: 'DATE AND TIME', value: r['date'] as String),
            const SizedBox(height: 6),
            _MetaItem(icon: Icons.phone_outlined, label: 'CONTACT INFO', value: r['phone'] as String),
            const SizedBox(height: 6),
            _MetaItem(icon: Icons.location_on_outlined, label: 'REGION AND ADDRESS', value: r['gov'] as String),
            const SizedBox(height: 6),
            _MetaItem(icon: Icons.verified_outlined, label: 'STATUS', value: r['status'] as String, valueColor: kPrimary),
            const SizedBox(height: 12),
            const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            ...(r['services'] as List).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(s['name'], style: const TextStyle(fontSize: 12, color: kDarkText))),
                Text(s['price'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
              ]),
            )),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('FINANCIAL TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray)),
                Text(r['total'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
              ]),
            ),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
          ]),
        );
      },
    );
  }

  Widget _buildNurseDoneList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12), itemCount: _done.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = _done[i];
        return _CardShell(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Row(children: [
                _Avatar(url: r['img'] as String?, size: 46),
                const SizedBox(width: 10),
                Expanded(child: Text(r['nurse'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis)),
              ])),
              _StatusPill(label: 'DONE', color: kGreen, bg: const Color(0xFFE6F7F1)),
            ]),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF0F4F8)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Date & Time', style: TextStyle(fontSize: 11, color: kTextGray)),
              Flexible(child: Text(r['date'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Region', style: TextStyle(fontSize: 11, color: kTextGray)),
              Flexible(child: Text(r['region'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            ...(r['services'] as List).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(s['name'], style: const TextStyle(fontSize: 12, color: kDarkText))),
                Text(s['price'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kDarkText)),
              ]),
            )),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray)),
              Text(r['total'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimary)),
            ]),
          ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDICINE TAB
// ═══════════════════════════════════════════════════════════════════════════

class _MedicineTab extends StatelessWidget {
  const _MedicineTab();
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.medication_outlined, size: 64, color: kTextGray.withOpacity(0.3)),
      const SizedBox(height: 12),
      const Text('Medicine requests coming soon', style: TextStyle(fontSize: 15, color: kTextGray)),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DONATIONS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _DonationsTab extends StatefulWidget {
  const _DonationsTab();
  @override
  State<_DonationsTab> createState() => _DonationsTabState();
}

class _DonationsTabState extends State<_DonationsTab> with SingleTickerProviderStateMixin {
  late TabController _sub;

  final _pending = [
    {'name': 'Ahmed Mansour', 'hospital': 'Al-Salam Hospital, Cairo',       'bloodType': 'O+', 'status': 'PENDING',  'desc': 'Patient needs immediate surgery due to a road accident. Multiple internal lacerations requiring urgent blood transfusion within the next few hours.',   'time': 'Requested 2h ago'},
    {'name': 'Sarah Yassin',  'hospital': "Children's Cancer Center, Giza",  'bloodType': 'O+', 'status': 'PENDING',  'desc': 'Weekly platelette transfusion for ongoing oncology treatment. Rare blood type needed to continue chemotherapy cycle scheduled for tomorrow morning.', 'time': 'Requested 5h ago'},
    {'name': 'Khaled Reda',   'hospital': 'Alexandria Medical Center',       'bloodType': 'O+', 'status': 'PENDING',  'desc': 'Emergency heart surgery patient requires 3 units of A+ blood. Operation is currently ongoing, supply in hospital blood bank is critically low.',         'time': 'Requested 30m ago'},
    {'name': 'Mariam Fouad',  'hospital': 'Dar El-Fouad, 6th October',       'bloodType': 'O+', 'status': 'PENDING',  'desc': 'Post-delivery complication. Patient stable but requires replenishment of iron and blood volume following minor postpartum hemorrhage.',             'time': 'Requested 8h ago'},
  ];
  final _accepted = [
    {'name': 'Ahmed Mansour', 'hospital': 'Al-Salam Hospital, Cairo',       'bloodType': 'O+', 'status': 'Accepted', 'desc': 'Patient needs immediate surgery due to a road accident. Multiple internal lacerations requiring urgent blood transfusion within the next few hours.',   'time': 'Requested 2h ago'},
    {'name': 'Sarah Yassin',  'hospital': "Children's Cancer Center, Giza",  'bloodType': 'O+', 'status': 'Accepted', 'desc': 'Weekly platelette transfusion for ongoing oncology treatment. Rare blood type needed to continue chemotherapy cycle scheduled for tomorrow morning.', 'time': 'Requested 5h ago'},
    {'name': 'Khaled Reda',   'hospital': 'Alexandria Medical Center',       'bloodType': 'O+', 'status': 'Accepted', 'desc': 'Emergency heart surgery patient requires 3 units of A+ blood. Operation is currently ongoing, supply in hospital blood bank is critically low.',         'time': 'Requested 30m ago'},
    {'name': 'Mariam Fouad',  'hospital': 'Dar El-Fouad, 6th October',       'bloodType': 'O+', 'status': 'Accepted', 'desc': 'Post-delivery complication. Patient stable but requires replenishment of iron and blood volume following minor postpartum hemorrhage.',             'time': 'Requested 8h ago'},
  ];
  final _done = [
    {'name': 'Ahmed Mansour', 'hospital': 'Al-Salam Hospital, Cairo',       'bloodType': 'O+', 'status': 'DONE', 'desc': 'Patient needs immediate surgery due to a road accident. Multiple internal lacerations requiring urgent blood transfusion within the next few hours.',   'time': 'Requested 2h ago'},
    {'name': 'Sarah Yassin',  'hospital': "Children's Cancer Center, Giza",  'bloodType': 'O+', 'status': 'DONE', 'desc': 'Weekly platelette transfusion for ongoing oncology treatment. Rare blood type needed to continue chemotherapy cycle scheduled for tomorrow morning.', 'time': 'Requested 5h ago'},
    {'name': 'Khaled Reda',   'hospital': 'Alexandria Medical Center',       'bloodType': 'O+', 'status': 'DONE', 'desc': 'Emergency heart surgery patient requires 3 units of A+ blood. Operation is currently ongoing, supply in hospital blood bank is critically low.',         'time': 'Requested 30m ago'},
    {'name': 'Mariam Fouad',  'hospital': 'Dar El-Fouad, 6th October',       'bloodType': 'O+', 'status': 'DONE', 'desc': 'Post-delivery complication. Patient stable but requires replenishment of iron and blood volume following minor postpartum hemorrhage.',             'time': 'Requested 8h ago'},
  ];

  @override
  void initState() { super.initState(); _sub = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _sub.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Donation Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kDarkText)),
          const SizedBox(height: 14),
          TabBar(
            controller: _sub,
            labelColor: kPrimary,
            unselectedLabelColor: kTextGray,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            indicatorColor: kPrimary,
            indicatorWeight: 2.5,
            tabs: const [Tab(text: 'Pending'), Tab(text: 'Accepted'), Tab(text: 'Done')],
          ),
        ]),
      ),
      Expanded(
        child: TabBarView(controller: _sub, children: [
          _buildDonationList(_pending,  showActions: true),
          _buildDonationList(_accepted, showDone: true),
          _buildDonationList(_done,     isDone: true),
        ]),
      ),
    ]);
  }

  Widget _buildDonationList(List items, {bool showActions = false, bool showDone = false, bool isDone = false}) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _DonationCard(
        item: items[i],
        showActions: showActions,
        showDone: showDone,
        isDone: isDone,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DOCTOR BOOKING PAGE
// ═══════════════════════════════════════════════════════════════════════════

class _DoctorBookingPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const _DoctorBookingPage({required this.doctor});
  @override
  State<_DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<_DoctorBookingPage> {
  int    _selectedDayIdx = 1;
  String _selectedSlot   = '10:00 AM';
  String _governorate    = 'Cairo';
  final _sympCtrl = TextEditingController();
  final _addrCtrl = TextEditingController(text: 'Maadi, Cairo, Egypt');

  final _days = [
    {'name': 'MON', 'num': '14', 'month': 'OCT'},
    {'name': 'TUE', 'num': '15', 'month': 'OCT'},
    {'name': 'WED', 'num': '16', 'month': 'OCT'},
    {'name': 'THU', 'num': '17', 'month': 'OCT'},
    {'name': 'FRI', 'num': '18', 'month': 'OCT'},
  ];
  final _morningSlots = ['09:00 AM', '10:00 AM', '11:30 AM', '12:00 PM'];
  final _eveningSlots = ['05:00 PM', '06:00 PM', '07:30 PM', '08:00 PM'];
  final _govs = ['Cairo', 'Giza', 'Alexandria', 'Aswan'];

  @override
  void dispose() { _sympCtrl.dispose(); _addrCtrl.dispose(); super.dispose(); }

  double get _serviceFee => 25;
  double get _total => (widget.doctor['fee'] as int).toDouble() + _serviceFee;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: kDarkText), onPressed: () => Navigator.pop(context)),
        title: const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: kBorderColor, height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Book Appointment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
          const SizedBox(height: 4),
          const Text('Select your preferred time for a consultation with our specialist.', style: TextStyle(fontSize: 13, color: kTextGray)),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorderColor)),
            child: Row(children: [
              _Avatar(url: doc['img'] as String?, size: 60),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(doc['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                Text(doc['spec'] as String, style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(Icons.star_rounded, color: kAmber, size: 12),
                      const SizedBox(width: 2),
                      Text('${doc['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kAmber)),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  const Text('500+ Consultations', style: TextStyle(fontSize: 11, color: kTextGray)),
                ]),
                const SizedBox(height: 6),
                const Text('CONSULTATION FEE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
                Text('${doc['fee']} EGP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),

          _PaymentSummary(consultFee: (doc['fee'] as int).toDouble(), serviceFee: _serviceFee, total: _total),
          const SizedBox(height: 16),

          const Text('Governorate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          const SizedBox(height: 8),
          _DropdownRaw(value: _governorate, items: _govs, onChanged: (v) => setState(() => _governorate = v!)),
          const SizedBox(height: 14),

          Row(children: const [
            Icon(Icons.description_outlined, size: 15, color: kPrimary),
            SizedBox(width: 5),
            Text('Describe Your Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _sympCtrl, maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Please provide more details about how you are feeling...',
              hintStyle: const TextStyle(color: kTextGray, fontSize: 12),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Full Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          const SizedBox(height: 8),
          TextField(
            controller: _addrCtrl, maxLines: 2,
            decoration: InputDecoration(
              prefixIcon: const Padding(padding: EdgeInsets.only(left: 12, top: 12), child: Icon(Icons.location_on_outlined, size: 16, color: kTextGray)),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: const [
            Icon(Icons.calendar_today_outlined, size: 16, color: kPrimary),
            SizedBox(width: 6),
            Text('Select Date & Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(_days.length, (i) {
              final d = _days[i]; final active = i == _selectedDayIdx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDayIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 58, height: 72,
                    decoration: BoxDecoration(
                      color: active ? kPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: active ? kPrimary : kBorderColor),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(d['name']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Colors.white.withOpacity(0.8) : kTextGray)),
                      const SizedBox(height: 3),
                      Text(d['num']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: active ? Colors.white : kDarkText)),
                      Text(d['month']!, style: TextStyle(fontSize: 10, color: active ? Colors.white.withOpacity(0.8) : kTextGray)),
                    ]),
                  ),
                ),
              );
            })),
          ),
          const SizedBox(height: 16),
          const Text('MORNING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _morningSlots.map((s) => _SlotChip(slot: s, selected: _selectedSlot == s, onTap: () => setState(() => _selectedSlot = s))).toList()),
          const SizedBox(height: 14),
          const Text('EVENING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _eveningSlots.map((s) => _SlotChip(slot: s, selected: _selectedSlot == s, onTap: () => setState(() => _selectedSlot = s))).toList()),
          const SizedBox(height: 16),
          _NeedHelp(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NURSE BOOKING PAGE
// ═══════════════════════════════════════════════════════════════════════════

class _NurseBookingPage extends StatefulWidget {
  final Map<String, dynamic> nurse;
  const _NurseBookingPage({required this.nurse});
  @override
  State<_NurseBookingPage> createState() => _NurseBookingPageState();
}

class _NurseBookingPageState extends State<_NurseBookingPage> {
  final Set<int> _selectedServices = {0};
  int    _selectedDayIdx = 1;
  String _selectedSlot   = '10:00 AM';
  String _governorate    = 'Cairo';
  final _sympCtrl = TextEditingController();
  final _addrCtrl = TextEditingController(text: 'Maadi, Cairo, Egypt');

  final _days = [
    {'name': 'MON', 'num': '14', 'month': 'OCT'},
    {'name': 'TUE', 'num': '15', 'month': 'OCT'},
    {'name': 'WED', 'num': '16', 'month': 'OCT'},
    {'name': 'THU', 'num': '17', 'month': 'OCT'},
    {'name': 'FRI', 'num': '18', 'month': 'OCT'},
  ];
  final _morningSlots = ['09:00 AM', '10:00 AM', '11:30 AM', '12:00 PM'];
  final _eveningSlots = ['05:00 PM', '06:00 PM', '07:30 PM', '08:00 PM'];
  final _govs = ['Cairo', 'Giza', 'Alexandria', 'Aswan'];

  @override
  void dispose() { _sympCtrl.dispose(); _addrCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _services => (widget.nurse['services'] as List).cast<Map<String, dynamic>>();
  double get _subtotal => _selectedServices.fold(0, (s, i) => s + (_services[i]['price'] as int));
  double get _serviceFee => 50;
  double get _total => _subtotal + _serviceFee;

  @override
  Widget build(BuildContext context) {
    final nurse = widget.nurse;
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: kDarkText), onPressed: () => Navigator.pop(context)),
        title: const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: kBorderColor, height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Book Appointment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
          const SizedBox(height: 4),
          const Text('Select your preferred time for a consultation with our specialist.', style: TextStyle(fontSize: 13, color: kTextGray)),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorderColor)),
            child: Row(children: [
              _Avatar(url: nurse['img'] as String?, size: 60),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nurse['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                Text('Specialty: ${nurse['spec']}', style: const TextStyle(fontSize: 11, color: kTextGray)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: const [
                  _Tag(label: 'Certified Specialist'),
                  _Tag(label: 'Home Visits'),
                  _Tag(label: 'Vaccinations'),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.star_rounded, color: kAmber, size: 13),
                  const SizedBox(width: 2),
                  Text('${nurse['rating']} (4.9/5)', style: const TextStyle(fontSize: 11, color: kAmber, fontWeight: FontWeight.w700)),
                ]),
              ])),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
            ]),
          ),
          const SizedBox(height: 16),

          _PaymentSummary(sessionSubtotal: _subtotal, serviceFee: _serviceFee, total: _total, isNurse: true),
          const SizedBox(height: 16),

          Row(children: const [
            Icon(Icons.list_alt_rounded, size: 16, color: kPrimary),
            SizedBox(width: 6),
            Text('Select Services', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(border: Border.all(color: kBorderColor), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: List.generate(_services.length, (i) {
                final s = _services[i];
                final checked = _selectedServices.contains(i);
                return InkWell(
                  onTap: () => setState(() { if (checked) _selectedServices.remove(i); else _selectedServices.add(i); }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: checked ? kPrimary : Colors.transparent,
                          border: Border.all(color: checked ? kPrimary : kBorderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s['name'] as String, style: const TextStyle(fontSize: 13, color: kDarkText))),
                      Text('${s['price']} EGP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGray)),
                    ]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Governorate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          const SizedBox(height: 8),
          _DropdownRaw(value: _governorate, items: _govs, onChanged: (v) => setState(() => _governorate = v!)),
          const SizedBox(height: 14),

          Row(children: const [
            Icon(Icons.description_outlined, size: 15, color: kPrimary),
            SizedBox(width: 5),
            Text('Describe Your Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _sympCtrl, maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Please provide more details about how you are feeling...',
              hintStyle: const TextStyle(color: kTextGray, fontSize: 12),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Full Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          const SizedBox(height: 8),
          TextField(
            controller: _addrCtrl, maxLines: 2,
            decoration: InputDecoration(
              prefixIcon: const Padding(padding: EdgeInsets.only(left: 12, top: 12), child: Icon(Icons.location_on_outlined, size: 16, color: kTextGray)),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: const [
            Icon(Icons.calendar_today_outlined, size: 16, color: kPrimary),
            SizedBox(width: 6),
            Text('Select Date & Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(_days.length, (i) {
              final d = _days[i]; final active = i == _selectedDayIdx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDayIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 58, height: 72,
                    decoration: BoxDecoration(
                      color: active ? kPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: active ? kPrimary : kBorderColor),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(d['name']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Colors.white.withOpacity(0.8) : kTextGray)),
                      const SizedBox(height: 3),
                      Text(d['num']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: active ? Colors.white : kDarkText)),
                      Text(d['month']!, style: TextStyle(fontSize: 10, color: active ? Colors.white.withOpacity(0.8) : kTextGray)),
                    ]),
                  ),
                ),
              );
            })),
          ),
          const SizedBox(height: 16),
          const Text('MORNING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _morningSlots.map((s) => _SlotChip(slot: s, selected: _selectedSlot == s, onTap: () => setState(() => _selectedSlot = s))).toList()),
          const SizedBox(height: 14),
          const Text('EVENING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _eveningSlots.map((s) => _SlotChip(slot: s, selected: _selectedSlot == s, onTap: () => setState(() => _selectedSlot = s))).toList()),
          const SizedBox(height: 16),
          _NeedHelp(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED CARD WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onBook;
  const _DoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          _Avatar(url: doctor['img'] as String?, size: 60),
          Container(width: 12, height: 12, decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2)])),
        ]),
        const SizedBox(height: 8),
        Text(doctor['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(doctor['spec'] as String, style: const TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.location_on_outlined, size: 10, color: kTextGray),
          const SizedBox(width: 2),
          Flexible(child: Text(doctor['gov'] as String, style: const TextStyle(fontSize: 10, color: kTextGray), overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Icon(
          i < (doctor['rating'] as double).floor() ? Icons.star_rounded : Icons.star_border_rounded,
          color: kAmber, size: 12,
        ))),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFFF0F4F8), height: 1),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CONSULTATION FEE', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.3)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${doctor['fee']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDarkText)),
              const SizedBox(width: 2),
              const Padding(padding: EdgeInsets.only(bottom: 1), child: Text('EGP', style: TextStyle(fontSize: 9, color: kTextGray, fontWeight: FontWeight.w600))),
            ]),
          ])),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Book Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _NurseCard extends StatelessWidget {
  final Map<String, dynamic> nurse;
  final VoidCallback onBook;
  const _NurseCard({required this.nurse, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final services = (nurse['services'] as List).cast<Map<String, dynamic>>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Avatar(url: nurse['img'] as String?, size: 52),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nurse['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText), overflow: TextOverflow.ellipsis),
            Text(nurse['spec'] as String, style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 11, color: kTextGray),
              const SizedBox(width: 2),
              Flexible(child: Text(nurse['gov'] as String, style: const TextStyle(fontSize: 11, color: kTextGray), overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Row(children: List.generate(5, (i) => Icon(
            i < (nurse['rating'] as double).floor() ? Icons.star_rounded : Icons.star_border_rounded,
            color: kAmber, size: 12,
          ))),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Color(0xFFF0F4F8))),
        const Text('REQUESTED SERVICES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        ...services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(s['name'] as String, style: const TextStyle(fontSize: 12, color: kDarkText))),
            Text('${s['price']} EGP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextGray)),
          ]),
        )),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('STARTING FROM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.3)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${nurse['starting']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
              const SizedBox(width: 2),
              const Padding(padding: EdgeInsets.only(bottom: 1), child: Text('EGP', style: TextStyle(fontSize: 9, color: kTextGray, fontWeight: FontWeight.w600))),
            ]),
          ]),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Book Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final dynamic item;
  final bool showActions, showDone, isDone;
  const _DonationCard({required this.item, this.showActions = false, this.showDone = false, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String;
    Color statusColor, statusBg;
    if (isDone)                { statusColor = kGreen;   statusBg = const Color(0xFFE6F7F1); }
    else if (status == 'Accepted') { statusColor = kPrimary; statusBg = kPrimary.withOpacity(0.10); }
    else                       { statusColor = kAmber;   statusBg = const Color(0xFFFFFBEB); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline_rounded, color: kTextGray, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText),
                  overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 11, color: kTextGray),
                const SizedBox(width: 2),
                Flexible(child: Text(item['hospital'] as String,
                    style: const TextStyle(fontSize: 11, color: kTextGray),
                    overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StatusPill(label: status, color: statusColor, bg: statusBg),
            const SizedBox(height: 4),
            Text(item['bloodType'] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
            const Text('BLOOD TYPE',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: kTextGray, letterSpacing: 0.4)),
          ]),
        ]),
        const SizedBox(height: 12),

        Text(item['desc'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.5)),

        if (isDone) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGreen.withOpacity(0.25)),
            ),
            child: Row(children: const [
              Icon(Icons.check_circle_outline_rounded, color: kGreen, size: 15),
              SizedBox(width: 6),
              Flexible(child: Text('THE DONATION PROCESS WAS SUCCESSFUL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kGreen, letterSpacing: 0.2))),
            ]),
          ),
        ],

        if (!isDone) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item['time'] as String, style: const TextStyle(fontSize: 11, color: kTextGray)),
            // ✅ تم تعديل الجزء الخاص بـ if (showActions) و if (showDone)
            // باستخدام if-else داخل قائمة الأطفال لتجنب أي خطأ
            if (showActions) ...[
              Row(children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDarkText, side: const BorderSide(color: kBorderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
            ] else if (showDone) ...[
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MICRO WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _SubTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  const _SubTabBar({required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: TabBar(
      controller: controller,
      labelColor: kPrimary,
      unselectedLabelColor: kTextGray,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      indicatorColor: kPrimary,
      indicatorWeight: 2.5,
      tabs: labels.map((l) => Tab(text: l)).toList(),
    ),
  );
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF0F4F8)),
      boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3))],
    ),
    child: child,
  );
}

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: url != null && url!.isNotEmpty
          ? Image.network(url!, width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder())
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
    child: Icon(Icons.person_outline_rounded, color: kPrimary, size: size * 0.44),
  );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color, bg;
  final IconData? icon;
  const _StatusPill({required this.label, required this.color, required this.bg, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 3)],
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color valueColor;
  const _MetaItem({required this.icon, required this.label, required this.value, this.valueColor = kDarkText});

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 13, color: kTextGray),
    const SizedBox(width: 5),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.4)),
      const SizedBox(height: 1),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor)),
    ])),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, onChanged: onChanged,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: kTextGray, fontSize: 13),
      prefixIcon: const Icon(Icons.search_rounded, color: kTextGray, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      filled: true, fillColor: Colors.white,
    ),
  );
}

class _FilterDropdown extends StatelessWidget {
  final String value, hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value, onChanged: onChanged, isExpanded: true,
    style: const TextStyle(fontSize: 12, color: kDarkText),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      filled: true, fillColor: Colors.white,
    ),
  );
}

class _SlotChip extends StatelessWidget {
  final String slot;
  final bool selected;
  final VoidCallback onTap;
  const _SlotChip({required this.slot, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? kPrimary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? kPrimary : kBorderColor),
        boxShadow: selected ? [BoxShadow(color: kPrimary.withOpacity(0.22), blurRadius: 5, offset: const Offset(0, 2))] : [],
      ),
      child: Text(slot, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : kDarkText)),
    ),
  );
}

class _DropdownRaw extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownRaw({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value, onChanged: onChanged, isExpanded: true,
    style: const TextStyle(fontSize: 14, color: kDarkText),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    ),
  );
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600)),
  );
}

class _PaymentSummary extends StatelessWidget {
  final double? consultFee, sessionSubtotal;
  final double serviceFee, total;
  final bool isNurse;
  const _PaymentSummary({this.consultFee, this.sessionSubtotal, required this.serviceFee, required this.total, this.isNurse = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBorderColor),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kPrimary)),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(isNurse ? 'Session Subtotal' : 'Consultation Fee', style: const TextStyle(fontSize: 13, color: kTextGray)),
        Text('${isNurse ? sessionSubtotal!.toStringAsFixed(0) : consultFee!.toStringAsFixed(0)} EGP',
            style: const TextStyle(fontSize: 13, color: kDarkText, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Service Fee', style: TextStyle(fontSize: 13, color: kTextGray)),
        Text('${serviceFee.toStringAsFixed(0)} EGP', style: const TextStyle(fontSize: 13, color: kDarkText, fontWeight: FontWeight.w600)),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF0F4F8))),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.4)),
        Text('${total.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
      ]),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('Confirm Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.lock_outline_rounded, size: 12, color: kTextGray),
        SizedBox(width: 4),
        Text('Secure encrypted payment', style: TextStyle(fontSize: 11, color: kTextGray)),
      ]),
    ]),
  );
}

class _NeedHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kBorderColor),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: const [
        Icon(Icons.help_outline_rounded, size: 15, color: kPrimary),
        SizedBox(width: 5),
        Text('Need Help?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
      ]),
      const SizedBox(height: 6),
      const Text('Cancel or reschedule up to 24 hours before your appointment for a full refund.',
          style: TextStyle(fontSize: 12, color: kTextGray, height: 1.5)),
      const SizedBox(height: 6),
      const Text('Read Refund Policy',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary,
              decoration: TextDecoration.underline)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.inbox_outlined, size: 64, color: kTextGray.withOpacity(0.3)),
    const SizedBox(height: 12),
    const Text('No requests here', style: TextStyle(fontSize: 15, color: kTextGray)),
  ]));
}