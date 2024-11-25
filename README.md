# CassetteFrontEnd
 

Cassette is a music-focused social media application built with Flutter. This README will guide you through setting up and running the project.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

## Running the App

1. Connect a device or start an emulator.

2. Run the app:
   
   flutter run -d chrome --web-port=56752
   It is important to run on the same port that is specified in the spotify dashboard redirect URI list (current port is 56752)

## Project Structure

- `lib/`: Contains the main Dart code for the application.
- `lib/assets/`: Stores images and other static assets.
- `lib/constants/`: Holds constant values used throughout the app.
- `lib/styles/`: Contains app-wide styling definitions.
- `lib/services/`: Includes service classes for API interactions.


## Styling

The app uses a centralized styling approach. All styles are defined in:

dart:lib/styles/app_styles.dart

## Constants

App-wide constants, including colors and sizes, are defined in:

dart:lib/constants/app_constants.dart

