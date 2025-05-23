import 'package:clica/utilities/constants.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:clica/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        },),
        title: const Text('Friend Requests'),
        centerTitle: true,
      ),
      body: Column(
          children: [
        
            // cupertinoSearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                // Handle search logic here
              },
            ),
        
           const Expanded(
            child: FriendsList(
              viewType: FriendViewType.friendRequests,
              )),
          ],
        ),
    );
  }
}