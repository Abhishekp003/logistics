import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_screens/buy_sell.dart';
import 'bottom_nav_screens/finance_insurance.dart';
import 'bottom_nav_screens/history.dart';
import 'bottom_nav_screens/loads.dart';
import 'bottom_nav_screens/profile.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Loads(),
    buyandsell(),
    financeandinsurance(),
    history(),
    profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leadingWidth: 150,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.asset(
            'images/logo_removebg.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: ImageIcon(AssetImage('images/icons/bell.png')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: ImageIcon(AssetImage('images/icons/question.png')),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/icons/loads_icon.png')),
            label: 'Loads',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/icons/buyandsell_icon.png')),
            label: 'Sell & Buy',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/icons/financeandinsurance_icon.png')),
            label: 'Finance & Insurance',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/icons/history_icon.png')),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('images/icons/user_icon.png')),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
