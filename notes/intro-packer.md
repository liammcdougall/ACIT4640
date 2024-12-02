# Packer

## What is Packer and when would you use it?

Packer is a tool that can be used to automate the process of building machine and container images. This allows you build images for multiple platforms (different cloud service providers, your on-premise infrastructure, container runtimes... ). You can build these images from a single source configuration that can be managed with version control tools like Git.

Packer doesn't replace tools like Ansible. Ansible can be used with Packer to build images. You can also use shell scripts and a host of other tools.

Packer is shipped as a single binary and similar to Terraform *plugins* are used to build images for different environments. 

Using Packer allows you to quickly deploy provisioned and configured machines rapidly in production.

Another way to look at this is, rather than deploying a stock VM running Ubuntu, for example, and installing software and configuring it on a remote server. When everything is configured and your application is running putting this server into production. With Packer you build a custom Ubuntu image that already has the software you need configured and installed, and deploy this pre-built image. 

I think it is important to note that this isn't a new concept. Packer is just a tool designed to simplify the automation process so that a team can quickly build images for a variety of environments.

In addition to the benefit of building images for multiple environments this approach helps to keep your development, staging and production as close as possible.  

*Golden images* (you may come across this term when doing your own research on packer)

> A golden image is an image on top of which developers can build applications, letting them focus on the application itself instead of system dependencies and patches. A typical golden image includes common system, logging, and monitoring tools, recent security patches, and application dependencies.
> - [hashcorp docs](https://developer.hashicorp.com/packer/tutorials/cloud-production/golden-image-with-hcp-packer)

## Getting started with Packer

### Installing packer

Packer is available as a binary at the "installation docs" link below. There are binaries for a number of different operating systems and architectures. Just download the binary for your OS and architecture and put it in your path.

Hashicorp maintains package repositories with most of their tools for Ubuntu, Fedora, and several other Linux distros.

To install in Ubuntu for example use the following commands:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

Packer is also independently maintained by developers for a large number of package managers not mentioned in the installation docs. For example, I installed packer in Void Linux for this document with the command `sudo xbps-install packer`.

[installation docs](https://developer.hashicorp.com/packer/install)

### writing a packer template

A Packer template is a configuration file that defines an image.

Packer configuration is written in HCL (just like Terraform). Packer templates were written in JSON, so avoid older tutorials, because things have changed.

Packer templates generally have the file extensions pkr and hcl, eg `aws-ubuntu.pkr.hcl`

Because Packer templates are written in HCL the syntax will look familiar to you. 

HCL syntax consists of:
> - _Blocks_ are containers for other content and usually represent the configuration of some kind of object, like a source. Blocks have a _block type,_ can have zero or more _labels,_ and have a _body_ that contains any number of arguments and nested blocks. Most of Packer's features are controlled by top-level blocks in a configuration file.
> - _Arguments_ assign a value to a name. They appear within blocks.
> - _Expressions_ represent a value, either literally or by referencing and combining other values. They appear as values for arguments, or within other expressions.
>    [Packer docs](https://developer.hashicorp.com/packer/docs/templates/hcl_templates#arguments-blocks-and-expressions)


```hcl
# specify plugin, version of plugin and where to find that plugin
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}

# source image, the default, initial image
source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
}

# build instructions, what Packer does with image
build {
  name    = "learn-packer"
  sources = [
    "source.docker.ubuntu"
  ]
}

```

### Packer commands

Packer commands will also look familiar to you having worked with Terraform.

To see a list of packer commands and short description run
```bash
packer -h
```
You should see something like this:
```
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build           build image(s) from template
    console         creates a console for testing variable interpolation
    fix             fixes templates from old versions of packer
    fmt             Rewrites HCL2 config files to canonical format
    hcl2_upgrade    transform a JSON template into an HCL2 configuration
    init            Install missing plugins or upgrade plugins
    inspect         see components of a template
    plugins         Interact with Packer plugins and catalog
    validate        check that a template is valid
    version         Prints the Packer version
```

Download and install plugins in the 'required_plugins' block
```bash
packer init .
``` 

Unlike Terraform by default this install plugins in `~/.config/packer/plugins` (on Unix like OSs).

You can validate the syntax of your Packer template with the command

```bash
packer validate <my-template.pkr.hcl>
```

Generate artifacts from the template

```bash
packer build
```

[Command docs](https://developer.hashicorp.com/packer/docs/commands)

### Install Nginx example template

Packer uses an access key and secret access key to authenticate an AWS user, just like Terraform.

I generally just use environment variables in my development environment for this. 

```bash
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
export AWS_DEFAULT_REGION=us-west-2
```

Create a new working directory and inside of that create a new file `aws-ubuntu.pkr.hcl` save the template below into the file.

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  # use a shell proviioner to run some shell commands
  # provisioners can also add local files to an image
  # If you wanted to combine Ansible with Packer you would do so in
  # a provisioner block
  provisioner "shell" {
    inline = [
      "echo Installing Nginx",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

Install plugins
```bash
packer init .
```

fmt the file (your editor can do this step on save with an LSP)
```bash
packer fmt aws-ubuntu.pkr.hcl
```

validate the code in the file
```bash
packer fmt aws-ubuntu.pkr.hcl
```

Build your new ubuntu image
```bash
packer build aws-ubuntu.pkr.hcl
```

This will create a new ami in your AWS account. As the command runs you should see the build steps in the terminal and in your AWS account. This will create a security group, ssh keys and an ec2 instance. In the ec2 instance our provisioner is run and nginx is installed. When the new ami has been created packer will delete the resources needed to create the new ami. 
## Resources

[packer.io](https://www.packer.io/)

[packer tutorials](https://developer.hashicorp.com/packer/tutorials)

