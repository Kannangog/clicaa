import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/screens/chat_screens/create_group_screen.dart';
import 'package:clica/screens/chat_screens/my_chats_screen.dart';
import 'package:clica/screens/chat_screens/groups_screen.dart';
import 'package:clica/screens/chat_screens/people_screen.dart';
import 'package:clica/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // user comes back to the app
        // update user status to online
        context.read<AuthenticationProvider>().updateUserStatus(
              value: true,
            );
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // app is inactive, paused, detached or hidden
        // update user status to offline
        context.read<AuthenticationProvider>().updateUserStatus(
              value: false,
            );
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
      title: const Text('Clica'),
      actions: [
        Padding(
        padding: const EdgeInsets.all(8.0),
        child: userImageWidget(
          imageUrl: authProvider.userModel!.image,
          radius: 20,
          onTap: () {
          if (authProvider.userModel != null) {
            Navigator.pushNamed(
            context,
            Constants.profileScreen,
            arguments: authProvider.userModel!.uid,
            );
          }
          },
        ),
        )
      ],
      ),
      body: PageView(
      controller: pageController,
      onPageChanged: (index) => setState(() => currentIndex = index),
      children: pages,
      ),
      floatingActionButton: currentIndex == 1
        ? FloatingActionButton(
          onPressed: () async {
          await context.read<GroupProvider>().clearGroupMembersList();
          if (mounted) {
            Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateGroupScreen(),
            ),
            );
          }
          },
          child: const Icon(CupertinoIcons.add),
        )
        : null,
      bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.chat_bubble_2),
        label: 'Chats',
        ),
        BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.group),
        label: 'Groups',
        ),
        BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.globe),
        label: 'People',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        );
        setState(() => currentIndex = index);
      },
      ),
    );
}
    }