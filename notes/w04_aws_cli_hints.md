# AWS CLI Hints

## Create VPC and Store the ID

    vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query Vpc.VpcId --output text)

## Name the VPC, and add Project

    aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name Key=Project,Value="${project_name}"

## Enable DNS Hostnames for EC2 instances

    aws ec2 modify-vpc-attribute \
     --vpc-id "${vpc_id}" \
     --enable-dns-hostnames "{\"Value\":true}"

## Record a value to a file (VPC ID) to file

    echo "vpc_id=$vpc_id" >> state_file

## Create Subnet and Store the ID

    subnet_id=$(aws ec2 create-subnet  --vpc-id $vpc_id --cidr-block $subnet_cidr --query Subnet.SubnetId  --output text)

    make sure to specify the availability zone

## Name the Subnet and Project

    aws ec2 create-tags \
    --resources "${subnet_id}" \
    --tags Key=Name,Value="${subnet_name}" Key=Project,Value="${project_name}"

## Create Internet Gateway Storing the ID

    gateway_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)

## Set gateway Name

    aws ec2 create-tags --resources $gateway_id --tags Key=Name,Value=$gateway_name Key=Project,Value="${project_name}"

## Attach Internet Gateway to VPC

    aws ec2 attach-internet-gateway --internet-gateway-id $gateway_id --vpc-id $vpc_id

## Create Route-Table and store ID

    route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query RouteTable.RouteTableId --output text)

## Set Routing Table Name and Project

    aws ec2 create-tags  --resources $route_table_id  --tags Key=Name,Value=$route_table_name Key=Project,Value="${project_name}"

## Associate Routing Table with Subnet and store association ID

    rt_association_id=$(aws ec2 associate-route-table --route-table-id $route_table_id --subnet-id $subnet_id --query AssociationId --output text)

## Add default Route to Routing Table

    aws ec2 create-route --route-table-id $route_table_id --destination-cidr-block $default_cidr --gateway-id $gateway_id --output text

## Create security Group and store ID

    security_group_id=$(aws ec2 create-security-group --group-name "$security_group_name" --description "$security_group_desc" --vpc-id $vpc_id --query GroupId --output text)

## Create Inbound rule to allow inbound ssh from BCIT

    aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $bcit_cidr

## Delete all Ingress rules from a security group using AWS CLI

   ```bash
   ingress_rules_json=$(aws ec2 describe-security-groups \
                      --output json \
                      --group-ids "${_security_group_id}" \
                      --query "SecurityGroups[0].IpPermissions")
   aws ec2 revoke-security-group-ingress /
      --group-id "${_security_group_id}" /
      --ip-permissions "${ingress_rules_json}"
   ```

## Create EC2 Instance and store ID

    instance_id=$(aws ec2 run-instances \
             --image-id $ami_id \
             --instance-type $instance_type \
             --key-name $ssh_key_name \
             --security-group-ids $security_group_id \
             --query 'Instances[*].InstanceId' \
             --output text)

## Discover and Record the Public Hostname of an EC2 Instance

    ec2_dns_name=$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

## Discover and Record the Public Hostname of an EC2 Instance

    ec2_dns_name=$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[*].Instances[*].PublicDnsName' --output text)


## Loop to wait for EC2 Instance to come up

    aws ec2 wait instance-running --instance-ids "${instance_id}"

# Resources

## AWS CLI

1. [AWS Command Line Interface User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)
1. [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/)
1. [Filtering AWS CLI output](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html)
1. [JMESPATH Tutorial](https://jmespath.org/tutorial.html) - JMESPATH is the query language used by AWS CLI to filter output.

## AWS VPC

### AWS Networking

1. [AWS routing 101](https://medium.com/@mda590/aws-routing-101-67879d23014d)

### AWS VPC Operations

1. [AWS VPC Userguide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
1. [AWS CLI `create-vpc`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-vpc.html)
1. [AWS CLI `describe-vpcs`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-vpcs.html)
1. [AWS CLI `delete-vpcs`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-vpc.html)

### AWS Subnets

1. [AWS VPC Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
1. [Create an IPv4-enabled VPC and subnets using the AWS CLI](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-subnets-commands-example.html)
1. [AWS CLI `create-subnet`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-subnet.html)
1. [AWS CLI `describe-subnets`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-subnets.html)
1. [AWS CLI `delete-subnet`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-subnet.html)
1. [AWS CLI `modify-subnet-attribute`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-subnet-attribute.html)
1. Modify Subnet to enable public IP assignment
   ```bash
   aws ec2 modify-subnet-attribute --subnet-id "${subnet-id}" --map-public-ip-on-launch
   ```

### AWS Route Tables

1. [AWS VPC Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)
1. [AWS CLI `create-route-table`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route-table.html)
1. [AWS CLI `describe-route-tables`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-route-tables.html)
1. [AWS CLI `delete-route-table`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-route-table.html)
1. [AWS CLI `create-route`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html)
1. [AWS CLI `associate-route-table`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/associate-route-table.html)
1. [AWS CLI `disassociate-route-table`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/disassociate-route-table.html)

### AWS Internet Gateway

1. [AWS Connect to the Internet using an internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
1. [AWS CLI Creating, configuring, and deleting internet gateways for Amazon VPC](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-igw.html)
1. [AWS CLI: `create-internet-gateway`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-internet-gateway.html)
1. [AWS CLI: `attach-internet-gateway`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/attach-internet-gateway.html)
1. [AWS CLI: `descibe-internet-gateways`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-internet-gateways.html)
1. [AWS CLI: `detach-internet-gateway`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/detach-internet-gateway.html)
1. [AWS CLI: `delete-internet-gateways`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-internet-gateway.html)

### AWS Security Groups

1. [AWS Control traffic to resources using security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
1. [AWS CLI Creating, configuring, and deleting security groups for Amazon EC2](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-sg.html)
1. [AWS CLI: `create-security-group`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-security-group.html)
1. [AWS CLI: `describe-security-groups`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-security-groups.html)
1. [AWS CLI: `delete-security-group`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/delete-security-group.html)
1. [AWS CLI: `authorize-security-group-ingress`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/authorize-security-group-ingress.html)
1. [AWS CLI: `revoke-security-group-ingress`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/revoke-security-group-ingress.html)

## AWS EC2 Key Pairs

1. [Amazon EC2 key pairs and Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
1. [AWS CLI Creating, configuring, and deleting key pairs for Amazon EC2](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html)
1. [AWS CLI: `import-key-pair`](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)
1. [AWS CLI: `create-key-pair`](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html)

## AMI

1. [Search and launch Ubuntu 22.04 in AWS using CLI](https://ubuntu.com/tutorials/search-and-launch-ubuntu-22-04-in-aws-using-cli#2-search-for-the-right-ami)

## AWS EC2 Instances

1. [AWS EC2 User Guide for Linux Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
1. [AWS EC2 Instance Addressing](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html)
1. [AWS CLI: `describe-instances`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html)
1. [AWS CLI: `run-instances`](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)
1. [AWS CLI: `terminate-instances`](https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html)
1. [AWS CLI: `wait instance-running`](https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-running.html)
1. [AWS CLI: `wait instance-terminated`](https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-terminated.html)