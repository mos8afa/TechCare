import 'package:flutter/material.dart';
import '../Doctor/doctor_edit_profile.dart';
import '../Doctor/doctor_edit_slots.dart';
import '../Doctor/doctor_requests_screen.dart';
import '../Doctor/doctor_notifications.dart';
import '../Doctor/doctor_wallet.dart';
import '../Doctor/doctor_complaints.dart';
import '../services/api_service.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kSecondary = Color(0xFF2179C2);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kGreen = Color(0xFF10B981);
const Color kAmber = Color(0xFFF59E0B);
const Color kDarkText = Color(0xFF1A1C1E);

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({String? day}) async {
    setState(() => _isLoading = true);
    final result = await ApiService.getDoctorDashboard(day: day);
    if (result.success) {
      setState(() {
        _dashboardData = result.data;
        _isLoading = false;
        _error = null;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _loadDashboard(),
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadDashboard(),
                  color: kPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildBottomGrid(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final profilePic = _dashboardData?['profile_pic'];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: kDarkText, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text('Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText)),
      actions: [
        const _AppBarNotification(),
        const SizedBox(width: 12),
        const VerticalDivider(width: 1, thickness: 1, color: kBorderColor, indent: 16, endIndent: 16),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundImage: (profilePic != null && profilePic.isNotEmpty)
              ? NetworkImage(ApiService.buildMediaUrl(profilePic)) as ImageProvider
              : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
          backgroundColor: kBgLight,
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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('img/logo.png', width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('TechCare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimary)),
                      Text('Medical Portal', style: TextStyle(fontSize: 12, color: kTextGray)),
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
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToPage(context, item['label'] as String);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Icon(item['icon'] as IconData,
                                color: isActive ? Colors.white : const Color(0xFF4B5563), size: 22),
                            const SizedBox(width: 12),
                            Text(item['label'] as String,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? Colors.white : const Color(0xFF4B5563))),
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

  Widget _buildProfileCard() {
    final data = _dashboardData!;
    final name = data['name'] ?? '';
    final specification = data['specification'] ?? '';
    final price = data['price']?.toString() ?? '';
    final phone = data['phone_number'] ?? '';
    final email = data['email'] ?? '';
    final governorate = data['governorate'] ?? '';
    final address = data['address'] ?? '';
    final brief = data['brief'] ?? '';
    final profilePic = data['profile_pic'];
    final avgRating = data['average_rating'] ?? 0;

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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                      ? NetworkImage(ApiService.buildMediaUrl(profilePic)) as ImageProvider
                      : const NetworkImage('https://ui-avatars.com/api/?name=Doctor&background=1D89E4&color=fff'),
                    backgroundColor: kBgLight,
                  ),
                  Positioned(
                    right: 4, bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kGreen, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFBDC), borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < avgRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: kAmber, size: 18,
                    )),
                    const SizedBox(width: 8),
                    Text('$avgRating Reviews',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kAmber)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDarkText)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 13, color: kPrimary),
                    SizedBox(width: 5),
                    Text('Verified Doctor',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(specification,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 32, runSpacing: 8,
            children: [
              _infoItem(Icons.payments_outlined, 'Consultation:', '$price EGP'),
              _infoItem(Icons.phone_outlined, 'Phone:', phone),
              _infoItem(Icons.email_outlined, 'Email:', email),
              _infoItem(Icons.location_on_outlined, 'Location:', '$address, $governorate'),
            ],
          ),
          if (brief.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(brief,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.6)),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorEditProfileScreen()),
                );
                _loadDashboard();
              },
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kPrimary),
        const SizedBox(width: 6),
        Text('$label ', style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDarkText)),
      ],
    );
  }

  Widget _buildBottomGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTimeSlotsCard()),
          const SizedBox(width: 20),
          Expanded(child: _buildFinancialsCard()),
        ],
      );
    }
    return Column(
      children: [
        _buildTimeSlotsCard(),
        const SizedBox(height: 20),
        _buildFinancialsCard(),
      ],
    );
  }

  Widget _buildTimeSlotsCard() {
    final data = _dashboardData!;
    final days = (data['days'] as List?) ?? [];
    final morningSlots = (data['morning_slots'] as List?) ?? [];
    final eveningSlots = (data['evening_slots'] as List?) ?? [];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_rounded, color: kPrimary, size: 20),
                  SizedBox(width: 8),
                  Text('Available Time Slots',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorEditTimeSlotsScreen()),
                  );
                  _loadDashboard();
                },
                icon: const Icon(Icons.edit_calendar_outlined, size: 14),
                label: const Text('Edit Slots',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (days.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final active = _selectedDayIndex == i;
                  final dayData = days[i] as Map;
                  final dayName = (dayData['day'] as String).substring(0, 3).toUpperCase();
                  final dateStr = dayData['date'] as String;
                  final dayNum = dateStr.split('-').last;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDayIndex = i);
                      _loadDashboard(day: dayData['day'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: active ? kPrimary : kBgLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dayName,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : kTextGray)),
                          const SizedBox(height: 4),
                          Text(dayNum,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800,
                                  color: active ? Colors.white : kDarkText)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          _sectionLabel('MORNING SLOTS'),
          const SizedBox(height: 10),
          morningSlots.isEmpty
              ? const Text('No morning slots', style: TextStyle(color: kTextGray, fontSize: 13))
              : _buildReadOnlySlots(morningSlots.map((s) => s['time'] as String).toList()),
          const SizedBox(height: 16),
          _sectionLabel('EVENING SLOTS'),
          const SizedBox(height: 10),
          eveningSlots.isEmpty
              ? const Text('No evening slots', style: TextStyle(color: kTextGray, fontSize: 13))
              : _buildReadOnlySlots(eveningSlots.map((s) => s['time'] as String).toList()),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800, color: kTextGray, letterSpacing: 1.2));
  }

  Widget _buildReadOnlySlots(List<String> slots) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: slots.map((slot) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kBgLight, border: Border.all(color: kBorderColor),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(slot,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
      )).toList(),
    );
  }

  Widget _buildFinancialsCard() {
    final data = _dashboardData!;
    final pending = data['pending'] ?? 0;
    final completed = data['completed'] ?? 0;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: kPrimary, size: 20),
                  SizedBox(width: 8),
                  Text('Financials & Activity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDarkText)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const DoctorWalletScreen()),
                ),
                child: const Text('View History',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Text('Total Wallet Balance',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                SizedBox(height: 8),
                Text('— EGP',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Completed\nRequests',
                  value: completed.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: kGreen, bgColor: const Color(0xFFE6F7E6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  label: 'Pending\nRequests',
                  value: pending.toString(),
                  icon: Icons.article_outlined,
                  color: kAmber, bgColor: const Color(0xFFFFFBEB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label, required String value,
    required IconData icon, required Color color, required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kTextGray, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: kDarkText)),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageLabel) {
    switch (pageLabel) {
      case 'Profile': break;
      case 'Requests':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorRequestsScreen()));
        break;
      case 'Notifications':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorNotificationsScreen()));
        break;
      case 'Wallet':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorWalletScreen()));
        break;
      case 'Complaints':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorComplaintsScreen()));
        break;
    }
  }
}

class _AppBarNotification extends StatelessWidget {
  const _AppBarNotification();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: const [
          Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563), size: 24),
          Positioned(
            right: -2, top: -2,
            child: CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444)),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}