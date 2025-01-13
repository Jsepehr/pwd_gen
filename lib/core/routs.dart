import 'package:go_router/go_router.dart';
import 'package:pwd_gen/view/pwd_list_view.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => PwdListView(),
    ),
   
  ],
);