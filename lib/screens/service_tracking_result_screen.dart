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

  Widget _metaItem(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                fontSize: 15,
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
    VoidCallback? onTap,
    Color borderColor = Colors.transparent,
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
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageRow(String stageName, String stageStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              stageName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusBg(stageStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stageStatus,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _statusText(stageStatus),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (progressPercent.clamp(0, 100)) / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8EDF3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF081B45)),
            ),
          ),
          const SizedBox(height: 18),
          ...stages.map((stage) {
            return _stageRow(
              '${stage['name'] ?? '-'}',
              '${stage['status'] ?? '-'}',
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
    final progress = (data['overall_progress_percent'] ?? 0) is int
        ? data['overall_progress_percent'] as int
        : int.tryParse('${data['overall_progress_percent'] ?? 0}') ?? 0;
    final groups = (data['groups'] as List?) ?? [];

    return Column(
      children: [
        Container(
          width: double.infinity,
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
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
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
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Tracking ID: $trackingId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(status),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _statusText(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Overall progress',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (progress.clamp(0, 100)) / 100,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE8EDF3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF081B45)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _actionButton(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    background: const Color(0xFF081B45),
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
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDF',
                    background: Colors.white,
                    textColor: AppColors.text,
                    borderColor: AppColors.border,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _metaItem('Mobile', mobile),
                  _metaItem('Branch', branch),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _metaItem('Submission', submissionDate),
                  _metaItem('Appointment', appointmentDate),
                ],
              ),
              if (notes.trim().isNotEmpty && notes.trim() != '-') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    notes,
                    style: const TextStyle(
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...groups.map((group) {
          return _groupCard(
            title: '${group['title'] ?? 'Document'}',
            progressPercent: (group['progress_percent'] ?? 0) is int
                ? group['progress_percent'] as int
                : int.tryParse('${group['progress_percent'] ?? 0}') ?? 0,
            stages: (group['stages'] as List?) ?? [],
          );
        }),
      ],
    );
  }
}