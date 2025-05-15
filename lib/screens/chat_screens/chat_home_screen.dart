import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/screens/chat_screens/chats_list_screen.dart';
import 'package:clica/screens/chat_screens/groups_screen.dart';
import 'package:clica/screens/chat_screens/people_screen.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    ChatsListsScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding:const  EdgeInsets.all(8.0),
            child: userImageWidget(imageUrl: authProvider.userModel!.image, 
            radius: 20, 
            onTap: (){
            // navigate to user profile with uis as argument
            Navigator.pushNamed(context, Constants.profileScreen, 
            arguments: authProvider.userModel!.uid,
            );
            },),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group,),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe,),
            label: 'People',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          // animate to the page
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}