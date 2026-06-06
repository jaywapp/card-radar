import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:card_radar/core/github_config.dart';

enum FeedbackType { bug, improvement }

class FeedbackService {
  static const _repo = 'jaywapp/card-radar';

  static Future<bool> submit({
    required String title,
    required String description,
    required FeedbackType type,
  }) async {
    if (githubIssueToken.isEmpty) return false;
    try {
      final label = type == FeedbackType.bug ? 'bug' : 'enhancement';
      final body = '''**유형**: ${type == FeedbackType.bug ? '🐛 버그' : '💡 불편사항'}

**내용**:
$description

---
*앱에서 직접 제보된 이슈입니다.*''';

      final response = await http.post(
        Uri.parse('https://api.github.com/repos/$_repo/issues'),
        headers: {
          'Authorization': 'Bearer $githubIssueToken',
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'labels': [label],
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
