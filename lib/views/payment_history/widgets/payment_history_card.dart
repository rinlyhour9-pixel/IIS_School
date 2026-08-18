import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:schoolapp/core/configs/app_style.dart';
import 'package:schoolapp/core/resources/locales.g.dart';
import 'package:schoolapp/models/payment_history/model.dart';

class PaymentHistoryCard extends StatelessWidget {
  final PaymentHistoryItem item;
  final String studentName;
  final VoidCallback? onTap;
  final bool isLoading;

  const PaymentHistoryCard({
    super.key,
    required this.item,
    required this.studentName,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final due = _toNum(item.dueAmount);
    final statusLabel = due <= 0 ? LocaleKeys.paid.tr : LocaleKeys.unpaid.tr;
    final statusBg =
        due <= 0 ? const Color(0xFFC8F0D2) : const Color(0xFFFFD8D8);
    final statusText =
        due <= 0 ? const Color(0xFF1B8F3A) : const Color(0xFFD83232);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    studentName.isEmpty ? 'Student' : studentName,
                    style: AppTextStyle.regularPrimaryBoldblack,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatDate(item.paymentDate),
                  style: AppTextStyle.smallRegular,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LocaleKeys.invoiceLabel.tr} ${item.invoiceNo}',
                    style: AppTextStyle.smallPrimarytextgrey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (isLoading) const SizedBox(width: 8),
                _amountBadge('\$${item.grandTotal}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(value, style: AppTextStyle.regularPrimarytext),
    );
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw.trim());
    if (date == null) return raw;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  num _toNum(String value) {
    return num.tryParse(value.trim()) ?? 0;
  }
}
