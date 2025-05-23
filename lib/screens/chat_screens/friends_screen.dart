import 'package:clica/utilities/constants.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:clica/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        },),
        title: const Text('Friends'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
        
           const Expanded(child: FriendsList(viewType: FriendViewType.friends ,)),
          ],
        ),
      ),
    );
  }
}