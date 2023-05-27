import 'package:chat_app/controller/states/auth_states.dart';
import 'package:chat_app/helper/cache_helper.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/my_methods.dart';
import '../../shared/widgets/my_text_form_feild.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController(),
        passwordController = TextEditingController(),
        usernameController = TextEditingController();

    return BlocProvider<AuthServices>(
      create: (context) => AuthServices(),
      child: BlocConsumer<AuthServices, AuthStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<AuthServices>(context);
          print(state);
          return Scaffold(
            resizeToAvoidBottomInset: true,

            body: (state is RegisterLoading)
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 80),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Groupie',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Register now to chat and explore',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 15),
                            ),
                            Image.asset('assets/images/register.png'),
                            MyTextFormField(
                              label: 'Email',
                              icon: Icons.email,
                              controller: emailController,
                              val: (value) =>
                                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value!)
                                      ? null
                                      : 'Please Enter a Valid Email',
                            ),
                            MyTextFormField(
                              label: 'Username',
                              icon: Icons.person,
                              controller: usernameController,
                              val: (val) {
                                if (val!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Enter your name';
                                }
                              },
                            ),
                            MyTextFormField(
                              label: 'password',
                              icon: Icons.lock,
                              controller: passwordController,
                              obscure: true,
                              val: (value) {
                                if (value!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    AuthServices()
                                        .registerWithUserNameAndPassword(
                                      usernameController.text,
                                      emailController.text,
                                      passwordController.text,
                                    )
                                        .then((value) async {
                                      if (value == true) {
                                        navTo(context, const LoginScreen());
                                      } else {
                                        showSnackBar(
                                            context, value, Colors.red);
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.all(10),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    )),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text.rich(TextSpan(
                                text: "Already have an account? ",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Login here',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        navTo(context, const LoginScreen());
                                      },
                                  )
                                ]))
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
