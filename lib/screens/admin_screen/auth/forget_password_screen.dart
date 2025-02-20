import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powerps/helper/constes.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/screens/admin_screen/auth/login_screen.dart';
import 'package:powerps/repositories/authenticatiom_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? accountId;
  String? password;
  int _timerCountDown = 60;
  String _actionButtonText = "ارسال درخواست";
  bool _hasSendCode = false;
  bool _showeResendCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(
                height: AppStyle.defaultPadding,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Text(
                  projectName,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              Center(
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width > 600
                        ? 640
                        : MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(90),
                            bottomRight: Radius.circular(90))),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "فراموشی رمز عبور",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  TextFormField(
                                    textDirection: TextDirection.ltr,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintText: 'اکانت آیدی را وارد کنید.',
                                        fillColor: Colors.grey[300],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        )),
                                    validator: (phonenumber) {
                                      if (phonenumber!.isEmpty &&
                                          phonenumber.length != 11) {
                                        return 'اکانت آیدی را وارد کنید';
                                      }
                                      accountId = phonenumber;
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _hasSendCode == true
                                      ? TextFormField(
                                          obscureText: true,
                                          textDirection: TextDirection.ltr,
                                          decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.vpn_key,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              hintText:
                                                  'رمز عبور را وارد کنید.',
                                              fillColor: Colors.grey[300],
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              )),
                                          validator: (passwordValue) {
                                            if (passwordValue!.isEmpty) {
                                              return 'رمز عبور را وارد کنید';
                                            }
                                            password = passwordValue;
                                            return null;
                                          },
                                        )
                                      : const Opacity(opacity: 1),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _hasSendCode == true
                                      ? Text(
                                          "$_timerCountDown ثانیه",
                                          textDirection: TextDirection.rtl,
                                        )
                                      : const Opacity(opacity: 1),
                                  _showeResendCode == true &&
                                          _hasSendCode == true
                                      ? ElevatedButton(
                                          onPressed: () {
                                            _forgetPassword();
                                          },
                                          child: const Text("ارسال مجدد"))
                                      : const Opacity(opacity: 1)
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: 240,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _hasSendCode == false
                                        ? _forgetPassword()
                                        : _login();
                                  }
                                },
                                style: ButtonStyle(
                                    shape: WidgetStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            side: const BorderSide(
                                                color: Colors.red)))),
                                child: Text(
                                  _actionButtonText,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "بازگشت ",
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ]),
                    )),
              ),
              SizedBox(
                height: AppStyle.defaultPadding,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Text(
                  "version: $projectVersion",
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            ]),
          ),
        )));
  }

  void _forgetPassword() async {
    setState(() {
      _actionButtonText = "در حال پردازش";
    });

    try {
      await forgetPassword(accountID: int.parse(accountId!)).then((response) {
        if (response) {
          if (!mounted) return;

          // ignore: use_build_context_synchronously
          showMsg(
              context: context, msg: 'رمز عبور جدید در تلگرام ارسال گردید.');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          setState(() {
            _actionButtonText = "ورود";
            _timerCountDown = 60;
            _hasSendCode = true;
          });
          _startTimer();
        } else {
          // ignore: use_build_context_synchronously
          showMsg(context: context, msg: 'خطا');
          setState(() {
            _actionButtonText = "ارسال درخواست";
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    setState(() {});
  }

  _startTimer() {
    Timer? r;
    r = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCountDown >= 1) {
          _timerCountDown--;
          _showeResendCode = false;
        } else {
          _showeResendCode = true;
          r?.cancel();
        }
      });
    });
  }

  void _login() async {
    try {
      await logIn(accountID: accountId!, password: password!).then((value) {
        if (!mounted) return;

        if (value) {
          try {
            Navigator.of(context)
                .pushReplacementNamed('/home'); // replaces the current screen
          } catch (e) {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          showMsg(context: context, msg: 'خطا');
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
