import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schoolapp/models/requestleave/model.dart';

class AllRequestleaveControlller extends GetxController {
  var selectedClass = "ថ្នាក់ទី ៥".obs;
  var selectedShift = "".obs;
  var leaveType = "".obs;

  var dateStart = "".obs;
  var dateEnd = "".obs;

  TextEditingController reasonController = TextEditingController();

  List<String> classes = [
    "ថ្នាក់ទី ១",
    "ថ្នាក់ទី ២",
    "ថ្នាក់ទី ៣",
    "ថ្នាក់ទី ៤",
    "ថ្នាក់ទី ៥",
    "ថ្នាក់ទី ៦",
  ];

  RequestLeaveModel buildRequest() {
    return RequestLeaveModel(
      dateStart: dateStart.value,
      dateEnd: dateEnd.value,
      leaveType: leaveType.value,
      reason: reasonController.text,
    );
  }

  Future<void> pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String date = picked.toString().split(" ")[0];
      if (isStart) {
        dateStart.value = date;
      } else {
        dateEnd.value = date;
      }
    }
  }
}
