#!/bin/bash

# pub cache directory
PUB_CACHE="$HOME/.pub-cache"

# Process pub.dev plugins
echo "Processing pub.dev plugins..."
find "$PUB_CACHE/hosted/pub.dev" -maxdepth 2 -type d | while read plugin_dir; do
    ANDROID_DIR="$plugin_dir/android"
    if [ -d "$ANDROID_DIR" ]; then
        for build_file in "$ANDROID_DIR/build.gradle" "$ANDROID_DIR/build.gradle.kts"; do
            if [ -f "$build_file" ]; then
                echo "  $build_file"
                cp "$build_file" "$build_file.bak"
                if grep -q "namespace" "$build_file"; then
                    echo "    Namespace already exists, skipping"
                else
                    # Get the directory name that contains the android directory
                    PLUGIN_DIR=$(dirname "$ANDROID_DIR")
                    # Get the parent directory name as plugin name and remove version number if exists
                    PLUGIN_NAME=$(basename "$PLUGIN_DIR")
                    PLUGIN_NAME=${PLUGIN_NAME%%-*}
                    NAMESPACE="com.example.$PLUGIN_NAME"
                    echo "    Adding namespace=$NAMESPACE"
                    # Create a backup and add namespace after android {
                    sed -i '' 's/android {/android {\
    namespace = "'"$NAMESPACE"'"\
/' "$build_file"
                    
                    # Fix AndroidManifest.xml if it exists
                    manifest_file="$(dirname "$build_file")/src/main/AndroidManifest.xml"
                    if [ -f "$manifest_file" ]; then
                        echo "    Fixing $manifest_file"
                        # Remove package attribute from manifest tag if it exists
                        sed -i '' 's/package="[^"]*"//' "$manifest_file"
                    fi
                fi
            fi
        done
    fi
done

# Process Git plugins
echo "Processing Git plugins..."
find "$PUB_CACHE/git" -type d -name "android" | while read ANDROID_DIR; do
    for build_file in "$ANDROID_DIR/build.gradle" "$ANDROID_DIR/build.gradle.kts"; do
        if [ -f "$build_file" ]; then
            echo "  $build_file"
            cp "$build_file" "$build_file.bak"
            if grep -q "namespace" "$build_file"; then
                echo "    Namespace already exists, skipping"
            else
                # Get the directory name that contains the android directory
                PLUGIN_DIR=$(dirname "$ANDROID_DIR")
                # Get the parent directory name as plugin name and remove version number if exists
                PLUGIN_NAME=$(basename "$PLUGIN_DIR")
                PLUGIN_NAME=${PLUGIN_NAME%%-*}
                NAMESPACE="com.example.$PLUGIN_NAME"
                echo "    Adding namespace=$NAMESPACE"
                # Create a backup and add namespace after android {
                sed -i.bak 's/android {/android {\
    namespace = "'"$NAMESPACE"'"\
/' "$build_file"
                
                # Fix AndroidManifest.xml if it exists
                manifest_file="$(dirname "$build_file")/src/main/AndroidManifest.xml"
                if [ -f "$manifest_file" ]; then
                    echo "    Fixing $manifest_file"
                    # Remove package attribute from manifest tag if it exists
                    sed -i.bak 's/package="[^"]*"//' "$manifest_file"
                fi
            fi
        fi
    done
done

echo "Done!"

