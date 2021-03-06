import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paradox/models/brightness_options.dart';
import 'package:paradox/models/leaderBoardUser.dart';
import 'package:paradox/models/user.dart' as BaseUser;
import 'package:paradox/providers/api_authentication.dart';
import 'package:paradox/providers/leaderboard_provider.dart';
import 'package:paradox/providers/question_provider.dart';
import 'package:paradox/providers/theme_provider.dart';
import 'package:paradox/providers/user_provider.dart';
import 'package:paradox/screens/InfoScreen.dart';
import 'package:paradox/screens/question_screen.dart';
import 'package:paradox/screens/rules_screen.dart';
import 'package:paradox/screens/stageCompleted_screen.dart';
import 'package:paradox/screens/user_profile_screen.dart';
import 'package:paradox/utilities/Toast.dart';
import 'package:paradox/screens/member_screen.dart';
import 'package:paradox/utilities/notifications.dart';
import 'package:paradox/utilities/type_writer_box.dart';
import 'package:paradox/widgets/drawer.dart';
import 'package:paradox/widgets/top_player_card.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  static String routeName = '/home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  @override
  bool get wantKeepAlive => true;
  bool load = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            'Paradox',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          ),
          actions: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image(
                      image: NetworkImage(UserProvider().getUserProfileImage()),
                    ),
                  ),
                ),
              ),
              onTap: load
                  ? null
                  : () {
                      Navigator.pushNamed(context, ProfileScreen.routeName);
                    },
            ),
          ],
        ),
        drawer: load
            ? Drawer(
                child: Center(
                  child: SpinKitDualRing(color: Colors.blue),
                ),
              )
            : AppDrawer(),
        body: load != true
            ? HomePage()
            : Center(
                child: SpinKitFoldingCube(
                  color: Colors.blue,
                ),
              ));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      load = true;
    });

    Future.delayed(Duration.zero, () async {
      try {
        await ApiAuthentication().userIsPresent().then((value) async => {
              if (value)
                {print('user already in database')}
              else
                {await ApiAuthentication().createUser()}
            });
        Provider.of<UserProvider>(context, listen: false).assignUser(
            FirebaseAuth.instance.currentUser.uid,
            FirebaseAuth.instance.currentUser.email,
            FirebaseAuth.instance.currentUser.displayName);
        Provider.of<UserProvider>(context, listen: false).updateUserImage();
        await Future.wait([
          Provider.of<QuestionProvider>(context, listen: false)
              .fetchQuestions(),
          Provider.of<QuestionProvider>(context, listen: false).fetchHints(),
          Provider.of<UserProvider>(context, listen: false).fetchUserDetails()
        ]);
        showNotification(
            "Play Paradox 2k21", "Win exciting prizes and goodies");
        setState(() {
          load = false;
        });
      } catch (e) {
        createToast("There is some error. Please Try again later");
      }
    });
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Animation scaleAnimation;
  AnimationController animationController;
  int _currentIndex = 0;

  List itemList = [ParadoxPlayEasy(), ParadoxPlayMedium(), ParadoxPlayHard()];

  // generic function
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();

    Provider.of<LeaderBoardProvider>(context, listen: false)
        .fetchAndSetLeaderBoard();

    // animation controller for scale animation
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // animation for scaling effect
    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceOut,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// start the animation
    animationController.forward();

    List<LeaderBoardUser> users =
        Provider.of<LeaderBoardProvider>(context, listen: true).topPlayerList;
    BaseUser.User user = Provider.of<UserProvider>(context, listen: true).user;

    return SafeArea(
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        child: SingleChildScrollView(
          child: Container(
            padding: null,
            margin: null,
            child: Column(
              children: [
                Container(
                  // margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 180,
                              height: 50,
                              margin: EdgeInsets.only(left: 10, top: 10),
                              child: TypeWriterBox('Paradox')),
                          GestureDetector(
                            child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(top: 10, right: 10),
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: Text('View Rules',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue.withOpacity(0.85))),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RulesScreen.routeName);
                            },
                          ),
                        ],
                      ),
                      ScaleTransition(
                        scale: scaleAnimation,
                        child: Container(
                          margin: EdgeInsets.only(top: 16),
                          child: CarouselSlider(
                            options: CarouselOptions(
                                height: 230,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                pauseAutoPlayOnTouch: true,
                                aspectRatio: 2.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                }),
                            items: itemList.map((paradoxCard) {
                              return Builder(builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Transform.scale(
                                    scale: 1,
                                    child: paradoxCard,
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: scaleAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: map(itemList, (index, dot) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? Colors.blue.withOpacity(0.7)
                                    : Colors.grey.withOpacity(0.55),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 5),
                      ScaleTransition(
                        scale: scaleAnimation,
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider()),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              width: 200,
                              height: 50,
                              child: TypeWriterBox('Top Players'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            height: 45,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: Text('nimbus'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue.withOpacity(0.85))),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 250,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: users.length == 0
                            ? SpinKitDualRing(color: Colors.blue)
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return PlayerCard(users[index], index + 1);
                                },
                                itemCount: users.take(5).length,
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider()),
                ),
                SizedBox(height: 8),
                Container(
                  child: Text('Use referral code',
                      style: TextStyle(
                          color: Colors.blue.withOpacity(0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.w400)),
                ),
                SizedBox(height: 13),
                ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.blue.withOpacity(0.84),
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                  'Your referral code is: ${user.referralCode}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16))),
                          FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Share.share(
                                  'Download Paradox from https://play.google.com/store/apps/details?id=com.exe.paradoxplay and use my referral code: ${user.referralCode} and earn 50 coins.');
                            },
                            child: Text('Share'.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Spacer(),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          Navigator.pushNamed(context, MemberScreen.routeName);
                        },
                        child: Text('Members',
                            style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue.withOpacity(0.85))),
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          Navigator.pushNamed(context, InfoScreen.routeName);
                        },
                        child: Text('Information',
                            style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue.withOpacity(0.85))),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 50,
                  color: Colors.blue.withOpacity(0.85),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                          children: [
                            TextSpan(text: 'Made with '),
                            TextSpan(
                                text: String.fromCharCode(0x2665),
                                style: TextStyle(fontFamily: 'Material Icons')),
                            TextSpan(text: ' by '),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  if (await canLaunch('https://teamexe.in')) {
                                    launch('https://teamexe.in');
                                  } else {
                                    throw 'Could not launch https://teamexe.in';
                                  }
                                },
                              text: 'Team .E',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.lightBlue[900].withAlpha(1000),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  if (await canLaunch('https://teamexe.in')) {
                                    launch('https://teamexe.in');
                                  } else {
                                    throw 'Could not launch https://teamexe.in';
                                  }
                                },
                              text: 'X',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.lightBlue[100],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  if (await canLaunch('https://teamexe.in')) {
                                    launch('https://teamexe.in');
                                  } else {
                                    throw 'Could not launch https://teamexe.in';
                                  }
                                },
                              text: 'E',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.lightBlue[900].withAlpha(1000),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        duration: Duration(milliseconds: 1000),
        builder: (ctx, value, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              return RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent
                      ],
                      radius: value * 5,
                      stops: [0.0, .55, .66, 1.0],
                      center: FractionalOffset(.1, .6))
                  .createShader(rect);
            },
            child: child,
          );
        },
      ),
    );
  }
}

class ParadoxPlayEasy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness =
        Provider.of<ThemeProvider>(context, listen: true).brightnessOption;
    final easyList = Provider.of<QuestionProvider>(context).easyList;
    final level = Provider.of<UserProvider>(context).user.level;
    return GestureDetector(
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: brightness == BrightnessOption.light
              ? Colors.blue.withOpacity(.85)
              : Colors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: brightness == BrightnessOption.light
                ? Colors.lightBlue.shade100
                : Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/logo.png',
                      height: 100, width: 100),
                ),
                Spacer(),
                if (brightness == BrightnessOption.dark)
                  Divider(
                    color: Colors.grey,
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: brightness == BrightnessOption.light
                        ? Colors.blue.withOpacity(.85)
                        : Colors.black,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              if (easyList.length == 0) {
                                createToast(
                                    'No questions present. Please try again later!');
                              } else if (easyList.length < level) {
                                Navigator.pushNamed(
                                    context, StageCompleted.routeName);
                              } else {
                                Navigator.pushNamed(
                                    context, QuestionScreen.routeName);
                              }
                            },
                            child: Text('Easy Level'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2))),
                        FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            if (easyList.length == 0) {
                              createToast(
                                  'No questions present. Please try again later!');
                            } else if (easyList.length < level) {
                              Navigator.pushNamed(
                                  context, StageCompleted.routeName);
                            } else {
                              Navigator.pushNamed(
                                  context, QuestionScreen.routeName);
                            }
                          },
                          child: Text('nimbus'.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2)),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
        width: double.infinity,
      ),
      onTap: () {
        if (easyList.length == 0) {
          createToast('No questions present. Please try again later!');
        } else if (easyList.length < level) {
          Navigator.pushNamed(context, StageCompleted.routeName);
        } else {
          Navigator.pushNamed(context, QuestionScreen.routeName);
        }
      },
    );
  }
}

class ParadoxPlayMedium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness =
        Provider.of<ThemeProvider>(context, listen: true).brightnessOption;
    final mediumList = Provider.of<QuestionProvider>(context).mediumList;
    final easyList = Provider.of<QuestionProvider>(context).easyList;
    final level = Provider.of<UserProvider>(context).user.level;
    return GestureDetector(
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: brightness == BrightnessOption.light
              ? Colors.blue.withOpacity(0.85)
              : Colors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: brightness == BrightnessOption.light
                ? Colors.lightBlue.shade100
                : Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        child: Image.asset('assets/images/logo.png',
                            height: 100, width: 100),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Transform.rotate(
                          angle: pi / 3,
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image.asset('assets/images/logo.png',
                                height: 100, width: 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                if (brightness == BrightnessOption.dark)
                  Divider(
                    color: Colors.grey,
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: brightness == BrightnessOption.light
                        ? Colors.blue.withOpacity(0.85)
                        : Colors.black,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                            onPressed: () {
                              if (mediumList.length == 0) {
                                createToast(
                                    'No questions present. Please try again later!');
                              } else if (easyList.length >= level) {
                                createToast(
                                    'Please complete previous levels first');
                              } else if (mediumList.length <
                                  (level - easyList.length)) {
                                Navigator.pushNamed(
                                    context, StageCompleted.routeName);
                              } else {
                                Navigator.pushNamed(
                                    context, QuestionScreen.routeName);
                              }
                            },
                            child: Text('Medium Level'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2))),
                        FlatButton(
                          onPressed: () {
                            if (mediumList.length == 0) {
                              createToast(
                                  'No questions present. Please try again later!');
                            } else if (easyList.length >= level) {
                              createToast(
                                  'Please complete previous levels first');
                            } else if (mediumList.length <
                                (level - easyList.length)) {
                              Navigator.pushNamed(
                                  context, StageCompleted.routeName);
                            } else {
                              Navigator.pushNamed(
                                  context, QuestionScreen.routeName);
                            }
                          },
                          child: Text('nimbus'.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2)),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
        width: double.infinity,
      ),
      onTap: () {
        if (mediumList.length == 0) {
          createToast('No questions present. Please try again later!');
        } else if (easyList.length >= level) {
          createToast('Please complete previous levels first');
        } else if (mediumList.length < (level - easyList.length)) {
          Navigator.pushNamed(context, StageCompleted.routeName);
        } else {
          Navigator.pushNamed(context, QuestionScreen.routeName);
        }
      },
    );
  }
}

class ParadoxPlayHard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness =
        Provider.of<ThemeProvider>(context, listen: true).brightnessOption;

    final mediumList = Provider.of<QuestionProvider>(context).mediumList;
    final easyList = Provider.of<QuestionProvider>(context).easyList;
    final hardList = Provider.of<QuestionProvider>(context).hardList;
    final level = Provider.of<UserProvider>(context).user.level;
    return GestureDetector(
      child: Container(
        width: double.infinity,
        child: Card(
          color: brightness == BrightnessOption.light
              ? Colors.blue.withOpacity(0.85)
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: brightness == BrightnessOption.light
                ? Colors.lightBlue.shade100
                : Colors.black,
            child: Column(
              children: [
                Spacer(),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Transform.rotate(
                          angle: -pi / 3,
                          child: Container(
                            height: 100,
                            width: 75,
                            child: Image.asset('assets/images/logo.png',
                                height: 100, width: 100),
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 75,
                        child: Image.asset('assets/images/logo.png',
                            height: 100, width: 100),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Transform.rotate(
                          angle: pi / 3,
                          child: Container(
                            height: 100,
                            width: 75,
                            child: Image.asset('assets/images/logo.png',
                                height: 100, width: 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                if (brightness == BrightnessOption.dark)
                  Divider(
                    color: Colors.grey,
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: brightness == BrightnessOption.light
                        ? Colors.blue.withOpacity(0.85)
                        : Colors.black,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                            onPressed: () {
                              if (hardList.length == 0) {
                                createToast(
                                    'No questions present. Please try again later!');
                              } else if (easyList.length + mediumList.length >=
                                  level) {
                                createToast(
                                    'Please complete previous levels first');
                              } else if (hardList.length <
                                  level -
                                      (easyList.length + mediumList.length)) {
                                Navigator.pushNamed(
                                    context, StageCompleted.routeName);
                              } else {
                                Navigator.pushNamed(
                                    context, QuestionScreen.routeName);
                              }
                            },
                            child: Text('Hard Level'.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2))),
                        FlatButton(
                          onPressed: () {
                            if (hardList.length == 0) {
                              createToast(
                                  'No questions present. Please try again later!');
                            } else if (easyList.length + mediumList.length >=
                                level) {
                              createToast(
                                  'Please complete previous levels first');
                            } else if (hardList.length <
                                level - (easyList.length + mediumList.length)) {
                              Navigator.pushNamed(
                                  context, StageCompleted.routeName);
                            } else {
                              Navigator.pushNamed(
                                  context, QuestionScreen.routeName);
                            }
                          },
                          child: Text('nimbus'.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2)),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        print(easyList);
        print(mediumList);
        print(hardList);
        if (hardList.length == 0) {
          createToast('No questions present. Please try again later!');
        } else if (easyList.length + mediumList.length >= level) {
          createToast('Please complete previous levels first');
        } else if (hardList.length <
            level - (easyList.length + mediumList.length)) {
          Navigator.pushNamed(context, StageCompleted.routeName);
        } else {
          Navigator.pushNamed(context, QuestionScreen.routeName);
        }
      },
    );
  }
}
