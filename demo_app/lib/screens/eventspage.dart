import 'package:demo_app/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/new_taskpage';

class Post {
  final String name;
  final String image;
  final String caption;

  Post({required this.name, required this.image, required this.caption});
}

class EventsPage extends StatelessWidget {
  static const String routeName = '/home';

  final List<Post> posts = [
    Post(
      name: 'Cryptocurrency',
      image: 'assets/crypto.png',
      caption: '7:23 AM > 9:41 AM',
    ),
    Post(
      name: 'Web3 Technology',
      image: 'assets/bd.png',
      caption: '7:23 AM > 9:41 AM',
    ),
    Post(
      name: 'Big Data Analytics',
      image: 'assets/bitcoin.png',
      caption: '7:23 AM > 9:41 AM',
    ),
    Post(
      name: 'Bitcoin Darken',
      image: 'assets/web3.png',
      caption: '7:23 AM > 9:41 AM',
    ),
    // Add more posts with different names, images, and captions
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
        // Adjust the value as needed
        leading: IconButton(
          icon: Icon(Icons.more_vert_outlined),
          onPressed: () {
            // Handle menu button press
          },
        ),
        title: Text(
          'Events',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            onPressed: () {
              // Handle notifications button press
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/profile.png',
              height: 40,
              width: 40,
            ),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color.fromARGB(230, 255, 142, 22),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 20),
                  child: InkWell(
                    onTap: () {
                      // Handle button tap
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  posts[index].image,
                                  height: 60,
                                  width: 60,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      posts[index].name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      posts[index].caption,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lorem ipsum dolor sit amet consectetur. In proin scelerisque rhoncus magna odio tellus habitant eleifend. Justo risus eget pretium turpis",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Image.asset(
                                    'assets/participants.png',
                                    height: 50,
                                    width: 80,
                                  )),
                              const SizedBox(width: 2),
                              Text(
                                'Participants',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                              SizedBox(width: 107),
                              IconButton(
                                  onPressed: () {},
                                  icon: Image.asset(
                                    'assets/Mask.png',
                                    color: Colors.white,
                                    height: 15,
                                  )),
                              Text(
                                'Live',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              )
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.home_outlined,
                ),
                Text('Home'),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(Icons.chat_bubble_outline),
                Text('Chat'),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(Icons.calendar_month_outlined, color: Colors.orange),
                Text(
                  'Events',
                  style: TextStyle(color: Colors.orange),
                )
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(Icons.file_open_outlined),
                Text('Learn'),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(Icons.computer_outlined),
                Text('AI'),
              ],
            ),
            label: '',
          ),
        ],
        onTap: (int index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
      ),
    );
  }
}
