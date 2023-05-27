import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? val;
  const MyTextFormField(
      {Key? key,
      required this.label,
      this.icon,
      this.controller,
      this.obscure = false,
      this.val, this.suffix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        decoration: InputDecoration(
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          label: Text(label),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 25,
          ),
          suffixIcon: suffix,
        ),
        controller: controller,
        obscureText: obscure,
        // onChanged: (value) => print(value),
        validator: val,
      ),
    );
  }
}
