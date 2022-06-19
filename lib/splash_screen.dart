import 'dart:async';
import 'package:flutter/material.dart';
import 'second.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Second(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img.png',
              height: MediaQuery.of(context).size.height * 0.65,
            ),
            Container(
              height: 100,
              child: VerticalDivider(
                thickness: 2.5,
                color: Colors.amber[700],
                width: 60,
              ),
            ),
            Text(
              'Fire Fighter',
              style: Theme.of(context).textTheme.headline3.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
