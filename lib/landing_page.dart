import 'package:flutter/material.dart';
import 'detailed_landing_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentPage = 0;

  void _goToNextPage() {
    setState(() {
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentPage == 0 
          ? GestureDetector(
              onTap: _goToNextPage,
              child: DetailLandingPage(isFirstPage: true),
            )
          : DetailLandingPage(isFirstPage: false),
      ),
    );
  }
}