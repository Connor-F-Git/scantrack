import 'package:flutter/material.dart';
import 'package:scantrack/pages/file_page.dart';
import 'pages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPageIndex = 0;
  late List<Widget> _pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = 0;

    _pages = [
      const AccountPage(),
      const FilePage(),
      const QueryPage(),
    ];

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        // New Page in Botto Bar Procedure:
        // 1. create page .dart file in /pages/ folder
        // 2. add instance of page to _pages list
        // 3. add BottomNavigationBarItem of that page to the items list below
        // 4. make sure the items and _pages lists are in the same order
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.file_open), label: 'Files'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Query',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.onSecondary,
        unselectedItemColor: Theme.of(context).colorScheme.onTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
      ),
      appBar: AppBar(
        title: const Text('TPI File Tracker'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: _pageController,
        //The following parameter is just to prevent
        //the user from swiping to the next page.
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }
}
