import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'signup_page.dart';
import 'signin_page.dart';
import 'track_page.dart';
import 'profile_page.dart'; // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headlineMedium: AppStyles.headlineStyle,
          bodyLarge: AppStyles.bodyStyle,
          bodyMedium: AppStyles.bodyStyle,
        ),
      ),
      home: MyHomePage(title: AppStrings.appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _linkController = TextEditingController();
  bool _showBox = false;

  void _convertLink() {
    String link = _linkController.text.trim().toLowerCase();
    if (link.isEmpty || link == "track2") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrackPage(trackId: "USUM71207190")),
      );
    } else if (link == "track1") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrackPage(trackId: "AUAP07600012")),
      );
    } else {
      // TODO: Implement API call for other cases
      print('Converting link: $link');
    }
  }

  void _toggleBoxVisibility() {
    setState(() {
      _showBox = !_showBox;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        clipBehavior: Clip.antiAlias,
        decoration: AppStyles.mainContainerDecoration,
        child: Stack(
          children: [
            // Logo
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.245),
                width: MediaQuery.of(context).size.width * AppSizes.cassetteNameLogoWidth,
                height: MediaQuery.of(context).size.height * AppSizes.cassetteNameLogoHeight,
                child: Image.asset(
                  'lib/assets/images/cassette_name_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Input Field
            Positioned(
              left: MediaQuery.of(context).size.width * 0.136,
              top: MediaQuery.of(context).size.height * 0.462,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.729,
                height: MediaQuery.of(context).size.height * 0.053,
                child: TextField(
                  controller: _linkController,
                  decoration: AppStyles.textFieldDecoration,
                ),
              ),
            ),
            // Convert Button and Info Icon
            Positioned(
              left: MediaQuery.of(context).size.width * 0.336,
              top: MediaQuery.of(context).size.height * 0.544,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _convertLink,
                    style: AppStyles.elevatedButtonStyle.copyWith(
                      fixedSize: WidgetStateProperty.all(Size(
                        MediaQuery.of(context).size.width * 0.322,
                        MediaQuery.of(context).size.height * 0.050,
                      )),
                    ),
                    child: const Text(
                      AppStrings.convertButtonText,
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _toggleBoxVisibility,
                    child: const Icon(Icons.info_outline,
                        size: 28, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            // Box with additional text and buttons
            Visibility(
              visible: _showBox,
              child: Positioned(
                left: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.625,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.textPrimary, width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.infoBoxTitle,
                        style: AppStyles.headlineStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${AppStrings.infoBoxContent.split('\n\n')[0]}\n\n',
                              style: AppStyles.bodyStyleBold,
                            ),
                            TextSpan(
                              text: AppStrings.infoBoxContent.split('\n\n')[1],
                              style: AppStyles.bodyStyle,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sign In Button
            Positioned(
              left: MediaQuery.of(context).size.width * 0.255,
              top: MediaQuery.of(context).size.height * 0.1, // Adjusted position
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SigninPage()),
                  );
                },
                child: const Text(
                  AppStrings.signInText,
                  style: AppStyles.signInTextStyle,
                ),
              ),
            ),
            // Sign Up Button
            Positioned(
              left: MediaQuery.of(context).size.width * 0.530,
              top: MediaQuery.of(context).size.height * 0.093, // Adjusted position
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                style: AppStyles.elevatedButtonStyle.copyWith(
                  fixedSize: WidgetStateProperty.all(Size(
                    MediaQuery.of(context).size.width * 0.255,
                    MediaQuery.of(context).size.height * 0.039,
                  )),
                ),
                child: const Text(
                  AppStrings.signUpText,
                  style: AppStyles.signUpTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
