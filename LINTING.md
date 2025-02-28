# Linting Setup for Mars Lander

This document explains how to set up and use the linting tools for the Mars Lander project.

## Required VSCode Extensions

To enable linting in VSCode, you need to install the following extensions:

1. **Lua Language Server** (sumneko.lua) - For Lua code intelligence, diagnostics, and formatting
   - Install from: https://marketplace.visualstudio.com/items?itemName=sumneko.lua

2. **EditorConfig for VS Code** - For consistent coding style
   - Install from: https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig

3. **StyLua** (JohnnyMorganz.stylua) - For Lua code formatting
   - Install from: https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua

## Optional Extensions

These extensions are not required but can enhance your development experience:

1. **Lua Debug** - For debugging Lua code
   - Install from: https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug

2. **vscode-lua-format** - Alternative Lua formatter
   - Install from: https://marketplace.visualstudio.com/items?itemName=Koihik.vscode-lua-format

## Configuration Files

The project includes several configuration files for linting:

- `.vscode/settings.json` - VSCode-specific settings for Lua Language Server
- `.luacheckrc` - Configuration for Luacheck linter
- `.editorconfig` - Editor-agnostic coding style configuration
- `stylua.toml` - Configuration for StyLua formatter

## Linting Features

With the setup complete, you'll get the following features:

1. **Real-time error detection** - Syntax errors, undefined variables, and other issues will be highlighted as you type
2. **Code formatting** - Press `Alt+Shift+F` (or `Option+Shift+F` on Mac) to format the current file
3. **Automatic formatting on save** - Files will be automatically formatted when you save them
4. **Hover information** - Hover over variables and functions to see their types and documentation
5. **Go to definition** - Ctrl+click (or Cmd+click on Mac) on a function or variable to jump to its definition
6. **Find references** - Right-click and select "Find All References" to see where a function or variable is used

## Customizing Linting Rules

If you want to customize the linting rules:

1. Edit `.luacheckrc` to change Luacheck rules
2. Edit `stylua.toml` to change formatting rules
3. Edit `.vscode/settings.json` to change Lua Language Server settings

## Troubleshooting

If linting is not working:

1. Make sure you've installed all required extensions
2. Reload VSCode window (Ctrl+Shift+P or Cmd+Shift+P, then type "Reload Window")
3. Check the "Output" panel in VSCode (View > Output) and select "Lua Language Server" from the dropdown to see any errors

## Using Linting from the Command Line

If you want to run linting from the command line:

1. Install Luacheck: `luarocks install luacheck`
2. Run: `luacheck .` from the project root
3. Install StyLua: Follow instructions at https://github.com/JohnnyMorganz/StyLua
4. Run: `stylua .` from the project root 
