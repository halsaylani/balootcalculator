import 'package:flutter/material.dart';
import 'screens/ScoreScreen.dart';
import 'package:provider/provider.dart';
import 'models/ScoreModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'models/ThemeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  final themeProvider = ThemeProvider();
  themeProvider.updateStatusBar();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScoreModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const BalootApp(),
    ),
  );
}

class BalootApp extends StatelessWidget {
  const BalootApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.tajawalTextTheme(),
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScoreScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
