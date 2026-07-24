import 'package:flutter/material.dart';
import 'package:card_radar/services/feedback_service.dart';

class FeedbackFab extends StatelessWidget {
  const FeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'feedback_fab',
      onPressed: () => _showFeedbackSheet(context),
      tooltip: '버그/불편사항 제보',
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      child: const Icon(Icons.feedback_outlined),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _FeedbackSheet(),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _formKey = GlobalKey<FormState>();
  FeedbackType _type = FeedbackType.bug;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final result = await FeedbackService.submit(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      contact: _contactController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.isSuccess) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? result.issueNumber == null
                    ? '제보해 주셔서 감사합니다.'
                    : '제보 #${result.issueNumber}이 등록되었습니다.'
              : '제출에 실패했습니다. 입력 내용은 유지되니 잠시 후 다시 시도해 주세요.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '불편사항 / 버그 제보',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SegmentedButton<FeedbackType>(
                segments: const [
                  ButtonSegment(
                    value: FeedbackType.bug,
                    icon: Icon(Icons.bug_report_outlined),
                    label: Text('버그'),
                  ),
                  ButtonSegment(
                    value: FeedbackType.improvement,
                    icon: Icon(Icons.lightbulb_outline),
                    label: Text('불편사항'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 *',
                  hintText: '한 줄로 요약해 주세요',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? '제목을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: '내용 *',
                  hintText: '재현 방법, 발생 상황 등을 상세히 작성해 주세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (value) => value == null || value.trim().isEmpty
                    ? '내용을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: '연락처 (선택)',
                  hintText: '답변이 필요하면 이메일 등을 입력해 주세요',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
                keyboardType: TextInputType.emailAddress,
              ),
              const Text('앱 버전과 플랫폼 정보가 함께 전송되며, 연락처는 입력한 경우에만 포함됩니다.'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('제출하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
