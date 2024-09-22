import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'report_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final TextEditingController _employeeIdController = TextEditingController();
  String _mealType = 'Breakfast';
  String _selectedRating = '';
  bool _isSubmitting = false; // Prevent multiple submissions

  @override
  void initState() {
    super.initState();
    _updateMealType();
  }

  void _updateMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 1 && hour < 11) {
      setState(() {
        _mealType = 'Breakfast';
      });
    } else if (hour >= 11 && hour < 19) {
      setState(() {
        _mealType = 'Lunch';
      });
    } else if (hour >= 19 && hour < 23) {
      setState(() {
        _mealType = 'Dinner';
      });
    } else {
      setState(() {
        _mealType = 'Late Night';
      });
    }
  }

  Future<bool> _checkIfAlreadySubmitted(String employeeId, String currentDate) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('employeeId', isEqualTo: employeeId)
        .where('mealType', isEqualTo: _mealType)
        .where('date', isEqualTo: currentDate)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _saveData() async {
    if (_isSubmitting) return; // Prevent multiple submissions
    _isSubmitting = true; // Lock submission

    final employeeId = _employeeIdController.text;
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (employeeId.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee ID must be exactly 6 digits long.')),
      );
      _isSubmitting = false;
      return;
    }

    if (_selectedRating.isNotEmpty) {
      final alreadySubmitted = await _checkIfAlreadySubmitted(employeeId, currentDate);

      if (alreadySubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already submitted a rating for this meal today.')),
        );
        _isSubmitting = false;
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          'employeeId': employeeId,
          'mealType': _mealType,
          'rating': _selectedRating,
          'date': currentDate,
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

    _isSubmitting = false; // Unlock submission
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://st3.depositphotos.com/2861195/14236/i/1600/depositphotos_142361642-stock-photo-blurred-food-background-colorful-dishes.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Rating Buttons
                      _buildRatingButtons(),
                      const SizedBox(height: 20),
                      // Employee ID Input and Keypad
                      _buildEmployeeIdInput(),
                      const SizedBox(height: 10),
                      _buildCustomNumberPad(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildReportButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "Omega Line Vavuniya" text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Omega Line Vavuniya',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 35, 64, 189),
                fontFamily: 'Lobster',
                shadows: const [
                  Shadow(
                    blurRadius: 40.0,
                    color: Color.fromARGB(193, 7, 7, 7),
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            Text(
              _mealType.toUpperCase(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        // Calendar Date
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 171, 252, 248),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 14, 85).withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                DateFormat('dd').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingButtons() {
    return Column(
      children: [
        _buildRatingButton('Excellent', const Color.fromARGB(255, 52, 177, 104), 'assets/excellent.png'),
        const SizedBox(height: 10),
        _buildRatingButton('Good', Colors.lightGreen.shade700, 'assets/good.png'),
        const SizedBox(height: 10),
        _buildRatingButton('Average', const Color.fromARGB(255, 255, 241, 38), 'assets/average.png'),
        const SizedBox(height: 10),
        _buildRatingButton('Bad', const Color.fromARGB(255, 255, 147, 59), 'assets/bad.png'),
        const SizedBox(height: 10),
        _buildRatingButton('Very Bad', const Color.fromARGB(255, 255, 99, 99), 'assets/very_bad.png'),
      ],
    );
  }

  void _selectRating(String text) {
    setState(() {
      _selectedRating = text;
    });
  }

  Widget _buildRatingButton(String text, Color color, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _selectRating(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRating == text
                    ? color.withOpacity(0.5)
                    : color,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Image.asset(
            imagePath,
            width: 80,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeIdInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _employeeIdController,
            decoration: InputDecoration(
              labelText: 'Enter Employee ID',
              border: const OutlineInputBorder(),
              fillColor: Colors.white.withOpacity(0.9),
              filled: true,
            ),
            style: const TextStyle(fontSize: 20, color: Colors.black),
            keyboardType: TextInputType.number,
            maxLength: 6, // Restrict to 6 digits
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 35, 64, 189),
            minimumSize: const Size(60, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Icon(Icons.save, size: 40),
        ),
      ],
    );
  }

Widget _buildCustomNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 5),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 5),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 5),
        _buildNumberRow(['', '0', '⌫']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return _buildNumberButton(number);
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () {
        if (number == '⌫') {
          if (_employeeIdController.text.isNotEmpty) {
            _employeeIdController.text = _employeeIdController.text
                .substring(0, _employeeIdController.text.length - 1);
          }
        } else {
          if (_employeeIdController.text.length < 6) {
            _employeeIdController.text += number;
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 25, 25, 26),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(5),
        
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }


  Widget _buildReportButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        },
        icon: const Icon(Icons.pie_chart),
        label: const Text('REPORT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 35, 64, 189),
          minimumSize: const Size(150, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
