import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class chatMessage extends StatelessWidget {
  const chatMessage({super.key});

  @override
  Widget build(BuildContext context) {
final authenticatedUser= FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatsnapshots) {
        if (chatsnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatsnapshots.hasData || chatsnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages found'),
          );
        }
        if (chatsnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        final loadmessages = chatsnapshots.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadmessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadmessages[index].data();
              final nextchatmessage = index + 1 < loadmessages.length
                  ? loadmessages[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextchatMessageUserId =
                  nextchatmessage != null ? nextchatmessage['userId'] : null;
              final nextuserIsSame =
                  nextchatMessageUserId == currentMessageUserId;
              if (nextuserIsSame) {
                return MessageBubble.next(message: chatMessage['text'], isMe: authenticatedUser.uid==currentMessageUserId);
              }
              else{
                return MessageBubble.first(userImage: chatMessage['userImage'], username: chatMessage['username'], message: chatMessage['text'], isMe: authenticatedUser.uid==currentMessageUserId);
              }
            });
      },
    );
  }
}
