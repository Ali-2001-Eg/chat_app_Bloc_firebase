import 'package:chat_app/helper/cache_helper.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared/widgets/my_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? _groups;
  bool _userHasSearched = false;
  String username = '';
  User? user = FirebaseAuth.instance.currentUser;
  bool _isJoined = false;
  @override
  void initState() {
    super.initState();
    getUsernameAndId();
  }

  getUsernameAndId()  async{
     await CacheHelper.getUserName().then((value) {
       return username = value!;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          //search text field
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _search();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search For New Groups....',
                      hintStyle:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _search();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          //groups retrieved from search
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : _groupList,
        ],
      ),
    );
  }

  Future<void> _search() async {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchByName(_searchController.text)
          .then((snapshot) {
        setState(() {
          _groups = snapshot;
          _isLoading = false;
          _userHasSearched = true;
        });
      });
    }
  }

  Widget get _groupList => (!_userHasSearched)
      ? const Center(
          child: Text(
          'Type Group Name Please',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 23),
        ))
      : StreamBuilder(
          builder: (context, snapshot) => Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _groups!.docs.length,
              itemBuilder: (context, index) {
                 // print(_groups!.docs[index]['groupId']);
                return _groupTile(
                    username,
                    _groups!.docs[index]['groupId'],
                    _groups!.docs[index]['groupName'],
                    _groups!.docs[index]['admin']);
              },
            ),
          ),
        );
  _joinedOrNot(
      String username, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(username, groupName, groupId)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }

  Widget _groupTile(
      String username, String groupId, String groupName, String admin) {
    _joinedOrNot(username, groupId, groupName, admin);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 30,
            child: Text(
              groupName.substring(0, 1),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupName,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Admin: ${admin.substring(admin.indexOf('_') + 1)}',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Expanded(child: Container()),
          ElevatedButton(
            onPressed: () async {
               DatabaseService(uid: user!.uid)
                  .toggleGroupJoin(groupId, groupName, username);
              if (!_isJoined) {
                setState(() => _isJoined = !_isJoined);
                showSnackBar(context, 'You Joined $groupName successfully', Colors.green);
                await Future.delayed(const Duration(seconds: 2),() => navTo(context, ChatScreen(groupId: groupId, groupName: groupName, username: username)),);
              } else {
                setState(() => _isJoined = !_isJoined);
                showSnackBar(context, 'You left $groupName successfully', Colors.red);
                await Future.delayed(const Duration(seconds: 2),() => navTo(context,const HomeScreen()),);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    !_isJoined ? Colors.black : Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            child:
                !_isJoined ? const Text('Join Now') : const Text('Leave Group'),
          ),
        ],
      ),
    );
  }
}
