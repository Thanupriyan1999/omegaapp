import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Feedback Report'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBarChart(context, 'Breakfast'),
            _buildBarChart(context, 'Lunch'),
            _buildBarChart(context, 'Dinner'),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, String mealType) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('feedback')
          .where('mealType', isEqualTo: mealType)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
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
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();

        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 16),
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
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // Reserve space to show labels fully
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  ratingCounts.keys.toList()[value.toInt()],
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the left titles
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the right titles
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the top titles
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.teal[800],
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${ratingCounts.keys.toList()[group.x.toInt()]}\n',
                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '${rod.toY.toString()} feedback(s)',
                                  style: TextStyle(
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
                _buildRatingCountsAboveBars(ratingCounts),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingCountsAboveBars(Map<String, int> ratingCounts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ratingCounts.entries.map((entry) {
        return Column(
          children: [
            Text(
              entry.value.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              entry.key,
              style: TextStyle(fontSize: 14, color: _getBarColor(entry.key)),
            ),
          ],
        );
      }).toList(),
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