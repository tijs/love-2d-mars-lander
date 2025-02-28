# Mars Lander Build Scripts

This directory contains scripts for building and packaging the Mars Lander game for different platforms.

## macOS Build Script (`make.sh`)

The `make.sh` script automates the process of creating a macOS application bundle for the Mars Lander game.

### Prerequisites

- macOS operating system
- Löve2D installed at `/Applications/love.app`
- Bash shell

### Usage

To build the macOS application:

```bash
./scripts/make.sh
```

### What the Script Does

1. Creates a `.love` file containing all game files
2. Creates a copy of the Löve2D application and renames it to "Mars Lander.app"
3. Copies the `.love` file into the application bundle
4. Modifies the `Info.plist` file to customize the application
   - Changes the bundle identifier to "com.tijs.marslander"
   - Changes the bundle name to "Mars Lander"
   - Updates the copyright information
   - Removes the UTExportedTypeDeclarations section
5. Creates a distributable ZIP file

### Output

The script creates the following files in the `dist` directory:

- `Mars Lander.love`: The packaged game file
- `Mars Lander.app`: The macOS application bundle
- `Mars Lander-macOS.zip`: The distributable ZIP file

### Customization

You can modify the following variables at the top of the script to customize the build:

- `GAME_NAME`: The name of the game
- `BUNDLE_ID`: The bundle identifier for the application
- `VERSION`: The version number
- `COPYRIGHT`: The copyright information
- `LOVE_APP`: The path to the Löve2D application
- `OUTPUT_DIR`: The directory where the build files will be placed

## Future Scripts

Additional build scripts for other platforms (Windows, Linux, etc.) can be added to this directory in the future. 