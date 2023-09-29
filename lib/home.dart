import 'dart:async';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Balloon> balloons = [];
  final List<Color> colors = [Colors.blue, Colors.red];
  Timer? timer;
  final int clusterSize = 3; // Number of balloons in each cluster
  final audioCache = AudioCache();

  @override
  void initState() {
    super.initState();
    getRandomBalloonColor();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final random = Random();
      final clusterSize = random.nextInt(4) + 6;
      for (int i = 0; i < clusterSize; i++) {
        final color = getRandomBalloonColor();
        final text = generateRandomText();
        balloons.add(Balloon(color, text));
      }
      setState(() {});
    });
  }

  Color getRandomBalloonColor() {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  String generateRandomText() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String text = '';

    for (int i = 0; i < 1; i++) {
      text += letters[random.nextInt(letters.length)];
    }

    return text;
  }

  void popBalloon(int index) {
    final balloonColor = balloons[index].color;
    if (balloonColor == Colors.red) {
      setState(() {
        playBalloonBurstSound();
        balloons.removeAt(index);
        Fluttertoast.showToast(
          msg: 'Balloon Burst!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      });
    } else if (balloonColor == Colors.blue) {
      setState(() {
        playBalloonBurstSound();
        balloons.removeAt(index);
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Wrong Color!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void playBalloonBurstSound() {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/song.mp3"),
      autoStart: true,
      showNotification: true,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height * 1.0,
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            image: AssetImage("assets/yellow.png"),
          ),
        ),
        child: Stack(
          children: [
            for (int i = 0; i < balloons.length; i++)
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                curve: Curves.linear,
                bottom: i * 100.0,
                left: Random().nextInt(300).toDouble(),
                child: GestureDetector(
                  onTap: () => popBalloon(i),
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        "assets/balloon.svg",
                        height: 90,
                        width: 90,
                        color: balloons[i].color,
                      ),
                      Positioned(
                        top: 20,
                        left: 30,
                        right: 10,
                        child: Text(
                          balloons[i].text,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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


class Balloon {
  final Color color;
  final String text;

  Balloon(this.color, this.text);
}
