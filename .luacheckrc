-- Lua linting configuration for Mars Lander game
-- Global objects
globals = {
    -- LÖVE2D globals
    "love",

    -- Game globals
    "fonts"
}

-- Don't report unused self arguments of methods
self = false

-- Don't report unused arguments
unused_args = false

-- Allow defining globals in the top level scope
allow_defined_top = true

-- Maximum line length
max_line_length = 120

-- Maximum cyclomatic complexity of functions
max_cyclomatic_complexity = 15

-- Ignore certain warnings
ignore = {
    -- Ignore warnings about whitespace
    "611", -- Line contains trailing whitespace
    "612", -- Line contains trailing tabs
    "613", -- Trailing whitespace in a string
    "614", -- Trailing whitespace in a comment

    -- Ignore warnings about unused variables named "_"
    "212/.*_.*", -- Unused variable

    -- Ignore warnings about shadowing
    "421", -- Shadowing a local variable
    "422", -- Shadowing an argument
    "423", -- Shadowing a loop variable
}

-- Files to exclude from linting
exclude_files = {
    "lib/**",     -- Third-party libraries
    ".vscode/**", -- VSCode configuration
    "dist/**",    -- Distribution files
}

-- Specific file configurations
files["main.lua"] = {
    -- Allow globals to be defined in main.lua
    allow_defined_top = true,
}

files["conf.lua"] = {
    -- Allow globals to be defined in conf.lua
    allow_defined_top = true,
}
