import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/app_colors.dart';
import 'request_tracking_result_screen.dart';
import 'service_tracking_result_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final TextEditingController trackingController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? resultType;
  Map<String, dynamic>? result;

  Future<void> searchTracking() async {
    final trackingId = trackingController.text.trim();

    FocusScope.of(context).unfocus();

    if (trackingId.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a tracking ID';
        result = null;
        resultType = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
      resultType = null;
    });

    try {
      final data = await ApiService.unifiedTrack(trackingId);

      setState(() {
        resultType = '${data['data']?['type'] ?? ''}';
        result = data['data']?['payload'] ?? {};
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

  Widget buildResult() {
    if (resultType == 'service_tracking') {
      return ServiceTrackingResultScreen(data: result ?? {});
    }

    if (resultType == 'request') {
      return RequestTrackingResultScreen(data: result ?? {});
    }

    return const Center(
      child: Text(
        'No result found',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 16,
        ),
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
        title: const Text('Track Service'),
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
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchTracking(),
                decoration: InputDecoration(
                  hintText: 'Enter tracking ID',
                  prefixIcon: const Icon(Icons.search),
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
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : searchTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search'),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: errorMessage != null
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
                        ? SingleChildScrollView(child: buildResult())
                        : const Center(
                            child: Text(
                              'Enter a tracking ID and tap Search',
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