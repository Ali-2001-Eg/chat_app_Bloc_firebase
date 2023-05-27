import 'package:chat_app/controller/states/auth_states.dart';
import 'package:chat_app/screens/auth/register_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/shared/widgets/my_text_form_feild.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/my_methods.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthServices>(
      create: (context) => AuthServices(),
      lazy: false,
      child: BlocConsumer<AuthServices, AuthStates>(
          listener: (context, state) {},
          builder: (context, state) {
            final GlobalKey<FormState> formKey = GlobalKey<FormState>();
            final TextEditingController emailController =
                    TextEditingController(),
                passwordController = TextEditingController();
            var cubit = BlocProvider.of<AuthServices>(context);
            print(state);
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: (state is LoginLoadingState)
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
                          key: formKey,
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
                                'Login now to see what they are talking!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 15),
                              ),
                              Image.asset('assets/images/login.png'),
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
                                label: 'password',
                                icon: Icons.lock,
                                controller: passwordController,
                                obscure: cubit.isObscure,
                                val: (value) {
                                  if (value!.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  } else {
                                    return null;
                                  }
                                },
                                suffix: null,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      await AuthServices().login(
                                          context,
                                          emailController.text,
                                          passwordController.text);
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
                                    'Sign in',
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
                                  text: "Don't have an account? ",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Register here',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          navTo(
                                              context, const RegisterScreen());
                                        },
                                    )
                                  ]))
                            ],
                          ),
                        ),
                      ),
                    ),
            );
          }),
    );
  }
}
