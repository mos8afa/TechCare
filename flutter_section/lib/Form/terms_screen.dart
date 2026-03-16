import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                // Header
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFF1D89E4), size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                ),
                const SizedBox(height: 24),

                // Terms Content Box
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 480),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TermsSection(
                            icon: Icons.medical_services_outlined,
                            title: '1. Service Description',
                            content: 'Tech Care is a digital platform that connects patients, doctors, nurses, pharmacists, and blood donors. The platform enables:',
                            bullets: [
                              'For patients: Search and book doctors or nurses for home visits, order medications from nearby pharmacies.',
                              'For doctors & nurses: Create a verified profile, set consultation fees, and provide home visits.',
                              'For pharmacists: Synchronize a limited catalog of available medications.',
                              'Blood donation: Patients can request specific blood types; potential donors receive notifications.',
                            ],
                            footer: 'Tech Care acts solely as an intermediary. All medical services are provided by licensed independent professionals.',
                          ),
                          _TermsSection(
                            icon: Icons.verified_user_outlined,
                            title: '2. User Responsibilities',
                            content: 'Every user must provide accurate, complete, and up-to-date information. You agree to:',
                            bullets: [
                              'Submit genuine identification documents and professional credentials.',
                              'Provide honest medical history when relevant.',
                              'Respect appointment times and cancellation policies.',
                              'Not misuse the platform for fraudulent or illegal purposes.',
                            ],
                            footer: 'Tech Care is not liable for any damages arising from false or incomplete information.',
                          ),
                          _TermsSection(
                            icon: Icons.warning_amber_outlined,
                            title: '3. Medical Disclaimer',
                            content: 'Tech Care is not a healthcare provider. We do not practice medicine, give medical advice, or diagnose conditions. All consultations and treatments are delivered solely by qualified, licensed professionals who are independent from Tech Care.',
                          ),
                          _TermsSection(
                            icon: Icons.credit_card_outlined,
                            title: '4. Appointments & Payments',
                            bullets: [
                              'Booking fee: A small service fee may be charged to both patient and professional.',
                              'Payment methods: Cash upon arrival or secure in-app card payment.',
                              'Cancellation: Users may cancel up to 2 hours before the appointment without penalty.',
                              'Pharmacy orders: Payment is handled directly between the user and the pharmacy.',
                            ],
                          ),
                          _TermsSection(
                            icon: Icons.lock_outline,
                            title: '5. Privacy & Data Protection',
                            content: 'All personal data is stored encrypted and used only to provide and improve our services. We never sell your data to third parties.',
                            note: 'We comply with applicable data protection laws. You may request deletion of your account at any time.',
                          ),
                          _TermsSection(
                            icon: Icons.balance_outlined,
                            title: '6. Limitation of Liability',
                            content: 'To the maximum extent permitted by law, Tech Care shall not be liable for:',
                            bullets: [
                              'Any medical outcome or treatment provided by a professional booked through the platform.',
                              'Delays, errors, or unavailability of doctors, nurses, or medication stock.',
                              'Indirect or consequential damages arising from use of the service.',
                            ],
                          ),
                          _TermsSection(
                            icon: Icons.bloodtype_outlined,
                            title: '7. Blood Donation Requests',
                            content: 'When a patient requests a specific blood type, Tech Care may send notifications to potential donors who have agreed to be contacted. Donors are free to accept or decline.',
                          ),
                          _TermsSection(
                            icon: Icons.edit_outlined,
                            title: '8. Changes to Terms',
                            content: 'We may update these Terms & Conditions from time to time. Continued use of Tech Care after changes constitutes your acceptance of the new terms.',
                          ),
                          _TermsSection(
                            icon: Icons.email_outlined,
                            title: '9. Contact Us',
                            content: 'If you have any questions about these Terms, please contact our support team through the in-app help section.',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Accept Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D89E4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Accept & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// ==================== Terms Section Widget ====================
class _TermsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? content;
  final List<String>? bullets;
  final String? footer;
  final String? note;
  final bool isLast;

  const _TermsSection({
    required this.icon,
    required this.title,
    this.content,
    this.bullets,
    this.footer,
    this.note,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1572C2), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1572C2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (content != null)
          Text(content!, style: const TextStyle(fontSize: 14, color: Color(0xFF253746), height: 1.7)),

        if (bullets != null) ...[
          const SizedBox(height: 8),
          ...bullets!.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF1D89E4), fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(child: Text(b, style: const TextStyle(fontSize: 14, color: Color(0xFF253746), height: 1.6))),
              ],
            ),
          )),
        ],

        if (footer != null) ...[
          const SizedBox(height: 8),
          Text(footer!, style: const TextStyle(fontSize: 14, color: Color(0xFF253746), height: 1.7)),
        ],

        if (note != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(10),
              border: const Border(left: BorderSide(color: Color(0xFF1D89E4), width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF1D89E4), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(note!, style: const TextStyle(fontSize: 13, color: Color(0xFF194A6A), height: 1.6))),
              ],
            ),
          ),
        ],

        if (!isLast) ...[
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEDF2F7)),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}