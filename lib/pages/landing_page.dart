// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(
                  () => _currentPage = index,
                ),
                children: [
                  _buildPage(
                    title:
                        "We provide professional service at a friendly price",
                    // "Kami menyediakan jasa profesional dengan harga yang terjangkau",
                    image: "assets/images/handyman_landing_1.png",
                  ),
                  _buildPage(
                    title:
                        // "Hasil terbaik dan kepuasan anda merupakan prioritas utama kami",
                        "The best result and your satisfaction is our top priority",
                    image: "assets/images/handyman_landing_2.png",
                  ),
                  _buildPage(
                    // title: "Ayo buat perubahan hebat untuk rumah mu",
                    title: "Let's make awesome changes to your home",
                    image: "assets/images/handyman_landing_3.png",
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                dotWidth: 10.0,
                dotHeight: 10.0,
                expansionFactor: 4,
                spacing: 4.0,
                activeDotColor: Colors.blueAccent,
                dotColor: Colors.blueGrey.shade900,
              ),
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: nextPage,
              child: Container(
                height: 40,
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(horizontal: 24).copyWith(
                  bottom: 40,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent,
                ),
                child: Center(
                  child: Text(_currentPage < 2 ? 'Next' : 'Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String image,
  }) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 40),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }
}
