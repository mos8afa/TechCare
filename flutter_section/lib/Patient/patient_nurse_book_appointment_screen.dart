import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  List<dynamic> _days = [];
  Map<String, dynamic> _allSlots = {};

  Set<int> _selectedServices = {};

  bool _isLoading = true;
  // bool _isBooking = false;

  int _selectedDayIndex = 0;
  String? _selectedTime;
  String? _selectedGovernorate;

  final _symptomsCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ApiService.getNurseBookingInfo(widget.nurseId);

    if (result.success) {
      final data = result.data;

      setState(() {
        _nurseData = data['nurse'];
        _services  = data['services'] ?? [];
        _days      = data['days'] ?? [];
        _allSlots  = data['all_slots'] ?? {};
        _isLoading = false;
      });
    }
  }

  String get _selectedDayKey =>
      _days.isEmpty ? '' : _days[_selectedDayIndex]['day'];

  String get _selectedFullDate =>
      _days.isEmpty ? '' : _days[_selectedDayIndex]['full_date'];

  List<String> get _morningSlots =>
      List<String>.from(_allSlots[_selectedDayKey]?['morning'] ?? []);

  List<String> get _eveningSlots =>
      List<String>.from(_allSlots[_selectedDayKey]?['evening'] ?? []);

  double get _totalPrice {
    double total = 0;
    for (var s in _services) {
      if (_selectedServices.contains(s['id'])) {
        total += double.tryParse(s['price'].toString()) ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: kDarkText,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                ],
              ),
            ),
    );
  }

  // ================= Nurse Card =================
  Widget _buildNurseCard() {
    final doc = _nurseData!;
    final pic = ApiService.buildMediaUrl(doc['profile_pic']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 32, backgroundImage: NetworkImage(pic)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(doc['brief'] ?? '',
                    style: const TextStyle(color: kTextGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SERVICES =================
  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Services',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._services.map((s) {
            final id = s['id'];
            final selected = _selectedServices.contains(id);

            return CheckboxListTile(
              value: selected,
              onChanged: (_) {
                setState(() {
                  if (selected) {
                    _selectedServices.remove(id);
                  } else {
                    _selectedServices.add(id);
                  }
                });
              },
              title: Text(s['name']),
              subtitle: Text(s['description'] ?? ''),
              // trailing: Text('${(s['price'] ?? '0')} EGP'),
            );
          })
        ],
      ),
    );
  }

  // ================= DATE =================
  Widget _buildDateTimeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Date & Time"),
        const SizedBox(height: 10),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (_, i) {
              final d = _days[i];
              final active = _selectedDayIndex == i;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = i;
                    _selectedTime = null;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: active ? kPrimary : kBgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d['date_num']),
                      Text(d['month']),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          children: [..._morningSlots, ..._eveningSlots].map((t) {
            final active = _selectedTime == t;

            return ChoiceChip(
              label: Text(_fmtSlotTime(t)),
              selected: active,
              onSelected: (_) {
                setState(() => _selectedTime = t);
              },
            );
          }).toList(),
        )
      ],
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryCard() {
    return Column(
      children: [
        Text("Total: $_totalPrice EGP"),
        ElevatedButton(
          onPressed: _handleBook,
          child: const Text("Confirm Booking"),
        )
      ],
    );
  }

  // ================= BOOK =================
  Future<void> _handleBook() async {
    if (_selectedServices.isEmpty) {
      _snack('Please select at least one service');
      return;
    }

    if (_selectedTime == null) {
      _snack('Please select a time slot');
      return;
    }

    if (_selectedGovernorate == null) {
      _snack('Please select your governorate');
      return;
    }

    if (_symptomsCtrl.text.isEmpty) {
      _snack('Please describe your symptoms');
      return;
    }

    if (_addressCtrl.text.isEmpty) {
      _snack('Please enter your full address');
      return;
    }

    final result = await ApiService.bookNurse(
      nurseId: widget.nurseId,
      serviceIds: _selectedServices.toList(),
      date: _selectedFullDate,
      time: _selectedTime!,
      diseaseDescription: _symptomsCtrl.text,
      governorate: _selectedGovernorate ?? '',
      address: _addressCtrl.text,
    );

    _snack(result.success ? "تم الحجز ✅" : result.error!);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildGovernorateField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Governorate',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedGovernorate,
            hint: const Text('Select governorate',
                style: TextStyle(fontSize: 14, color: kTextGray)),
            items: kGovernorates
                .map((g) => DropdownMenuItem(
                      value: g['value'],
                      child: Text(g['label']!),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedGovernorate = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: kBgLight,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: kPrimary, width: 1.5)),
            ),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: kPrimary),
              SizedBox(width: 6),
              Text('Describe Your Symptoms',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kDarkText)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _symptomsCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Please provide more details about how you are feeling...',
              hintStyle:
                  const TextStyle(color: kTextGray, fontSize: 13),
              filled: true,
              fillColor: kBgLight,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Full Address',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kDarkText)),
          const SizedBox(height: 10),
          TextField(
            controller: _addressCtrl,
            decoration: InputDecoration(
              hintText: 'Street, Building, Apartment',
              hintStyle:
                  const TextStyle(color: kTextGray, fontSize: 13),
              prefixIcon: const Icon(Icons.location_on_outlined,
                  color: kTextGray, size: 18),
              filled: true,
              fillColor: kBgLight,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }


}