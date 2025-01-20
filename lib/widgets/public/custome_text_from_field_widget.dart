import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powerps/styles/app_theme.dart';

class CustomTextFromFieldWidget extends StatefulWidget {
  const CustomTextFromFieldWidget(
      {super.key,
      required this.controller,
      required this.textHint,
      required this.validationError,
      this.keyboardType,
      this.textAlign,
      this.inputFormatters,
      this.textInputAction,
      this.validatorType,
      this.obscureText,
      this.labelText,
      this.textDirection,
      this.enable = true,
      this.formKey,
      this.callback});

  final TextEditingController controller;
  final String textHint, validationError;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? validatorType, labelText;
  final bool? obscureText;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Function(bool)? callback;
  final bool enable;
  final GlobalKey<FormState>? formKey;

  @override
  State<CustomTextFromFieldWidget> createState() =>
      _CustomTextFromFieldWidgetState();
}

class _CustomTextFromFieldWidgetState extends State<CustomTextFromFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppStyle.defaultPadding),
      padding: EdgeInsets.all(AppStyle.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2, color: AppStyle.primaryColor..withValues(alpha: 0.15)),
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyle.defaultPadding),
        ),
      ),
      child: TextFormField(
        enabled: widget.enable,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        controller: widget.controller,
        textDirection: widget.textDirection != null
            ? widget.textDirection!
            : TextDirection.rtl,
        textAlign:
            widget.textAlign != null ? widget.textAlign! : TextAlign.right,
        obscureText: widget.obscureText != null ? widget.obscureText! : false,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(
              color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 1)),
          hintText: widget.textHint,
          labelText: widget.labelText ?? widget.textHint,
          fillColor: AppStyle.secondaryColor,
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onTap: () async {
          // widget.callback!(true);
        },
        key: widget.formKey,
        validator: (String? value) {
          if (widget.validatorType == "tel") {
            if (value!.length != 11) {
              return "شماره تلفن همراه 11 عدد می باشد.";
            } else if (value.isEmpty) {
              return 'شماره تلفن همراه را وارد کنید.';
            } else {
              return null;
            }
          } else if (widget.validatorType == "password") {
            if (value!.length < 6) {
              return "رمز عبور نمی تواند کمتر از 6 حرف باشد.";
            } else if (value.isEmpty) {
              return 'رمز عبور را وارد کنید.';
            } else {
              return null;
            }
          } else if (widget.validatorType == "text") {
            if (value!.isEmpty) {
              return 'متن را وارد کنید.';
            } else {
              return null;
            }
          } else {
            return (value!.isEmpty) ? widget.validationError : null;
          }
        },
        textInputAction: widget.textInputAction,
      ),
    );
  }
}
