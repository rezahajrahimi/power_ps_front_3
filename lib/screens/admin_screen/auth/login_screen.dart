import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/constes.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/screens/admin_screen/auth/forget_password_screen.dart';
import 'package:powerps/repositories/authenticatiom_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? accountID;
  String? password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _showMsg(msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textDirection: TextDirection.rtl,
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                                  "ورود",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        textDirection: TextDirection.ltr,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.account_circle,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                            hintText:
                                                'نام کاربری یا اکانت آیدی تلگرام را وارد کنید.',
                                            fillColor: Colors.grey[300],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            )),
                                        validator: (emailValue) {
                                          if (emailValue!.isEmpty) {
                                            return 'نام کاربری یا اکانت آیدی تلگرام را وارد کنید.';
                                          }
                                          accountID = emailValue;
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        onFieldSubmitted: (value) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _login();
                                          }
                                        },
                                        obscureText: true,
                                        textDirection: TextDirection.ltr,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.vpn_key,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                            hintText: 'رمز عبور را وارد کنید.',
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
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 240,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.login,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _login();
                                          }
                                        },
                                        label: Text(
                                          _isLoading
                                              ? 'در حال پردازش...'
                                              : 'ورود به پنل',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24),
                                        ),
                                        style: ButtonStyle(
                                            shape: WidgetStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    side: const BorderSide(
                                                        color: Colors.red)))),
                                      ),
                                    )
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgetPasswordScreen()));
                                  },
                                  child: const Text(
                                    "بازیابی رمز عبور ",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
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
                ],
              ),
            ),
          ),
        ));
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await logIn(accountID: accountID!, password: password!).then((value) {
        if (value != null || value != false) {
          debugPrint('value: $value');
          try {
            if (!mounted) return;

            Provider.of<AuthChangeController>(context, listen: false)
                .setUser(value);

            Navigator.of(context)
                .pushReplacementNamed('/home'); // replaces the current screen
            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            _showMsg('اطلاعات ورودی اشتباه می باشد.');
            debugPrint(e.toString());
            setState(() {
              _isLoading = false;
            });

            // Navigator.of(context).pop();
            // Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          _showMsg('اطلاعات ورودی اشتباه می باشد.');
          // Navigator.of(context).pop();
          // Navigator.of(context).pushReplacementNamed('/login');
        }
      }).catchError((e, s) {
        debugPrint(e.toString());
        setState(() {
          _isLoading = false;
        });

        _showMsg('خطا در ارتباط با سرور.');
        // Navigator.of(context).pop();
        // Navigator.of(context).pushReplacementNamed('/login');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showMsg('خطا در ارتباط با سرور.');

      debugPrint(e.toString());
    }
  }
}
