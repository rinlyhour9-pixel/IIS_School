import 'package:flutter/material.dart';

class StudentDocumentWidget extends StatelessWidget {
  const StudentDocumentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),

            const SizedBox(height: 20),

            _buildScoreTable(),

            const SizedBox(height: 20),

            _buildSummarySection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Circular Borders
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF006D5B), width: 2),
            ),
            child: const CircleAvatar(
              radius: 35,
              //backgroundImage: AssetImage('assets/images/user_kid.jpg'),
              backgroundImage: NetworkImage(
                'https://img.freepik.com/free-photo/view-child-hair-salon_23-2150462483.jpg',
              ),
            ),
          ),
          const SizedBox(width: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'ឈ្មោះ: ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'សិន ដារ៉ា',
                      style: TextStyle(
                        color: Color(0xFF006D5B),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'ភេទ: ប្រុស  /  ថ្នាក់ទី: ៧ "A"',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              const Text(
                'លេខសម្គាល់: SC123',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'មុខវិជ្ជា',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'ពិន្ទុ(%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'ស្ថានភាព',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          _scoreRow('គណិតវិទ្យា', '៨៥%', 'ល្អណាស់', Colors.green),
          _scoreRow('ភាសាខ្មែរ', '៩០%', 'ល្អបំផុត', Colors.green),
          _scoreRow('អង់គ្លេស', '៦៧%', 'មធ្យម', Colors.orange),
          _scoreRow('ប្រវត្តិវិទ្យា', '៨១%', 'ល្អ', Colors.green),
          _scoreRow('ជីវវិទ្យា', '៧៦%', 'ល្អ', Colors.green),
          _scoreRow('គីមីវិទ្យា', '៦៦%', 'មធ្យម', Colors.orange),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _scoreRow(
    String subject,
    String score,
    String status,
    Color statusColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(subject, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: Center(
                  child: Text(score, style: const TextStyle(fontSize: 13)),
                ),
              ),
              Expanded(
                child: Text(
                  status,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'សង្ខេបឥរិយាបថ',
          style: TextStyle(
            color: Color(0xFF006D5B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'វត្តមាន៖',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              'ខែមីនា',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const Divider(),
        // Attendance stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statItem('មកេរៀនចំនួន', '២៤ដង', Colors.green),
            _statItem('មានច្បាប់', '១ដង', Colors.purple),
            _statItem('អត់ច្បាប់ចំនួន', '៣ដង', Colors.red),
            _statItem('មកយឺត', '២ដង', Colors.orange),
          ],
        ),
        const SizedBox(height: 20),
        _buildSimpleRow('បញ្ហារឥរិយាបថ៖', 'សមរម្យ', Colors.green),
        const Divider(),
        _buildSimpleRow('ការចូលរួមក្នុងថ្នាក់៖', 'មធ្យម', Colors.orange),
        const Divider(),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
