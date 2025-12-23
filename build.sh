#!/bin/bash
set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Setup Flutter
echo "Setting up Flutter..."
flutter doctor
flutter config --enable-web

# Build the web app
echo "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "Build completed successfully!"
