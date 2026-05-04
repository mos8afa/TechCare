import 'package:flutter/material.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
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
  } catch (_) { return raw; }
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

class DonorDoctorBookAppointmentScreen extends StatefulWidget {
  final int doctorId;
  const DonorDoctorBookAppointmentScreen({super.key, required this.doctorId});

  @override
  State<DonorDoctorBookAppointmentScreen> createState() =>
      _DonorDoctorBookAppointmentScreenState();
}

class _DonorDoctorBookAppointmentScreenState
    extends State<DonorDoctorBookAppointmentScreen> {

  // TODO: replace with ApiService calls when donor API is ready
  Map<String, dynamic>? _doctorData;
  List<dynamic> _days            = [];
  Map<String, dynamic> _allSlots = {};
  bool    _isLoading  = false; // set false until API is ready
  bool    _isBooking  = false;
  String? _error;

  int     _selectedDayIndex    = 0;
  String? _selectedTime;
  String? _selectedGovernorate;

  final _symptomsCtrl = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: _load() when API ready
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _selectedDayKey {
    if (_days.isEmpty) return '';
    return (_days[_selectedDayIndex] as Map)['day'] as String? ?? '';
  }

  List<String> get _morningSlots {
    final s = _allSlots[_selectedDayKey];
    if (s == null) return [];
    return List<String>.from((s as Map)['morning'] ?? []);
  }

  List<String> get _eveningSlots {
    final s = _allSlots[_selectedDayKey];
    if (s == null) return [];
    return List<String>.from((s as Map)['evening'] ?? []);
  }

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
                    onPressed: () {}, // TODO: _load()
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ]))
              : _doctorData == null
                  ? _buildPlaceholder()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDoctorCard(),
                          const SizedBox(height: 16),
                          _buildGovernorateField(),
                          const SizedBox(height: 16),
                          _buildSymptomsCard(),
                          const SizedBox(height: 16),
                          _buildAddressCard(),
                          const SizedBox(height: 16),
                          _buildPhoneCard(),
                          const SizedBox(height: 16),
                          _buildDateTimeCard(),
                          const SizedBox(height: 16),
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  // Placeholder until API is connected
  Widget _buildPlaceholder() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.medical_services_outlined, size: 60, color: kTextGray.withOpacity(0.3)),
      const SizedBox(height: 12),
      const Text('Doctor booking coming soon',
          style: TextStyle(fontSize: 15, color: kTextGray)),
      const SizedBox(height: 8),
      const Text('API will be connected shortly',
          style: TextStyle(fontSize: 12, color: kTextGray)),
    ]));
  }

  Widget _buildDoctorCard() {
    final doc = _doctorData!;
    final picUrl = doc['profile_pic'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: kBgLight,
          backgroundImage: picUrl.isNotEmpty
              ? NetworkImage(picUrl) as ImageProvider
              : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc['name'] as String? ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDarkText)),
          const SizedBox(height: 2),
          Text(doc['specification'] as String? ?? '',
              style: const TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, color: kAmber, size: 15),
            const SizedBox(width: 3),
            Text('${doc['avg_rating'] ?? 0}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: kTextGray),
            const SizedBox(width: 3),
            Expanded(child: Text(
              '${doc['governorate'] ?? ''}, ${doc['address'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: kTextGray),
              overflow: TextOverflow.ellipsis,
            )),
          ]),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('CONSULTATION FEE',
              style: TextStyle(fontSize: 9, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('${doc['price'] ?? ''} EGP',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimary)),
        ]),
      ]),
    );
  }

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

  Widget _buildPhoneCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Phone Number',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+20 1XX XXX XXXX',
            hintStyle: const TextStyle(color: kTextGray, fontSize: 13),
            prefixIcon: const Icon(Icons.phone_outlined, color: kTextGray, size: 18),
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
          const Center(child: Text('No available days', style: TextStyle(color: kTextGray, fontSize: 13))),
        const SizedBox(height: 16),
        if (_morningSlots.isNotEmpty) ...[
          Row(children: const [
            Icon(Icons.wb_sunny_outlined, size: 14, color: kAmber),
            SizedBox(width: 6),
            Text('MORNING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 8),
          _buildSlots(_morningSlots),
          const SizedBox(height: 14),
        ],
        if (_eveningSlots.isNotEmpty) ...[
          Row(children: const [
            Icon(Icons.nightlight_round, size: 14, color: Color(0xFF6366F1)),
            SizedBox(width: 6),
            Text('EVENING SLOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 8),
          _buildSlots(_eveningSlots),
        ],
        if (_morningSlots.isEmpty && _eveningSlots.isEmpty && _days.isNotEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No slots available for this day', style: TextStyle(color: kTextGray, fontSize: 13)),
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
              boxShadow: active ? [BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))] : [],
            ),
            child: Text(_fmtSlotTime(rawSlot),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : kDarkText)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    final doc   = _doctorData!;
    final price = double.tryParse(doc['price']?.toString() ?? '0') ?? 0;
    const fee   = 25.0;
    final total = price + fee;

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
        _summaryRow('Consultation Fee', '${price.toStringAsFixed(2)} EGP'),
        const SizedBox(height: 8),
        _summaryRow('Service Fee', '${fee.toStringAsFixed(2)} EGP'),
        const Divider(height: 20, color: kBorderColor),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL AMOUNT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          Text('${total.toStringAsFixed(2)} EGP',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
        ]),
        const SizedBox(height: 16),
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

  Widget _summaryRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: kTextGray)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkText)),
    ]);
  }

  Future<void> _handleBook() async {
    // TODO: connect to donor API when ready
    _snack('Booking API not connected yet', isError: true);
  }

  void _snack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}