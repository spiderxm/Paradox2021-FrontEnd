import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:paradox/models/brightness_options.dart';
import 'package:paradox/providers/stats_provider.dart';
import 'package:paradox/providers/theme_provider.dart';
import 'package:paradox/widgets/customCard.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  static String routeName = "stats-screen";

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    int question = Provider.of<StatsProvider>(context).totalQuestions;
    int users = Provider.of<StatsProvider>(context).totalUsers;
    int attempts = Provider.of<StatsProvider>(context).attempts;
    int answered = Provider.of<StatsProvider>(context).totalQuestionsAnswered;
    final brightness = Provider.of<ThemeProvider>(context).brightnessOption;
    return Scaffold(
        appBar: AppBar(
          title: Text("Global Stats".toUpperCase(),
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: brightness == BrightnessOption.dark ? FontWeight.w300 : FontWeight.w400,
            ),
          ),
          automaticallyImplyLeading: false,
          leading: Container(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: loading
            ? Center(
                child: SpinKitFadingGrid(
                  color: Colors.blue,
                  size: 80,
                ),
              )
            : SafeArea(
                child: Container(
                  child: Column(
                    children: [
                      CustomCard2(
                          heading1: 'Total Users : $users',
                          imagePath: 'assets/images/user.jpg'),
                      CustomCard2(
                          heading1: 'Questions : $question',
                          imagePath: 'assets/images/question.jpeg'),
                      CustomCard2(
                          heading1: 'Attempts : $attempts',
                          imagePath: 'assets/images/attempts.jpg'),
                      CustomCard2(
                          heading1: 'Correctly Attempted : $answered',
                          imagePath: 'assets/images/correct_answer.jpg'),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.blue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.info, color: Colors.blue),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  "This Page uses caching. It may take up-to 2 minutes to update global stats.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    Future.delayed(Duration.zero, () async {
      try {
        await Provider.of<StatsProvider>(context, listen: false)
            .fetchAndSetStats();
        setState(() {
          loading = false;
        });
      } catch (e) {
        Navigator.of(context).pop();
      }
    });
  }
}