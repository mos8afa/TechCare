import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kAmber = Color(0xFFF59E0B);
const Color kSky = Color(0xFF0EA5E9);

class DoctorEditTimeSlotsScreen extends StatefulWidget {
  const DoctorEditTimeSlotsScreen({super.key});

  @override
  State<DoctorEditTimeSlotsScreen> createState() => _DoctorEditTimeSlotsScreenState();
}

class _DoctorEditTimeSlotsScreenState extends State<DoctorEditTimeSlotsScreen> {
  int _selectedDayIndex = 0;
  bool _isLoadingDays = true;
  bool _isLoadingSlots = false;
  String? _error;

  List<Map<String, dynamic>> _days = [];
  List<Map<String, dynamic>> _morningSlots = [];
  List<Map<String, dynamic>> _eveningSlots = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoadingDays = true);
    final result = await ApiService.getDoctorTimeSlots();
    if (result.success) {
      final data = result.data;
      setState(() {
        _days = List<Map<String, dynamic>>.from(data['days'] ?? []);
        _morningSlots = List<Map<String, dynamic>>.from(data['morning_slots'] ?? []);
        _eveningSlots = List<Map<String, dynamic>>.from(data['evening_slots'] ?? []);
        _isLoadingDays = false;
        _error = null;
      });
    } else {
      setState(() { _error = result.error; _isLoadingDays = false; });
    }
  }

  Future<void> _loadSlotsForDay(String day) async {
    setState(() => _isLoadingSlots = true);
    final result = await ApiService.getDoctorTimeSlots(day: day);
    if (result.success) {
      final data = result.data;
      setState(() {
        _morningSlots = List<Map<String, dynamic>>.from(data['morning_slots'] ?? []);
        _eveningSlots = List<Map<String, dynamic>>.from(data['evening_slots'] ?? []);
        _isLoadingSlots = false;
      });
    } else {
      setState(() => _isLoadingSlots = false);
    }
  }

  String get _selectedDay {
    if (_days.isEmpty) return '';
    return _days[_selectedDayIndex]['day'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      body: _isLoadingDays
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      const SizedBox(height: 32),
                      _buildWeeklySchedule(),
                      const SizedBox(height: 32),
                      if (_isLoadingSlots)
                        const LinearProgressIndicator(color: kPrimary, backgroundColor: kBgLight),
                      const SizedBox(height: 8),
                      _buildSessionCard(isMorning: true, slots: _morningSlots),
                      const SizedBox(height: 20),
                      _buildSessionCard(isMorning: false, slots: _eveningSlots),
                      const SizedBox(height: 32),
                      _buildBottomActions(context),
                    ],
                  ),
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
      title: const Text('Time Slots',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit Time Slots',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kDarkText)),
        SizedBox(height: 6),
        Text('Customize your working hours and appointment slots.',
            style: TextStyle(fontSize: 14, color: kTextGray)),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4B5563),
            side: const BorderSide(color: kBorderColor),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WEEKLY SCHEDULE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        SizedBox(
          height: 88,
          child: _days.isEmpty
              ? const Center(child: Text('No days available', style: TextStyle(color: kTextGray)))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final active = _selectedDayIndex == i;
                    final dayData = _days[i];
                    final dayName = (dayData['day'] as String).substring(0, 3).toUpperCase();
                    final dateStr = dayData['date'] as String;
                    final dayNum = dateStr.split('-').last;
                    return GestureDetector(
                      onTap: () {
                        if (_selectedDayIndex == i) return;
                        setState(() => _selectedDayIndex = i);
                        _loadSlotsForDay(dayData['day'] as String);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 76,
                        decoration: BoxDecoration(
                          color: active ? kPrimary : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: active
                              ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayName,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5, color: active ? Colors.white : kTextGray)),
                            const SizedBox(height: 6),
                            Text(dayNum,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                                    color: active ? Colors.white : kDarkText)),
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

  Widget _buildSessionCard({
    required bool isMorning,
    required List<Map<String, dynamic>> slots,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isMorning ? const Color(0xFFFEEDDF) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isMorning ? kAmber : kSky, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMorning ? 'Morning Sessions' : 'Evening Sessions',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                  Text(
                    isMorning ? 'Recommended: 08:00 AM – 12:00 PM' : 'Recommended: 04:00 PM – 09:00 PM',
                    style: const TextStyle(fontSize: 12, color: kTextGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 0, runSpacing: 0,
            children: [
              ...slots.asMap().entries.map((entry) {
                final slot = entry.value;
                return _buildPill(
                  label: slot['time'] as String,
                  onRemove: () => _deleteSlot(slot['id'] as int),
                );
              }),
              _buildAddPill(onTap: () => _showAddSlotModal(isMorning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({required String label, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kPrimary, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimary)),
          ),
          Positioned(
            top: -8, right: -8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(color: Color(0xFFB91C1C), shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPill({required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
              SizedBox(width: 6),
              Text('Add Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSlot(int slotId) async {
    final result = await ApiService.deleteDoctorTimeSlot(slotId);
    if (result.success) {
      await _loadSlotsForDay(_selectedDay);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Failed to delete'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddSlotModal(bool isMorning) {
    TimeOfDay selectedTime = isMorning
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 16, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: kBorderColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add New Time Slot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
              const SizedBox(height: 20),
              StatefulBuilder(builder: (context, setModalState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Time',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: kPrimary),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) setModalState(() => selectedTime = picked);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: kTextGray, size: 20),
                            const SizedBox(width: 10),
                            Text(selectedTime.format(context),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600, color: kDarkText)),
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
                              foregroundColor: const Color(0xFF4B5563),
                              side: const BorderSide(color: kBorderColor),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);

                              final h = selectedTime.hour.toString().padLeft(2, '0');
                              final m = selectedTime.minute.toString().padLeft(2, '0');
                              final newTime = '$h:$m';

                              // ── اجمع الـ slots الموجودة + الجديدة ──
                              final existingTimes = [
                                ..._morningSlots.map((s) => s['time'] as String),
                                ..._eveningSlots.map((s) => s['time'] as String),
                              ];
                              if (!existingTimes.contains(newTime)) {
                                existingTimes.add(newTime);
                              }

                              final result = await ApiService.saveDoctorTimeSlots(
                                day: _selectedDay,
                                times: existingTimes,
                              );

                              if (result.success) {
                                await _loadSlotsForDay(_selectedDay);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.error ?? 'Failed to add'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Add Slot',
                                style: TextStyle(fontWeight: FontWeight.w600)),
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