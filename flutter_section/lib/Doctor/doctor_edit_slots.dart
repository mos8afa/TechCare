import 'package:flutter/material.dart';

// ─── Color Palette ────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kAmber = Color(0xFFF59E0B);
const Color kSky = Color(0xFF0EA5E9);

// ─── Edit Time Slots Screen ───────────────────────────────────────────────
class DoctorEditTimeSlotsScreen extends StatefulWidget {
  const DoctorEditTimeSlotsScreen({super.key});

  @override
  State<DoctorEditTimeSlotsScreen> createState() =>
      _DoctorEditTimeSlotsScreenState();
}

class _DoctorEditTimeSlotsScreenState
    extends State<DoctorEditTimeSlotsScreen> {
  int _selectedDayIndex = 2; // WED default

  final List<Map<String, String>> _days = [
    {'name': 'MON', 'num': '14'},
    {'name': 'TUE', 'num': '15'},
    {'name': 'WED', 'num': '16'},
    {'name': 'THU', 'num': '17'},
    {'name': 'FRI', 'num': '18'},
    {'name': 'SAT', 'num': '19'},
    {'name': 'SUN', 'num': '20'},
  ];

  // Morning slots: Map<label, isActive>
  final List<Map<String, dynamic>> _morningSlots = [
    {'time': '09:00 AM', 'active': false},
    {'time': '09:30 AM', 'active': true},
    {'time': '10:00 AM', 'active': false},
  ];

  // Evening slots
  final List<Map<String, dynamic>> _eveningSlots = [
    {'time': '06:00 PM', 'active': false},
    {'time': '07:00 PM', 'active': false},
    {'time': '07:30 PM', 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(context),
            const SizedBox(height: 32),
            _buildWeeklySchedule(),
            const SizedBox(height: 32),
            _buildSessionCard(
              isMorning: true,
              slots: _morningSlots,
            ),
            const SizedBox(height: 20),
            _buildSessionCard(
              isMorning: false,
              slots: _eveningSlots,
            ),
            const SizedBox(height: 32),
            _buildBottomActions(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
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
      title: const Text('Time Slots',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
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
                    radius: 5, backgroundColor: Color(0xFFEF4444)),
              ),
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
        GestureDetector(
          onTap: () {},
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/women/44.jpg'),
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'active': true},
      {'icon': Icons.list_alt_rounded, 'label': 'Requests', 'active': false},
      {'icon': Icons.notifications_none_rounded, 'label': 'Notifications', 'active': false},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet', 'active': false},
      {'icon': Icons.warning_amber_rounded, 'label': 'Complaints', 'active': false},
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
                final isActive = item['active'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isActive ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.pop(context),
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

  // ── Header Row (title + subtitle only) ───────────────────────────────────
  Widget _buildHeaderRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Edit Time Slots',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: kDarkText)),
        SizedBox(height: 6),
        Text('Customize your working hours and appointment slots.',
            style: TextStyle(fontSize: 14, color: kTextGray)),
      ],
    );
  }

  // ── Bottom Actions (Cancel / Save) ────────────────────────────────────────
  Widget _buildBottomActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4B5563),
          ),
          child: const Text('Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // TODO: save to API
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            shadowColor: kPrimary.withOpacity(0.4),
          ),
          child: const Text('Save Changes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Weekly Schedule ───────────────────────────────────────────────────────
  Widget _buildWeeklySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WEEKLY SCHEDULE',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: kTextGray,
                letterSpacing: 1.5)),
        const SizedBox(height: 16),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final active = _selectedDayIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 76,
                  decoration: BoxDecoration(
                    color: active ? kPrimary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: kPrimary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6))
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_days[i]['name']!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: active ? Colors.white : kTextGray)),
                      const SizedBox(height: 6),
                      Text(_days[i]['num']!,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: active
                                  ? Colors.white
                                  : kDarkText)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Session Card (Morning / Evening) ─────────────────────────────────────
  Widget _buildSessionCard({
    required bool isMorning,
    required List<Map<String, dynamic>> slots,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 24,
              offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isMorning
                      ? const Color(0xFFFEEDDF)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMorning
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: isMorning ? kAmber : kSky,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMorning ? 'Morning Sessions' : 'Evening Sessions',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kDarkText),
                  ),
                  Text(
                    isMorning
                        ? 'Recommended: 08:00 AM – 12:00 PM'
                        : 'Recommended: 04:00 PM – 09:00 PM',
                    style: const TextStyle(
                        fontSize: 12, color: kTextGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Existing slots
              ...slots.asMap().entries.map((entry) {
                final i = entry.key;
                final slot = entry.value;
                final isActive = slot['active'] as bool;
                return _buildPill(
                  label: slot['time'] as String,
                  isActive: isActive,
                  onTap: () => setState(() {
                    slot['active'] = !isActive;
                  }),
                  onRemove: () => setState(() => slots.removeAt(i)),
                );
              }),
              // Add button
              _buildAddPill(
                onTap: () => _showAddSlotModal(slots),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? kPrimary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? kPrimary : const Color(0xFF64748B),
              ),
            ),
            if (isActive)
              Positioned(
                top: -18,
                right: -18,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB91C1C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPill({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 2,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(100),
          color: Colors.transparent,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 18, color: Color(0xFF94A3B8)),
            SizedBox(width: 6),
            Text('Add Slot',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  // ── Add Slot Modal ────────────────────────────────────────────────────────
  void _showAddSlotModal(List<Map<String, dynamic>> targetList) {
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add New Time Slot',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kDarkText)),
              const SizedBox(height: 20),
              // Time picker trigger
              StatefulBuilder(builder: (context, setModalState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Time',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: kPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: kTextGray, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              selectedTime.format(context),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: kDarkText),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFF4B5563),
                              side:
                                  const BorderSide(color: kBorderColor),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final label =
                                  selectedTime.format(context);
                              setState(() {
                                targetList.add(
                                    {'time': label, 'active': true});
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Add Slot',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}