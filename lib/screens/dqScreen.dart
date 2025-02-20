import 'package:balootcalculator/screens/ScoreScreen.dart';
import 'package:balootcalculator/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../models/ThemeProvider.dart';
import 'package:provider/provider.dart';

class DqScreen extends StatefulWidget {
  @override
  _DqScreenState createState() => _DqScreenState();
}

class _DqScreenState extends State<DqScreen> {
  final TextEditingController controller1 = TextEditingController();
  final FocusNode focusNode = FocusNode();

  List<String> players = [];

  void playersAdded() {
    if (controller1.text.isNotEmpty) {
      setState(() {
        players.add(controller1.text);
        controller1.clear();
      });
      // Keep the focus on the TextField
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    controller1.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void openBottomSheet() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Hide keyboard
    Util().hideKeyboard(context);
    if (players.length >= 4) {
      // Show a loader for 2 seconds
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: themeProvider.text2Color, // Loader color
            ),
          );
        },
      );

      // Wait for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Close the loader
      Navigator.pop(context);

      // Shuffle the players list randomly
      players.shuffle(Random());
      // 4 playrs to be shufled
      List<String> selectedPlayers = players.take(4).toList();

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: themeProvider.cardColor,
        constraints: BoxConstraints(
            // maxHeight: MediaQuery.of(context).size.height / 1,
            minWidth: MediaQuery.of(context).size.width),
        builder: (BuildContext context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lottie animation in the center
                Lottie.asset(
                  'images/dqIcon.json',
                  width: 300,
                  height: 300,
                ),

                // Top player
                Positioned(
                  top: 100,
                  child: Text(
                    selectedPlayers[0],
                    style: TextStyle(
                        color: themeProvider.text2Color, fontSize: 20),
                  ),
                ),

                // Bottom player
                Positioned(
                  bottom: 100,
                  child: Text(
                    selectedPlayers[1],
                    style: TextStyle(
                        color: themeProvider.text2Color, fontSize: 20),
                  ),
                ),

                // Left player
                Positioned(
                  left: 40,
                  child: Text(
                    selectedPlayers[2],
                    style: TextStyle(
                        color: themeProvider.text2Color, fontSize: 20),
                  ),
                ),

                // Right player
                Positioned(
                  right: 40,
                  child: Text(
                    selectedPlayers[3],
                    style: TextStyle(
                        color: themeProvider.text2Color, fontSize: 20),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: Util.width(context) / 1.5,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Util().pop(context);
                        Util().pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('ابدأ الصكّة',
                          style: TextStyle(
                            color: Colors.white70,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // If less than 4 players, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يجب إضافة ٤ لاعبين على الأقل!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.updateStatusBar();
    return GestureDetector(
      onTap: () => Util().hideKeyboard(context),
      child: Scaffold(
        backgroundColor: themeProvider.bgColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Util().pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: themeProvider.text2Color,
            ),
          ),
          backgroundColor: themeProvider.bgColor,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                players.length.toString(),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 30,
                ),
              ),
              Container(
                width: Util.width(context) / 1.5,
                height: 50,
                decoration: BoxDecoration(
                  color: themeProvider.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller1,
                  focusNode: focusNode,
                  onSubmitted: (value) {
                    playersAdded();
                  },
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'اسم اللاعب',
                    hintStyle: TextStyle(color: themeProvider.text2Color),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: Util.width(context) / 3,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () => playersAdded(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('سجل',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: Util.width(context) / 3,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          if (players.isNotEmpty) {
                            players.removeLast();
                          }
                        }),
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
                        child: Text('تراجع',
                            style: TextStyle(
                              color: themeProvider.text2Color,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: Util.width(context) / 3,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          players.clear();
                        }),
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
                        child: Text('حذف الكل',
                            style: TextStyle(
                              color: themeProvider.text2Color,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: ListTile(
                        trailing: Icon(
                          Icons.circle,
                          color: themeProvider.cardColor,
                          size: 15,
                        ),
                        title: Text(
                          players[index],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: Util.width(context) / 1.5,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () => openBottomSheet(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('دِق الولد',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
