import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared/widgets/my_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName, adminName;
  const GroupInfo(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.adminName})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? _members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        _members = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.adminName);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Group Info'),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text('Leave Group!'),
                        content: const Text(
                            'Are you sure you want to exit from this chat?'),
                        actions: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: ()  => DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(widget.groupId,
                                      widget.groupName, widget.adminName.substring(widget.adminName.indexOf('_')+1)).whenComplete(() {
                                        navToWithReplace(context, const HomeScreen());
                                        showSnackBar(context, 'You left ${widget.groupName} successfully', Theme.of(context).primaryColor);
                              }),
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              ))
                        ],
                      ),
                    ),
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              //admin section
              _infoTile(
                  isAdminSection: true,
                  topText: 'Group: ${widget.groupName}',
                  footerText: 'Admin: ${widget.adminName}'),
              //members section
              _memberList,
            ],
          ),
        ));
  }

  Widget _infoTile({
    bool isAdminSection = false,
    required String topText,
    required String footerText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isAdminSection
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                footerText,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  StreamBuilder get _memberList => StreamBuilder(
        stream: _members,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'].length != 0) {
                return SizedBox(
                  height: 250,
                  width: 360,
                  child: ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String topText = (snapshot.data['members'][index]);
                      // print(snapshot.data['id']);
                      return _infoTile(
                          topText: topText.substring(topText.indexOf('_') + 1),
                          footerText: snapshot.data['id']);
                    },
                  ),
                );
              } else {
                return const Center(
                    child: Text(
                  'No Members in the group',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ));
              }
            } else {
              return const Center(
                  child: Text(
                'No Members in the group',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            );
          }
        },
      );
}
