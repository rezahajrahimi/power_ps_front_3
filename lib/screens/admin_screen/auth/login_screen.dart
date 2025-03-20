import 'package:flutter/material.dart';
import 'package:powerps/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:powerps/helper/constes.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/screens/admin_screen/auth/forget_password_screen.dart';
import 'package:powerps/repositories/authenticatiom_repository.dart';
import 'package:powerps/styles/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.accountID = "0", this.password = "0"});
  final String accountID;
  final String password;

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
  void initState() {
    if (widget.accountID != "0") {
      _autoLogin();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha:0.8),
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
                        const Padding(
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
                                  color: Colors.black.withValues(alpha:0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.3),
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
                                        Icons.lock_open_rounded,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "ورود",
                                        style: TextStyle(
                                            fontSize: 30,
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
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.account_circle,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintText:
                                                      'نام کاربری یا اکانت آیدی تلگرام را وارد کنید.',
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
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.vpn_key,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintText:
                                                      'رمز عبور را وارد کنید.',
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
                                      const SizedBox(height: 30),
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
                                              onPressed: _isLoading
                                                  ? null
                                                  : () async {
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
                                                    fontSize: 18),
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty 
                                                          .resolveWith<Color>(
                                                    (Set<WidgetState>
                                                        states) {
                                                      if (states.contains(
                                                          WidgetState
                                                              .disabled)) {
                                                        return Colors.grey;
                                                      }
                                                      return Theme.of(context)
                                                          .colorScheme
                                                          .secondary;
                                                    },
                                                  ),
                                                  elevation:
                                                      WidgetStateProperty.all(
                                                          5),
                                                  shape: WidgetStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0)))),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ]),
                              )),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "version: $projectVersion",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        SizedBox(
                          height: AppStyle.defaultPadding,
                        ),
                      ],
                    ),
                  ),
                ),
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
        if (!mounted) return;

        if (value.runtimeType == User) {
          try {
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

  void _autoLogin() async {
    setStateIfMounted(() {
      accountID = widget.accountID;
      password = widget.password;
    });

    _login();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }
}
