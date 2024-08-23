// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'report_page.dart'; // Import the ReportPage

// class WelcomePage extends StatefulWidget {
//   const WelcomePage({super.key});

//   @override
//   _WelcomePageState createState() => _WelcomePageState();
// }

// class _WelcomePageState extends State<WelcomePage> {
//   final TextEditingController _employeeIdController = TextEditingController();
//   String _mealType = 'Breakfast';
//   String _selectedRating = '';

//   @override
//   void initState() {
//     super.initState();
//     _updateMealType();
//   }

//   void _updateMealType() {
//     final hour = DateTime.now().hour;
//     if (hour >= 6 && hour < 11) {
//       setState(() {
//         _mealType = 'Breakfast';
//       });
//     } else if (hour >= 11 && hour < 17) {
//       setState(() {
//         _mealType = 'Lunch';
//       });
//     } else {
//       setState(() {
//         _mealType = 'Dinner';
//       });
//     }
//   }

//   Future<void> _saveData() async {
//     final employeeId = _employeeIdController.text;

//     if (employeeId.isNotEmpty && _selectedRating.isNotEmpty) {
//       try {
//         await FirebaseFirestore.instance.collection('feedback').add({
//           'employeeId': employeeId,
//           'mealType': _mealType,
//           'rating': _selectedRating,
//           'timestamp': FieldValue.serverTimestamp(), // Using server timestamp
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Data saved successfully!')),
//         );
//         _employeeIdController.clear();
//         setState(() {
//           _selectedRating = '';
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter Employee ID and select a rating.')),
//       );
//     }
//   }

//   void _selectRating(String rating) {
//     setState(() {
//       _selectedRating = rating;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Image
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                   'https://t4.ftcdn.net/jpg/03/15/56/21/240_F_315562154_IHPB75WqP42YzXarrHYasro0Q0VQUbad.jpg', // Example background image URL
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _buildRatingButton('Excellent', Colors.greenAccent.shade700),
//                             _buildRatingButton('Good', Colors.lightGreen.shade700),
//                             _buildRatingButton('Average', Colors.yellow.shade600),
//                             _buildRatingButton('Bad', Colors.orange.shade800),
//                             _buildRatingButton('Very Bad', Colors.red.shade800),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 100),
//                       Expanded(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _buildEmployeeIdInput(),
//                             _buildCustomNumberPad(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildReportButton(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Center(
//       child: Column(
//         children: [
//           Text(
//             'Omega Line Vavuniya'
//             ,
//             style: TextStyle(
//               fontSize: 40,
//               fontWeight: FontWeight.bold,
//               color: const Color.fromARGB(255, 65, 32, 109),
//               fontFamily: 'Lobster',
//               shadows: [
//                 Shadow(
//                   blurRadius: 30.0,
//                   color: Colors.black38,
//                   offset: Offset(5.0, 5.0),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             'Food Rating'
//             ,
//             style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//               color: const Color.fromARGB(255, 65, 32, 109),
//               fontFamily: 'Lobster',
//               shadows: [
//                 Shadow(
//                   blurRadius: 30.0,
//                   color: Colors.black38,
//                   offset: Offset(5.0, 5.0),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               children: [
//                 Text(
//                   _mealType.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 35,
//                     fontWeight: FontWeight.bold,
//                     color: const Color.fromARGB(255, 43, 8, 238),
//                   ),
//                 ),
//                 Text(
//                   DateFormat('MMMM dd').format(DateTime.now()),
//                   style: TextStyle(
//                     fontSize: 32,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRatingButton(String text, Color color) {
//     return Stack(
//       children: [
//         ElevatedButton(
//           onPressed: () => _selectRating(text),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _selectedRating == text ? const Color.fromARGB(255, 1, 9, 15) : color,
//             minimumSize: Size(double.infinity, 60),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: Text(text, style: TextStyle(fontSize: 35)),
//         ),
//         // Positioned(
//         //   right: 10,
//         //   top: 5,
//         //   child: Image.network(
//         //     'https://www.publicdomainpictures.net/pictures/320000/velka/smiley-face.png', // Example smiley image URL
//         //     height: 5,
//         //     width: 40,
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildEmployeeIdInput() {
//     return TextField(
//       controller: _employeeIdController,
//       decoration: InputDecoration(
//         labelText: 'Enter Employee ID',
//         labelStyle: TextStyle(fontSize: 28),
//         border: OutlineInputBorder(),
//         fillColor: Colors.white.withOpacity(0.9),
//         filled: true,
//       ),
//       style: TextStyle(fontSize: 35),
//       textAlign: TextAlign.center,
//       keyboardType: TextInputType.none,
//     );
//   }

//   Widget _buildCustomNumberPad() {
//     return GridView.builder(
//       shrinkWrap: true,
//       itemCount: 12,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 2.5,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//       ),
//       itemBuilder: (context, index) {
//         if (index == 9) {
//           return _buildNumberButton('Del', Icons.backspace, () {
//             if (_employeeIdController.text.isNotEmpty) {
//               _employeeIdController.text =
//                   _employeeIdController.text.substring(0, _employeeIdController.text.length - 1);
//             }
//           });
//         } else if (index == 10) {
//           return _buildNumberButton('0', null, () {
//             _employeeIdController.text += '0';
//           });
//         } else if (index == 11) {
//           return _buildNumberButton('Enter', Icons.check, _saveData);
//         } else {
//           return _buildNumberButton('${index + 1}', null, () {
//             _employeeIdController.text += '${index + 1}';
//           });
//         }
//       },
//     );
//   }

//   Widget _buildNumberButton(String label, IconData? icon, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.black87,
//         minimumSize: Size(20, 20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//       ),
//       child: icon == null
//           ? Text(label, style: TextStyle(fontSize: 25, color: Colors.white))
//           : Icon(icon, color: Colors.white, size: 25),
//     );
//   }

    

//   Widget _buildReportButton() {
//     return Align(
//       alignment: Alignment.bottomRight,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ReportPage()), // Navigate to the ReportPage
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 1, 6, 15),
//           minimumSize: Size(10, 10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: const Text('►', style: TextStyle(fontSize: 30)),
//       ),
//     );
//   }
// }
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
  } else if (hour >= 11 && hour < 17) {  // Adjusted to make Lunch end at 5 PM
    setState(() {
      _mealType = 'Lunch';
    });
  } else if (hour >= 17 && hour < 23) {  // Dinner now ends at 11 PM
    setState(() {
      _mealType = 'Dinner';
    });
  } else {
    setState(() {
      _mealType = 'Late Night';  // Optionally handle the time between 11 PM and 6 AM
    });
  }
}


  Future<void> _saveData() async {
    final employeeId = _employeeIdController.text;
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if the employee ID is exactly 6 digits long
    if (employeeId.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee ID must be exactly 6 digits long.')),
      );
      return; // Exit the function if the validation fails
    }

    if (_selectedRating.isNotEmpty) {
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
                  'https://img.freepik.com/free-photo/arrangement-raw-pasta-ingredients-with-copy-space_23-2148360832.jpg?t=st=1724153975~exp=1724157575~hmac=e15a70269573510c9c6a3f9f40c484d48bd46a09a4817c928128d72ad51663b0&w=996',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // Rating Buttons Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRatingButton('Excellent', const Color.fromARGB(255, 52, 177, 104), 'assets/excellent.png'),
                            _buildRatingButton('Good', Colors.lightGreen.shade700, 'assets/good.png'),
                            _buildRatingButton('Average', const Color.fromARGB(255, 255, 241, 38), 'assets/average.png'),
                            _buildRatingButton('Bad', const Color.fromARGB(255, 255, 147, 59), 'assets/bad.png'),
                            _buildRatingButton('Very Bad', const Color.fromARGB(255, 255, 99, 99), 'assets/very_bad.png'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 100),
                      // Employee ID and Keypad Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEmployeeIdInput(), // Updated with save button
                            const SizedBox(height: 20),
                            _buildCustomNumberPad(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 35, 64, 189),
                fontFamily: 'Lobster',
                shadows: const [
                  Shadow(
                    blurRadius: 10.0,
                    color: Color.fromARGB(193, 38, 164, 242),
                    offset: Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
            Text(
              _mealType.toUpperCase(),
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        // Calendar Date
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                  color: const Color.fromARGB(255, 2, 14, 85).withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                DateFormat('dd').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 60,
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

  // Inside the WelcomePageState class

void _selectRating(String text) {
  setState(() {
    _selectedRating = text;
  });
}

// No changes needed to the button creation code in _buildRatingButton:
Widget _buildRatingButton(String text, Color color, String imagePath) {
  return Padding(
    padding: const EdgeInsets.only(right: 60),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectRating(text), // This is where the rating is selected
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedRating == text 
                  ? color.withOpacity(0.5) 
                  : color,
              minimumSize: const Size(double.infinity, 80),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 40, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Image.asset(
          imagePath,
          width: 90,
          height: 90,
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
              labelStyle: const TextStyle(fontSize: 35, color: Colors.black),
              border: const OutlineInputBorder(),
              fillColor: Colors.white.withOpacity(0.9),
              filled: true,
            ),
            style: const TextStyle(fontSize: 35, color: Colors.black),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.none,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 34, 128, 215),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Icon(
            Icons.save,
            size: 30,
            color: Colors.white,
          ),
        ),
      ],
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
        if (index < 9) {
          return _buildNumberButton((index + 1).toString());
        } else if (index == 9) {
          return _buildNumberButton('');
        } else if (index == 10) {
          return _buildNumberButton('0');
        } else {
          return _buildBackspaceButton();
        }
      },
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: number.isEmpty ? null : () => _addNumber(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 11, 22, 71),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 40, color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return ElevatedButton(
      onPressed: _removeLastDigit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Icon(
        Icons.backspace,
        color: Colors.white,
      ),
    );
  }

  void _addNumber(String number) {
    if (_employeeIdController.text.length < 6) {
      setState(() {
        _employeeIdController.text += number;
      });
    }
  }

  void _removeLastDigit() {
    if (_employeeIdController.text.isNotEmpty) {
      setState(() {
        _employeeIdController.text = _employeeIdController.text.substring(0, _employeeIdController.text.length - 1);
      });
    }
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
          backgroundColor: const Color.fromARGB(255, 0, 100, 100),
          minimumSize: Size(10, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Icon(
          Icons.analytics,
          color: const Color.fromARGB(255, 255, 255, 255),
          size: 40,
        ),
      ),
    );
  }

}

_selectRating(String text) {
}
