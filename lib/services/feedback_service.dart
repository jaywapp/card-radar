import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/supabase_config.dart';

enum FeedbackType { bug, improvement }

class FeedbackService {
  static Future<bool> submit({
    required String title,
    required String description,
    required FeedbackType type,
  }) async {
    if (!supabaseConfigured) return false;
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'submit-feedback',
        body: {
          'title': title,
          'description': description,
          'type': type.name,
        },
      );
      return response.status == 201;
    } catch (_) {
      return false;
    }
  }
}
