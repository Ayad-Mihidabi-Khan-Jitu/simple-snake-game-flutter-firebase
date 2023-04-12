import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  int rowSize = 12;
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

  var time;

  //highscore list
  List<String> highScoreDocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
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

  //start game function
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        time = timer;

        //is game over
        if (isGameOver()) {
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

  void stopGame(){
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

  void howtoplay(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('How to control the Snake',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.pink)),
            content: SizedBox(
              height: 300,
              child: Image.asset('assets/ins.PNG'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event){
          if(event.isKeyPressed(LogicalKeyboardKey.keyI) && currentDirection!= SnakeDirection.DOWN)
          {
            currentDirection = SnakeDirection.UP;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyK) && currentDirection!= SnakeDirection.UP)
          {
            currentDirection = SnakeDirection.DOWN;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyJ) && currentDirection!= SnakeDirection.RIGHT)
          {
            currentDirection = SnakeDirection.LEFT;
          }
          else if(event.isKeyPressed(LogicalKeyboardKey.keyL) && currentDirection!= SnakeDirection.LEFT){
            currentDirection = SnakeDirection.RIGHT;
          }

        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(children: [
            //Your Score & HighScore
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Your Score', style: TextStyle(fontSize: 15)),
                      Text(currentScore.toString(),
                          style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.yellow)),
                    ],
                  ),
                  const SizedBox(height:50, child: VerticalDivider(thickness: 2, color: Colors.white)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Top Scores'),
                      SizedBox(
                        height: 100,
                        width: 105,
                        child: gameHasStarted
                              ? Container()
                              : FutureBuilder(
                                  future: letsGetDocIds,
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                        itemCount: highScoreDocIds.length,
                                        itemBuilder: (context, index) {
                                          return HighScoreTile(
                                              documentId: highScoreDocIds[index]);
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
                  color: gameHasStarted ? Colors.orange : Colors.pink,
                  onPressed: gameHasStarted ? () => stopGame() : (){
                      howtoplay();
                      //startGame();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 8),
                    child: Text(gameHasStarted ? 'Stop': 'Play', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),
            Text('বাগ থাকলে জিতুকে জানাও', style: TextStyle(fontSize: 15,color: Colors.grey[600])),
          ]),
        ),
      ),
    );
  }
}
