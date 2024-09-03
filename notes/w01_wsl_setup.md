# Setting Up a Local Development and Control Environment

The only real requirement for the local development environment for this course is that you have a Linux environment which you will use to install software and run commands from.

I recommend and will support the  use a recent Ubuntu release under WSL2. For students running Windows this is probably the easiest approach.

## WSL

A few important things to be aware of if you chose this option:
1. WSL will create its own file system. Microsoft recommends working from the WSL file system when you are using WSL. You can still access Windows GUI tools like the file explore. `explorer.exe .` will open the explorer in your working directory.

1. Similarly you can work with VSCode from WSL. Install the Remote development extension(link below) and open VSCode like this `code .` form within the WSL terminal.

There are two reasons for this:
1. according to the docs working from the WSL file system system performs better.
2. Windows is much more permissive than even Ubuntu. When you create new files on Windows permissions are wide open. Some of the tools that we will be using this term will complain about permissions (SSH for example). You will spend additional time trouble shooting little things like this.

The links below specify how to setup WSL and VSCode. The second link is a good tutorial for setting up VSCode to use WSL.

### Reference

1. [WSL Docs](https://learn.microsoft.com/en-us/windows/wsl/)
1. [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
1. [WSL File storage and performance across file systems](https://learn.microsoft.com/en-us/windows/wsl/filesystems#file-storage-and-performance-across-file-systems)

## Optional: Hyper-v

WSL2  uses Hyper-v.  If you have errors setting up WSL2 you may need to enable Hyper-V by running the following command in an elevated PowerShell prompt.

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

### Reference

1. [Install Hyper-V on Windows 10](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)


## Enable Systemd in Ubuntu WSL 2

For testing purposes, it is useful to be able to run `systemd` in WSL 2.  This can be done by following the steps below. Edit the file `/etc/wsl.conf` form WSL2 terminal and add the following lines:

    [boot]
    systemd=true

## Reference

1. [Systemd support lands in WSL](https://ubuntu.com/blog/ubuntu-wsl-enable-systemd)


## Editing: VSCode

We will be using VSCode as our development environment for this course.

1. Install WSL, Remote Development, and Remote WSL Extensions in VSCode when running from Windows

    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode-remote.remote-wsl
    ms-vscode-remote.vscode-remote-extensionpack
    ms-vscode.powershell
    ms-vscode.remote-explorer
    ms-vscode.remote-server

1. Install  Bash Debugging, Shellcheck, and Shell-Format Extensions in VSCode when running from WSL2:

    foxundermoon.shell-format
    hashicorp.terraform
    mads-hartmann.bash-ide-vscode
    redhat.ansible
    redhat.vscode-yaml
    rogalmic.bash-debug
    timonwong.shellcheck

