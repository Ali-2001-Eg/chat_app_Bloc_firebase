import 'package:chat_app/helper/cache_helper.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared/widgets/group_tile.dart';
import 'package:chat_app/shared/widgets/my_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  String email = '';
  Stream? groups;
  final TextEditingController _groupController = TextEditingController();
  bool _isLoading = false;
  getUserData() async {
    await CacheHelper.getUserName().then((value) {
      setState(() {
        name = value!;
      });
    });
    await CacheHelper.getEmail().then((value) {
      setState(() {
        email = value!;
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroup()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }
  //get  list of snapshot

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _groupController.dispose();
    super.dispose();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    // print(_isLoading);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Groups',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                navTo(context, const SearchScreen());
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: _groupList(),
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () => navTo(
                  context,
                  ProfileScreen(
                    name: name,
                    email: email,
                  )),
              // selectedColor: Theme.of(context).primaryColor,
              // selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        )),
                    IconButton(
                        onPressed: () async =>
                            await AuthServices().logout(context),
                        icon: const Icon(
                          Icons.done,
                          color: Colors.green,
                        ))
                  ],
                ),
              ),
              // selectedColor: Theme.of(context).primaryColor,
              // selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _popUpDialog(context),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    //to get latest group in top of the screen
                    int reversedIndex = snapshot.data['groups'].length-index-1;
                    return GroupTile(
                      username: name,
                      groupId: getId(snapshot.data['groups'][reversedIndex])  ,
                      groupName: getName(snapshot.data['groups'][reversedIndex])  ,
                    );
                  },
                ),
              );
            } else {
              return _noGroupWidget();
            }
          } else {
            return _noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  void _popUpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : AlertDialog(
                title: const Text(
                  'Create a group',
                  textAlign: TextAlign.left,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : TextField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              labelText: 'Group Name',
                            ),
                            controller: _groupController,
                            maxLength: 30,
                            style: const TextStyle(color: Colors.black),
                          )
                  ],
                ),
                elevation: 0,
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text('Cancel')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (_groupController.text.isNotEmpty) {
                          setState(() {
                            _isLoading = true;
                          });
                          await DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .createGroup(
                            name,
                            FirebaseAuth.instance.currentUser!.uid,
                            _groupController.text,
                          )
                              .whenComplete(() {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                            showSnackBar(context, 'Group Created Successfully',
                                Colors.green);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Create')),
                ],
              ),
      ),
    );
  }

  Widget _noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any group, tap on the add icon to create a group or search from top search button.",
            textAlign: TextAlign.center,
            style: TextStyle(),
          )
        ],
      ),
    );
  }
}
