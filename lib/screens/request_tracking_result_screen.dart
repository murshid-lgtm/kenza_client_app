import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (s.contains('progress')) return const Color(0xFFEAF2FF);
    if (s.contains('pending')) return const Color(0xFFFFF4E5);
    return const Color(0xFFF2F4F7);
  }

  Color _statusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFF1E8E5A);
    if (s.contains('progress')) return const Color(0xFF2F6FED);
    if (s.contains('pending')) return const Color(0xFFC98512);
    return AppColors.text;
  }

  void _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking ID copied')),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF7A8594)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
    final message = '${data['message'] ?? ''}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF241200),
                Color(0xFF5A3513),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _copy(context, trackingId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tracking ID: $trackingId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _statusText(status),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (message.trim().isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFF2DCC8),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: infoTile(
                      icon: Icons.business_center_outlined,
                      label: 'Owner Mode',
                      value: ownerMode,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoTile(
                      icon: Icons.apartment_outlined,
                      label: 'Company ID',
                      value: companyId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              infoTile(
                icon: Icons.email_outlined,
                label: 'Customer Email',
                value: email,
              ),
            ],
          ),
        ),
      ],
    );
  }
}