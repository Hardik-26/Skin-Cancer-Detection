import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoleDataHandler {
  static final List<String> regions = [
    'ABDOMEN', 'ARM', 'BACK', 'NECK', 'CHEST', 'EAR', 'FACE', 'FOOT',
    'FOREARM', 'HAND', 'LIP', 'NOSE', 'SCALP', 'THIGH'
  ];

  // Show the mole data collection carousel
  static Future<Map<String, dynamic>> showMoleDataCarousel(
      BuildContext context, String screenshotPath) async {

    double diameter = 0;
    String selectedRegion = '';
    bool bleeds = false;
    bool itches = false;
    bool hurts = false;
    bool hasGrown = false;
    bool hasChanged = false;

    // Create question pages
    final PageController pageController = PageController();
    int currentPage = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(10),
              content: Container(
                width: 500,
                height: 400,
                child: Column(
                  children: [
                    Text(
                      "Mole Information ${currentPage + 1}/7",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Carousel pages
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        children: [
                          // Page 1: Diameter input
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("What is the diameter of the mole in MM?"),
                              SizedBox(height: 20),
                              TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter diameter in MM",
                                ),
                                onChanged: (value) {
                                  diameter = double.tryParse(value) ?? 0;
                                },
                              ),
                            ],
                          ),

                          // Page 2: Region selection
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Select the region where the mole is located:"),
                              SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: regions.length,
                                  itemBuilder: (context, index) {
                                    return RadioListTile<String>(
                                      title: Text(regions[index]),
                                      value: regions[index],
                                      groupValue: selectedRegion,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRegion = value!;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Page 3: Does it bleed
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Does the mole bleed?"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("Yes"),
                                      value: true,
                                      groupValue: bleeds,
                                      onChanged: (value) {
                                        setState(() {
                                          bleeds = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("No"),
                                      value: false,
                                      groupValue: bleeds,
                                      onChanged: (value) {
                                        setState(() {
                                          bleeds = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Page 4: Does it itch
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Does the mole itch?"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("Yes"),
                                      value: true,
                                      groupValue: itches,
                                      onChanged: (value) {
                                        setState(() {
                                          itches = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("No"),
                                      value: false,
                                      groupValue: itches,
                                      onChanged: (value) {
                                        setState(() {
                                          itches = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Page 5: Does it hurt
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Does the mole hurt?"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("Yes"),
                                      value: true,
                                      groupValue: hurts,
                                      onChanged: (value) {
                                        setState(() {
                                          hurts = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("No"),
                                      value: false,
                                      groupValue: hurts,
                                      onChanged: (value) {
                                        setState(() {
                                          hurts = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Page 6: Has it grown
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Has the mole grown?"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("Yes"),
                                      value: true,
                                      groupValue: hasGrown,
                                      onChanged: (value) {
                                        setState(() {
                                          hasGrown = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("No"),
                                      value: false,
                                      groupValue: hasGrown,
                                      onChanged: (value) {
                                        setState(() {
                                          hasGrown = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Page 7: Has it changed
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Has the mole changed?"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("Yes"),
                                      value: true,
                                      groupValue: hasChanged,
                                      onChanged: (value) {
                                        setState(() {
                                          hasChanged = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: Text("No"),
                                      value: false,
                                      groupValue: hasChanged,
                                      onChanged: (value) {
                                        setState(() {
                                          hasChanged = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Navigation buttons
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currentPage > 0
                            ? TextButton(
                          onPressed: () {
                            pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text("Previous"),
                        )
                            : SizedBox(width: 80),
                        Text("${currentPage + 1}/7"),
                        currentPage < 6
                            ? TextButton(
                          onPressed: () {
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text("Next"),
                        )
                            : TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Process the data after dialog is closed
    Map<String, dynamic> moleData = {
      "image_path": screenshotPath,
      "diameter": (diameter-0)/(100-0),
      "bleed": bleeds ? 1 : 0,
      "itch": itches ? 1 : 0,
      "hurt": hurts ? 1 : 0,
      "grew": hasGrown ? 1 : 0,
      "changed": hasChanged ? 1 : 0,
    };

    // Set all region values to 0
    for (String region in regions) {
      moleData["region_$region"] = region == selectedRegion ? 1 : 0;
    }

    return moleData;
  }

  // Fetch user data from Firebase
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_uid') ?? '';
      print(uid);
      if (uid.isEmpty) {
        throw Exception('User ID not found in shared preferences');
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore
          .collection('user')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('User document not found');
      }

      return snapshot.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  // Combine mole data and user data
  static Future<Map<String, dynamic>> combineData(
      Map<String, dynamic> moleData, Map<String, dynamic> userData) async {

    Map<String, dynamic> combinedData = {
      "data": {
        // Mole data
        "image_path": moleData["image_path"],
        "diameter": moleData["diameter"],
        "region_ABDOMEN": moleData["region_ABDOMEN"],
        "region_ARM": moleData["region_ARM"],
        "region_BACK": moleData["region_BACK"],
        "region_NECK": moleData["region_NECK"],
        "region_CHEST": moleData["region_CHEST"],
        "region_EAR": moleData["region_EAR"],
        "region_FACE": moleData["region_FACE"],
        "region_FOOT": moleData["region_FOOT"],
        "region_FOREARM": moleData["region_FOREARM"],
        "region_HAND": moleData["region_HAND"],
        "region_LIP": moleData["region_LIP"],
        "region_NOSE": moleData["region_NOSE"],
        "region_SCALP": moleData["region_SCALP"],
        "region_THIGH": moleData["region_THIGH"],
        "bleed": moleData["bleed"],
        "itch": moleData["itch"],
        "hurt": moleData["hurt"],
        "grew": moleData["grew"],
        "changed": moleData["changed"],

        // User data
        "smokes": userData["smokes"] ?? 0,
        "drinks": userData["drinks"] ?? 0,
        "age": userData["age"] ?? 0,
        "pesticide_exposure": userData["pesticide_exposure"] ?? 0,
        "skin_cancer_history": userData["skin_cancer_history"] ?? 0,
        "cancer_history": userData["cancer_history"] ?? 0,
        "has_piped_water": userData["has_piped_water"] ?? 0,
        "has_sewage_system": userData["has_sewage_system"] ?? 0,
        "gender_FEMALE": userData["gender_FEMALE"] ?? 0,
        "gender_MALE": userData["gender_MALE"] ?? 0,
        "gender_OTHER": userData["gender_OTHER"] ?? 0,
        "fitzpatrick": userData["fitzpatrick"] ?? 0,
      }
    };

    return combinedData;
  }
}