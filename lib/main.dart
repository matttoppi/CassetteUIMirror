import 'package:cassettefrontend/profile_page.dart';
import 'package:cassettefrontend/signin_page.dart';
import 'package:cassettefrontend/signup_page.dart';
import 'package:cassettefrontend/track_page.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'styles/app_styles.dart';
import 'constants/app_constants.dart';
import 'services/router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:cassettefrontend/services/spotify_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  //testing
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      debug: true,
    );
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  final supabase = Supabase.instance.client;

  setPathUrlStrategy(); // removes the '#' from the URL
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = router; 
    _handleInitialUri();
  }

  void _handleInitialUri() {
    final uri = Uri.base;
    if (uri.path == '/spotify_callback') {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      _handleSpotifyCallback(code, error);
    }
  }

  void _handleSpotifyCallback(String? code, String? error) async {
    if (code != null) {
      try {
        await SpotifyService.exchangeCodeForToken(code);
        print('Successfully exchanged code for token');
      } catch (e) {
        print('Error exchanging code for token: $e');
      }
    } else if (error != null) {
      print('Spotify auth error: $error');
    }
    // Navigate to profile page
    _router.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Cassette App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _linkController = TextEditingController();
  bool _showBox = false;

  void _convertLink() async {
    String link = _linkController.text.trim().toLowerCase();
    if (link.isEmpty || link == "track2") {
      context.push('/track/track1');
    } else if (link == "track1") {
      context.push('/track/track2');
    } else if (link == "track3") {
      context.push('/track/track3');
    } else {
      context.push('/track/$link');
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Set to 0 as we'll manually position the profile icon
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        clipBehavior: Clip.antiAlias,

        // Main container for the home page
        // Includes the Cassette logo and name
        // The logo size is responsive based on screen dimensions
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
            // Centered Sign In and Sign Up buttons
            Positioned(
              top: 35,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.push('/signin'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(120, 45),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      AppStrings.signInText,
                      style: AppStyles.signInTextStyle,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  ElevatedButton(
                    onPressed: () => context.push('/signup'),
                    style: AppStyles.elevatedButtonStyle.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(120, 45)),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                    ),
                    child: const Text(
                      AppStrings.signUpText,
                      style: AppStyles.signUpTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            // Profile Icon
            Positioned(
              right: 35,
              top: 35,
              child: GestureDetector(
                onTap: () {
                  context.push('/profile');
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
