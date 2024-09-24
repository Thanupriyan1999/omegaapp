import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:excel/excel.dart'; // Excel package for exporting data
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For getting external storage directory

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Breakfast'; // Default to 'Breakfast'
  Map<String, int> ratingCounts = {
    'Excellent': 0,
    'Good': 0,
    'Average': 0,
    'Bad': 0,
    'Very Bad': 0,
  };

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
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(
                'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateSelectedMealType('Breakfast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMealType == 'Breakfast' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Breakfast'),
                ),
                ElevatedButton(
                  onPressed: () => _updateSelectedMealType('Lunch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMealType == 'Lunch' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Lunch'),
                ),
                ElevatedButton(
                  onPressed: () => _updateSelectedMealType('Dinner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMealType == 'Dinner' ? Colors.teal : Colors.grey,
                  ),
                  child: const Text('Dinner'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBarChart(context, _selectedMealType, 80.0, 300.0),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportDataToExcel,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Export to Excel'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSelectedMealType(String mealType) {
    setState(() {
      _selectedMealType = mealType;
    });
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildBarChart(BuildContext context, String mealType, double spacing, double chartHeight) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('feedback')
          .where('mealType', isEqualTo: mealType)
          .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate)) // Filter by selected date
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbackDocs = snapshot.data!.docs;
        ratingCounts = {
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
                SizedBox(height: spacing), // Adjustable space between the heading and the chart
                SizedBox(
                  height: chartHeight,  // Adjustable chart height
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
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the left titles
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the right titles
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hides the top titles
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

Future<void> _exportDataToExcel() async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];

  // Adding headers: Date, Rating, Breakfast, Lunch, Dinner
  sheetObject.appendRow(['Date', 'Rating', 'Breakfast', 'Lunch', 'Dinner']);

  // Define the meal types
  List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  // Initialize a map to store rating counts for each meal type
  Map<String, Map<String, int>> allMealRatings = {
    'Excellent': {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0},
    'Good': {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0},
    'Average': {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0},
    'Bad': {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0},
    'Very Bad': {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0},
  };

  // Loop through each meal type and fetch feedback data
  for (String mealType in mealTypes) {
    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('mealType', isEqualTo: mealType)
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate))
        .get();

    // Update the rating counts for each meal type
    for (var doc in feedbackSnapshot.docs) {
      final rating = doc['rating'];
      if (allMealRatings.containsKey(rating)) {
        allMealRatings[rating]![mealType] = allMealRatings[rating]![mealType]! + 1;
      }
    }
  }

  // Append rows for each rating category (Excellent, Good, etc.)
  allMealRatings.forEach((rating, mealCounts) {
    sheetObject.appendRow([
      DateFormat('yyyy-MM-dd').format(_selectedDate), // Date
      rating, // Rating (Excellent, Good, etc.)
      mealCounts['Breakfast'].toString(), // Count for Breakfast
      mealCounts['Lunch'].toString(),     // Count for Lunch
      mealCounts['Dinner'].toString(),    // Count for Dinner
    ]);
  });

  // Save the Excel file to external storage
  Directory? directory = await getExternalStorageDirectory();
  String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
  String outputFilePath = '${directory!.path}/meal_feedback_$formattedDate.xlsx';

  File(outputFilePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.save()!);

  // Show a success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Data exported successfully to $outputFilePath'),
    ),
  );
}



  Color _getBarColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Average':
        return Colors.yellow;
      case 'Bad':
        return Colors.orange;
      case 'Very Bad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
