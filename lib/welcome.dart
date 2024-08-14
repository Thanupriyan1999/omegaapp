import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'report_page.dart'; // Import the ReportPage

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _employeeIdController = TextEditingController();
  String _mealType = 'Breakfast';
  String _selectedRating = '';

  @override
  void initState() {
    super.initState();
    _updateMealType();
  }

  void _updateMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      setState(() {
        _mealType = 'Breakfast';
      });
    } else if (hour >= 11 && hour < 17) {
      setState(() {
        _mealType = 'Lunch';
      });
    } else {
      setState(() {
        _mealType = 'Dinner';
      });
    }
  }

  Future<void> _saveData() async {
    final employeeId = _employeeIdController.text;

    if (employeeId.isNotEmpty && _selectedRating.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          'employeeId': employeeId,
          'mealType': _mealType,
          'rating': _selectedRating,
          'timestamp': FieldValue.serverTimestamp(), // Using server timestamp
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );
        _employeeIdController.clear();
        setState(() {
          _selectedRating = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Employee ID and select a rating.')),
      );
    }
  }

  void _selectRating(String rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRatingButton('Excellent', const Color.fromARGB(255, 19, 245, 26)),
                        _buildRatingButton('Good', const Color.fromARGB(255, 109, 179, 29)),
                        _buildRatingButton('Average', Colors.yellow),
                        _buildRatingButton('Bad', const Color.fromARGB(255, 255, 153, 0)),
                        _buildRatingButton('Very Bad', const Color.fromARGB(255, 241, 23, 7)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildEmployeeIdInput(),
                        _buildCustomNumberPad(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildReportButton(), // Add the report button here
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Omega Line Vavuniya',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            fontFamily: 'Lobster',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                _mealType.toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                DateFormat('MMMM dd').format(DateTime.now()),
                style: TextStyle(fontSize: 30, color: const Color.fromARGB(221, 0, 6, 10)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () => _selectRating(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedRating == text ? const Color.fromARGB(255, 119, 127, 236) : color,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(fontSize: 40)),
    );
  }

  Widget _buildEmployeeIdInput() {
    return TextField(
      controller: _employeeIdController,
      decoration: InputDecoration(
        labelText: 'Enter Employee ID',
        labelStyle: TextStyle(fontSize: 36),
        border: OutlineInputBorder(),
        fillColor: Colors.white.withOpacity(0.9),
        filled: true,
      ),
      style: TextStyle(fontSize: 40),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.none,
    );
  }

  Widget _buildCustomNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        if (index == 9) {
          return _buildNumberButton('Del', Icons.backspace, () {
            if (_employeeIdController.text.isNotEmpty) {
              _employeeIdController.text = _employeeIdController.text
                  .substring(0, _employeeIdController.text.length - 1);
            }
          });
        } else if (index == 10) {
          return _buildNumberButton('0', null, () {
            _employeeIdController.text += '0';
          });
        } else if (index == 11) {
          return _buildNumberButton('Enter', Icons.check, _saveData);
        } else {
          return _buildNumberButton('${index + 1}', null, () {
            _employeeIdController.text += '${index + 1}';
          });
        }
      },
    );
  }

  Widget _buildNumberButton(String label, IconData? icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        minimumSize: Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: icon == null
          ? Text(label, style: TextStyle(fontSize: 30, color: Colors.white))
          : Icon(icon, color: Colors.white, size: 30),
    );
  }

  Widget _buildReportButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportPage()), // Navigate to the ReportPage
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: Size(30, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('►', style: TextStyle(fontSize: 25)),
      ),
    );
  }
}
