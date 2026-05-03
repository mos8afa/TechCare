import 'package:flutter/material.dart';
import '../Patient/patient_profile_screen.dart';
import '../Patient/patient_doctor_requests_screen.dart';
import '../Patient/patient_notifications.dart';
import '../Patient/patient_wallet.dart';
import '../Patient/patient_donation.dart';

const Color kPrimary = Color(0xFF1D89E4);
const Color kBgLight = Color(0xFFF4F7FC);
const Color kTextGray = Color(0xFF718096);
const Color kBorderColor = Color(0xFFE1E6EC);
const Color kDarkText = Color(0xFF1A1C1E);
const Color kRed = Color(0xFFEF4444);
const Color kAmber = Color(0xFFF59E0B);
const Color kGreen = Color(0xFF10B981);

class PatientComplaintsScreen extends StatefulWidget {
  const PatientComplaintsScreen({super.key});

  @override
  State<PatientComplaintsScreen> createState() =>
      _PatientComplaintsScreenState();
}

class _PatientComplaintsScreenState extends State<PatientComplaintsScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  final List<Map<String, dynamic>> _previousComplaints = [
    {
      'subject': 'Long Waiting Time',
      'message':
          'I waited for over 45 minutes for my scheduled appointment.',
      'date': 'Apr 2, 2026',
      'status': 'Resolved',
    },
    {
      'subject': 'Incorrect Prescription',
      'message': 'The pharmacy gave me the wrong medication dosage.',
      'date': 'Mar 20, 2026',
      'status': 'Under Review',
    },
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

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
            _buildSubmitCard(),
            const SizedBox(height: 24),
            if (_previousComplaints.isNotEmpty) ...[
              const Text('Previous Complaints',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kDarkText)),
              const SizedBox(height: 14),
              ..._previousComplaints.map(_buildComplaintCard),
            ],
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
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
      title: const Text('Complaints',
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
                      radius: 5, backgroundColor: Color(0xFFEF4444))),
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
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/1.jpg'), // patient avatar
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'active': false
      },
      {
        'icon': Icons.list_alt_rounded,
        'label': 'Requests',
        'active': false
      },
      {
        'icon': Icons.local_hospital_outlined,
        'label': 'Donation',
        'active': false
      },
      {
        'icon': Icons.notifications_none_rounded,
        'label': 'Notifications',
        'active': false
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'active': false
      },
      {
        'icon': Icons.warning_amber_rounded,
        'label': 'Complaints',
        'active': true
      },
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
                      Text('Patient Portal',
                          style: TextStyle(fontSize: 12, color: kTextGray)),
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
                        _handleNav(context, item['label'] as String);
                      },
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

  void _handleNav(BuildContext context, String label) {
    switch (label) {
      case 'Profile':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
        );
        break;
      case 'Requests':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDoctorRequestsScreen()),
        );
        break;
      case 'Notifications':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const PatientNotificationsScreen()),
        );
        break;
      case 'Wallet':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientWalletScreen()),
        );
        break;
      case 'Donation':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDonationScreen()),
        );
        break;
      default:
        break;
    }
  }

  // ── Submit Complaint Card ─────────────────────────────────────────────────
  Widget _buildSubmitCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: _submitted ? _buildSuccessState() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: kRed, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Submit a Complaint',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kDarkText)),
                  Text('We\'ll review and respond within 24 hours.',
                      style: TextStyle(fontSize: 12, color: kTextGray)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subject
          _label('Subject'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectCtrl,
            validator: (v) =>
                v == null || v.isEmpty ? 'Please enter a subject' : null,
            decoration: _inputDec(hintText: 'Brief title of your complaint'),
          ),
          const SizedBox(height: 16),

          // Message
          _label('Message'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 5,
            validator: (v) =>
                v == null || v.isEmpty ? 'Please describe your complaint' : null,
            decoration: _inputDec(
                hintText: 'Describe your issue in detail...'),
          ),
          const SizedBox(height: 24),

          // Submit
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _submitted = true);
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Submit Complaint',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: kGreen, size: 36),
        ),
        const SizedBox(height: 16),
        const Text('Complaint Submitted!',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kDarkText)),
        const SizedBox(height: 8),
        const Text(
          'We\'ve received your complaint and will respond within 24 hours.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: kTextGray, height: 1.5),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _submitted = false;
              _subjectCtrl.clear();
              _messageCtrl.clear();
            });
          },
          child: const Text('Submit Another',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: kPrimary)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Previous Complaint Card ───────────────────────────────────────────────
  Widget _buildComplaintCard(Map<String, dynamic> c) {
    final status = c['status'] as String;
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Resolved':
        statusColor = kGreen;
        statusBg = const Color(0xFFE6F7E6);
        break;
      case 'Under Review':
        statusColor = kAmber;
        statusBg = const Color(0xFFFFFBEB);
        break;
      default:
        statusColor = kTextGray;
        statusBg = kBgLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(c['subject'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kDarkText)),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c['message'] as String,
              style: const TextStyle(
                  fontSize: 13, color: kTextGray, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: kTextGray),
              const SizedBox(width: 4),
              Text(c['date'] as String,
                  style: const TextStyle(fontSize: 12, color: kTextGray)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151)));

  InputDecoration _inputDec({String? hintText}) => InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: kTextGray, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRed),
        ),
      );
}