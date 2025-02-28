# Mars Lander

A simple Mars Lander game made with LÖVE2D. Control your spacecraft and safely land on the designated landing pads on the Martian surface.

## Game Overview

In Mars Lander, you control a spacecraft and must navigate it safely to a landing pad on the Martian surface. The game features:

- Physics-based movement with Mars gravity (38% of Earth's)
- Multiple levels with randomly generated Martian terrain
- Fuel management
- Score system based on landing efficiency
- Simple vector graphics drawn in code (no external assets)
- Martian dust storms and atmospheric effects

## Controls

- **Arrow Keys** or **WASD**: Control the lander
  - **Up/W**: Apply thrust
  - **Left/A**: Rotate counterclockwise
  - **Right/D**: Rotate clockwise
- **R**: Restart the game
- **ESC**: Quit the game
- **F1**: Show FPS counter (debug)

## Gameplay

- Land safely on the blue landing pads
- Land with low velocity and near-vertical orientation to avoid crashing
- Conserve fuel for bonus points
- Complete multiple levels with increasing difficulty
- Watch out for the Martian dust storms!

## Installation

1. Install LÖVE2D from [love2d.org](https://love2d.org/)
2. Clone this repository
3. Run the game using LÖVE2D:
   ```
   love /path/to/mars-lander
   ```

## Project Structure

- `main.lua`: Entry point for the game
- `conf.lua`: LÖVE2D configuration
- `src/entities/`: Game entities (lander, terrain)
- `src/scenes/`: Game scenes (game scene)
- `src/utils/`: Utility functions

## Development

This game was developed following the LÖVE2D project guidelines and best practices:

- Object-oriented design with Lua metatables
- Separation of logic and rendering
- Efficient collision detection
- Proper game state management

## Code Quality and Linting

The project includes a comprehensive linting setup for maintaining code quality:

- Lua Language Server integration for real-time error detection
- Automatic code formatting with StyLua
- EditorConfig for consistent coding style
- Luacheck configuration for additional static analysis

For detailed setup instructions, see [LINTING.md](LINTING.md).

## Credits

### Game Development
- Mars Lander - A LÖVE2D Game
- A physics-based landing simulation
- Developed as an open-source project
- Inspired by classic arcade games

### Font Credits
- "Press Start 2P" Font by CodeMan38
- Copyright 2012 The Press Start 2P Project Authors
- Licensed under the SIL Open Font License, Version 1.1
- Font available at fonts.google.com

### AI Assistance
- Game design assistance by Claude 3.7 Sonnet
- Developed by Anthropic
- Used for code generation and game design
- Part of the creative development process

### Special Thanks
- LÖVE2D Framework and Community
- Open Source Game Development Resources
- Beta Testers and Early Players
- Everyone who provided feedback and support

## License

This project is open source and available under the MIT License. 
