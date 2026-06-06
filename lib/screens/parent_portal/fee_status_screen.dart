import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class FeeStatusScreen extends StatelessWidget {
  const FeeStatusScreen({super.key});

  void _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/94702821035?text=Hello%2C%20I%20would%20like%20to%20inquire%20about%20the%20fee%20payment%20plan%20for%20my%20child.');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'school': return Icons.school_rounded;
      case 'home': return Icons.home_rounded;
      case 'airplane': return Icons.airplane_ticket_rounded;
      case 'health': return Icons.health_and_safety_rounded;
      case 'flight_land': return Icons.flight_land_rounded;
      case 'payment': return Icons.payment_rounded;
      default: return Icons.receipt_rounded;
    }
  }

  int _parseAmount(String amount) {
    final cleaned = amount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('💳 Fee Status', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('student_fees').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoDataView(context);
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = (data['items'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList();

          final totalPaid = items
              .where((i) => i['status'] == 'Paid')
              .fold<int>(0, (sum, i) => sum + _parseAmount(i['amount'] ?? '0'));
          final totalPending = items
              .where((i) => i['status'] == 'Pending')
              .fold<int>(0, (sum, i) => sum + _parseAmount(i['amount'] ?? '0'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Row(children: [
                    Expanded(child: _buildSummaryCard(context, 'Total Paid', 'USD $totalPaid', const Color(0xFF00E676))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSummaryCard(context, 'Pending', 'USD $totalPending', AppColors.primary)),
                  ]),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: Text('🧾 Fee Breakdown', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: context.dc.textMain)),
                ),
                const SizedBox(height: 14),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No fee records yet.', style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted))),
                  )
                else
                  ...items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final fee = entry.value;
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 150 + i * 70),
                      child: _buildFeeCard(context, fee),
                    );
                  }),
                const SizedBox(height: 8),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: context.dc.surfaceHighlight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Grand Total', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: context.dc.textMain)),
                      Text('USD ${totalPaid + totalPending}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                    ]),
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: _launchWhatsApp,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: Row(children: [
                        const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Inquire About Payment Plan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Installment options available — chat via WhatsApp', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
                        ])),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💳', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text('Fee Records Not Available Yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: context.dc.textMain)),
            const SizedBox(height: 12),
            Text('Your fee records will appear here once the admin uploads them. Contact us for fee details.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: context.dc.textMuted, height: 1.6)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _launchWhatsApp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Contact Admin via WhatsApp', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.dc.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ]),
    );
  }

  Widget _buildFeeCard(BuildContext context, Map<String, dynamic> fee) {
    final isPaid = fee['status'] == 'Paid';
    final statusColor = isPaid ? const Color(0xFF00E676) : AppColors.primary;
    final iconKey = fee['iconKey'] as String? ?? 'receipt';
    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: statusColor.withOpacity(0.25),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Icon(_iconFromKey(iconKey), color: statusColor, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fee['label'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: context.dc.textMain)),
          const SizedBox(height: 3),
          Text(fee['note'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.dc.textMuted, height: 1.4)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fee['amount'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: context.dc.textMain)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(fee['status'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
      ]),
    );
  }
}
