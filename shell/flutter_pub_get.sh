#!/bin/bash

flutter clean 
# Check if melos is installed
if ! command -v melos &> /dev/null; then
    echo "Melos is not installed. Installing Melos..."
    dart pub global activate melos
    
    # Check if melos was installed successfully
    if ! command -v melos &> /dev/null; then
        echo "Failed to install Melos. Please install it manually by running:"
        echo "dart pub global activate melos"
        echo "And make sure to add Dart's pub-cache bin directory to your PATH."
        echo "On macOS/Linux, add this to your ~/.zshrc or ~/.bashrc:"
        echo "export PATH="\$PATH":"\$HOME/.pub-cache/bin""
        exit 1
    fi
fi

echo "Syncing dependency overrides..."
dart run tool/sync_versions.dart

echo "Running melos pub_get..."
melos pub_get
sh add_namespace_all.sh
