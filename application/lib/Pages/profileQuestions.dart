import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserQuestionnaire extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String uid;

  const UserQuestionnaire({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.uid,
  }) : super(key: key);

  @override
  _UserQuestionnaireState createState() => _UserQuestionnaireState();
}

class _UserQuestionnaireState extends State<UserQuestionnaire> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // User data
  int? age;
  bool? cancerHistory;
  bool? skinCancerHistory;
  bool? drinks;
  String? gender;
  bool? hasPipedWater;
  bool? hasSewageSystem;
  bool? pesticideExposure;
  bool? smokes;
  int? skinTone;
  int? burns;
  int? tans;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Calculate Fitzpatrick score
  double calculateFitzpatrick() {
    if (skinTone == null || burns == null || tans == null) return 0;
    int x = ((skinTone! + burns! + tans!) / 3).floor();
    return (x - 1) / (6 - 1);
  }

  // Normalize age
  double normalizeAge() {
    if (age == null) return 0;
    return (age! - 6) / (94 - 6);
  }

  // Save data to Firestore
  Future<void> saveUserData() async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // Query to find the user document based on phone number
      QuerySnapshot querySnapshot = await users
          .where('number', isEqualTo: int.parse(widget.phoneNumber))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the existing document
        String docId = querySnapshot.docs.first.id;
        await users.doc(docId).update({
          'age': normalizeAge(),
          'cancer_history': cancerHistory,
          'skin_cancer_history': skinCancerHistory,
          'drinks': drinks,
          'gender': gender,
          'has_piped_water': hasPipedWater,
          'has_sewage_system': hasSewageSystem,
          'pesticide_exposore': pesticideExposure,
          'smokes': smokes,
          'fitzpatrick': calculateFitzpatrick(),
        });

        showMessage("Profile updated successfully!");
        // Navigate to home screen or dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        showMessage("User record not found!");
      }
    } catch (e) {
      showMessage("Error saving data: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void nextPage() {
    if (_currentPage < 11) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFCCD2F2),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Card widget for each question
  Widget questionCard({
    required String question,
    required Widget content,
    required int index,
  }) {
    bool isLastPage = index == 11;

    return Card(
      margin: EdgeInsets.all(20),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Question ${index + 1} of 12",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            Text(
              question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Expanded(child: Center(child: content)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: previousPage,
                    child: Text("Previous"),
                    style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  SizedBox(width: 1),
                isLastPage
                    ? ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                    // Validate all fields are filled
                    if (age == null ||
                        cancerHistory == null ||
                        skinCancerHistory == null ||
                        drinks == null ||
                        gender == null ||
                        hasPipedWater == null ||
                        hasSewageSystem == null ||
                        pesticideExposure == null ||
                        smokes == null ||
                        skinTone == null ||
                        burns == null ||
                        tans == null) {
                      showMessage(
                          "Please go back and complete all questions");
                      return;
                    }
                    saveUserData();
                  },
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAD88C6),
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                )
                    : ElevatedButton(
                  onPressed: nextPage,
                  child: Text("Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAD88C6),
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Profile',
          style: TextStyle(fontFamily: 'BaskervvilleSC'),
        ),
        backgroundColor: Color(0xFFAD88C6),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // Question 1: Age
          questionCard(
            question: "What is your age?",
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your age',
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  age = int.tryParse(value);
                });
              },
            ),
            index: 0,
          ),

          // Question 2: Cancer History
          questionCard(
            question: "Do you have a history of cancer?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: cancerHistory,
                  onChanged: (value) {
                    setState(() {
                      cancerHistory = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: cancerHistory,
                  onChanged: (value) {
                    setState(() {
                      cancerHistory = value;
                    });
                  },
                ),
              ],
            ),
            index: 1,
          ),

          // Question 3: Skin Cancer History
          questionCard(
            question: "Do you have a history of skin cancer?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: skinCancerHistory,
                  onChanged: (value) {
                    setState(() {
                      skinCancerHistory = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: skinCancerHistory,
                  onChanged: (value) {
                    setState(() {
                      skinCancerHistory = value;
                    });
                  },
                ),
              ],
            ),
            index: 2,
          ),

          // Question 4: Drinks
          questionCard(
            question: "Do you consume alcoholic beverages?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: drinks,
                  onChanged: (value) {
                    setState(() {
                      drinks = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: drinks,
                  onChanged: (value) {
                    setState(() {
                      drinks = value;
                    });
                  },
                ),
              ],
            ),
            index: 3,
          ),

          // Question 5: Gender
          questionCard(
            question: "What is your gender?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text("Male"),
                  value: "Male",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text("Female"),
                  value: "Female",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ],
            ),
            index: 4,
          ),

          // Question 6: Has Piped Water
          questionCard(
            question: "Do you have access to piped water at home?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: hasPipedWater,
                  onChanged: (value) {
                    setState(() {
                      hasPipedWater = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: hasPipedWater,
                  onChanged: (value) {
                    setState(() {
                      hasPipedWater = value;
                    });
                  },
                ),
              ],
            ),
            index: 5,
          ),

          // Question 7: Has Sewage System
          questionCard(
            question: "Do you have access to a sewage system?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: hasSewageSystem,
                  onChanged: (value) {
                    setState(() {
                      hasSewageSystem = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: hasSewageSystem,
                  onChanged: (value) {
                    setState(() {
                      hasSewageSystem = value;
                    });
                  },
                ),
              ],
            ),
            index: 6,
          ),

          // Question 8: Pesticide Exposure
          questionCard(
            question: "Have you been exposed to pesticides?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: pesticideExposure,
                  onChanged: (value) {
                    setState(() {
                      pesticideExposure = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: pesticideExposure,
                  onChanged: (value) {
                    setState(() {
                      pesticideExposure = value;
                    });
                  },
                ),
              ],
            ),
            index: 7,
          ),

          // Question 9: Smokes
          questionCard(
            question: "Do you smoke tobacco products?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  title: Text("Yes"),
                  value: true,
                  groupValue: smokes,
                  onChanged: (value) {
                    setState(() {
                      smokes = value;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("No"),
                  value: false,
                  groupValue: smokes,
                  onChanged: (value) {
                    setState(() {
                      smokes = value;
                    });
                  },
                ),
              ],
            ),
            index: 8,
          ),

          // Question 10: Skin Tone
          questionCard(
            question: "What is your natural skin tone?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(6, (index) {
                return RadioListTile<int>(
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                              Colors.white, Colors.brown[900], index / 5),
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("Type ${index + 1}"),
                    ],
                  ),
                  value: index + 1,
                  groupValue: skinTone,
                  onChanged: (value) {
                    setState(() {
                      skinTone = value;
                    });
                  },
                );
              }),
            ),
            index: 9,
          ),

          // Question 11: Burns
          questionCard(
            question: "How easily does your skin burn in the sun?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  title: Text("1 - Always burns, never tans"),
                  value: 1,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("2 - Usually burns, tans minimally"),
                  value: 2,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("3 - Sometimes burns, tans gradually"),
                  value: 3,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("4 - Rarely burns, tans easily"),
                  value: 4,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("5 - Very rarely burns, tans easily"),
                  value: 5,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("6 - Never burns, deeply pigmented"),
                  value: 6,
                  groupValue: burns,
                  onChanged: (value) {
                    setState(() {
                      burns = value;
                    });
                  },
                ),
              ],
            ),
            index: 10,
          ),

          // Question 12: Tans
          questionCard(
            question: "How well does your skin tan?",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  title: Text("1 - Never tans"),
                  value: 1,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("2 - Tans minimally"),
                  value: 2,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("3 - Tans gradually"),
                  value: 3,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("4 - Tans well"),
                  value: 4,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("5 - Tans very easily"),
                  value: 5,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text("6 - Deeply pigmented, always dark"),
                  value: 6,
                  groupValue: tans,
                  onChanged: (value) {
                    setState(() {
                      tans = value;
                    });
                  },
                ),
              ],
            ),
            index: 11,
          ),
        ],
      ),
    );
  }
}