import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kGreen       = Color(0xFF10B981);
const Color kAmber       = Color(0xFFF59E0B);

String _fmtSlotTime(String raw) {
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

const List<Map<String, String>> kGovernorates = [
  {'value': 'alexandria', 'label': 'Alexandria'}, {'value': 'aswan', 'label': 'Aswan'},
  {'value': 'asyut', 'label': 'Assiut'}, {'value': 'beheira', 'label': 'Beheira'},
  {'value': 'beni_suef', 'label': 'Beni Suef'}, {'value': 'cairo', 'label': 'Cairo'},
  {'value': 'dakahlia', 'label': 'Dakahlia'}, {'value': 'damietta', 'label': 'Damietta'},
  {'value': 'fayoum', 'label': 'Faiyum'}, {'value': 'gharbia', 'label': 'Gharbia'},
  {'value': 'giza', 'label': 'Giza'}, {'value': 'ismailia', 'label': 'Ismailia'},
  {'value': 'kafr_el_sheikh', 'label': 'Kafr El Sheikh'}, {'value': 'luxor', 'label': 'Luxor'},
  {'value': 'matrouh', 'label': 'Matrouh'}, {'value': 'minya', 'label': 'Minya'},
  {'value': 'monufia', 'label': 'Monufia'}, {'value': 'new_valley', 'label': 'New Valley'},
  {'value': 'north_sinai', 'label': 'North Sinai'}, {'value': 'port_said', 'label': 'Port Said'},
  {'value': 'qalyubia', 'label': 'Qalyubia'}, {'value': 'qena', 'label': 'Qena'},
  {'value': 'red_sea', 'label': 'Red Sea'}, {'value': 'sharqia', 'label': 'Sharqia'},
  {'value': 'sohag', 'label': 'Sohag'}, {'value': 'south_sinai', 'label': 'South Sinai'},
  {'value': 'suez', 'label': 'Suez'},
];

class PatientNurseBookAppointmentScreen extends StatefulWidget {
  final int nurseId;
  const PatientNurseBookAppointmentScreen({super.key, required this.nurseId});

  @override
  State<PatientNurseBookAppointmentScreen> createState() =>
      _PatientNurseBookAppointmentScreenState();
}

class _PatientNurseBookAppointmentScreenState
    extends State<PatientNurseBookAppointmentScreen> {

  Map<String, dynamic>? _nurseData;
  List<dynamic> _services = [];
  List<dynamic> _days     = [];
  Map<String, dynamic> _allSlots = {};

  Set<int> _selectedServices = {};

  bool    _isLoading  = true;
  bool    _isBooking  = false;
  String? _error;

  int     _selectedDayIndex    = 0;
  String? _selectedTime;
  String? _selectedGovernorate;

  final _symptomsCtrl = TextEditingController();
  final _addressCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ApiService.getNurseBookingInfo(widget.nurseId);
    if (result.success) {
      final data = result.data;
      setState(() {
        _nurseData = Map<String, dynamic>.from(data['nurse'] ?? {});
        _services  = List<dynamic>.from(data['services'] ?? []);
        _days      = List<dynamic>.from(data['days']     ?? []);
        _allSlots  = Map<String, dynamic>.from(data['all_slots'] ?? {});
        _isLoading = false;
      });
    } else {
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  // ── Computed getters ──────────────────────────────────────────────────────
  String get _selectedDayKey =>
      _days.isEmpty ? '' : (_days[_selectedDayIndex] as Map)['day'] as String? ?? '';

  String get _selectedFullDate =>
      _days.isEmpty ? '' : (_days[_selectedDayIndex] as Map)['full_date'] as String? ?? '';

  List<String> get _morningSlots =>
      List<String>.from(_allSlots[_selectedDayKey]?['morning'] ?? []);

  List<String> get _eveningSlots =>
      List<String>.from(_allSlots[_selectedDayKey]?['evening'] ?? []);

  /// Price of selected services
  double get _servicesTotal {
    double total = 0;
    for (final s in _services) {
      if (_selectedServices.contains(s['id'])) {
        total += double.tryParse(s['price'].toString()) ?? 0;
      }
    }
    return total;
  }

  /// Selected service items (for summary display)
  List<Map> get _selectedServiceItems =>
      _services.where((s) => _selectedServices.contains(s['id'])).map((s) => s as Map).toList();

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Book Appointment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kBorderColor, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildNurseCard(),
                    const SizedBox(height: 16),
                    _buildServicesCard(),
                    const SizedBox(height: 16),
                    _buildGovernorateField(),
                    const SizedBox(height: 16),
                    _buildSymptomsCard(),
                    const SizedBox(height: 16),
                    _buildAddressCard(),
                    const SizedBox(height: 16),
                    _buildDateTimeCard(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                  ]),
                ),
    );
  }

  // ── Nurse Card ────────────────────────────────────────────────────────────
  Widget _buildNurseCard() {
    final nurse  = _nurseData!;
    final picUrl = ApiService.buildMediaUrl(nurse['profile_pic'] as String?);
    final rating = nurse['avg_rating'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Photo + online dot
        Stack(children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: kBgLight,
            backgroundImage: picUrl.isNotEmpty
                ? NetworkImage(picUrl) as ImageProvider
                : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=10B981&color=fff'),
          ),
          Positioned(bottom: 2, right: 2,
            child: Container(width: 12, height: 12,
              decoration: BoxDecoration(color: kGreen,
                  shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
          ),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name + stars
          Row(children: [
            Expanded(child: Text(nurse['name'] as String? ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDarkText))),
            Row(children: [
              ...List.generate(5, (i) => Icon(Icons.star_rounded,
                  size: 14, color: i < rating ? kAmber : const Color(0xFFD1D5DB))),
              const SizedBox(width: 3),
              Text('($rating/5)', style: const TextStyle(fontSize: 11, color: kTextGray)),
            ]),
          ]),
          const SizedBox(height: 4),
          // Brief
          if ((nurse['brief'] ?? '').toString().isNotEmpty)
            Text(nurse['brief'],
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          // Location
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: kTextGray),
            const SizedBox(width: 3),
            Expanded(child: Text(
              '${nurse['governorate'] ?? ''}, ${nurse['address'] ?? ''}',
              style: const TextStyle(fontSize: 11, color: kTextGray),
              overflow: TextOverflow.ellipsis,
            )),
          ]),
        ])),
      ]),
    );
  }

  // ── Services Card ─────────────────────────────────────────────────────────
  Widget _buildServicesCard() {
    if (_services.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        Row(children: const [
          Icon(Icons.list_alt_outlined, size: 16, color: kPrimary),
          SizedBox(width: 6),
          Text('Select Services',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
        const SizedBox(height: 12),

        // Service items
        ..._services.map((s) {
          final id       = s['id'] as int;
          final selected = _selectedServices.contains(id);
          final price    = double.tryParse(s['price'].toString()) ?? 0;

          return GestureDetector(
            onTap: () => setState(() {
              if (selected) _selectedServices.remove(id);
              else _selectedServices.add(id);
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? kPrimary.withOpacity(0.06) : kBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? kPrimary.withOpacity(0.4) : kBorderColor,
                    width: selected ? 1.5 : 1),
              ),
              child: Row(children: [
                // Custom checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: selected ? kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: selected ? kPrimary : kBorderColor, width: 1.5),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                // Name + description
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'] ?? '',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: selected ? kDarkText : kDarkText)),
                  if ((s['description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(s['description'],
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: kTextGray)),
                  ],
                ])),
                const SizedBox(width: 12),
                // Price
                Text('${price.toStringAsFixed(0)} EGP',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: selected ? kPrimary : kDarkText)),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  // ── Governorate ───────────────────────────────────────────────────────────
  Widget _buildGovernorateField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Governorate',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          hint: const Text('Select governorate', style: TextStyle(fontSize: 14, color: kTextGray)),
          items: kGovernorates
              .map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGovernorate = v),
          decoration: InputDecoration(
            filled: true, fillColor: kBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary, width: 1.5)),
          ),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
        ),
      ]),
    );
  }

  // ── Symptoms ──────────────────────────────────────────────────────────────
  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.description_outlined, size: 16, color: kPrimary),
          SizedBox(width: 6),
          Text('Describe Your Symptoms',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _symptomsCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Please provide more details about how you are feeling...',
            hintStyle: const TextStyle(color: kTextGray, fontSize: 13),
            filled: true, fillColor: kBgLight,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  // ── Address ───────────────────────────────────────────────────────────────
  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Full Address',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 10),
        TextField(
          controller: _addressCtrl,
          decoration: InputDecoration(
            hintText: 'Street, Building, Apartment',
            hintStyle: const TextStyle(color: kTextGray, fontSize: 13),
            prefixIcon: const Icon(Icons.location_on_outlined, color: kTextGray, size: 18),
            filled: true, fillColor: kBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  // ── Date & Time ───────────────────────────────────────────────────────────
  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.calendar_month_outlined, size: 16, color: kPrimary),
          SizedBox(width: 6),
          Text('Select Date & Time',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
        const SizedBox(height: 14),

        // Day picker
        if (_days.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final active = _selectedDayIndex == i;
                final day    = _days[i] as Map;
                return GestureDetector(
                  onTap: () => setState(() { _selectedDayIndex = i; _selectedTime = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 62,
                    decoration: BoxDecoration(
                      color: active ? kPrimary : kBgLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text((day['day'] as String? ?? '').substring(0, 3).toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: active ? Colors.white : kTextGray)),
                      const SizedBox(height: 4),
                      Text(day['date_num'] as String? ?? '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: active ? Colors.white : kDarkText)),
                      Text(day['month'] as String? ?? '',
                          style: TextStyle(fontSize: 10,
                              color: active ? Colors.white70 : kTextGray)),
                    ]),
                  ),
                );
              },
            ),
          )
        else
          const Center(child: Text('No available days',
              style: TextStyle(color: kTextGray, fontSize: 13))),

        const SizedBox(height: 16),

        // Morning slots
        if (_morningSlots.isNotEmpty) ...[
          Row(children: const [
            Icon(Icons.wb_sunny_outlined, size: 14, color: kAmber),
            SizedBox(width: 6),
            Text('MORNING SLOTS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: kTextGray, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 8),
          _buildSlots(_morningSlots),
          const SizedBox(height: 14),
        ],

        // Evening slots
        if (_eveningSlots.isNotEmpty) ...[
          Row(children: const [
            Icon(Icons.nightlight_round, size: 14, color: Color(0xFF6366F1)),
            SizedBox(width: 6),
            Text('EVENING SLOTS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: kTextGray, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 8),
          _buildSlots(_eveningSlots),
        ],

        if (_morningSlots.isEmpty && _eveningSlots.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No slots available for this day',
                style: TextStyle(color: kTextGray, fontSize: 13)),
          )),
      ]),
    );
  }

  Widget _buildSlots(List<String> slots) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: slots.map((rawSlot) {
        final active = _selectedTime == rawSlot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = rawSlot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? kPrimary : kBgLight,
              border: Border.all(color: active ? kPrimary : kBorderColor),
              borderRadius: BorderRadius.circular(30),
              boxShadow: active ? [
                BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))
              ] : [],
            ),
            child: Text(_fmtSlotTime(rawSlot),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : kDarkText)),
          ),
        );
      }).toList(),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    const serviceFee = 50.0;
    final subtotal   = _servicesTotal;
    final total      = subtotal + serviceFee;
    final selected   = _selectedServiceItems;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payment Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 14),

        // ── Selected services breakdown ──────────────────────────────
        if (selected.isNotEmpty) ...[
          const Text('SESSION SUBTOTAL',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...selected.map((s) {
            final price = double.tryParse(s['price'].toString()) ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(s['name'] ?? '',
                    style: const TextStyle(fontSize: 13, color: kTextGray))),
                Text('${price.toStringAsFixed(0)} EGP',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
              ]),
            );
          }),
          const SizedBox(height: 8),
          // Subtotal row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(fontSize: 13, color: kTextGray)),
            Text('${subtotal.toStringAsFixed(0)} EGP',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          ]),
          const SizedBox(height: 6),
        ] else ...[
          const Text('SESSION SUBTOTAL',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('No service selected', style: TextStyle(fontSize: 13, color: kTextGray)),
            const Text('0 EGP',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
          ]),
          const SizedBox(height: 6),
        ],

        // Service fee
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Service Fee', style: TextStyle(fontSize: 13, color: kTextGray)),
          Text('${serviceFee.toStringAsFixed(0)} EGP',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
        ]),

        const Divider(height: 20, color: kBorderColor),

        // Total
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL PRICE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: kTextGray, letterSpacing: 0.5)),
          Text('${total.toStringAsFixed(0)} EGP',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimary)),
        ]),

        const SizedBox(height: 16),

        // Confirm button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isBooking ? null : _handleBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isBooking
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirm Booking',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),

        const SizedBox(height: 10),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: 13, color: kTextGray),
          SizedBox(width: 4),
          Text('Secure encrypted payment', style: TextStyle(fontSize: 12, color: kTextGray)),
        ]),
      ]),
    );
  }

  // ── Handle Book ───────────────────────────────────────────────────────────
  Future<void> _handleBook() async {
    if (_selectedServices.isEmpty) { _snack('Please select at least one service', isError: true); return; }
    if (_selectedTime == null)     { _snack('Please select a time slot',          isError: true); return; }
    if (_selectedGovernorate == null){ _snack('Please select a governorate',      isError: true); return; }
    if (_symptomsCtrl.text.trim().isEmpty){ _snack('Please describe your symptoms', isError: true); return; }
    if (_selectedFullDate.isEmpty) { _snack('Please select a date',               isError: true); return; }

    setState(() => _isBooking = true);

    final result = await ApiService.bookNurse(
      nurseId:            widget.nurseId,
      serviceIds:         _selectedServices.toList(),
      date:               _selectedFullDate,
      time:               _selectedTime!,
      diseaseDescription: _symptomsCtrl.text.trim(),
      governorate:        _selectedGovernorate!,
      address:            _addressCtrl.text.trim(),
    );

    setState(() => _isBooking = false);

    if (result.success) {
      _snack('Appointment booked successfully!', isError: false);
      if (mounted) Navigator.pop(context);
    } else {
      _snack(result.error ?? 'Booking failed', isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}