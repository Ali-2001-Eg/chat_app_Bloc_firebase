import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  //ref for collection
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //save user data
  Future<void> saveUserData(String name, String email) async {
    return await _userCollection.doc(uid).set({
      'fullName': name,
      'email': email,
      'uid': uid,
      'groups': [],
      'profilePic': ''
    });
  }

  //get user data
  Future<QuerySnapshot> getUserData(String email) async {
    return await _userCollection.where('email', isEqualTo: email).get();
  }

//get user groups
  Future getUserGroup() async {
    return _userCollection.doc(uid).snapshots();
  }

  //create group
  Future<void> createGroup(String username, String id, String groupName) async {
    //set method has a type of void, so its value cannot be used in updating member
    //so I used add method which has a type of DocumentReference
    DocumentReference groupDocumentReference = await _groupCollection.add({
      'groupName': groupName,
      'id': id,
      'admin': '$id _$username',
      'groupIcon': '',
      'members': [],
      'groupId': '',
      'recentMessageSender': '',
      'recentMessage': '',
    });
    //update members
    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion(['$uid _ $username']),
      'groupId': groupDocumentReference.id,
    });
    //add group to user collection
    DocumentReference userDocRF = _userCollection.doc(uid);
    return await userDocRF.update({
      'groups':
          FieldValue.arrayUnion([('${groupDocumentReference.id}_$groupName')])
    });
  }

  //getting chat messages
  Future getChat(String groupId) async{
    return _groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  //get group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = _groupCollection.doc(groupId);
    //get method for only one field
    //snapshot for retrieving all document
    DocumentSnapshot snapshot = await documentReference.get();
    return snapshot['admin'];
  }

  Future getGroupMembers(String groupId) async {
    return _groupCollection.doc(groupId).snapshots();
  }

  //search
  Future searchByName(String groupName) async {
    return _groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  Future<bool> isUserJoined(String username, String groupName, groupId) async {
    DocumentReference userDocRF = _userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocRF.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

  //toggle exit/join
  Future<void> toggleGroupJoin(
      String groupId, String groupName, String username) async {
    DocumentReference userDocRF = _userCollection.doc(uid);
    DocumentReference groupDocRF = _groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocRF.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    // List<dynamic> members = await documentSnapshot['members'];
    // if user has group => remove him or rejoin from/to the group
    if (groups.contains('${groupId}_$groupName')) {
      await userDocRF.update({
        "groups": FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupDocRF.update({
        "members": FieldValue.arrayRemove(['${uid}_$username'])
      });
    } else {
      await userDocRF.update({
        "groups": FieldValue.arrayUnion(['${groupId}_$groupName'])
      });
      await groupDocRF.update({
        "members": FieldValue.arrayUnion(['${uid}_$username'])
      });
    }
  }

  Future<void> sendMessage(String groupId, Map<String, dynamic> chatMessageData) async{
    //add chat in the new collection
    _groupCollection.doc(groupId).collection('messages').add(chatMessageData);
    //update the old collection
    _groupCollection.doc(groupId).update({
      'recentMessage':chatMessageData['message'],
      'recentMessageSender':chatMessageData['sender'],
      'recentMessageTime':chatMessageData['time'].toString(),
    });
  }

}
