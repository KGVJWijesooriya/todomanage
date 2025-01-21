import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.secondary,
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
                  color: Theme.of(context).colorScheme.secondary,
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              NavIndex = 0;
              _bottomNavIndex = 4;
            });
          },
          backgroundColor: const Color(0xFFF6C445),
          label: Text(
            'Add Task',
            style: TextStyle(color: Color(0xFF14142B)),
          ),
          icon: Icon(
            Icons.add,
            size: 35,
            color: Color(0xFF14142B),
          ),
          // child: Row(
          //   children: [
          // Icon(
          //   Icons.add,
          //   size: 35,
          //   color: Color(0xFF14142B),
          // ),
          //     Text('Add New Task')
          //   ],
          // ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: NavIndex == 5
              ? addNewClients()
              : NavIndex == 6
                  ? ProfileView()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_bottomNavIndex == 0) myTask(),
                          if (_bottomNavIndex == 1)
                            clients(
                              onIconPressed: handleIconPressed,
                            ),
                          if (_bottomNavIndex == 3) Mainanalize(),
                          if (_bottomNavIndex == 4) addNewTask(),
                        ],
                      ),
                    ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GNav(
            gap: 8,
            iconSize: MediaQuery.of(context).size.width/15,
            activeColor: Theme.of(context).colorScheme.surface,
          tabBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            color: Colors.grey,
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.all(16),
            selectedIndex: _bottomNavIndex,
            onTabChange: (index) => setState(() {
              NavIndex = 0;
              _bottomNavIndex = index;
            }),
            tabs: const [
              GButton(icon: Icons.home, text: 'My Tasks'),
              GButton(icon: Icons.groups, text: 'Clients'),
              GButton(icon: Icons.attach_money, text: 'Payment'),
              GButton(icon: Icons.trending_up, text: 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }
}
