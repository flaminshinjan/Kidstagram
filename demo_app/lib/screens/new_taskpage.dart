import 'package:flutter/material.dart';
import 'package:demo_app/screens/homepage.dart';

class NewTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
        // Adjust the value as needed
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            // Handle menu button press
          },
        ),
        title: Text(
          '',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: MaterialButton(
              onPressed: () {},

              minWidth: 65, // Adjust the minimum width
              height: 35, // Adjust the height
              color: const Color.fromARGB(255, 255, 136, 0),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Share Now',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: CardWithTextField(),
      ),
    );
  }
}

class CardWithTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "What's happening?",
                  border: InputBorder.none,
                ),
              ),
            ),
            Positioned(
              left: 1,
              bottom: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () {
                      // Handle photo button press
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.video_call),
                    onPressed: () {
                      // Handle video call button press
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: () {
                      // Handle location button press
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: MaterialButton(
                onPressed: () {},

                minWidth: 50, // Adjust the minimum width
                height: 35, // Adjust the height
                color: Color.fromARGB(255, 245, 205, 160),
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Everyone can view & reply',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 133, 2),
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
