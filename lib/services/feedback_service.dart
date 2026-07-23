import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/supabase_config.dart';

enum FeedbackType { bug, improvement }

class FeedbackSubmissionResult {
  const FeedbackSubmissionResult({required this.isSuccess, this.issueNumber});

  final bool isSuccess;
  final int? issueNumber;
}

class FeedbackService {
  static Future<FeedbackSubmissionResult> submit({
    required String title,
    required String description,
    required FeedbackType type,
    String? contact,
  }) async {
    if (!supabaseConfigured) {
      return const FeedbackSubmissionResult(isSuccess: false);
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await Supabase.instance.client.functions.invoke(
        'submit-feedback',
        body: {
          'title': title,
          'description': description,
          'type': type.name,
          'contact': contact?.trim(),
          'appVersion': packageInfo.version,
          'platform': _platformName,
        },
      );
      final data = response.data;
      final issueNumber = data is Map<String, dynamic>
          ? data['issueNumber'] as int?
          : null;
      return FeedbackSubmissionResult(
        isSuccess: response.status == 201,
        issueNumber: issueNumber,
      );
    } catch (_) {
      return const FeedbackSubmissionResult(isSuccess: false);
    }
  }

  static String get _platformName {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.windows => 'windows',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}
