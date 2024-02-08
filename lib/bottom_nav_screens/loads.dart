import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../my_form.dart';

class PlaceSuggestion {
  final String displayName;

  PlaceSuggestion({
    required this.displayName,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      displayName: json['display_name'] ?? '',
    );
  }
}

class Loads extends StatefulWidget {
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  late Timer timer;
  late ScrollController _controller;
  int _currentIndex = 0;

  late TextEditingController _fromController;
  late TextEditingController _toController;

  List<PlaceSuggestion> _fromSuggestions = [];
  List<PlaceSuggestion> _toSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      if (_currentIndex < 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _controller.animateTo(
        _currentIndex * MediaQuery.of(context).size.width,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    });

    _fromController = TextEditingController();
    _toController = TextEditingController();
  }

  @override
  void dispose() {
    timer.cancel();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<List<PlaceSuggestion>> fetchFromSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<PlaceSuggestion> suggestions =
        data.map((json) => PlaceSuggestion.fromJson(json)).toList();
        return suggestions;
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  void _swapTextFields() {
    String temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 18, top: 15),
              child: Text(
                "Hi Manoj,",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  bottom: BorderSide(color: Colors.orange, width: 6),
                  top: BorderSide(color: Colors.orange),
                  right: BorderSide(color: Colors.orange),
                  left: BorderSide(color: Colors.orange),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(63, 0, 10, 5),
                        child: Text(
                          "From,",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 30, 5),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Icon(Icons.circle_outlined,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _fromController,
                                decoration: InputDecoration(
                                  hintText: 'Load from...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                onChanged: (value) async {
                                  List<PlaceSuggestion> suggestions =
                                  await fetchFromSuggestions(value);
                                  setState(() {
                                    _fromSuggestions = suggestions;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_fromSuggestions.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width, // Match the width of the text field
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _fromSuggestions
                                .map((suggestion) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _fromController.text =
                                      suggestion.displayName;
                                  _fromSuggestions.clear();
                                });
                              },
                              child: ListTile(
                                title: Text(suggestion.displayName),
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: CustomPaint(
                          size: Size(30, 20),
                          painter: DottedLinePainter(),
                        ),
                      ),
                      SizedBox(width: 9),
                      Text("To,"),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: _swapTextFields,
                          icon: Icon(Icons.swap_vert, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 30, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orangeAccent,
                          ),
                          child: Icon(Icons.location_on_outlined,
                              color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _toController,
                            decoration: InputDecoration(
                              hintText: 'Unload to...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onChanged: (value) async {
                              List<PlaceSuggestion> suggestions =
                              await fetchFromSuggestions(value);
                              setState(() {
                                _toSuggestions = suggestions;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_toSuggestions.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _toSuggestions
                            .map((suggestion) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _toController.text =
                                  suggestion.displayName;
                              _toSuggestions.clear();
                            });
                          },
                          child: ListTile(
                            title: Text(suggestion.displayName),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 10, 30, 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyForm(
                              enteredName: 'Some Name',
                              phoneNumber: '1234567890',
                              fromLocation: _fromController.text,
                              toLocation: _toController.text,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: Image.asset('images/offerimage.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Image.asset('images/sale${index + 1}.png');
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: Image.asset('images/delivery.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startY = 0;
    double startX = size.width / 2;

    while (startY < size.height) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX, startY + 4), paint);
      startY += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
