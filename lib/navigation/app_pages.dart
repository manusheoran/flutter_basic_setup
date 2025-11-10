import 'package:get/get.dart';
import '../features/splash/splash_page.dart';
import '../features/login/login_page.dart';
import '../features/login/login_controller.dart';
import '../features/home/home_page.dart';
import '../features/home/home_controller.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/dashboard/dashboard_controller.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/settings_controller.dart';
import '../features/admin/admin_page.dart';
import '../features/admin/admin_controller.dart';

class AppPages {
  static const INITIAL = '/splash';
  
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => SplashPage(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: '/home',
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: '/dashboard',
      page: () => DashboardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: '/settings',
      page: () => SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage(
      name: '/admin',
      page: () => AdminPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminController>(() => AdminController());
      }),
    ),
  ];
}