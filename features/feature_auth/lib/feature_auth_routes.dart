import 'package:get/get.dart';

import 'pages/auth_login_page.dart';

final authPages = <GetPage<dynamic>>[
  GetPage(
    name: '/auth/login',
    page: () => const AuthLoginPage(),
    binding: AuthLoginBinding(),
  ),
];
