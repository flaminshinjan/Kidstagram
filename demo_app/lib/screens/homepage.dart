import 'package:flutter/material.dart';
import 'package:demo_app/screens/new_taskpage';

class Story {
  final String name;
  final String image;

  Story({required this.name, required this.image});
}

class Post {
  final String name;
  final String image;
  final String caption;

  Post({required this.name, required this.image, required this.caption});
}

class HomePage extends StatelessWidget {
  static const String routeName = '/home';

  final List<Story> stories = [
    Story(name: 'Meme Club', image: 'assets/stars.jpg'),
    Story(name: 'Tech Club', image: 'assets/cars.jpg'),
    Story(name: 'Art Club', image: 'assets/art.jpg'),
    Story(name: 'Market Club', image: 'assets/tech.jpg'),
    Story(name: 'Reading Club', image: 'assets/books.jpg'),
    // Add more stories with different names and images
  ];

  final List<Post> posts = [
    Post(
      name: 'John',
      image: 'assets/p1.png',
      caption: 'Enjoying a beautiful day!',
    ),
    Post(
      name: 'Emma',
      image: 'assets/circuit.png',
      caption: 'Exploring new places!',
    ),
    Post(
      name: 'Alex',
      image: 'assets/p1.png',
      caption: 'Feeling adventurous!',
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
        title: Row(
          children: [
            SizedBox(
              height: 28,
              width: 190,
              child: Image.asset(
                'assets/logo.png',
                height: 28,
                width: 190,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded),
            onPressed: () {
              // Handle search button press
            },
          ),
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
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (context, index) => SizedBox(width: 25),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor:
                              const Color.fromARGB(255, 255, 140, 0),
                          backgroundImage: AssetImage(stories[index].image),
                        ),
                      ),
                      Text(
                        stories[index].name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color.fromARGB(230, 255, 255, 255),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/profile.png',
                                height: 35,
                                width: 35,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Jenny Wilson",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    "10 Mins ago",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontSize: 8),
                                  ),
                                ],
                              ),
                              SizedBox(width: 229),
                              Icon(
                                Icons.more_horiz,
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                              height: 200,
                              child: Image.asset(posts[index].image)),
                          Row(children: [
                            IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/like.png',
                                  height: 30,
                                )),
                            const SizedBox(width: 2),
                            IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/share.png',
                                  height: 30,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/chat.png',
                                  height: 28,
                                )),
                          ]),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lorem ipsum dolor sit amet consectetur. In proin scelerisque rhoncus magna ",
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                "odio tellus habitant eleifend. Justo risus eget pretium turpis tincidunt sagittis ",
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                "nulla ",
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        ],
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
                  color: Colors.orange,
                ),
                Text(
                  'Home',
                  style: TextStyle(color: Colors.orange),
                  selectionColor: Colors.orange,
                ),
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
                Icon(Icons.computer_outlined),
                Text('AI'),
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
                Icon(Icons.calendar_month_outlined),
                Text('Events'),
              ],
            ),
            label: '',
          ),
        ],
        onTap: (int index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewTaskPage()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTaskPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
