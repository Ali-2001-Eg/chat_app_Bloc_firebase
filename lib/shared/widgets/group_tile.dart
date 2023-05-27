import 'package:chat_app/shared/widgets/my_methods.dart';
import 'package:flutter/material.dart';

import '../../screens/chat_screen.dart';

class GroupTile extends StatelessWidget {
  final String username, groupId, groupName;
  const GroupTile(
      {Key? key,
      required this.username,
      required this.groupId,
      required this.groupName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navTo(
          context,
          ChatScreen(
              groupId: groupId, groupName: groupName, username: username)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Join the conversation as $username',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
