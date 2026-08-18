import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/models/payment_history/model.dart';
import 'package:schoolapp/views/payment_history/controller.dart';
import 'package:schoolapp/views/payment_history/invoice_detail_view.dart';
import 'package:schoolapp/views/payment_history/widgets/payment_history_card.dart';
import 'package:schoolapp/views/payment_history/widgets/payment_status_tab_bar.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  late final PaymentHistoryController controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PaymentHistoryController>();
    _pageController = PageController(
      initialPage: controller.selectedStatusTab.value,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<PaymentHistoryItem> _filterPayments(
    List<PaymentHistoryItem> source,
    int tabIndex,
  ) {
    num parseNum(String raw) {
      final normalized = raw.trim().replaceAll(',', '');
      final matched = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
      return num.tryParse(matched?.group(0) ?? '0') ?? 0;
    }

    return source
        .where((item) {
          final total = parseNum(item.grandTotal);
          if (total <= 0) return false;
          final due = parseNum(item.dueAmount);
          if (tabIndex == 1) return due <= 0;
          if (tabIndex == 2) return due > 0;
          return true;
        })
        .toList(growable: false);
  }

  Widget _buildPaymentList(List<PaymentHistoryItem> visiblePayments) {
    if (controller.isLoading.value && controller.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error.value.isNotEmpty && visiblePayments.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              controller.error.value,
              style: AppTextStyle.normalRedRegular,
            ),
          ),
        ],
      );
    }

    if (visiblePayments.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              LocaleKeys.noPaymentHistoryFound.tr,
              style: AppTextStyle.smallGreyRegular,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: visiblePayments.length,
      itemBuilder: (context, index) {
        final item = visiblePayments[index];
        return PaymentHistoryCard(
          item: item,
          studentName: item.displayStudentName,
          isLoading:
              controller.isLoadingInvoice.value &&
              controller.loadingInvoiceId.value == item.id,
          onTap: () async {
            final paymentId = item.id;
            if (controller.isLoadingInvoice.value) {
              return;
            }
            await controller.fetchInvoiceDetails(paymentId);
            if (controller.selectedInvoice.value != null) {
              Get.to(() => const InvoiceDetailView());
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.payments.tr)),
      body: RefreshIndicator(
        onRefresh: controller.fetchPaymentHistory,
        child: Obx(() {
          final selectedTab = controller.selectedStatusTab.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PaymentStatusTabBar(
                  selectedIndex: selectedTab,
                  onChanged: (index) {
                    controller.selectedStatusTab.value = index;
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    controller.selectedStatusTab.value = index;
                  },
                  children: [
                    _buildPaymentList(_filterPayments(controller.payments, 0)),
                    _buildPaymentList(_filterPayments(controller.payments, 1)),
                    _buildPaymentList(_filterPayments(controller.payments, 2)),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
