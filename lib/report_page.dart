import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Map<String, int> _breakfastData = {'Bad': 0, 'Good': 0, 'Excellent': 0};
  Map<String, int> _lunchData = {'Bad': 0, 'Good': 0, 'Excellent': 0};
  Map<String, int> _dinnerData = {'Bad': 0, 'Good': 0, 'Excellent': 0};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('feedback').get();

    final breakfastData = <String, int>{'Bad': 0, 'Good': 0, 'Excellent': 0};
    final lunchData = <String, int>{'Bad': 0, 'Good': 0, 'Excellent': 0};
    final dinnerData = <String, int>{'Bad': 0, 'Good': 0, 'Excellent': 0};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      breakfastData[data['breakfast']] =
          (breakfastData[data['breakfast']] ?? 0) + 1;
      lunchData[data['lunch']] = (lunchData[data['lunch']] ?? 0) + 1;
      dinnerData[data['dinner']] = (dinnerData[data['dinner']] ?? 0) + 1;
    }

    setState(() {
      _breakfastData = breakfastData;
      _lunchData = lunchData;
      _dinnerData = dinnerData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Breakfast Feedback', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(_breakfastData),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Lunch Feedback', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(_lunchData),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Dinner Feedback', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(_dinnerData),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data) {
    final total = data.values.fold(0, (sum, count) => sum + count);

    return data.entries.map((entry) {
      final percentage = total == 0 ? 0 : (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
        color: _getColorForCategory(entry.key),
        radius: 100,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Bad':
        return Colors.red;
      case 'Good':
        return Colors.green;
      case 'Excellent':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
