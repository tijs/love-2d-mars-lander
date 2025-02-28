#!/bin/bash

# Mars Lander - macOS Build Script
# This script automates the process of creating a macOS application bundle for the Mars Lander game

# Exit on error
set -e

# Configuration
GAME_NAME="Mars Lander"
BUNDLE_ID="org.tijs.marslander"
VERSION_FILE=".version"
COPYRIGHT="© 2025 Tijs Teulings"
LOVE_APP="/Applications/love.app"
OUTPUT_DIR="./dist"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "=== Building $GAME_NAME for macOS ==="
echo ""

# Get the last used version number or use default
LAST_VERSION="1.0"
if [ -f "$VERSION_FILE" ]; then
    LAST_VERSION=$(cat "$VERSION_FILE")
fi

# Ask for version number
read -p "Enter version number [$LAST_VERSION]: " VERSION
VERSION=${VERSION:-$LAST_VERSION}

# Save the version number for next time
echo "$VERSION" > "$VERSION_FILE"

echo "Building version $VERSION"
echo ""

# Step 1: Create .love file
echo "Step 1: Creating .love file..."
if [ -f "$OUTPUT_DIR/$GAME_NAME.love" ]; then
    rm "$OUTPUT_DIR/$GAME_NAME.love"
fi

# Exclude unnecessary files from the .love package
zip -9 -r "$OUTPUT_DIR/$GAME_NAME.love" . -x "*.git*" "*.DS_Store" "*.vscode*" "*.love" "dist/*" "scripts/*" "Mars Lander.app/*" "Mars Lander-macOS.zip" ".version"
echo "Created $OUTPUT_DIR/$GAME_NAME.love"
echo ""

# Step 2: Create a copy of the LÖVE application
echo "Step 2: Creating application bundle..."
APP_BUNDLE="$OUTPUT_DIR/$GAME_NAME.app"

# Remove existing app bundle if it exists
if [ -d "$APP_BUNDLE" ]; then
    rm -rf "$APP_BUNDLE"
fi

# Copy the LÖVE.app to our new app bundle
cp -R "$LOVE_APP" "$APP_BUNDLE"
echo "Created $APP_BUNDLE"
echo ""

# Step 3: Copy the .love file into the app bundle
echo "Step 3: Copying .love file into app bundle..."
cp "$OUTPUT_DIR/$GAME_NAME.love" "$APP_BUNDLE/Contents/Resources/"
echo "Copied $GAME_NAME.love to app bundle"
echo ""

# Step 4: Modify the Info.plist file
echo "Step 4: Updating Info.plist..."
PLIST_FILE="$APP_BUNDLE/Contents/Info.plist"

# Use PlistBuddy to modify the Info.plist file
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$PLIST_FILE"
/usr/libexec/PlistBuddy -c "Set :CFBundleName $GAME_NAME" "$PLIST_FILE"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST_FILE"
/usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright $COPYRIGHT" "$PLIST_FILE"

# Remove UTExportedTypeDeclarations to prevent association with all .love files
if /usr/libexec/PlistBuddy -c "Print :UTExportedTypeDeclarations" "$PLIST_FILE" &>/dev/null; then
    /usr/libexec/PlistBuddy -c "Delete :UTExportedTypeDeclarations" "$PLIST_FILE"
    echo "Removed UTExportedTypeDeclarations from Info.plist"
fi

echo "Updated Info.plist"
echo ""

# Step 5: Create a distributable ZIP file
echo "Step 5: Creating distributable ZIP file..."
ZIP_FILE="$OUTPUT_DIR/$GAME_NAME-macOS.zip"

# Remove existing zip file if it exists
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# Create the ZIP file with the -y flag to preserve symbolic links
(cd "$OUTPUT_DIR" && zip -y -r "$GAME_NAME-macOS.zip" "$GAME_NAME.app")
echo "Created $ZIP_FILE"
echo ""

# Step 6: Create a git tag for this version
echo "Step 6: Creating git tag for version $VERSION..."
TAG_NAME="v$VERSION"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    read -p "Tag $TAG_NAME already exists. Overwrite? (y/n): " OVERWRITE
    if [ "$OVERWRITE" = "y" ]; then
        git tag -d "$TAG_NAME"
        git tag -a "$TAG_NAME" -m "Version $VERSION release"
        echo "Overwritten tag $TAG_NAME"
    else
        echo "Skipped creating tag $TAG_NAME"
    fi
else
    git tag -a "$TAG_NAME" -m "Version $VERSION release"
    echo "Created tag $TAG_NAME"
fi

# Ask if the tag should be pushed
read -p "Push tag to remote repository? (y/n): " PUSH_TAG
if [ "$PUSH_TAG" = "y" ]; then
    git push origin "$TAG_NAME"
    echo "Pushed tag $TAG_NAME to remote repository"
fi

echo ""
echo "=== Build completed successfully! ==="
echo "Version: $VERSION"
echo "Application bundle: $APP_BUNDLE"
echo "Distributable ZIP: $ZIP_FILE"
echo "Git tag: $TAG_NAME"
echo ""
echo "You can distribute the ZIP file to macOS users."
