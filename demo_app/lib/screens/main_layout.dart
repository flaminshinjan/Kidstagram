import 'package:demo_app/screens/eventspage.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:demo_app/screens/new_taskpage.dart';
import 'package:demo_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  static const String routeName = '/main';

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    Center(child: Text('Chat')), // Placeholder for Chat screen
    EventsPage(),
    ProfilePage(), // Profile page
    Center(child: Text('AI')),    // Placeholder for AI screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: _currentIndex == 0 ? Colors.orange : Colors.grey,
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: _currentIndex == 0 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: _currentIndex == 1 ? Colors.orange : Colors.grey,
                ),
                Text(
                  'Chat',
                  style: TextStyle(
                    color: _currentIndex == 1 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: _currentIndex == 2 ? Colors.orange : Colors.grey,
                ),
                Text(
                  'Events',
                  style: TextStyle(
                    color: _currentIndex == 2 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  color: _currentIndex == 3 ? Colors.orange : Colors.grey,
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: _currentIndex == 3 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.computer_outlined,
                  color: _currentIndex == 4 ? Colors.orange : Colors.grey,
                ),
                Text(
                  'AI',
                  style: TextStyle(
                    color: _currentIndex == 4 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            label: '',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTaskPage(
                onPostCreated: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
} 