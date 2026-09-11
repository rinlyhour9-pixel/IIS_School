import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/score_verification/controller.dart';

/// Same orange already used for the Class Schedule tabs
/// (schedule_card.dart) — reused here for "View" rather than a new one-off
/// color, to visually distinguish it from the green "Verify" as on the web.
const Color _viewAccent = Color(0xFFF2993F);

/// One category's block: title + description, a "Verify All" button when
/// there's something to act on, then either the empty message or a card per
/// pending item.
class PendingScoreSection extends StatelessWidget {
  const PendingScoreSection({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.items,
    required this.controller,
  });

  final PendingScoreCategory category;
  final String title;
  final String description;
  final List<PendingScoreItem> items;
  final ScoreVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => controller.verifyAll(category),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    side: const BorderSide(color: AppColor.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: Text(
                    LocaleKeys.scoreVerificationVerifyAll.tr,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  LocaleKeys.scoreVerificationNothingPending.tr,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final item in items) ...[
                  _PendingScoreCard(
                    category: category,
                    item: item,
                    controller: controller,
                  ),
                  if (item != items.last) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PendingScoreCard extends StatelessWidget {
  const _PendingScoreCard({
    required this.category,
    required this.item,
    required this.controller,
  });

  final PendingScoreCategory category;
  final PendingScoreItem item;
  final ScoreVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.examLabel != null)
            _fieldRow(LocaleKeys.scoreVerificationExam.tr, item.examLabel!),
          _fieldRow(LocaleKeys.classLabel.tr, item.className),
          _fieldRow(LocaleKeys.section.tr, item.sectionName),
          _fieldRow(LocaleKeys.subject.tr, item.subjectName),
          if (item.sessionLabel != null)
            _fieldRow(
              LocaleKeys.scoreVerificationSession.tr,
              item.sessionLabel!,
            ),
          _fieldRow(
            LocaleKeys.scoreVerificationStudents.tr,
            item.studentCount.toString(),
          ),
          _fieldRow(LocaleKeys.scoreVerificationSubmitted.tr, item.submittedAt),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDetail(context),
                  style: OutlinedButton.styleFrom(
                    // Matches the web's amber "View" vs green "Verify" —
                    // same orange already used for the Class Schedule tabs
                    // (schedule_card.dart), not a new one-off color.
                    foregroundColor: _viewAccent,
                    side: const BorderSide(color: _viewAccent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(LocaleKeys.scoreVerificationView.tr),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.verifyOne(category, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(LocaleKeys.scoreVerificationVerify.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.scoreVerificationView.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (item.examLabel != null)
                _fieldRow(LocaleKeys.scoreVerificationExam.tr, item.examLabel!),
              _fieldRow(LocaleKeys.classLabel.tr, item.className),
              _fieldRow(LocaleKeys.section.tr, item.sectionName),
              _fieldRow(LocaleKeys.subject.tr, item.subjectName),
              if (item.sessionLabel != null)
                _fieldRow(
                  LocaleKeys.scoreVerificationSession.tr,
                  item.sessionLabel!,
                ),
              _fieldRow(
                LocaleKeys.scoreVerificationStudents.tr,
                item.studentCount.toString(),
              ),
              _fieldRow(
                LocaleKeys.scoreVerificationSubmitted.tr,
                item.submittedAt,
              ),
            ],
          ),
        );
      },
    );
  }
}
