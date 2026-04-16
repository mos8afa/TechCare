import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Nurse/nurse_edit_profile.dart';
import '../Nurse/nurse_edit_slots.dart';
import '../Nurse/nurse_requests_screen.dart';
import '../Nurse/nurse_notifications.dart';
import '../Nurse/nurse_wallet.dart';
import '../Nurse/nurse_complaints.dart';

// ─── Colors ───────────────────────────────────────────────────────────────
const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);
const Color kGreen      = Color(0xFF10B981);
const Color kAmber      = Color(0xFFF59E0B);

// ─── Service Model ────────────────────────────────────────────────────────
class NurseService {
  final int id;
  String title;
  double price;
  String description;
  NurseService({required this.id, required this.title, required this.price, required this.description});
}

// ─── Nurse Profile Screen ─────────────────────────────────────────────────
class NurseProfileScreen extends StatefulWidget {
  const NurseProfileScreen({super.key});
  @override
  State<NurseProfileScreen> createState() => _NurseProfileScreenState();
}

class _NurseProfileScreenState extends State<NurseProfileScreen> {
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  bool _isServicesLoading = false;
  String? _error;
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _slots = [];
  List<NurseService> _services = [];

  final List<Map<String, String>> _days = [
    {'name': 'MON', 'num': '14'}, {'name': 'TUE', 'num': '15'},
    {'name': 'WED', 'num': '16'}, {'name': 'THU', 'num': '17'},
    {'name': 'FRI', 'num': '18'}, {'name': 'SAT', 'num': '19'},
    {'name': 'SUN', 'num': '20'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }


  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ApiService.getNurseDashboard();
    if (result.success) {
      final data = result.data;
      // Parse services from dashboard data if available
      List<NurseService> services = [];
      if (data['services'] != null) {
        services = (data['services'] as List).map<NurseService>((s) {
          // Handle price which may be a String or num
          double priceValue = 0;
          final priceField = s['price'];
          if (priceField is String) {
            priceValue = double.tryParse(priceField) ?? 0;
          } else if (priceField is num) {
            priceValue = priceField.toDouble();
          }
          return NurseService(
            id: s['id'],
            title: s['name'] ?? s['title'] ?? '',
            price: priceValue,
            description: s['description'] ?? '',
          );
        }).toList();
      }
      setState(() {
        _profileData = data;
        _services = services;
        _isLoading = false;
      });
      _loadTimeSlots();
    } else {
      if (result.error == 'Session expired') {
        await ApiService.clearTokens();
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        return;
      }
      setState(() {
        _error = result.error ?? 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimeSlots() async {
    // Get day string like "Monday", "Tuesday" etc based on selected day index
    // For now we'll use the day name from _days mapping
    final dayName = _getDayName(_selectedDayIndex);
    final result = await ApiService.getNurseTimeSlots(day: dayName);
    if (result.success) {
      setState(() {
        _slots = List<Map<String, dynamic>>.from(result.data['slots'] ?? []);
      });
    }
  }

  String _getDayName(int index) {
    // Map index to day name expected by backend (e.g., "Monday")
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }

  Future<void> _addService(String title, String description, double price) async {
    setState(() => _isServicesLoading = true);
    final result = await ApiService.addService(
      name: title,
      description: description,
      price: price.toStringAsFixed(0),
    );
    if (result.success) {
      // Reload dashboard to get updated services
      await _loadProfile();
    } else {
      _showSnackBar(result.error ?? 'Failed to add service');
    }
    setState(() => _isServicesLoading = false);
  }

  Future<void> _updateService(int serviceId, String title, String description, double price) async {
    setState(() => _isServicesLoading = true);
    final result = await ApiService.editService(
      serviceId: serviceId,
      name: title,
      description: description,
      price: price.toStringAsFixed(0),
    );
    if (result.success) {
      await _loadProfile();
    } else {
      _showSnackBar(result.error ?? 'Failed to update service');
    }
    setState(() => _isServicesLoading = false);
  }

  Future<void> _deleteService(int serviceId) async {
    // Confirm deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isServicesLoading = true);
    final result = await ApiService.deleteService(serviceId);
    if (result.success) {
      await _loadProfile();
    } else {
      _showSnackBar(result.error ?? 'Failed to delete service');
    }
    setState(() => _isServicesLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: kPrimary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTopRow(context),
                        const SizedBox(height: 20),
                        _buildTimeSlotsCard(),
                        const SizedBox(height: 20),
                        _buildServicesCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final profilePic = _profileData?['profile_pic'];
    final picUrl = ApiService.buildMediaUrl(profilePic);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      )),
      title: const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2, child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
          ]),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: kBgLight,
          backgroundImage: picUrl.isNotEmpty
              ? NetworkImage(picUrl) as ImageProvider
              : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=1D89E4&color=fff'),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(color: kBorderColor, height: 1)),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    return _NurseDrawer(activePage: 'Profile', onNav: (ctx, label) {
      switch (label) {
        case 'Requests':     Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const NurseRequestsScreen())); break;
        case 'Notifications':Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const NurseNotificationsScreen())); break;
        case 'Wallet':       Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const NurseWalletScreen())); break;
        case 'Complaints':   Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const NurseComplaintsScreen())); break;
        default: break;
      }
    });
  }

  // ── Top Row: Profile card + Financials card side by side ─────────────────
  Widget _buildTopRow(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    if (isWide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: _buildProfileCard()),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildFinancialsCard()),
      ]);
    }
    return Column(children: [
      _buildProfileCard(),
      const SizedBox(height: 20),
      _buildFinancialsCard(),
    ]);
  }

  // ── Profile Card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    final data = _profileData!;
    final name = data['name'] ?? data['username'] ?? '';
    final email = data['email'] ?? '';
    final phone = data['phone_number'] ?? '';
    final governorate = data['governorate'] ?? '';
    final address = data['address'] ?? '';
    final brief = data['brief'] ?? data['bio'] ?? '';
    final profilePic = data['profile_pic'];
    final picUrl = ApiService.buildMediaUrl(profilePic);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar + Name
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 40,
              backgroundImage: picUrl.isNotEmpty
                  ? NetworkImage(picUrl) as ImageProvider
                  : const NetworkImage('https://ui-avatars.com/api/?name=Nurse&background=1D89E4&color=fff'),
              backgroundColor: kBgLight),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDarkText)),
            const SizedBox(height: 2),
            const Text('Registered Nurse', style: TextStyle(fontSize: 13, color: kTextGray)),
          ])),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: kBorderColor)),

        // Info items
        _profileInfoItem(Icons.email_outlined, 'Email Address', email),
        const SizedBox(height: 10),
        _profileInfoItem(Icons.phone_outlined, 'Phone Number', phone),
        const SizedBox(height: 10),
        _profileInfoItem(Icons.location_on_outlined, 'Governorate', governorate),
        const SizedBox(height: 10),
        _profileInfoItem(Icons.home_outlined, 'Address', address),
        const SizedBox(height: 16),

        // About
        if (brief.isNotEmpty) ...[
          const Text('About', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 6),
          Text(brief, style: const TextStyle(fontSize: 13, color: kTextGray, height: 1.6)),
          const SizedBox(height: 20),
        ],

        // Edit button
        Align(alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const NurseEditProfileScreen()));
              _loadProfile();
            },
            icon: const Icon(Icons.edit_rounded, size: 15),
            label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _profileInfoItem(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: kPrimary),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kTextGray, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(value.isNotEmpty ? value : 'Not provided', 
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: value.isNotEmpty ? kDarkText : kTextGray)),
      ]),
    ]);
  }

  // ── Financials Card ───────────────────────────────────────────────────────
  Widget _buildFinancialsCard() {
    final data = _profileData!;
    final balance = data['wallet_balance']?.toString() ?? '0.00';
    final completedRequests = data['completed']?.toString() ?? '0';
    final pendingRequests = data['pending']?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.show_chart_rounded, color: kPrimary, size: 20),
            SizedBox(width: 8),
            Text('Financials & Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const NurseWalletScreen())); },
            child: const Text('View History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary))),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            const Text('Total Wallet Balance', style: TextStyle(fontSize: 13, color: kTextGray)),
            const SizedBox(height: 6),
            Text('$balance EGP', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kPrimary)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _statCard('Completed\nRequests', completedRequests, Icons.check_circle_outline_rounded, kGreen, const Color(0xFFE6F7E6))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Pending\nRequests', pendingRequests, Icons.article_outlined, kAmber, const Color(0xFFFFFBEB))),
        ]),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray, height: 1.4)),
        const SizedBox(height: 10),
        Row(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDarkText)),
        ]),
      ]),
    );
  }

  // ── Time Slots Card ───────────────────────────────────────────────────────
  Widget _buildTimeSlotsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.access_time_rounded, color: kPrimary, size: 20),
            SizedBox(width: 8),
            Text('Available Time Slots', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kDarkText)),
          ]),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const NurseEditTimeSlotsScreen()));
              _loadProfile(); // Refresh slots after edit
            },
            icon: const Icon(Icons.edit_calendar_outlined, size: 14),
            label: const Text('Edit Slots', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Days
        SizedBox(height: 72, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final active = _selectedDayIndex == i;
            return GestureDetector(
              onTap: () async {
                setState(() => _selectedDayIndex = i);
                await _loadTimeSlots();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                decoration: BoxDecoration(
                  color: active ? kPrimary : kBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_days[i]['name']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: active ? Colors.white : kTextGray)),
                  const SizedBox(height: 4),
                  Text(_days[i]['num']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: active ? Colors.white : kDarkText)),
                ]),
              ),
            );
          },
        )),
        const SizedBox(height: 16),

        // Slots
        if (_slots.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No slots set for this day', style: TextStyle(color: kTextGray)),
          ))
        else
          Wrap(spacing: 8, runSpacing: 8, children: _slots.map((slot) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(color: kBgLight, border: Border.all(color: kBorderColor),
                borderRadius: BorderRadius.circular(30)),
            child: Text(slot['time'] as String? ?? '', 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          )).toList()),
      ]),
    );
  }

  // ── Services Card ─────────────────────────────────────────────────────────
  Widget _buildServicesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('My Services (${_services.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
          ElevatedButton.icon(
            onPressed: () => _showAddServiceSheet(),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ]),
        const SizedBox(height: 16),

        if (_isServicesLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (_services.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              Icon(Icons.medical_services_outlined, size: 48, color: kTextGray.withOpacity(0.4)),
              const SizedBox(height: 10),
              const Text('No services added yet', style: TextStyle(fontSize: 14, color: kTextGray)),
            ]),
          ))
        else
          ...List.generate(_services.length, (i) => _serviceCard(_services[i], i)),
      ]),
    );
  }

  Widget _serviceCard(NurseService s, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.medical_services_outlined, color: kPrimary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 3),
          Text(s.description, style: const TextStyle(fontSize: 12, color: kTextGray)),
          const SizedBox(height: 6),
          Text('${s.price.toStringAsFixed(0)} EGP',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPrimary)),
        ])),
        // Edit and Delete buttons - now active with API calls
        Row(children: [
          GestureDetector(
            onTap: () => _showEditServiceSheet(index),
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, size: 15, color: kPrimary)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteService(s.id),
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFEF4444))),
          ),
        ]),
      ]),
    );
  }

  // ── Add Service Bottom Sheet ───────────────────────────────────────────────
  void _showAddServiceSheet() => _showServiceSheet(null);
  void _showEditServiceSheet(int index) => _showServiceSheet(index);

  void _showServiceSheet(int? editIndex) {
    final existing = editIndex != null ? _services[editIndex] : null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '');
    final descCtrl  = TextEditingController(text: existing?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: kBorderColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(editIndex != null ? 'Edit Service' : 'Add New Service',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 20),
          _sheetField('Title', titleCtrl, hintText: 'e.g. Wound Dressing'),
          const SizedBox(height: 14),
          _sheetField('Price (EGP)', priceCtrl, hintText: '0', keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _sheetField('Description', descCtrl, hintText: 'Short description', maxLines: 3),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(foregroundColor: kTextGray,
                  side: const BorderSide(color: kBorderColor),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final desc  = descCtrl.text.trim();
                if (title.isEmpty || price <= 0) return;
                Navigator.pop(ctx);
                if (editIndex != null) {
                  await _updateService(_services[editIndex].id, title, desc, price);
                } else {
                  await _addService(title, desc, price);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(editIndex != null ? 'Save Changes' : 'Add Service',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl,
      {String? hintText, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
          filled: true, fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
        ),
      ),
    ]);
  }
}

// ─── Shared Nurse Drawer ──────────────────────────────────────────────────
class _NurseDrawer extends StatelessWidget {
  final String activePage;
  final void Function(BuildContext, String) onNav;
  const _NurseDrawer({required this.activePage, required this.onNav});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.person_outline_rounded,          'label': 'Profile'},
      {'icon': Icons.list_alt_rounded,                'label': 'Requests'},
      {'icon': Icons.notifications_none_rounded,      'label': 'Notifications'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.warning_amber_rounded,           'label': 'Complaints'},
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
              Text('Nurse Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
            ]),
          ]),
          const SizedBox(height: 32),
          ...items.map((item) {
            final isActive = item['label'] == activePage;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isActive ? kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () { Navigator.pop(context); if (!isActive) onNav(context, item['label'] as String); },
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
        ]),
      )),
    );
  }
}