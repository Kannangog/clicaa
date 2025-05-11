import 'package:flutter/material.dart';

class ChatsListsScreen extends StatefulWidget {
  const ChatsListsScreen({super.key});

  @override
  State<ChatsListsScreen> createState() => _ChatsListsScreenState();
}

class _ChatsListsScreenState extends State<ChatsListsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chats')
      ),
    );
  }
}