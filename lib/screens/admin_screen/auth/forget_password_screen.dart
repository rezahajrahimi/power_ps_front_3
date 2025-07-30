import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
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
  String projectVersion = "";
  String projectName = "";

  String? accountId;
  String? password;
  int _timerCountDown = 60;
  String _actionButtonText = "ارسال درخواست";
  bool _hasSendCode = false;
  bool _showeResendCode = false;

  @override
  void initState() {
    _fillProjectInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                  child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? size.width * 0.1 : 25,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: AppStyle.defaultPadding,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: Text(
                            projectName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                              width: isDesktop ? 500 : double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 10),
                                    )
                                  ]),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.password_rounded,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "فراموشی رمز عبور",
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 30),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30),
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
                                                  hintText:
                                                      'اکانت آیدی را وارد کنید.',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 14,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[900],
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[700]!,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 2,
                                                    ),
                                                  )),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              validator: (phonenumber) {
                                                if (phonenumber!.isEmpty &&
                                                    phonenumber.length != 11) {
                                                  return 'اکانت آیدی را وارد کنید';
                                                }
                                                accountId = phonenumber;
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            _hasSendCode == true
                                                ? TextFormField(
                                                    obscureText: true,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    decoration: InputDecoration(
                                                        prefixIcon: Icon(
                                                          Icons.vpn_key,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor,
                                                        ),
                                                        hintText:
                                                            'رمز عبور را وارد کنید.',
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontSize: 14,
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey[900],
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .grey[700]!,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Colors.red,
                                                            width: 2,
                                                          ),
                                                        )),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                    validator: (passwordValue) {
                                                      if (passwordValue!
                                                          .isEmpty) {
                                                        return 'رمز عبور را وارد کنید';
                                                      }
                                                      password = passwordValue;
                                                      return null;
                                                    },
                                                  )
                                                : const SizedBox(height: 0),
                                            const SizedBox(height: 10),
                                            _hasSendCode == true
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[800],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      "$_timerCountDown ثانیه",
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(height: 0),
                                            const SizedBox(height: 10),
                                            _showeResendCode == true &&
                                                    _hasSendCode == true
                                                ? ElevatedButton.icon(
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                    onPressed: () {
                                                      _forgetPassword();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    label: const Text(
                                                        "ارسال مجدد"),
                                                  )
                                                : const SizedBox(height: 0)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        height: 50,
                                        width: 240,
                                        child: ElevatedButton.icon(
                                          icon: Icon(
                                            _hasSendCode
                                                ? Icons.login
                                                : Icons.send,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _hasSendCode == false
                                                  ? _forgetPassword()
                                                  : _login();
                                            }
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                              elevation:
                                                  WidgetStateProperty.all(5),
                                              shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ))),
                                          label: Text(
                                            _actionButtonText,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "بازگشت ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ]),
                              )),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "version: $projectVersion",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        SizedBox(
                          height: AppStyle.defaultPadding,
                        ),
                      ]),
                ),
              )),
            ),
          ),
        ));
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

    // setState(() {});
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

  void _fillProjectInfo() async {
    String name = await AppInfoPreference().getAppName();
    String version = await AppInfoPreference().getAppVersion();
    setState(() {
      projectName = name;
      projectVersion = version;
    });
  }
}
