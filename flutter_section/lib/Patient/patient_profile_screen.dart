import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Patient/patient_edit_profile_screen.dart';
import '../Patient/patient_notifications.dart';
import '../Patient/patient_wallet.dart';
import '../Patient/patient_complaints.dart';
import '../Patient/patient_doctor_requests_screen.dart';

const Color kPrimary    = Color(0xFF1D89E4);
const Color kBgLight    = Color(0xFFF4F7FC);
const Color kTextGray   = Color(0xFF718096);
const Color kBorderColor= Color(0xFFE1E6EC);
const Color kDarkText   = Color(0xFF1A1C1E);
const Color kGreen      = Color(0xFF10B981);
const Color kAmber      = Color(0xFFF59E0B);

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getPatientDashboard();
    if (result.success) {
      setState(() { _data = result.data; _isLoading = false; _error = null; });
    } else {
      if (result.error == 'Session expired') {
        await ApiService.clearTokens();
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        return;
      }
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildRequestsGrid(),
                        const SizedBox(height: 20),
                        _buildBottomSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final profilePic = _data?['profile_pic'];
    final picUrl = ApiService.buildMediaUrl(profilePic);
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
      title: const Text('Patient Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        IconButton(
          icon: Stack(clipBehavior: Clip.none, children: const [
            Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
            Positioned(right: -2, top: -2,
                child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444))),
          ]),
          onPressed: () {
            // Navigate to notifications
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()));
          },
        ),
        const SizedBox(width: 4),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: kBgLight,
          backgroundImage: picUrl.isNotEmpty
              ? NetworkImage(picUrl) as ImageProvider
              : const NetworkImage('https://ui-avatars.com/api/?name=Patient&background=1D89E4&color=fff'),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  Widget _buildDrawer() {
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
                  Text('Patient Portal', style: TextStyle(fontSize: 12, color: kTextGray)), // changed
                ]),
              ]),
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
                      onTap: () {
                        Navigator.pop(context);
                        _navigateTo(item['label'] as String);
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

  Widget _buildProfileCard() {
    final data = _data!;
    final name = data['name'] ?? '';
    final email = data['email'] ?? '';
    final phone = data['phone_number'] ?? '';
    final governorate = data['governorate'] ?? '';
    final address = data['address'] ?? '';
    final profilePic = data['profile_pic'];
    final picUrl = ApiService.buildMediaUrl(profilePic);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: kBgLight,
                  backgroundImage: picUrl.isNotEmpty
                      ? NetworkImage(picUrl) as ImageProvider
                      : const NetworkImage('https://ui-avatars.com/api/?name=Patient&background=1D89E4&color=fff&size=200'),
                ),
                Positioned(
                  right: 2, bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kGreen, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 9),
                  ),
                ),
              ]),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kDarkText)),
                    const SizedBox(height: 12),
                    _infoRow(Icons.email_outlined, email),
                    const SizedBox(height: 6),
                    _infoRow(Icons.phone_outlined, phone),
                    const SizedBox(height: 6),
                    _infoRow(Icons.location_on_outlined, governorate),
                    const SizedBox(height: 6),
                    _infoRow(Icons.home_outlined, address),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PatientEditProfileScreen()));
                _load();
              },
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(children: [
      Icon(icon, size: 15, color: kPrimary),
      const SizedBox(width: 6),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
    ]);
  }

  Widget _buildRequestsGrid() {
    final doctor = _data!['doctor'] as Map? ?? {};
    final nurse = _data!['nurse'] as Map? ?? {};
    final combined = _data!['combined'] as Map? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Requests Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('Doctor Requests', doctor['total'] ?? 0, kPrimary, const Color(0xFFEFF6FF))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Nurse Requests', nurse['total'] ?? 0, kGreen, const Color(0xFFE6F7E6))),
        ]),
        const SizedBox(height: 12),
        _statCardWide('Total Appointments', combined['total'] ?? 0,
            combined['completed'] ?? 0, combined['pending'] ?? 0),
      ],
    );
  }

  Widget _statCard(String title, int count, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 8),
        Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text('requests', style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
      ]),
    );
  }

  Widget _statCardWide(String title, int total, int completed, int pending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat('Total', total, kPrimary),
          _dividerV(),
          _miniStat('Completed', completed, kGreen),
          _dividerV(),
          _miniStat('Pending', pending, kAmber),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int val, Color color) {
    return Column(children: [
      Text('$val', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextGray, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _dividerV() {
    return Container(width: 1, height: 40, color: kBorderColor);
  }

  Widget _buildBottomSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wallet card
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const PatientWalletScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D89E4), Color(0xFF2179C2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('TechCare Wallet',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 18),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Manage healthcare payments',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 16),
                  const Text('AVAILABLE BALANCE',
                      style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  const Text('2,450 EGP',  
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(String label) {
    switch (label) {
      case 'Profile':
        break;
      case 'Requests':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PatientDoctorRequestsScreen()));   
        break;
      case 'Notifications':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PatientNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PatientWalletScreen()));
        break;
      case 'Complaints':
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PatientComplaintsScreen()));
        break;
      default:
        break;
    }
  }
}