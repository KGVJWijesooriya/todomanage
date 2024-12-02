import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../component/filterDropdown.dart';
import 'Task/taskTimeline.dart';
import 'Client/AddNewClient.dart';
import 'Task/AddNewTask.dart';
import 'Task/MyTask.dart';
import 'Client/clients.dart';
import 'analize/mainAnalize.dart';
import 'profile.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _bottomNavIndex = 0;
  int NavIndex = 0;
  final List<IconData> iconList = [
    Icons.home,
    Icons.groups,
    Icons.attach_money,
    Icons.trending_up,
  ]; // Icon list for the nav bar
  String getAppBarTitle() {
    if (NavIndex == 5) {
      return 'Add New Client';
    } else if (NavIndex == 6) {
      return 'Profile';
    } else {
      switch (_bottomNavIndex) {
        case 0:
          return 'My Tasks';
        case 1:
          return 'Clients';
        case 2:
          return 'Payment';
        case 3:
          return 'Analytics';
        case 4:
          return 'Add New Task';
        default:
          return 'Home';
      }
    }
  }

  void handleIconPressed(int index) => setState(() => NavIndex = index);

  @override
  Widget build(BuildContext context) {
    print(NavIndex);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF14142B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14142B),
        leadingWidth: 100,
        leading: Hero(
          tag: 'logo',
          child: Center(
            child: Image.asset(
              'assets/images/Lucid.png',
              fit: BoxFit.fill,
              width: 35,
            ),
          ),
        ),
        title: Text(
          getAppBarTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  NavIndex = 6; // Set a NavIndex value for ProfileView
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ClipOval(
        child: GestureDetector(
          onTap: () {
            setState(() {
              NavIndex = 0;
              _bottomNavIndex = 4;
            });
          },
          child: Container(
            color: const Color(0xFFF6C445),
            width: 56,
            height: 56,
            child: Icon(
              Icons.add,
              size: 35,
              color: Color(0xFF14142B),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        height: 80,
        icons: iconList,
        iconSize: 30,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        backgroundColor: const Color(0xFF24263A),
        inactiveColor: Colors.grey,
        activeColor: const Color(0xFF73FA92),
        onTap: (index) => setState(() {
          NavIndex = 0;
          _bottomNavIndex = index;
        }),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MediaQuery.of(context).size.height / 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NavIndex == 5
                  ? addNewClients()
                  : NavIndex == 6 // Check if ProfileView should be shown
                      ? ProfileView() // Show ProfileView when NavIndex is 6
                      : Column(
                          children: [
                            if (_bottomNavIndex == 0) myTask(),
                            if (_bottomNavIndex == 1)
                              clients(
                                onIconPressed: handleIconPressed,
                              ),
                            // if (_bottomNavIndex == 2) TaskTimelineTile(),
                            if (_bottomNavIndex == 3) Mainanalize(),
                            if (_bottomNavIndex == 4) addNewTask(),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
