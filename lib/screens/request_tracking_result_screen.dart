import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

class RequestTrackingResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RequestTrackingResultScreen({
    super.key,
    required this.data,
  });

  @override
  State<RequestTrackingResultScreen> createState() =>
      _RequestTrackingResultScreenState();
}

class _RequestTrackingResultScreenState
    extends State<RequestTrackingResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _isBlank(dynamic value) {
    if (value == null) return true;
    final s = '$value'.trim();
    return s.isEmpty || s == '-' || s.toLowerCase() == 'null';
  }

  String _firstValue(List<String> keys, {String fallback = '-'}) {
    for (final key in keys) {
      if (!_isBlank(widget.data[key])) return '${widget.data[key]}'.trim();
    }
    return fallback;
  }

  List<dynamic> _firstList(List<String> keys) {
    for (final key in keys) {
      final value = widget.data[key];
      if (value is List && value.isNotEmpty) return value;
    }
    return const [];
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('${value ?? 0}') ?? 0;
  }

  Color _statusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFFE5F6EA);
    if (s.contains('progress')) return const Color(0xFFE6EEFF);
    if (s.contains('pending') || s.contains('new')) return const Color(0xFFF0F1F5);
    return const Color(0xFFF2F4F7);
  }

  Color _statusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFF18864F);
    if (s.contains('progress')) return const Color(0xFF2F6FED);
    if (s.contains('pending') || s.contains('new')) return const Color(0xFF6B7280);
    return AppColors.text;
  }

  bool _isPending(String status) {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('new');
  }

  bool _isCurrent(String status) {
    final s = status.toLowerCase();
    return s.contains('progress');
  }

  bool _isCompleted(String status) {
    return status.toLowerCase().contains('complete');
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking ID copied')),
    );
  }

  String _joinDateTime(Map<String, dynamic> stage) {
    final date = _pickStageValue(stage, const [
      'completed_date',
      'updated_date',
      'date',
      'stage_date',
      'created_at',
      'datetime',
      'timestamp'
    ]);
    final time = _pickStageValue(stage, const [
      'completed_time',
      'updated_time',
      'time',
      'stage_time'
    ]);

    if (_isPending('${stage['status'] ?? ''}')) return 'Pending';
    if (_isBlank(date) && _isBlank(time)) return 'In progress';
    if (_isBlank(time)) return date;
    if (_isBlank(date)) return time;
    return '$date, $time';
  }

  String _pickStageValue(Map<String, dynamic> stage, List<String> keys) {
    for (final key in keys) {
      final value = stage[key];
      if (!_isBlank(value)) return '$value'.trim();
    }
    return '';
  }

  List<String> _stageNotes(Map<String, dynamic> stage) {
    final rawCandidates = [
      stage['notes'],
      stage['customer_notes'],
      stage['stage_notes'],
      stage['messages'],
    ];

    for (final raw in rawCandidates) {
      if (raw is List) {
        return raw
            .where((e) => !_isBlank(e is Map ? e['note'] ?? e['message'] ?? e['text'] : e))
            .map((e) => e is Map
                ? '${e['note'] ?? e['message'] ?? e['text']}'.trim()
                : '$e'.trim())
            .toList();
      }
      if (!_isBlank(raw)) return ['${raw}'.trim()];
    }

    return const [];
  }

  Widget _metaCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B93A0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _statusText(status),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _noteBubble(String note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3ECF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE8F7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 13, color: Color(0xFF6883A8)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(Map<String, dynamic> stage, bool isLast) {
    final title = _pickStageValue(stage, const ['name', 'stage_name', 'title']);
    final status = _pickStageValue(stage, const ['status', 'stage_status']);
    final subtitle = _joinDateTime(stage);
    final notes = _stageNotes(stage);
    final current = _isCurrent(status);
    final completed = _isCompleted(status);
    final pending = _isPending(status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = current ? 1 + (_pulseController.value * 0.16) : 1.0;
                    final glow = current ? 0.22 + (_pulseController.value * 0.18) : 0.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed || current
                              ? const Color(0xFF3A2412)
                              : Colors.white,
                          border: Border.all(
                            color: completed || current
                                ? const Color(0xFF3A2412)
                                : const Color(0xFFD8D1C8),
                            width: 3,
                          ),
                          boxShadow: current
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF3A2412).withOpacity(glow),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: completed || current
                          ? const Color(0xFF7D5A3A)
                          : const Color(0xFFE3DDD4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.isEmpty ? '-' : title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: pending
                                    ? const Color(0xFF8D95A1)
                                    : AppColors.text,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: pending
                                    ? const Color(0xFF9DA5B1)
                                    : const Color(0xFF7A8594),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _statusPill(status.isEmpty ? 'Pending' : status),
                    ],
                  ),
                  if (notes.isNotEmpty) ...notes.map(_noteBubble),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingId = _firstValue(const ['tracking_id']);
    final status = _firstValue(const ['status'], fallback: 'Pending');
    final customerName = _firstValue(
      const [
        'customer_name',
        'company_name',
        'company_customer_name',
        'display_name',
        'title'
      ],
    );
    final requestTitle = _firstValue(
      const ['request_title', 'title', 'request_type', 'type_name'],
      fallback: '-',
    );
    final requestDate = _firstValue(
      const ['request_date', 'created_at_display', 'created_at', 'date'],
      fallback: '-',
    );
    final crNumber = _firstValue(
      const ['cr_number', 'company_cr_number', 'company_id'],
      fallback: '',
    );
    final assignedStaff = _firstValue(
      const ['assigned_staff', 'assigned_staff_name', 'staff_name'],
      fallback: '',
    );
    final progress = _asInt(widget.data['overall_progress_percent']);
    final message = _firstValue(const ['message', 'customer_note'], fallback: '');
    final stages = _firstList(const ['stages', 'timeline', 'progress_stages']);

    final meta = <Map<String, String>>[
      {'label': 'Request Date', 'value': requestDate},
      {'label': 'Request Title', 'value': requestTitle},
      if (!_isBlank(crNumber)) {'label': 'CR Number', 'value': crNumber},
      if (!_isBlank(assignedStaff)) {'label': 'Assigned Staff', 'value': assignedStaff},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF241200), Color(0xFF7B4316)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _copy(context, trackingId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                'Tracking ID: $trackingId',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
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
                  ),
                  const SizedBox(width: 12),
                  _statusPill(status),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Overall progress',
                style: TextStyle(
                  color: Color(0xFFF5F1EB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 100) / 100,
                        minHeight: 12,
                        backgroundColor: const Color(0xFF9B724C),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (!_isBlank(message)) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFF2DCC8),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: meta
                .map(
                  (item) => SizedBox(
                    width: MediaQuery.of(context).size.width > 420
                        ? (MediaQuery.of(context).size.width - 70) / 3
                        : (MediaQuery.of(context).size.width - 60) / 2,
                    child: _metaCard(label: item['label']!, value: item['value']!),
                  ),
                )
                .toList(),
          ),
        ),
        Container(
          height: 1,
          color: AppColors.border,
        ),
        const SizedBox(height: 14),
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
                  const Expanded(
                    child: Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 100) / 100,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8DED2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF3A2412)),
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(stages.length, (index) {
                final stage = stages[index] is Map<String, dynamic>
                    ? stages[index] as Map<String, dynamic>
                    : <String, dynamic>{};
                return _timelineItem(stage, index == stages.length - 1);
              }),
            ],
          ),
        ),
      ],
    );
  }
}
