# BASH Script Editing and Debugging Setup

Before writing our scripts we need to configure our development and debugging
environment. This includes configuring our shell, editor, and debugging tools.

## Configuration

1. BASH Tracing Setup:

   Add the following to the _end_ of your `~/.bashrc` file

   ```bash
   ## Bash Tracing Prompt
   export PS4=' \[\e[0;34m(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }\e[m\]'

   ```

   This configures your PS4 prompt (tracing prompt) to show the file, line
   number, and function name of the current command. This is useful for tracing
   scripts.

   The following demonstrates using the modified PS4 prompt for tracing.
   The trace shows that `bash -x .\script1.sh` was run the and is executing the
   `func1` function at line `53` in the `script1.sh` file. The  
   content of the line is: `echo -e '\n********** func1 starting **********'`

   ```log
   (script1.sh:53): func1(): echo -e '\n********** func1 starting **********'
   ```

1. VSCode Setup

   We will be installing the following extensions to help us write and debug our
   scripts:

   1. [Bash IDE](https://marketplace.visualstudio.com/items?itemName=mads-hartmann.bash-ide-vscode)
   1. [Editor Config](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
   1. [Shell Formatter](https://marketplace.visualstudio.com/items?itemName=mkhl.shfmt)
   1. [Bash Debugger](https://marketplace.visualstudio.com/items?itemName=rogalmic.bash-debug)

   These depend on the following tools being installed on your Linux / WSL system:

   1. [Shell Formatter](https://github.com/mvdan/sh)
   1. [Shell Linter](https://www.shellcheck.net/)

   The installing of these can be done by running the script:
   [bash_editor_config.sh](../utility/bash_editor_config.sh)


  You can also copy the [`.editorconfig`](.editorconfig) file to the root directory of your script project.
  this will ensure that the editor settings are set correctly for your project.

## Debugging and Tracing

1. To use command line tracing (show each line as it is executed) run scripts
   using `bash -x script.sh` to trace output With the prompt set you can use
   `bash -x <script_name>.sh` to launch your script and see it trace.

1. To debug your scripts you can use the bash debugger extension for VSCode.
   This will allow you to set breakpoints and step through your code. You will
   need to create a specify how to launch the debugger but setting configuration
   items in `launch.json` see
   [VS Code Bash Debug](https://marketplace.visualstudio.com/items?itemName=rogalmic.bash-debug)

## General Resources

1. [VSCode Debugging](https://code.visualstudio.com/docs/editor/debugging)
