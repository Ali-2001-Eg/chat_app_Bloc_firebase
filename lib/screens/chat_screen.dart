import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared/widgets/message_tile.dart';
import 'package:chat_app/shared/widgets/my_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'group_info.dart';

class ChatScreen extends StatefulWidget {
  final String groupId, groupName, username;
  const ChatScreen(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.username})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  String _admin = '';
  final TextEditingController _messageController = TextEditingController();
  Stream<QuerySnapshot>? _chats;
  Future<void> getChatAndAdmin() async {

        DatabaseService().getChat(widget.groupId).then((value) => setState(() {
          _chats = value;
        }));

    DatabaseService().getGroupAdmin(widget.groupId).then((value) => setState(
          () => _admin = value,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // print(DateTime.now());
    return Scaffold(
        // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(widget.groupName),
          actions: [
            IconButton(
                onPressed: () => navTo(
                    context,
                    GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: _admin.substring(_admin.indexOf('_') + 1))),
                icon: const Icon(Icons.info))
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chat_background.png',),
              fit:BoxFit.fill
            )
          ),
          child: Stack(
            children: [
              _chatMessages(),
              Container(
                alignment: Alignment.bottomCenter,
                width: double.maxFinite,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white, width: 2)),
                  // color: Colors.grey[700],
                  child: Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none,
                        ),
                      )),
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          (_messageController.text.isNotEmpty)
                              ? _sendMessage(_messageController.text)
                              : showSnackBar(context, 'Type a Message to be sent',
                                  Colors.redAccent);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  StreamBuilder _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
              // print( snapshot.data.docs.length);
                return MessageTile(
                  message: snapshot.data.docs[index]['message'],
                  sender: snapshot.data.docs[index]['sender'],
                  sentByMe:
                      widget.username == snapshot.data.docs[index]['sender'],
                );
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  _sendMessage(String message) {
    Map<String, dynamic> chatMessageMap = {
      'message': _messageController.text,
      'sender': widget.username,
      'time': DateTime.now(),
    };
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).sendMessage(widget.groupId, chatMessageMap);
    setState(() {
      _messageController.clear();
    });
  }
}
