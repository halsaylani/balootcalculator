import 'package:balootcalculator/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ScoreModel.dart';
import 'dqScreen.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key, required this.title});
  final String title;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  double _rotationAngle = 0;
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  late Timer _timer;
  int _secondsPassed = 0;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    final scoreModel = Provider.of<ScoreModel>(context, listen: false);
    scoreModel.onWin = _showWinDialog;
    _loadBannerAd();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsPassed++;
      });
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your actual AdMob ad unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _timer.cancel();
    _bannerAd?.dispose();

    super.dispose();
  }

  String get formattedTime {
    int minutes = _secondsPassed ~/ 60;
    int seconds = _secondsPassed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int getPointsLeftToWin(ScoreModel scoreModel) {
    if (scoreModel.team1Score > scoreModel.team2Score) {
      return scoreModel.winningScore - scoreModel.team1Score;
    } else if (scoreModel.team2Score > scoreModel.team1Score) {
      return scoreModel.winningScore - scoreModel.team2Score;
    } else {
      return scoreModel.winningScore - scoreModel.team1Score;
    }
  }

  void team1QuickAdds(ScoreModel scoreModel, points) {
    scoreModel.addPointsToTeam1(points);
    scoreModel.addPointsToTeam2(0);
    setState(() {
      _rotationAngle -= 90;
    });
  }

  void team2QuickAdds(ScoreModel scoreModel, points) {
    scoreModel.addPointsToTeam2(points);
    scoreModel.addPointsToTeam1(0);
    setState(() {
      _rotationAngle -= 90;
    });
  }

  void addPointsFromControllers(ScoreModel scoreModel) {
    setState(() {
      _rotationAngle -= 90;
    });
    final int team1Points =
        int.tryParse(Util().convertArabicToEnglishNumbers(controller1.text)) ??
            0;
    final int team2Points =
        int.tryParse(Util().convertArabicToEnglishNumbers(controller2.text)) ??
            0;

    if (team1Points > 0 && team2Points <= 0) {
      scoreModel.addPointsToTeam1(team1Points);
      scoreModel.addPointsToTeam2(0);
      controller1.clear();
    }

    if (team2Points > 0 && team1Points <= 0) {
      scoreModel.addPointsToTeam2(team2Points);
      scoreModel.addPointsToTeam1(0);
      controller2.clear();
    }
    if (team2Points > 0 && team1Points > 0) {
      scoreModel.addPointsToTeam1(team1Points);
      scoreModel.addPointsToTeam2(team2Points);
      controller1.clear();
      controller2.clear();
    }
  }

  void _showWinDialog(String team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final scoreModel = Provider.of<ScoreModel>(context, listen: false);

        return Dialog(
          backgroundColor: Util.darkCardColor,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: Util.width(context),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  '$team has won the game!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child:
                        const Text('OK', style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      scoreModel.resetScores();
                      _secondsPassed = 0;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Util.darkCardColor,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 1.9,
            minWidth: MediaQuery.of(context).size.width),
        builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: Util.width(context) / 3,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Util.darkBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () => print('1'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Util.darkBgColor,
                            elevation: 0),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('الارشيف',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                )),
                            Text('قريبا',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: Util.width(context) / 3,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Util.darkBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Util().pop(context);
                          Util().goTo(context, DqScreen());
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Util.darkBgColor,
                            elevation: 0),
                        child: const Text('دق الولد',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final scoreModel = Provider.of<ScoreModel>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Util.darkBgColor,
        appBar: AppBar(
          backgroundColor: Util.darkBgColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              child: const Text('صكة جديدة',
                  style: TextStyle(
                    color: Colors.white70,
                  )),
              onPressed: () {
                scoreModel.resetScores();
                _secondsPassed = 0;
              },
            ),
            TextButton(
              child: const Text('تراجع ',
                  style: TextStyle(
                    color: Colors.white70,
                  )),
              onPressed: () {
                scoreModel.undoLastAction();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: Util.width(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: Util.width(context) / 3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Util.darkCardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('لهم',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30)),
                                    Text('${scoreModel.team2Score}',
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 25)),
                                  ],
                                ),
                                Positioned(
                                  top: -12,
                                  right: -12,
                                  child: PopupMenuButton<int>(
                                    color: Util.darkBgColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (value) {
                                      team2QuickAdds(scoreModel, value);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 16,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('16',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 26,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('26',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 44,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('44',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ],
                                    icon: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 15),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 10),
                        Container(
                          width: Util.width(context) / 3,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Util.darkCardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: controller2,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              final newValue =
                                  Util().convertArabicToEnglishNumbers(value);
                              if (newValue != value) {
                                controller2.text = newValue;
                                controller2.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: controller2.text.length),
                                );
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'أدخل الرقم ٢',
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _rotationAngle -= 90;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(24),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Transform.rotate(
                            angle: _rotationAngle * 3.1415926535 / 180,
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        Text(formattedTime,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18)),
                        Text('${getPointsLeftToWin(scoreModel)}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 25)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            width: Util.width(context) / 3,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Util.darkCardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('لنا',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30)),
                                    Text('${scoreModel.team1Score}',
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 25)),
                                  ],
                                ),
                                Positioned(
                                  top: -12,
                                  right: -12,
                                  child: PopupMenuButton<int>(
                                    color: Colors
                                        .black, // Change dropdown background color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (value) {
                                      team1QuickAdds(scoreModel, value);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 16,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('16',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 26,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('26',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 44,
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Util.darkCardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text('44',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ],
                                    icon: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 15),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 10),
                        Container(
                          width: Util.width(context) / 3,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Util.darkCardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: controller1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              final newValue =
                                  Util().convertArabicToEnglishNumbers(value);
                              if (newValue != value) {
                                controller1.text = newValue;
                                controller1.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: controller1.text.length),
                                );
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'أدخل الرقم ١',
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Util.width(context) / 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Util.darkCardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () => addPointsFromControllers(scoreModel),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Util.darkCardColor,
                      ),
                      child: const Text('سجل',
                          style: TextStyle(
                            color: Colors.white70,
                          )),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: scoreModel.team1Inputs.length >
                          scoreModel.team2Inputs.length
                      ? scoreModel.team1Inputs.length
                      : scoreModel.team2Inputs.length,
                  itemBuilder: (context, index) {
                    String team1Score = '${scoreModel.team1Inputs[index]}';
                    String team2Score = '${scoreModel.team2Inputs[index]}';

                    return SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                team2Score,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                            ),
                          ),
                          // Divider between columns
                          Container(
                            width: 1,
                            color: Util.darkCardColor,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                          ),

                          Expanded(
                            child: Center(
                              child: Text(
                                team1Score,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_isAdLoaded && _bannerAd != null)
                SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  width: _bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
