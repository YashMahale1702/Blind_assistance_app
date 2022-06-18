import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/data_provider.dart';
import './screens/read_pdf_screen.dart';
import './screens/mail_screen.dart';
import './screens/homescreen.dart';
import './screens/maps_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Data(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blind Assistance',
        theme: ThemeData(
          primaryColorDark: const Color(0xff549bc9),
          primaryColorLight: const Color(0xff7599f5),
          scaffoldBackgroundColor: const Color(0xfff2f7fb),
          fontFamily: 'Quicksand',
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        routes: {
          '/': (_) => const HomeScreen(),
          MapsScreen.routeName: (_) => const MapsScreen(),
          ReadPdfScreen.routeName: (_) => const ReadPdfScreen(),
          MailScreen.routeName: (_) => const MailScreen(),
          // MeasureScreen.routeName: (_) => const MeasureScreen(),
        },
      ),
    );
  }
}
