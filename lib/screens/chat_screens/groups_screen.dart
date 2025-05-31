import 'package:clica/constants.dart';
import 'package:clica/screens/chat_screens/private_group_screen.dart';
import 'package:clica/screens/chat_screens/public_group_screen.dart';
import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  text: Constants.private.toUpperCase(),
                ),
                Tab(
                  text: Constants.public.toUpperCase(),
                ),
              ],
            ),
          ),
          body: const TabBarView(children: [
            PrivateGroupScreen(searchQuery: '',),
            PublicGroupScreen(searchQuery: '',),
          ]),
        ));
  }
}