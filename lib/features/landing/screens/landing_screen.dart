import "package:firechat/common/utils/colors.dart";
import "package:firechat/common/widgets/custom_button.dart";
import "package:firechat/features/auth/screens/login_screen.dart";
import "package:flutter/material.dart";

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: size.width,
            ),
            Text(
              'Welcome to FireChat',
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: size.height / 9,
            ),
            Image.asset(
              'assets/bg.png',
              width: size.width * 90 / 100,
              height: size.width * 90 / 100,
            ),
            SizedBox(
              height: size.height / 9,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
                "Read our Privacy Policy: Tap \"Accept and Continue\" to accept the terms of Service.",
                style: TextStyle(
                  color: greyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: size.width * 0.75,
              child: CustomButton(
                text: "AGREE AND CONTINUE", 
                onPressed: () => navigateToLoginScreen(context)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
