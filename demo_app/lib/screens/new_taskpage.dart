import 'package:flutter/material.dart';

class NewTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
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
            TextField(
              decoration: InputDecoration(
                hintText: "What's happening?",
                border: InputBorder.none,
              ),
            ),
            Positioned(
              left: 8.0,
              bottom: 8.0,
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
          ],
        ),
      ),
    );
  }
}
