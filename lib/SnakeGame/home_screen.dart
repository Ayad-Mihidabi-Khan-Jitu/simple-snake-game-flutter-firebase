import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'highscore_tile.dart';
import 'blank_pixel.dart';
import 'food_pixel.dart';
import 'snake_pixel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SnakeDirection { UP, DOWN, LEFT, RIGHT }

class _HomeScreenState extends State<HomeScreen> {
  //Grid Dimensions
  int rowSize = 15;
  late int totalNumberOfSquares = rowSize * rowSize;

  //game has started
  bool gameHasStarted = false;

  //snake position
  List<int> snakePosition = [0, 1];

  //snake direction
  var currentDirection = SnakeDirection.RIGHT;

  //food position
  int foodPosition = Random().nextInt(100);

  //player score
  int currentScore = 0;

  //player name textfield controller
  final _playerNameController = TextEditingController();
  final _bugReportTextController = TextEditingController();
  final _playerEmailTextController = TextEditingController();

  var time;

  //highscore list
  List<String> highScoreDocIds = [];
  late final Future? letsGetDocIds;

  //initialize bg music
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer audioPlayer1 = AssetsAudioPlayer();

  @override
  void initState() {
    audioPlayer.open(
      Audio('assets/musics/8-bit-Sheriff.mp3'),
      loopMode: LoopMode.single,
      volume: 0.5,
      autoStart: false,
      showNotification: false,
    );
    audioPlayer1.open(
      Audio('assets/musics/game-over.wav'),
      volume: 0.5,
      autoStart: false,
      showNotification: false,
    );
    letsGetDocIds = getDocId();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //getting the doc ids from firestore
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then((value) => value.docs.forEach((element) {
              highScoreDocIds.add(element.reference.id);
            }));
  }

  //Email sending
  Future<void> sendEmail(
      {required String name,
      required String email,
      required String subject,
      required String message}) async {
    final serviceId = 'service_9lca0mc';
    final templateId = 'template_oglglom';
    final userId = 'H_JAtxEIotTxiI14V'; //public key
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_name': name,
            'user_email': email,
            'user_subject': subject,
            'user_message': message,
          }
        }));
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.body),
      ),
    );
  }

  //start game function
  void startGame() {
    gameHasStarted = true;
    audioPlayer.play();
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        time = timer;

        //is game over
        if (isGameOver()) {
          audioPlayer.stop();
          audioPlayer1.play();
          //stop the timer
          timer.cancel();
          //display a message to the player
          displayGameOverDialog();
        }
      });
    });
  }

  //alert dialog display a message to the player
  void displayGameOverDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text('Your Score is ${currentScore.toString()}'),
                  TextField(
                    controller: _playerNameController,
                    decoration: InputDecoration(hintText: 'Name'),
                  )
                ],
              ),
            ),
            actions: [
              MaterialButton(
                  color: Colors.pinkAccent,
                  onPressed: () {
                    Navigator.pop(context);
                    submitScore();
                    newGame();
                  },
                  child: const Text('Submit'))
            ],
          );
        });
  }

  void displayBugReportDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            elevation: 5,
            shadowColor: Colors.pinkAccent,
            backgroundColor: Colors.black,
            title: const Text('Report Here'),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  //Text('Your Score is ${currentScore.toString()}'),
                  TextField(
                    controller: _bugReportTextController,
                    decoration:
                        InputDecoration(hintText: 'Write the problem here..'),
                  ),
                  TextField(
                    controller: _playerEmailTextController,
                    decoration: InputDecoration(hintText: 'Your Email'),
                  ),
                ],
              ),
            ),
            actions: [
              MaterialButton(
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    //send email
                    sendEmail(
                        email: _playerEmailTextController.text,
                        name: _playerNameController.text,
                        message: _bugReportTextController.text,
                        subject: 'bug snake game');
                  },
                  child: const Text('Report')),
              MaterialButton(
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  //submit the player score to the firestore
  void submitScore() {
    //get access to the database
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": _playerNameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highScoreDocIds = [];
    await getDocId();
    setState(() {
      //game has started
      gameHasStarted = false;
      //snake position
      snakePosition = [0, 1];
      //snake direction
      currentDirection = SnakeDirection.RIGHT;
      //food position
      foodPosition = Random().nextInt(100);
      //player score
      currentScore = 0;
    });
  }

  void stopGame() {
    audioPlayer.stop();
    time.cancel();
    newGame();
  }

  void eatFood() {
    currentScore++;
    //making sure that new food is not where the snake is
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(totalNumberOfSquares);
    }
  }

  void howtoplay() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('How to control the Snake',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
            content: SizedBox(
              height: 300,
              child: Image.asset('assets/images/ins.PNG'),
            ),
            actions: [
              MaterialButton(
                  color: Colors.pinkAccent,
                  onPressed: () {
                    Navigator.pop(context);
                    startGame();
                  },
                  child: const Text('Okay'))
            ],
          );
        });
  }

  //move snake to the user direction
  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.RIGHT:
        {
          //add a head and remove a tail
          if (snakePosition.last % rowSize == rowSize - 1) {
            snakePosition.add(snakePosition.last + 1 - rowSize);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          //snakePosition.removeAt(0);
        }
        break;
      case SnakeDirection.LEFT:
        {
          //add a head and remove a tail
          if (snakePosition.last % rowSize == 0) {
            snakePosition.add(snakePosition.last - 1 + rowSize);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          //snakePosition.removeAt(0);
        }
        break;
      case SnakeDirection.UP:
        {
          //add a head and remove a tail
          if (snakePosition.last < rowSize) {
            snakePosition
                .add(snakePosition.last - rowSize + totalNumberOfSquares);
          } else {
            snakePosition.add(snakePosition.last - rowSize);
          }
          //snakePosition.removeAt(0);
        }
        break;
      case SnakeDirection.DOWN:
        {
          //add a head and remove a tail
          if (snakePosition.last + rowSize > totalNumberOfSquares - 1) {
            snakePosition
                .add(snakePosition.last + rowSize - totalNumberOfSquares);
          } else {
            snakePosition.add(snakePosition.last + rowSize);
          }
          //snakePosition.removeAt(0);
        }
        break;
      default:
    }
    if (snakePosition.last == foodPosition) {
      eatFood();
    } else {
      snakePosition.removeAt(0);
    }
  }

  bool isGameOver() {
    List<int> bodySnake = snakePosition.sublist(0, snakePosition.length - 1);
    if (bodySnake.contains(snakePosition.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event.isKeyPressed(LogicalKeyboardKey.keyI) &&
                currentDirection != SnakeDirection.DOWN) {
              currentDirection = SnakeDirection.UP;
            } else if (event.isKeyPressed(LogicalKeyboardKey.keyK) &&
                currentDirection != SnakeDirection.UP) {
              currentDirection = SnakeDirection.DOWN;
            } else if (event.isKeyPressed(LogicalKeyboardKey.keyJ) &&
                currentDirection != SnakeDirection.RIGHT) {
              currentDirection = SnakeDirection.LEFT;
            } else if (event.isKeyPressed(LogicalKeyboardKey.keyL) &&
                currentDirection != SnakeDirection.LEFT) {
              currentDirection = SnakeDirection.RIGHT;
            }
          },
          child: SizedBox(
            width: screenWidth > 428 ? 428 : screenWidth,
            //height: screenHeight > 500 ? 500 : screenHeight,
            child: Column(children: [
              //Your Score & HighScore
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Your Score',
                            style: TextStyle(fontSize: 15)),
                        Text(currentScore.toString(),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow)),
                      ],
                    ),
                    const SizedBox(
                        height: 50,
                        child:
                            VerticalDivider(thickness: 2, color: Colors.white)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Top 5 Scores'),
                        SizedBox(
                          height: 100,
                          width: 105,
                          child: gameHasStarted
                              ? Container()
                              : FutureBuilder(
                                  future: letsGetDocIds,
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: highScoreDocIds.length,
                                        itemBuilder: (context, index) {
                                          return HighScoreTile(
                                              documentId:
                                                  highScoreDocIds[index]);
                                        });
                                  }),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              //GameGrid
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != SnakeDirection.UP) {
                      debugPrint('Swapped down');
                      currentDirection = SnakeDirection.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != SnakeDirection.DOWN) {
                      debugPrint('Swapped up');
                      currentDirection = SnakeDirection.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != SnakeDirection.LEFT) {
                      debugPrint('Swapped right');
                      currentDirection = SnakeDirection.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != SnakeDirection.RIGHT) {
                      debugPrint('Swapped left');
                      currentDirection = SnakeDirection.LEFT;
                    }
                  },
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePosition.contains(index)) {
                        return SnakePixel(
                          listposi: snakePosition,
                          curr: index,
                        );
                      } else if (foodPosition == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    },
                  ),
                ),
              ),

              //PlayButton
              Expanded(
                child: Center(
                  child: MaterialButton(
                    color: gameHasStarted ? Colors.deepOrange : Colors.pink,
                    onPressed: gameHasStarted
                        ? () => stopGame()
                        : () {
                            howtoplay();
                            //startGame();
                          },
                    child: Padding(
                      padding: screenHeight > 400
                          ? EdgeInsets.only()
                          : EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(gameHasStarted ? 'Stop' : 'Play',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  stopGame();
                  displayBugReportDialog();
                },
                child: Text('বাগ থাকলে জিতুকে জানাও',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400])),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
