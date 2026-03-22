import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ServiceTrackingResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ServiceTrackingResultScreen({
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

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return Icons.check_circle_rounded;
    if (s.contains('progress')) return Icons.pending_actions_rounded;
    if (s.contains('pending')) return Icons.schedule_rounded;
    return Icons.info_rounded;
  }

  Widget _metaCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF7A8594)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color background,
    required Color textColor,
    Color borderColor = Colors.transparent,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageRow({
    required String stageName,
    required String stageStatus,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _statusBg(stageStatus),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _statusIcon(stageStatus),
              color: _statusText(stageStatus),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stageName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _statusBg(stageStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stageStatus,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _statusText(stageStatus),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard({
    required String title,
    required int progressPercent,
    required List<dynamic> stages,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (progressPercent.clamp(0, 100)) / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE7EBF0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B1C44)),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            return _stageRow(
              stageName: '${stage['name'] ?? '-'}',
              stageStatus: '${stage['status'] ?? '-'}',
              isLast: index == stages.length - 1,
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingId = '${data['tracking_id'] ?? '-'}';
    final customerName = '${data['customer_name'] ?? '-'}';
    final status = '${data['status'] ?? '-'}';
    final mobile = '${data['mobile_masked'] ?? data['mobile'] ?? '-'}';
    final branch = '${data['branch'] ?? '-'}';
    final submissionDate = '${data['submission_date'] ?? '-'}';
    final appointmentDate = '${data['appointment_date'] ?? '-'}';
    final notes = '${data['notes'] ?? '-'}';
    final supportPhone = '${data['support_phone'] ?? '-'}';
    final whatsappNumber = '${data['whatsapp_number'] ?? '-'}';
    final brandLabel = '${data['brand_label'] ?? 'Support'}';

    final progress = (data['overall_progress_percent'] ?? 0) is int
        ? data['overall_progress_percent'] as int
        : int.tryParse('${data['overall_progress_percent'] ?? 0}') ?? 0;

    final groups = (data['groups'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E214E),
                Color(0xFF1A3B86),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Tracking ID: $trackingId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
              const SizedBox(height: 18),
              const Text(
                'Overall progress',
                style: TextStyle(
                  color: Color(0xFFCFD8F0),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: (progress.clamp(0, 100)) / 100,
                        minHeight: 11,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _actionButton(
              icon: Icons.support_agent_rounded,
              label: brandLabel,
              background: const Color(0xFF0B1C44),
              textColor: Colors.white,
            ),
            const SizedBox(width: 10),
            _actionButton(
              icon: Icons.call_outlined,
              label: 'Call',
              background: Colors.white,
              textColor: AppColors.text,
              borderColor: AppColors.border,
            ),
            const SizedBox(width: 10),
            _actionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              background: Colors.white,
              textColor: AppColors.text,
              borderColor: AppColors.border,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _metaCard(
              icon: Icons.phone_android_rounded,
              label: 'Mobile',
              value: mobile,
            ),
            const SizedBox(width: 12),
            _metaCard(
              icon: Icons.location_on_outlined,
              label: 'Branch',
              value: branch,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _metaCard(
              icon: Icons.calendar_today_outlined,
              label: 'Submission',
              value: submissionDate,
            ),
            const SizedBox(width: 12),
            _metaCard(
              icon: Icons.event_available_outlined,
              label: 'Appointment',
              value: appointmentDate,
            ),
          ],
        ),
        if (notes.trim().isNotEmpty && notes.trim() != '-') ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  notes,
                  style: const TextStyle(
                    color: AppColors.text,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        const Text(
          'Document Groups',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        ...groups.map((group) {
          return _groupCard(
            title: '${group['title'] ?? 'Document'}',
            progressPercent: (group['progress_percent'] ?? 0) is int
                ? group['progress_percent'] as int
                : int.tryParse('${group['progress_percent'] ?? 0}') ?? 0,
            stages: (group['stages'] as List?) ?? [],
          );
        }),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Info',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'WhatsApp: $whatsappNumber',
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                'Phone: $supportPhone',
                style: const TextStyle(color: AppColors.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}