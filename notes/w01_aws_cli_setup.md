# AWS CLI Install

We will be using Amazon Web Services as our cloud provider. The AWS CLI is a command line tool for interacting with AWS.  We will be using it to create and manage AWS resources.  The AWS CLI is available for Windows, Mac, and Linux.  The instructions below are for installing the AWS CLI on Ubuntu.  If you are using a different OS, please refer to the [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) for instructions on how to install the AWS CLI on your OS.


* [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* Commands
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
   ```

*  [Troubleshooting AWS CLI errors](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html)

## Configure AWS CLI

1. [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
1. [AWS CLI: `configure`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html)

## Configuring AWS CLI Autocompletion

Add the following to the _end_ of your `~/.bashrc` file

```bash
## add aws code completion
export path=/usr/local/bin/:$path
complete -c '/usr/local/bin/aws_completer' aws
```

# Creating an AMI User and Configure AWS CLI Profile

Currently you are likely logging into your AWS account using your root user.
There are a number of reasons this is not ideal.

## Create IAM User for the Course

You will need to create an user Amazon Identity Management (AIM) User for this
course.

### IAM User Specifications

- User name: `acit4640_admin`
- Group: `acit4640`
  - Permission policies:
    - IAMUserSSHKeys
    - AdministratorAccess
    - AmazonVPCFullAccess
    - AmazonRDSFullAccess
    - AmazonRoute53FullAccess

_Don't provide_ access to the AWS Management Console.

### Steps

1. [Sign in to the AWS Management Console](https://docs.aws.amazon.com/signin/latest/userguide/console-sign-in-tutorials.html)

1. Create an IAM user

   - Reference:

   1. Navigate to IAM by selecting to `View all services` and then `IAM` under
      `Security, Identity, & Compliance`.
   1. Navigate to User Creation: `Access management` -> `Users` -> `Create user`
   1. Specify that you want to create a group: `acit4640` and add the following
      permissions:
      - AdministratorAccess
      - AmazonVPCFullAccess
      - AmazonRDSFullAccess
      - AmazonRoute53FullAccess

1. Configure Security Credentials for the IAM User: `acit4640_admin`

   1. Navigate to the IAM user you just created: `Access management` -> `Users`
      -> `acit4640_admin`
   1. Select the `Security credentials` tab
   1. Select `Create access key` in the `Access keys` section
   1. Specify CLI use case and confirm the selection
   1. Download the the access keys `csv` file and store it in a safe place. You
      will need it later.
   1. Select `Done`

## Configure AWS-CLI to use IAM User and Credentials

### Steps:

1. Run `aws configure --profile acit4640_admin` and provide the following
   information:

   - AWS Access Key ID: from access keys `csv` file or copied during creation
   - AWS Secret Access Key: from access keys `csv` file or copied during
     creation
   - Default region name: `us-west-2`

   This will create two files: `~/.aws/config` and `~/.aws/credentials`

1. Append the following line to the end of your `~/.bashrc` file:

   ```bash
   export AWS_PROFILE=acit4640_admin
   ```

   This configures the AWS CLI to use the `acit4640_admin` profile by default.
   You will need to restart your terminal for this to have an effect.

# Resources

1. [AWS security credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-creds.html)
1. [AWS Account Root User](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html)
1. [Create an IAM user in your AWS account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)
1. [Authenticate with IAM user credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)

