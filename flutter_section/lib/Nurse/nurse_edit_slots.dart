import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);
const Color kAmber      = Color(0xFFF59E0B);
const Color kSky        = Color(0xFF0EA5E9);

class NurseEditTimeSlotsScreen extends StatefulWidget {
  const NurseEditTimeSlotsScreen({super.key});
  @override
  State<NurseEditTimeSlotsScreen> createState() => _NurseEditTimeSlotsScreenState();
}

class _NurseEditTimeSlotsScreenState extends State<NurseEditTimeSlotsScreen> {
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  
  final List<Map<String, String>> _days = [
    {'name': 'MON', 'api': 'Monday'},
    {'name': 'TUE', 'api': 'Tuesday'},
    {'name': 'WED', 'api': 'Wednesday'},
    {'name': 'THU', 'api': 'Thursday'},
    {'name': 'FRI', 'api': 'Friday'},
    {'name': 'SAT', 'api': 'Saturday'},
    {'name': 'SUN', 'api': 'Sunday'},
  ];

  // Store slots per day as list of time strings
  Map<String, List<String>> _slotsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // Load slots for current selected day
      final dayApi = _days[_selectedDayIndex]['api']!;
      final result = await ApiService.getTimeSlots(day: dayApi);
      if (result.success) {
        final slotsData = result.data['slots'] as List? ?? [];
        final times = slotsData.map<String>((s) => s['time'].toString()).toList();
        setState(() {
          _slotsByDay[dayApi] = times;
          _isLoading = false;
        });
      } else {
        if (result.error == 'Session expired') {
          await ApiService.clearTokens();
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          return;
        }
        setState(() {
          _error = result.error ?? 'Failed to load slots';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSlots() async {
    setState(() => _isSaving = true);
    final dayApi = _days[_selectedDayIndex]['api']!;
    final times = _slotsByDay[dayApi] ?? [];
    final result = await ApiService.addTimeSlot(
      day: dayApi,
      times: times,
    );
    setState(() => _isSaving = false);
    if (result.success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to save slots')),
      );
    }
  }

  void _addSlot(String dayApi, String time) {
    setState(() {
      _slotsByDay.putIfAbsent(dayApi, () => []);
      if (!_slotsByDay[dayApi]!.contains(time)) {
        _slotsByDay[dayApi]!.add(time);
        _slotsByDay[dayApi]!.sort();
      }
    });
  }

  void _removeSlot(String dayApi, String time) {
    setState(() {
      _slotsByDay[dayApi]?.remove(time);
    });
  }

  List<String> get _currentSlots {
    final dayApi = _days[_selectedDayIndex]['api']!;
    return _slotsByDay[dayApi] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: _loadSlots,
                      child: const Text('Retry'),
                    ),
                  ],
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildWeekly(),
                    const SizedBox(height: 28),
                    _buildSlotsEditor(),
                    const SizedBox(height: 28),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF4B5563)),
                        child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveSlots,
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13), elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                  ]),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
    leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: kDarkText),
        onPressed: () => Navigator.pop(context)),
    title: const Text('Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: kBorderColor, height: 1)),
  );

  Widget _buildHeader() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
    Text('Edit Time Slots', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kDarkText)),
    SizedBox(height: 4),
    Text('Customize your working hours and appointment slots.', style: TextStyle(fontSize: 14, color: kTextGray)),
  ]);

  Widget _buildWeekly() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('WEEKLY SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
        color: kTextGray, letterSpacing: 1.5)),
    const SizedBox(height: 14),
    SizedBox(height: 84, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final active = _selectedDayIndex == i;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedDayIndex = i);
            _loadSlots();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            decoration: BoxDecoration(
              color: active ? kPrimary : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              boxShadow: active ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_days[i]['name']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: active ? Colors.white : kTextGray)),
              const SizedBox(height: 4),
              // Just show day number placeholder
              Text((i+14).toString(), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                  color: active ? Colors.white : kDarkText)),
            ]),
          ),
        );
      },
    )),
  ]);

  Widget _buildSlotsEditor() {
    final slots = _currentSlots;
    final dayApi = _days[_selectedDayIndex]['api']!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.schedule_rounded, color: kSky, size: 22)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_days[_selectedDayIndex]['name']} Slots',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
            Text('Add or remove available times',
                style: const TextStyle(fontSize: 12, color: kTextGray)),
          ]),
        ]),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ...slots.map((time) => _slotChip(time, dayApi)),
          GestureDetector(
            onTap: () => _showAddSlot(dayApi),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                  borderRadius: BorderRadius.circular(100), color: Colors.transparent),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                SizedBox(width: 6),
                Text('Add Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _slotChip(String time, String dayApi) {
    return GestureDetector(
      onTap: () => _removeSlot(dayApi, time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kPrimary, width: 2),
          borderRadius: BorderRadius.circular(100)),
        child: Stack(clipBehavior: Clip.none, children: [
          Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
          Positioned(top: -16, right: -16,
            child: Container(width: 20, height: 20,
              decoration: const BoxDecoration(color: Color(0xFFB91C1C), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 12)),
          ),
        ]),
      ),
    );
  }

  void _showAddSlot(String dayApi) {
    TimeOfDay sel = TimeOfDay.now();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(builder: (_, setM) => Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: kBorderColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          const Text('Add New Time Slot', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 16),
          const Text('Select Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final p = await showTimePicker(context: context, initialTime: sel,
                  builder: (c, ch) => Theme(data: Theme.of(c).copyWith(
                      colorScheme: const ColorScheme.light(primary: kPrimary)), child: ch!));
              if (p != null) setM(() => sel = p);
            },
            child: Container(width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor)),
              child: Row(children: [
                const Icon(Icons.access_time_rounded, color: kTextGray, size: 20),
                const SizedBox(width: 10),
                Text(sel.format(context), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kDarkText)),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(foregroundColor: kTextGray,
                  side: const BorderSide(color: kBorderColor), padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                final label = sel.format(context);
                _addSlot(dayApi, label);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Add Slot', style: TextStyle(fontWeight: FontWeight.w600)))),
          ]),
        ])),
      ),
    );
  }
}