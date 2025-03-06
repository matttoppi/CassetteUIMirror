#!/bin/bash

set -e
set -x

echo "Current directory: $(pwd)"
echo "Listing directory contents:"
ls -la

echo "Building Flutter web project..."
flutter/bin/flutter build web --release \
  --dart-define=API_ENV="${API_ENV:-prod}" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SPOTIFY_CLIENT_ID="$SPOTIFY_CLIENT_ID" \
  --dart-define=SPOTIFY_CLIENT_SECRET="$SPOTIFY_CLIENT_SECRET"

echo "Build completed. Listing build/web directory:"
ls -la build/web