import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/app_colors.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final TextEditingController trackingController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? result;

  Future<void> searchTracking() async {
    final trackingId = trackingController.text.trim();

    if (trackingId.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a tracking ID';
        result = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    try {
      final data = await ApiService.guestTrack(trackingId);

      setState(() {
        result = data['data'] ?? data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Track Request'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  hintText: 'Enter tracking ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: isLoading ? null : searchTracking,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => searchTracking(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : result != null
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    infoCard(
                                      'Tracking ID',
                                      '${result!['tracking_id'] ?? '-'}',
                                    ),
                                    infoCard(
                                      'Status',
                                      '${result!['status'] ?? '-'}',
                                    ),
                                    infoCard(
                                      'Owner Mode',
                                      '${result!['owner_mode'] ?? '-'}',
                                    ),
                                    infoCard(
                                      'Customer Name',
                                      '${result!['customer_name'] ?? '-'}',
                                    ),
                                    infoCard(
                                      'Email',
                                      '${result!['customer_email_masked'] ?? '-'}',
                                    ),
                                    infoCard(
                                      'Company ID',
                                      '${result!['company_id'] ?? '-'}',
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Search a tracking ID to see request status',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}