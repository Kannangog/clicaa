// ignore_for_file: use_build_context_synchronously

import 'package:clica/models/user_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key,required this.viewType,});
  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final String uid = context.read<AuthenticationProvider>().userModel!.uid;

    final future = viewType == FriendViewType.friends
    ? context.read<AuthenticationProvider>().getFriendsList(uid)
    : viewType == FriendViewType.friendRequests
        ? context.read<AuthenticationProvider>().getFriendRequestsList(uid)
        : context.read<AuthenticationProvider>().getFriendsList(uid);


    return FutureBuilder<List<UserModel>>(
      future: future,
      builder:
          ( context,  snapshot) {

        if (snapshot.hasError) {
          return const  Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Friends"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return ListTile(
                contentPadding: const EdgeInsets.only(left:-10),
                leading: userImageWidget(imageUrl: data.image, radius: 40, onTap: (){
                 // Navigate to this friends profile with uid as argument
                  Navigator.pushNamed(context, Constants.profileScreen, arguments: data.uid);
                }),
                title: Text(data.name),
                subtitle: Text(data.aboutMe,maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: ElevatedButton(
                  onPressed: ()async{
                    if(viewType == FriendViewType.friends){
                      // Navigate to chat screen with the following arguments
                      // 1. friend uid 2. friend name 3. friend image 4.group id with an empty string
                      Navigator.pushNamed(context, Constants.chatScreen, 
                      arguments: {
                        Constants.contactUID : data.uid,
                        Constants.contactName : data.name,
                        Constants.contactImage : data.image,
                        Constants.groupID : '',
                      });

                    }else if(viewType == FriendViewType.friendRequests){
                      await context
                      .read<AuthenticationProvider>()
                      .acceptFriendRequest(friendID: data.uid)
                      .whenComplete((){
                      showSnackBar
                      (context, 'You are now friends with ${data.name}');
                 });
                    }else{
                      // check the check box
                    }
                }, 
                child: viewType == FriendViewType.friends ? const Text('chat') : const Text('Accept'),
                ),
              );
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}