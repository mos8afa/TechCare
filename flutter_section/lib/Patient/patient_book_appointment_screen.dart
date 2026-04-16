import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color kPrimary     = Color(0xFF1D89E4);
const Color kBgLight     = Color(0xFFF4F7FC);
const Color kTextGray    = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText    = Color(0xFF1A1C1E);
const Color kAmber       = Color(0xFFF59E0B);

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

class PatientBookAppointmentScreen extends StatefulWidget {
  final int doctorId;
  const PatientBookAppointmentScreen({super.key, required this.doctorId});

  @override
  State<PatientBookAppointmentScreen> createState() => _PatientBookAppointmentScreenState();
}

class _PatientBookAppointmentScreenState extends State<PatientBookAppointmentScreen> {
  Map<String, dynamic>? _doctorData;
  List<dynamic> _days     = [];
  Map<String, dynamic> _allSlots = {};
  bool _isLoading  = true;
  bool _isBooking  = false;
  String? _error;

  int    _selectedDayIndex  = 0;
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
    setState(() => _isLoading = true);
    final result = await ApiService.getDoctorBookingInfo(widget.doctorId);
    if (result.success) {
      final data = result.data as Map<String, dynamic>;
      setState(() {
        _doctorData = data['doctor'];
        _days       = data['days'] ?? [];
        _allSlots   = Map<String, dynamic>.from(data['all_slots'] ?? {});
        _isLoading  = false;
        _error      = null;
      });
    } else {
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  String get _selectedDayKey {
    if (_days.isEmpty) return '';
    return _days[_selectedDayIndex]['day'] as String? ?? '';
  }

  String get _selectedFullDate {
    if (_days.isEmpty) return '';
    return _days[_selectedDayIndex]['full_date'] as String? ?? '';
  }

  List<String> get _morningSlots {
    final daySlots = _allSlots[_selectedDayKey];
    if (daySlots == null) return [];
    return List<String>.from(daySlots['morning'] ?? []);
  }

  List<String> get _eveningSlots {
    final daySlots = _allSlots[_selectedDayKey];
    if (daySlots == null) return [];
    return List<String>.from(daySlots['evening'] ?? []);
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
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
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
                      _buildDateTimeCard(),
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDoctorCard() {
    final doc = _doctorData!;
    final picUrl = ApiService.buildMediaUrl(doc['profile_pic']);
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
          Text(doc['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kDarkText)),
          const SizedBox(height: 2),
          Text(doc['specification'] ?? '', style: const TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, color: kAmber, size: 15),
            const SizedBox(width: 3),
            Text('${doc['avg_rating'] ?? 0}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('CONSULTATION FEE', style: TextStyle(fontSize: 10, color: kTextGray, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('${doc['price'] ?? ''} EGP',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary)),
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
        const Text('Governorate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _selectedGovernorate,
          hint: const Text('Select governorate', style: TextStyle(fontSize: 14, color: kTextGray)),
          items: kGovernorates
              .map((g) => DropdownMenuItem(value: g['value'], child: Text(g['label']!)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGovernorate = v),
          decoration: InputDecoration(
            filled: true, fillColor: kBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
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
          Text('Describe Your Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
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
        const Text('Full Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 10),
        TextField(
          controller: _addressCtrl,
          decoration: InputDecoration(
            hintText: 'Street, Building, Apartment',
            hintStyle: const TextStyle(color: kTextGray, fontSize: 13),
            prefixIcon: const Icon(Icons.location_on_outlined, color: kTextGray, size: 18),
            filled: true, fillColor: kBgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderColor)),
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
          Text('Select Date & Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
        ]),
        const SizedBox(height: 14),

        // Days
        if (_days.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final active = _selectedDayIndex == i;
                final day = _days[i];
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
                          style: TextStyle(fontSize: 10, color: active ? Colors.white70 : kTextGray)),
                    ]),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // Morning slots
        if (_morningSlots.isNotEmpty) ...[
          const Text('MORNING SLOTS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _buildSlots(_morningSlots),
          const SizedBox(height: 14),
        ],

        // Evening slots
        if (_eveningSlots.isNotEmpty) ...[
          const Text('EVENING SLOTS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _buildSlots(_eveningSlots),
        ],

        if (_morningSlots.isEmpty && _eveningSlots.isEmpty)
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
      children: slots.map((slot) {
        final active = _selectedTime == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? kPrimary : kBgLight,
              border: Border.all(color: active ? kPrimary : kBorderColor),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(slot, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: active ? Colors.white : kDarkText)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    final doc = _doctorData!;
    final price = doc['price']?.toString() ?? '0';
    final total = (double.tryParse(price) ?? 0) + 25;

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
        _summaryRow('Consultation Fee', '$price EGP'),
        const SizedBox(height: 8),
        _summaryRow('Service Fee', '25 EGP'),
        const Divider(height: 20, color: kBorderColor),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 0.5)),
          Text('$total EGP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
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
                : const Text('Confirm Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot'), backgroundColor: Colors.red));
      return;
    }
    if (_symptomsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a governorate'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isBooking = true);
    final result = await ApiService.bookDoctor(
      doctorId: widget.doctorId,
      date: _selectedFullDate,
      time: _selectedTime!,
      diseaseDescription: _symptomsCtrl.text.trim(),
      governorate: _selectedGovernorate!,
      address: _addressCtrl.text.trim(),
    );
    setState(() => _isBooking = false);

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Booking failed'), backgroundColor: Colors.red));
      }
    }
  }
}