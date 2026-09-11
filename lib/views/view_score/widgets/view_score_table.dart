import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/views/score_entry/widgets/score_layout.dart'
    show
        kHeaderHeight,
        kScrollbarLaneHeight,
        kStudentColWidth,
        MaxScoreInputFormatter,
        scrollableWidthFor;
import 'package:schoolapp/views/view_score/controller.dart';
import 'package:schoolapp/views/weighted_result/controller.dart'
    show WeightCriterion, kWeightCriteria;

/// Frozen left column is wider than Score Entry's `kSubjectColWidth` (116) —
/// criterion labels are longer than subject names, and each row also
/// carries a small "(out of N)" caption underneath, matching Assessment
/// Management's table.
const double kCriterionColWidth = 150;

/// A criterion row's height — label (up to 2 lines) plus a small
/// "(out of N)" caption underneath.
const double kCriterionRowHeight = 80;

/// The raw per-criterion score sheet.
///
/// The 10 behaviour criteria run down the frozen left column; each student
/// is a column inside a single horizontal scroll view — the same
/// frozen-column/scrolling-students layout as Assessment Management's table,
/// since this screen is strictly the raw inputs (no summary footer — that's
/// Weighted Result's job).
///
/// StatefulWidget because it owns the horizontal ScrollController — hanging
/// that on the GetX controller risks `Scrollbar` asserting on a detached
/// controller across route transitions.
class ViewScoreTable extends StatefulWidget {
  const ViewScoreTable({super.key, required this.items});

  final List<ViewScoreItem> items;

  @override
  State<ViewScoreTable> createState() => _ViewScoreTableState();
}

class _ViewScoreTableState extends State<ViewScoreTable> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableHeight =
        kHeaderHeight +
        (kWeightCriteria.length * kCriterionRowHeight) +
        kScrollbarLaneHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CriterionColumn(),
            // Sells the "frozen" affordance — without it the pinned block
            // reads as part of the scrolling table.
            Container(width: 1, height: tableHeight, color: AppColor.divider),
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: scrollableWidthFor(widget.items.length),
                    child: _StudentColumns(items: widget.items),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frozen left column: an empty corner cell, then one label + "(out of N)"
/// caption per criterion.
class _CriterionColumn extends StatelessWidget {
  const _CriterionColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kCriterionColWidth,
      child: Column(
        children: [
          // Empty corner above the criterion labels, matching header height.
          Container(
            height: kHeaderHeight,
            decoration: const BoxDecoration(
              color: AppColor.backgroundColor,
              border: Border(bottom: BorderSide(color: AppColor.divider)),
            ),
          ),
          ...kWeightCriteria.map(
            (criterion) => Container(
              height: kCriterionRowHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColor.backgroundColor,
                border: Border(bottom: BorderSide(color: AppColor.divider)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    criterion.labelKey.tr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.normalPrimarySemiBold,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(out of ${criterion.maxScore})',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.smallGreyRegular,
                  ),
                ],
              ),
            ),
          ),
          // Matches the scrollbar lane on the scrolling side.
          const SizedBox(height: kScrollbarLaneHeight),
        ],
      ),
    );
  }
}

/// Scrolling right side: one column per student, each with a three-line
/// header (admission no, name, gender) above its score cells.
class _StudentColumns extends StatelessWidget {
  const _StudentColumns({required this.items});

  final List<ViewScoreItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: kHeaderHeight,
          child: Row(
            // Row defaults to centering children on the cross axis, which
            // would let each cell's own (shorter) intrinsic height float in
            // the middle of this fixed-height slot — its border then only
            // wraps its own content instead of reaching the true row
            // boundary, visibly misaligning against the frozen column's
            // dividers (which use an explicit height, not centering).
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                items.map((item) => _StudentHeaderCell(item: item)).toList(),
          ),
        ),
        ...kWeightCriteria.map(
          (criterion) => SizedBox(
            height: kCriterionRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  items
                      .map(
                        (item) => _ScoreCell(item: item, criterion: criterion),
                      )
                      .toList(),
            ),
          ),
        ),
        // Lane for the always-visible horizontal scrollbar.
        const SizedBox(height: kScrollbarLaneHeight),
      ],
    );
  }
}

class _StudentHeaderCell extends StatelessWidget {
  const _StudentHeaderCell({required this.item});

  final ViewScoreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kStudentColWidth,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
        border: Border(
          right: BorderSide(color: AppColor.divider),
          bottom: BorderSide(color: AppColor.divider),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.admissionNo,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.smallGreyRegular,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              item.studentName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.normalPrimarySemiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.gender,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.smallGreyRegular,
          ),
        ],
      ),
    );
  }
}

/// A single editable score cell for one (student, criterion) pair.
///
/// Deliberately has no `Obx`: the item's TextEditingController is the source
/// of truth and `TextField` listens to it internally, so typing rebuilds
/// nothing above `EditableText`.
class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.item, required this.criterion});

  final ViewScoreItem item;
  final WeightCriterion criterion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kStudentColWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // Now that the row's Row stretches this cell to the full row height,
      // a Container with no alignment leaves its child pinned to the top
      // instead of centering in the extra space.
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColor.divider),
          bottom: BorderSide(color: AppColor.divider),
        ),
      ),
      child: TextField(
        controller: item.controllerFor(criterion.key),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          MaxScoreInputFormatter(criterion.maxScore),
        ],
        style: AppTextStyle.smallRegular,
        decoration: InputDecoration(
          isDense: true,
          hintText: '-',
          filled: true,
          fillColor: AppColor.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColor.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColor.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColor.divider),
          ),
        ),
      ),
    );
  }
}
