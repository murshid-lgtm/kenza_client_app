import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class RequestTrackingResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const RequestTrackingResultScreen({
    super.key,
    required this.data,
  });

  Color _statusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFFE8FAEE);
    if (s.contains('progress')) return const Color(0xFFE7F0FF);
    if (s.contains('pending')) return const Color(0xFFFFF5E6);
    return const Color(0xFFF2F4F7);
  }

  Color _statusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFF1E8E5A);
    if (s.contains('progress')) return const Color(0xFF356AE6);
    if (s.contains('pending')) return const Color(0xFFC98512);
    return AppColors.text;
  }

  Widget infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingId = '${data['tracking_id'] ?? '-'}';
    final status = '${data['status'] ?? '-'}';
    final ownerMode = '${data['owner_mode'] ?? '-'}';
    final customerName = '${data['customer_name'] ?? '-'}';
    final email = '${data['customer_email_masked'] ?? '-'}';
    final companyId = '${data['company_id'] ?? '-'}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF356AE6),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(status),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _statusText(status),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Tracking ID: $trackingId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        infoTile('Owner Mode', ownerMode),
        infoTile('Customer Email', email),
        infoTile('Company ID', companyId),
      ],
    );
  }
}