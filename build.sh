#!/bin/bash

   set -e
   set -x

   echo "Current directory: $(pwd)"
   echo "Listing directory contents:"
   ls -la

   echo "Cloning Flutter SDK..."
   git clone https://github.com/flutter/flutter.git
   
   echo "Updating PATH..."
   export PATH="$PATH:`pwd`/flutter/bin"
   
   echo "Flutter version:"
   flutter --version
   
   echo "Running flutter pub get..."
   flutter pub get
   
   echo "Building Flutter web project..."
   flutter build web

   echo "Build completed. Listing build/web directory:"
   ls -la build/web