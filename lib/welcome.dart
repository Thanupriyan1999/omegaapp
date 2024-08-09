import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _employeeIdController = TextEditingController();
  String _breakfastAnswer = '';
  String _lunchAnswer = '';
  String _dinnerAnswer = '';

  Future<void> _saveData() async {
    final employeeId = _employeeIdController.text;

    if (employeeId.isNotEmpty &&
        _breakfastAnswer.isNotEmpty &&
        _lunchAnswer.isNotEmpty &&
        _dinnerAnswer.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          'employeeId': employeeId,
          'breakfast': _breakfastAnswer,
          'lunch': _lunchAnswer,
          'dinner': _dinnerAnswer,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );
        _employeeIdController.clear();
        setState(() {
          _breakfastAnswer = '';
          _lunchAnswer = '';
          _dinnerAnswer = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome '),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to Omega',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Employee ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              const Text(
                'How was your breakfast?',
                style: TextStyle(fontSize: 18),
              ),
              _buildOptionButtons('breakfast', ['Bad', 'Good', 'Excellent']),
              const SizedBox(height: 20),
              const Text(
                'How was your lunch?',
                style: TextStyle(fontSize: 18),
              ),
              _buildOptionButtons('lunch', ['Bad', 'Good', 'Excellent']),
              const SizedBox(height: 20),
              const Text(
                'How was your dinner?',
                style: TextStyle(fontSize: 18),
              ),
              _buildOptionButtons('dinner', ['Bad', 'Good', 'Excellent']),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                },
                child: const Text('View Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButtons(String question, List<String> options) {
    return Column(
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          leading: Radio<String>(
            value: option,
            groupValue: _getAnswer(question),
            onChanged: (value) {
              setState(() {
                _setAnswer(question, value!);
              });
            },
          ),
        );
      }).toList(),
    );
  }

  String _getAnswer(String question) {
    switch (question) {
      case 'breakfast':
        return _breakfastAnswer;
      case 'lunch':
        return _lunchAnswer;
      case 'dinner':
        return _dinnerAnswer;
      default:
        return '';
    }
  }

  void _setAnswer(String question, String answer) {
    switch (question) {
      case 'breakfast':
        _breakfastAnswer = answer;
        break;
      case 'lunch':
        _lunchAnswer = answer;
        break;
      case 'dinner':
        _dinnerAnswer = answer;
        break;
    }
  }
}
