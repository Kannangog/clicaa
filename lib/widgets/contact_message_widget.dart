import 'package:clica/models/message_model.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessageWidget extends StatelessWidget {
  const ContactMessageWidget({super.key, required this.message, required this.onRightSwipe});
  final Function() onRightSwipe;
  
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(
      message.timeSent,
      [hh, ':', nn, ' '],
    );
    final isReplying = message.repliedTo.isNotEmpty;
    final senderName = message.repliedTo == 'You' ? message.senderName:'You';
    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(isReplying)...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                  color:Colors.black,
                                  fontWeight: FontWeight.bold,
                                  ),
                                  
                                ),
                                Text(
                                  message.repliedMessage,
                                  style: const TextStyle(
                                  color:Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        )
                    ],
                      Text(
                        message.message,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}