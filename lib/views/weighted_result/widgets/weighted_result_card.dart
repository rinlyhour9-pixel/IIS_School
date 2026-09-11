import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/weighted_result/controller.dart';

/// Adapts the web's top-right "Weights:" badge cluster to a full-width
/// wrapping row — 10 badges won't fit one line on a phone.
class WeightsSummary extends StatelessWidget {
  const WeightsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.weightedResultWeightsLabel.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final criterion in kWeightCriteria)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    '${criterion.labelKey.tr}: ${criterion.weightPercent}%',
                    style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeightedResultCard extends StatelessWidget {
  const WeightedResultCard({super.key, required this.item});

  final WeightedResultItem item;

  @override
  Widget build(BuildContext context) {
    final resultColor =
        item.result.trim().toLowerCase() == 'pass'
            ? const Color(0xFF14925A)
            : const Color(0xFFD32F2F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.studentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryText,
                  ),
                ),
              ),
              Text(
                LocaleKeys.score.tr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${LocaleKeys.weightedResultAdmissionNo.tr}: ${item.admissionNo}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          for (final criterion in kWeightCriteria)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${criterion.labelKey.tr} (${criterion.weightPercent}%)',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  Text(
                    // The web renders each criterion as a percentage of its
                    // max, not the raw out-of-5 value — confirmed against a
                    // real row (100/60/80/... averaging to exactly the
                    // displayed Weighted %).
                    '${(((item.criteriaScores[criterion.key] ?? 0) / criterion.maxScore) * 100).round()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryStat(
                    LocaleKeys.weightedResultWeightedPercent.tr,
                    '${item.weightedPercent.toStringAsFixed(0)}%',
                    resultColor,
                  ),
                ),
                Expanded(
                  child: _summaryStat(
                    LocaleKeys.weightedResultGrade.tr,
                    item.grade,
                    resultColor,
                  ),
                ),
                Expanded(
                  child: _summaryStat(
                    LocaleKeys.weightedResultGpa.tr,
                    item.gpa.toStringAsFixed(1),
                    resultColor,
                  ),
                ),
                Expanded(
                  child: _summaryStat(
                    LocaleKeys.weightedResultResult.tr,
                    item.result,
                    resultColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
