import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/views/score_verification/mock_data.dart';

enum PendingScoreCategory { examination, quarter, assessment }

/// One pending score submission awaiting verification.
///
/// A single shared model rather than three separate classes: the web's three
/// tables (Examination/Quarter/Assessment) differ by exactly one extra
/// column each — `examLabel` for examination, `sessionLabel` for assessment.
class PendingScoreItem {
  const PendingScoreItem({
    required this.className,
    required this.sectionName,
    required this.subjectName,
    required this.studentCount,
    required this.submittedAt,
    this.examLabel,
    this.sessionLabel,
  });

  final String className;
  final String sectionName;
  final String subjectName;
  final int studentCount;

  /// Pre-formatted, e.g. "17 Aug 2026 10:16 AM" — matches the mock source;
  /// no live timestamp to format since nothing is ever really submitted.
  final String submittedAt;

  /// Examination category only ("Exam" column on the web).
  final String? examLabel;

  /// Assessment category only ("Session" column on the web).
  final String? sessionLabel;
}

class ScoreVerificationController extends GetxController {
  // TODO(api): all three are static fixtures for now — there is no backend
  // endpoint for pending-score verification yet. Swap for real fetches when
  // one exists, the same way Score Entry's dropdowns are meant to be swapped.
  final RxList<PendingScoreItem> examinationItems =
      <PendingScoreItem>[...kMockPendingExaminationScores].obs;
  final RxList<PendingScoreItem> quarterItems =
      <PendingScoreItem>[...kMockPendingQuarterScores].obs;
  final RxList<PendingScoreItem> assessmentItems =
      <PendingScoreItem>[...kMockPendingAssessmentScores].obs;

  RxList<PendingScoreItem> _listFor(PendingScoreCategory category) =>
      switch (category) {
        PendingScoreCategory.examination => examinationItems,
        PendingScoreCategory.quarter => quarterItems,
        PendingScoreCategory.assessment => assessmentItems,
      };

  /// Removes the item and shows a success snackbar. No confirmation dialog:
  /// this is a low-stakes preview action over mock data, and the web itself
  /// has no confirm step on Verify/Verify All either.
  Future<void> verifyOne(
    PendingScoreCategory category,
    PendingScoreItem item,
  ) async {
    // TODO(api): POST a verify request for this one submission instead of
    // just removing it locally.
    _listFor(category).remove(item);
    _success('Verified successfully');
  }

  Future<void> verifyAll(PendingScoreCategory category) async {
    final list = _listFor(category);
    if (list.isEmpty) return;
    // TODO(api): POST a bulk-verify request instead of just clearing.
    final count = list.length;
    list.clear();
    _success(
      count == 1 ? 'Verified successfully' : 'Verified $count submissions',
    );
  }

  void _success(String message) =>
      _snack('Success', message, const Color(0xFF14925A));

  void _snack(String title, String message, Color background) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: background,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
