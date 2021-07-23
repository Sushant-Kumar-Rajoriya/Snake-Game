import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var myBackgroundColor = Colors.brown[700];
  var myBackgroundColorLite = Colors.brown[400];

  var myBackgroundColorBlack = Colors.black;

  var snakeColor = Colors.white;
  var foodColor = Colors.lightGreenAccent;

  bool mode = true;

  bool isGameStarted = false;
  static List<int> snakePosition = [
    45,
    65,
    85,
  ];
  static int numberOfSquares = 900;
  int calSquares() {
    String height =
        (MediaQuery.of(context).size.height).toString().split('.').first;

    String first = height.substring(0, height.length - 2);
    int m = int.parse(height.substring(height.length - 2, height.length - 1));
    if (m % 2 != 0) {
      m--;
    }
    String middle = m.toString();
    String last = '0';

    return int.parse(first + middle + last);
  }

  static var randomNumber = Random();
  int food = randomNumber.nextInt(200);

  void generateNewFood() {
    HapticFeedback.mediumImpact();
    food = randomNumber.nextInt(numberOfSquares);
  }

  int speed = 300;
  void startGame() {
    speed = 300;
    HapticFeedback.mediumImpact();
    numberOfSquares = calSquares() - 100;
    isGameStarted = true;
    snakePosition = [
      45,
      65,
      85,
    ];
    Timer.periodic(Duration(milliseconds: speed), (timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        isGameStarted = false;
        _showGameOverScreen();
      }
    });
  }

  var direction = 'down';
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > (numberOfSquares - 20)) {
            snakePosition.add(snakePosition.last + 20 - numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up':
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + numberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;

        default:
      }
      if (snakePosition.last == food) {
        generateNewFood();
        speedIncrement();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  void speedIncrement() {
    if (speed > 2) {
      speed--;
    }
  }

  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count++;
        }
      }
      if (count > 1) {
        return true;
      }
    }
    return false;
  }

  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop();
            },
            child: AlertDialog(
              backgroundColor:
                  mode ? myBackgroundColor : myBackgroundColorBlack,
              title: Center(
                  child: Text(
                'GAME OVER',
                style: TextStyle(color: foodColor),
              )),
              content: Text(
                "Your Score = " + (snakePosition.length - 3).toString(),
                style: GoogleFonts.alike(color: snakeColor, fontSize: 30),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mode ? myBackgroundColor : myBackgroundColorBlack,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: mode ? myBackgroundColorLite : Colors.white10,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  "Score : " + (snakePosition.length - 3).toString(),
                  style: GoogleFonts.alike(color: snakeColor, fontSize: 25),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (direction != 'up' && details.delta.dy > 0) {
                          // HapticFeedback.mediumImpact();
                          direction = 'down';
                        } else if (direction != 'down' &&
                            details.delta.dy < 0) {
                          //  HapticFeedback.mediumImpact();
                          direction = 'up';
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (direction != 'left' && details.delta.dx > 0) {
                          //HapticFeedback.mediumImpact();
                          direction = 'right';
                        } else if (direction != 'right' &&
                            details.delta.dx < 0) {
                          //HapticFeedback.mediumImpact();
                          direction = 'left';
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: numberOfSquares,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 20),
                          itemBuilder: (BuildContext context, int index) {
                            if (snakePosition.contains(index)) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      color: snakeColor,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (index == food) {
                              return Container(
                                padding: EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    color: foodColor,
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                padding: EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    color: mode
                                        ? myBackgroundColorLite
                                        : myBackgroundColorBlack,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment(0, 0),
                      child: isGameStarted
                          ? Text("")
                          : GestureDetector(
                              onTap: startGame,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: snakeColor,
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 80,
                                  color: mode
                                      ? myBackgroundColor
                                      : myBackgroundColorBlack,
                                ),
                              ),
                            ),
                    ),
                    Container(
                      alignment: Alignment(0, 0.4),
                      child: isGameStarted
                          ? Text("")
                          : GestureDetector(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  mode = !mode;
                                });
                              },
                              child: Container(
                                height: 45,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: snakeColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Switch-Modes',
                                      style: GoogleFonts.alike(
                                          color: mode
                                              ? myBackgroundColor
                                              : myBackgroundColorBlack,
                                          fontSize: 20),
                                    ),
                                    Icon(
                                      Icons.swap_calls_sharp,
                                      size: 30,
                                      color: mode
                                          ? myBackgroundColor
                                          : myBackgroundColorBlack,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
