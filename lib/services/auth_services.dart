import 'package:chat_app/controller/states/auth_states.dart';
import 'package:chat_app/helper/cache_helper.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/widgets/my_methods.dart';

class AuthServices extends Cubit<AuthStates> {
  AuthServices() : super(AuthInitial());
 static BlocProvider get(context) => BlocProvider.of(context);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //login
  Future<void> login(
      BuildContext context, String email, String password) async {
    emit(LoginLoadingState());
    _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      QuerySnapshot snapshot = await DatabaseService().getUserData(email);
      await CacheHelper.saveUserLoggedIn(true);
      await CacheHelper.saveUserName(snapshot.docs[0]['fullName']);
      await CacheHelper.saveEmail(email);
    }).then((value) {
      emit(LoginSuccessState());
      navToWithReplace(context, const HomeScreen());
    }).catchError((e) {
      emit(LoginErrorState(e.toString()));
      showSnackBar(context, e.toString(), Colors.red);
    });
  }

  bool isObscure = true;
  IconData icon = Icons.visibility;
  void changePasswordVisibility() {
    isObscure = !isObscure;
    icon = isObscure ? Icons.visibility : Icons.visibility_off;
    emit(ChangeSuffixIcon());
  }

  //register
  Future registerWithUserNameAndPassword(
      String name, String email, String password) async {
    try {
      emit(RegisterLoading());
      User user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      //call our database to update user data
      await DatabaseService(uid: user.uid).saveUserData(name, email);

      if (user != null) {
        emit(RegisterSuccess());
        return true;
      }
    } on FirebaseAuthException catch (e) {
      emit(RegisterError());
      return e.toString();
    }
  }

  //logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut().then((value) {
      return CacheHelper.clear();
    }).then((value) => navToWithReplace(context, const LoginScreen()));
  }
}
