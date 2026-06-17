import 'package:powerps/helper/connector/dio.dart';
import 'package:powerps/helper/shared_prefrencess.dart';
import 'package:powerps/models/user_model.dart';
import 'package:powerps/provider/agent/agent_ballance_provider.dart';
import 'package:powerps/provider/agent/agent_provider.dart';
import 'package:powerps/provider/auth_provider.dart';
import 'package:powerps/provider/category_type_provider.dart';
import 'package:powerps/provider/panel_controller.dart';
import 'package:powerps/provider/menu_provider.dart';
import 'package:powerps/provider/paymeny_provider.dart';
import 'package:powerps/provider/prodct_provider.dart';
import 'package:powerps/provider/product_category_provider.dart';
import 'package:powerps/provider/transaction_provider.dart';
import 'package:powerps/provider/app_info_provider.dart';
import 'package:powerps/provider/user_admin_provider.dart';
import 'package:powerps/provider/user_provider.dart';
import 'package:powerps/provider/purchase_cart_provider.dart';
import 'package:powerps/screens/admin_screen/auth/login_screen.dart';
import 'package:powerps/screens/home_screen.dart';
import 'package:powerps/styles/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';

Future main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  // load persisted base URL (if set)
  await initBaseUrl();
  // await AppInfoPreference().init();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> stateKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        key: stateKey,
        providers: [
          ChangeNotifierProvider(create: (context) => AppInfoProvider()),
          ChangeNotifierProvider(create: (context) => MenuAppController()),
          ChangeNotifierProvider(create: (context) => PannelChangeController()),
          ChangeNotifierProvider(create: (context) => TransactionProvider()),
          ChangeNotifierProvider(create: (context) => AuthChangeController()),
          ChangeNotifierProvider(create: (context) => AgentProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => AgentBallanceProvider()),
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(
              create: (context) => ProductCategoryProvider()),
          ChangeNotifierProvider(create: (context) => UserAdminProvider()),
          ChangeNotifierProvider(create: (context) => PaymentProvider()),
          ChangeNotifierProvider(create: (context) => CategoryTypeProvider()),
          ChangeNotifierProvider(create: (context) => PurchaseCartProvider()),
        ],
        child: Consumer2<AuthChangeController, AppInfoProvider>(
          builder: (context, authController, appInfoProvider, child) {
            authController.checkAuthStatus();

            return MaterialApp(
              builder: EasyLoading.init(),
              title: appInfoProvider.displayTitle,
              onGenerateRoute: (setting) {
                if (setting.name!.contains("/login/")) {
                  String url =
                      setting.name!.substring(setting.name!.indexOf("login/"));
                  var inputs = url.split("/");
                  // print(inputs);

                  // print("acc: ${inputs[1].trim()} pass: ${inputs[2].trim()}");
                  return MaterialPageRoute(
                      builder: (_) => LoginScreen(
                            accountID: inputs[1],
                            password: inputs[2],
                          ));
                }

                return null;
              },
              theme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: AppStyle.bgColor,
                // textTheme:
                //     GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme)
                //         .apply(bodyColor: Colors.white),
                canvasColor: AppStyle.secondaryColor,
              ),
              routes: {
                '/': (context) => const Directionality(
                      textDirection: TextDirection.rtl,
                      child: CheckAuth(),
                    ),
                '/home': (context) => const HomeScreen(
                      selectedPage: 0,
                    ),
                '/login': (context) => const LoginScreen(),
              },
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
            );
          },
        ));
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget child;
    if (isAuth) {
      child = const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(
          selectedPage: 0,
        ),
      );
    } else {
      child = const Directionality(
          textDirection: TextDirection.rtl, child: LoginScreen());
    }
    return Scaffold(
      body: child,
    );
  }

  void _checkLogin() async {
    try {
      // فراخوانی متد checkAuthStatus در AuthChangeController
      await Provider.of<AuthChangeController>(context, listen: false)
          .checkAuthStatus();

      // بررسی وضعیت کاربر
      if (!mounted) return;
      User user =
          Provider.of<AuthChangeController>(context, listen: false).user;

      String token = await LoggingPreference().getToken();

      if (token != 'void' && token.isNotEmpty && user.id != 0) {
        // تنظیم هدرهای درخواست
        GenaralApi.dio.options.headers['Authorization'] = 'Bearer $token';
        GenaralApi.dio.options.headers['x-access-token'] = token;

        setState(() {
          isAuth = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isAuth = false;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking login: $e");
      setState(() {
        isAuth = false;
        isLoading = false;
      });
    }
  }
}
