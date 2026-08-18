import 'package:flutter/material.dart';
import 'package:schoolapp/core/widgets/month_filter_dropdown.dart';
import 'package:schoolapp/views/start/widgets/custom_indicator.dart';

class StandingsCardWidget extends StatefulWidget {
  const StandingsCardWidget({super.key});

  @override
  State<StandingsCardWidget> createState() => _StandingsCardWidgetState();
}

class _StandingsCardWidgetState extends State<StandingsCardWidget> {
  static const List<String> _months = <String>[
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  static const List<String> _terms = <String>[
    'ឆមាស ១',
    'ឆមាស ២',
  ];

  static const List<String> _years = <String>[
    '២០២៥',
    '២០២៦',
    '២០២៧',
  ];

  String _selectedMonth = _months.first;
  String _selectedTerm = _terms.last;
  String _selectedYear = _years[1];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CustomIndicator(progress: 1 / 4),
          ),
          const SizedBox(height: 12),
          _buildStudentHeader('សុខ សាន្ត - ថ្នាក់ ៧ "ក"'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallDropdown(
                value: _selectedMonth,
                items: _months,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedMonth = value);
                },
                isMonth: true,
              ),
              const SizedBox(width: 8),
              _buildSmallDropdown(
                value: _selectedTerm,
                items: _terms,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedTerm = value);
                },
              ),
              const SizedBox(width: 8),
              _buildSmallDropdown(
                value: _selectedYear,
                items: _years,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedYear = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00675B), width: 1.5),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                _buildScoreRow('អក្សរសាស្ត្រខ្មែរ', '៨០', 'ល្អ', Colors.green),
                _buildScoreRow('គណិតវិទ្យា', '៧០', 'ល្អ', Colors.green),
                _buildScoreRow('សិក្សាសង្គម', '៣០', 'គួរកែលម្អ', Colors.red),
                _buildScoreRow(
                  'វិទ្យាសាស្ត្រ',
                  '៥០',
                  'ព្យាយាមបន្ថែម',
                  Colors.orange,
                ),
                _buildScoreRow('ភាសាអង់គ្លេស', '៩០', 'ល្អណាស់', Colors.teal),
                _buildTableFooter('សរុប', '៣២០', '១២'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00675B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSmallDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isMonth = false,
  }) {
    return Expanded(
      child:
          isMonth
              ? MonthFilterDropdown(
                months: items,
                selectedMonth: value,
                onSelected: (selected) => onChanged(selected),
                showFilterIcon: false,
                borderColor: Colors.grey.shade300,
                backgroundColor: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 220,
                    borderRadius: BorderRadius.circular(10),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                    items:
                        items
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF00675B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'មុខវិជ្ជា',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ពិន្ទុ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ចំណាត់ថ្នាក់',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    String subject,
    String score,
    String grade,
    Color gradeColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              score,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              grade,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableFooter(String label, String totalScore, String rank) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF00675B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              totalScore,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rank,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
