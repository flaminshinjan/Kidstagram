import 'package:demo_app/screens/homepage.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  static const String routeName = '/home';

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
      body: Container(
        child: DefaultTabController(
          length: 3,
          // Number of tabs
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Recent'),
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                ],
              ),
              SizedBox(
                height: 553,
                child: TabBarView(
                  children: [
                    // Widget for Tab 1
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            color: Color.fromARGB(230, 43, 90, 244),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/web3.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Web3 Technology',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '60 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Card(
                            color: Color.fromARGB(230, 9, 164, 172),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bd.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Big Data Analytics',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '50 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Color.fromARGB(230, 192, 26, 173),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/crypto.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Crypto Zenith',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '80 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
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
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bitcoin.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bitcoin 101',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '70 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Add more cards as needed
                        ],
                      ),
                    ),

                    // Widget for Tab 2
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            color: Color.fromARGB(230, 43, 90, 244),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/web3.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Web3 Technology',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '60 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Card(
                            color: Color.fromARGB(230, 9, 164, 172),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bd.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Big Data Analytics',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '50 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Color.fromARGB(230, 192, 26, 173),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/crypto.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Crypto Zenith',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '80 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
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
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bitcoin.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bitcoin 101',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '70 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Add more cards as needed
                        ],
                      ),
                    ),

                    // Widget for Tab 3
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            color: Color.fromARGB(230, 43, 90, 244),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/web3.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Web3 Technology',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '60 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Card(
                            color: Color.fromARGB(230, 9, 164, 172),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bd.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Big Data Analytics',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '50 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Color.fromARGB(230, 192, 26, 173),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle button tap
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/crypto.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Crypto Zenith',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '80 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
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
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/bitcoin.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bitcoin 101',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '7:23 AM > 9:41 AM',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                        const SizedBox(width: 1),
                                        Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 70),
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/progress.png',
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            '70 %',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},

                                            minWidth:
                                                67, // Adjust the minimum width
                                            height: 20, // Adjust the height
                                            color: Color.fromARGB(
                                                255, 254, 230, 44),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Enrol Now',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Add more cards as needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          if (index == 0) {
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
