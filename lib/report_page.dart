import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Feedback Report'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Date Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select Date:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                ),
              ],
            ),
            _buildBarChart(context, 'Breakfast', 80.0, 300.0),
            _buildBarChart(context, 'Lunch', 80.0, 300.0),
            _buildBarChart(context, 'Dinner', 80.0, 300.0),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget _buildBarChart(BuildContext context, String mealType, double spacing, double chartHeight) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('feedback')
          .where('mealType', isEqualTo: mealType)
          .where('date', isEqualTo: "${selectedDate.toLocal()}".split(' ')[0]) // Filter by date
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbackDocs = snapshot.data!.docs;
        final Map<String, int> ratingCounts = {
          'Excellent': 0,
          'Good': 0,
          'Average': 0,
          'Bad': 0,
          'Very Bad': 0,
        };

        for (var doc in feedbackDocs) {
          final rating = doc['rating'];
          if (ratingCounts.containsKey(rating)) {
            ratingCounts[rating] = ratingCounts[rating]! + 1;
          }
        }

        final List<BarChartGroupData> barGroups = ratingCounts.entries.map((entry) {
          final int index = ratingCounts.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: _getBarColor(entry.key),
                width: 20,
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();

        return Card(
          elevation: 20,
          margin: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '$mealType Feedback',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: chartHeight,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  ratingCounts.keys.toList()[value.toInt()],
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${ratingCounts.keys.toList()[group.x.toInt()]}\n',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '${rod.toY.toString()} feedback(s)',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                          if (response != null && response.spot != null && event is! FlLongPressEnd && event is! FlPanEndEvent) {
                            final xValue = response.spot!.touchedBarGroup.x;
                            final count = ratingCounts.values.elementAt(xValue);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Total feedback: $count'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBarColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return const Color.fromARGB(255, 19, 245, 26);
      case 'Good':
        return const Color.fromARGB(255, 109, 179, 29);
      case 'Average':
        return Colors.yellow;
      case 'Bad':
        return const Color.fromARGB(255, 255, 153, 0);
      case 'Very Bad':
        return const Color.fromARGB(255, 241, 23, 7);
      default:
        return Colors.grey;
    }
  }
}
