import 'package:balootcalculator/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ScoreModel.dart';
import 'dqScreen.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import '../models/ThemeProvider.dart';

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
  final ScreenshotController screenshotController = ScreenshotController();

  late Timer _timer;
  int _secondsPassed = 0;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    final scoreModel = Provider.of<ScoreModel>(context, listen: false);
    scoreModel.onWin = (winningTeam, team1Score, team2Score) {
      _showWinDialog(winningTeam, team1Score, team2Score);
    };
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

  void addPointsFromControllers(ScoreModel scoreModel, context) {
    Util().hideKeyboard(context);
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

  Future<void> _captureAndShare() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture();

      if (imageBytes == null) {
        print("Screenshot failed to capture");
        return;
      }

      // ✅ Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = File('${directory.path}/win_card.png');

      // ✅ Save image
      await imagePath.writeAsBytes(imageBytes);

      print("Screenshot saved to: ${imagePath.path}");

      // ✅ Share image
      await Share.shareXFiles([XFile(imagePath.path)],
          text: '🎉 تحقق من نتيجتي في اللعبة!');
    } catch (e) {
      print('❌ Error capturing & sharing: $e');
    }
  }

  void _showWinDialog(String winningTeam, int team1Score, int team2Score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final scoreModel = Provider.of<ScoreModel>(context, listen: false);

        _timer.cancel();

        // Format elapsed time
        int minutes = _secondsPassed ~/ 60;
        int seconds = _secondsPassed % 60;
        String formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        // Determine the losing team dynamically
        String losingTeam = winningTeam == "لنا" ? "لهم" : "لنا";
        int winningScore = winningTeam == "لنا" ? team1Score : team2Score;
        int losingScore = winningTeam == "لنا" ? team2Score : team1Score;

        return Screenshot(
          controller: screenshotController,
          child: Dialog(
            backgroundColor: Util.darkCardColor,
            insetPadding: EdgeInsets.zero,
            child: Container(
              width: Util.width(context),
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.ios_share,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            await _captureAndShare();
                          },
                        ),
                        const Text(
                          'إنتهت الصكّة',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        ' 🥳 مبرووك فريق',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$winningTeam | $winningScore',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        ' 😞 هارد لك فريق ',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$losingTeam | $losingScore',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${Util.getFormattedDate()} ',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '⏳  $formattedTime ',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        child: const Text('صكّة جديدة',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          scoreModel.resetScores();
                          _startTimer();
                          setState(() {
                            _secondsPassed = 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: themeProvider.cardColor,
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
                        color: themeProvider.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () => print('1'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: themeProvider.bgColor,
                            overlayColor: Colors
                                .transparent, // ✅ Fixes deprecation warning
                            shadowColor: Colors.transparent,
                            elevation: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('الارشيف',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: themeProvider.text2Color,
                                )),
                            Text('قريبا',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: themeProvider.text2Color,
                                ))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: Util.width(context) / 3,
                      height: 100,
                      decoration: BoxDecoration(
                        color: themeProvider.bgColor,
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
                            backgroundColor: themeProvider.bgColor,
                            overlayColor: Colors
                                .transparent, // ✅ Fixes deprecation warning
                            shadowColor: Colors.transparent,
                            elevation: 0),
                        child: Text('دق الولد',
                            style: TextStyle(
                              fontSize: 20,
                              color: themeProvider.textColor,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.updateStatusBar();

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeProvider.bgColor, // Util.darkBgColor,
        appBar: AppBar(
          backgroundColor: themeProvider.bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.sunny : Icons.dark_mode,
            ),
            color: themeProvider.text2Color,
            iconSize: 20,
            onPressed: () => themeProvider.toggleTheme(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: themeProvider.cardColor,
            ),
          ),
          actions: [
            TextButton(
              child: Text('صكّة جديدة',
                  style: TextStyle(
                    color: themeProvider.text2Color,
                  )),
              onPressed: () {
                scoreModel.resetScores();
                _secondsPassed = 0;
                setState(() {
                  _rotationAngle -= 90;
                });
              },
            ),
            TextButton(
              child: Text('تراجع ',
                  style: TextStyle(
                    color: themeProvider.text2Color,
                  )),
              onPressed: () {
                scoreModel.undoLastAction();
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined,
                  size: 20, color: themeProvider.text2Color),
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => Util().hideKeyboard(context),
          child: Padding(
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
                                color: themeProvider.cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('لهم',
                                          style: TextStyle(
                                              color: themeProvider.textColor,
                                              fontSize: 30)),
                                      Text('${scoreModel.team2Score}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 25)),
                                    ],
                                  ),
                                  Positioned(
                                    top: -12,
                                    right: -12,
                                    child: PopupMenuButton<int>(
                                      color: themeProvider.bgColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onOpened: () {
                                        FocusScope.of(context).requestFocus(
                                            FocusNode()); // ✅ Force unfocus before opening
                                      },
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('16',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('26',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('44',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: controller2,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: themeProvider.text2Color),
                              onChanged: (value) {
                                final newValue =
                                    Util().convertArabicToEnglishNumbers(value);
                                if (newValue != value) {
                                  controller2.text = newValue;
                                  controller2.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: controller2.text.length),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'أدخل الرقم ٢',
                                hintStyle:
                                    TextStyle(color: themeProvider.text2Color),
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
                                backgroundColor: themeProvider.bgColor,
                                elevation: 0),
                            child: Transform.rotate(
                              angle: _rotationAngle * 3.1415926535 / 180,
                              child: Icon(
                                Icons.arrow_downward,
                                color: themeProvider.textColor,
                                size: 50,
                              ),
                            ),
                          ),
                          Text(formattedTime,
                              style: TextStyle(
                                  color: themeProvider.text2Color,
                                  fontSize: 18)),
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
                                color: themeProvider.cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('لنا',
                                          style: TextStyle(
                                              color: themeProvider.textColor,
                                              fontSize: 30)),
                                      Text('${scoreModel.team1Score}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 25)),
                                    ],
                                  ),
                                  Positioned(
                                    top: -12,
                                    right: -12,
                                    child: PopupMenuButton<int>(
                                      color: themeProvider
                                          .bgColor, // Change dropdown background color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onOpened: () {
                                        FocusScope.of(context).requestFocus(
                                            FocusNode()); // ✅ Force unfocus before opening
                                      },
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('16',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('26',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                                                color: themeProvider.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('44',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: themeProvider
                                                          .textColor)),
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
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: controller1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: themeProvider.textColor),
                              onChanged: (value) {
                                final newValue =
                                    Util().convertArabicToEnglishNumbers(value);
                                if (newValue != value) {
                                  controller1.text = newValue;
                                  controller1.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: controller1.text.length),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'أدخل الرقم ١',
                                hintStyle:
                                    TextStyle(color: themeProvider.text2Color),
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
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            addPointsFromControllers(scoreModel, context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: themeProvider.cardColor,
                          overlayColor:
                              Colors.transparent, // ✅ Fixes deprecation warning
                          shadowColor: Colors.transparent,
                        ),
                        child: Text('سجل',
                            style: TextStyle(
                              color: themeProvider.text2Color,
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
                                  style: TextStyle(
                                      color: themeProvider.text2Color,
                                      fontSize: 30),
                                ),
                              ),
                            ),
                            // Divider between columns
                            Container(
                              width: 1,
                              color: themeProvider.text2Color,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            ),

                            Expanded(
                              child: Center(
                                child: Text(
                                  team1Score,
                                  style: TextStyle(
                                      color: themeProvider.text2Color,
                                      fontSize: 30),
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
      ),
    );
  }
}
