import 'package:flutter/widgets.dart';
import '../screens/question_screen.dart';
import '../screens/leaderboard_screen.dart';
import 'package:paradox/screens/leaderboard_screen.dart';
import 'package:paradox/screens/rules_screen.dart';
import 'package:paradox/screens/user_profile_screen.dart';
import '../authentication/sign_in.dart';
import '../screens/home_screen.dart';

Map<String, Widget Function(BuildContext)> routes = {
  SignIn.routeName: (context) => SignIn(),
  Home.routeName: (context) => Home(),
  LeaderBoard.route: (context) => LeaderBoard(),
  QuestionScreen.routeName:(context) => QuestionScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  RulesScreen.routeName: (context) => RulesScreen(),
};
