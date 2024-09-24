#!/usr/bin/env bash
set -o nounset

#####################################################################
# adds a new EC2 instance to the AWS environment based on the VPC Configuration
# Arguments:
#   project: name of the project - used to tag the instance for retrieval
#   instance_type: the type of instance to create, i.e T2.micro
#   ami_id: the AMI id to use for the instance image
#   ssh_key_name: the name of the SSH key name from AWS existing key pairs - not a file
#   security_groups: an array of security group ids to attach to the instance
#   subnet_id: the subnet id to attach the instance to
#   instance_name: a name for the instance
# Outputs:
#   - A file named unmanaged_ec2_id.env containing the instance id
#   - The instance id is also printed to stdout
#####################################################################
function add_ec2() {
  # variables: project,  instance type, AMI, SSH_KEY, SECURITY_GROUP, SUBNET, instance_name
  local project="${1}"
  local instance_type="${2}"
  local ami_id="${3}"
  local ssh_key_name="${4}"
  local security_groups="${5}"
  local subnet_id="${6}"
  local instance_name="${7:-${project}_unmanaged}"
  local ec2_id_file="${8}"

  declare unmanaged_id
  unmanaged_id=$(aws ec2 run-instances \
    --instance-type "${instance_type}" \
    --image-id "${ami_id}" \
    --count 1 \
    --key-name "${ssh_key_name}" \
    --security-group-ids "${security_groups}" \
    --subnet-id "${subnet_id}" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance_name}},{Key=Project,Value=${project}}]" \
    --output text \
    --query 'Instances[*].InstanceId')

  echo "instance_id=\"${unmanaged_id}\"" >"${ec2_id_file}"
  echo "${unmanaged_id}"

}

#####################################################################
# uses AWS CLI to retrieve and display all AWS resources associated with a
# specific project.
# Arguments:
#   project_name: the name of the project to list resources that match
#                 the tag "project" = project_name
# Outputs:
#   - A list of all AWS resources associated with the project to stdout
#####################################################################
function show_project_resources() {
  local project_name="${1}"
  aws resourcegroupstaggingapi get-resources --tag-filters Key=Project,Values="${project_name}" --no-cli-pager
}

#####################################################################
# Generates the `imports.tf` file for Terraform. This file is used to
# import an EC2 instance created outside of Terraform into Terraform's
# management.
# Arguments:
#   unmanaged_id: The id of the unmanaged ec2 instance to import
#   ami_id: the AMI id to use for the instance image
# Side Effect:
#   - A file named `imports.tf` containing:
#       - an import block for the unmanaged EC2 instance
#       - a resource block for the unmanaged EC2 instance with minimal
#         configuration
#       - a data resource to delete the terrafrom configuration file on destroy
#         this is done to facilitated repeated demonstrations
#####################################################################
function gen_import_tf() {
  local unmanaged_id="${1}"
  local ami_id="${2}"
  local instance_type="${3}"

  local destination_dir
  destination_dir=$(dirname "${BASH_SOURCE[0]}")

  # Create imports.tf file that contains terraform blocks that
  # includes blocks to import and provision the unmanaged EC2
  # instance
  tee "${destination_dir}/imports.tf" <<EOF

import {
  # import the instance
  to = aws_instance.unmanaged
  id = "${unmanaged_id}"
}

# make resource id for the imported instance
resource "aws_instance" "unmanaged" {
  # provision the instance with minimal configuration
  ami = "${ami_id}"
  instance_type = "${instance_type}"
}
EOF
  # append a data resource to delete the imports.tf file on terraform destroy
  # this the here doc is quoted to prevent variable expansion - in this case
  # the terraform variables path.module and self.output should not be expanded
  # by bash
  tee -a "${destination_dir}/imports.tf" <<'EOF'
# Self reference to terraform file resource
# used to delete the imports.tf file when terraform destroy is run
resource "terraform_data" "import_file" {

  # this stores the path to the import.tf file
  input = "${path.module}/imports.tf"

  provisioner "local-exec" {
    command = "rm -f \"${self.output}\""
    when = destroy
  }
}
EOF

}

function demo() {
  declare script_dir
  script_dir=$(dirname "${BASH_SOURCE[0]}")

  # File path to store the unmanaged ec2 instance id incase you need
  # to delete the instance outside of terraform
  declare ec2_id_file="${script_dir}/unmanaged_ec2_id.env"

  # execute from the script directory and fail if it doesn't exist
  cd "${script_dir}" || exit

  # create infrastrucure using terraform
  echo "***********************************************************************"
  echo "Initialize and Apply Terraform Configuration"
  terraform init
  terraform apply -auto-approve
  echo "***********************************************************************"

  # Load the ID's of AWS Resources - this is genrated by the terraform module wk03 Example
  # This aws_resources.sh will load the following variables:
  #   PROJECT, AMI, VPC, SUBNET, SECURITY_GROUP, GATEWAY, ROUTE_TABLE, ROUTE_TABLE_ASSOCIATION, SSH_KEY
  source "${script_dir}/aws_resources.sh"

  # Show all AWS resources for project using the aws cli
  echo "***********************************************************************"
  echo "AWS Resources for Project (pre-EC2 Creation): ${PROJECT}"
  show_project_resources "${PROJECT}"
  echo "***********************************************************************"

  # Show the tresources managed by terrafrom
  echo "***********************************************************************"
  echo "Terraform Resources for Project(pre-EC2 Creation): ${PROJECT}"
  terraform state list
  echo "***********************************************************************"

  # add another ec2 instance to vpc on same subnet with same security group
  # uses the configuration from the terraform module wk03 Example loaded from
  # aws_resources.sh
  # Stores the instance id in um_id variable
  echo "***********************************************************************"
  echo "Create Unmanaged EC2 Instance using AWS CLI"
  um_id=$(add_ec2 "${PROJECT}" "t2.micro" "${AMI}" "${SSH_KEY}" "${SECURITY_GROUP}" "${SUBNET}" "${PROJECT}_unmanaged" "${ec2_id_file}")

  echo "***********************************************************************"

  # Show all AWS resources for project using the aws cli
  echo "***********************************************************************"
  echo "AWS Resources for Project(post EC2 Creation): ${PROJECT}"
  show_project_resources "${PROJECT}"
  echo "***********************************************************************"

  # Show the tresources managed by terrafrom
  echo "***********************************************************************"
  echo "Terraform Resources for Project(post EC2 Creation): ${PROJECT}"
  terraform state list
  echo "***********************************************************************"

  # If you try to run terraform destroy - it won't complete and you will need force halt
  # As the destroy command will fail because VPC, Subnet, Security Group, and Gateway
  # all have dependencies on the unmanaged EC2 instance.
  #
  # terraform destroy -auto-approve

  # Create imports.tf file
  # This is a terraform file that includes the import and basic configuration
  # for the unmanaged EC2 instance created by the add_ec2 function
  echo "***********************************************************************"
  echo "Generate imports.tf file for Unmanaged EC2 Instance"
  gen_import_tf "${um_id}" "${AMI}" "t2.micro" "${script_dir}"
  echo "***********************************************************************"

  # Instead of using import block like the one included in imports.tf
  # You could use the terraform import command. For example:
  #   terraform import aws_instance.unmanaged "${um_id}"

  # When `terraform apply` is run the imports.tf file will register the
  # unmanaged instance using the import block and allow the unmanged
  # instance to be managed by terraform. The actual configuration of the
  # is done in the aws_instance resource block in the imports.tf file.
  echo "***********************************************************************"
  echo "Apply Terraform Configuration to Manage Unmanaged EC2 Instance"
  echo "Running terraform apply to find and 'provision' the unmanaged EC2 instance"
  echo "because it will find the imports.tf file and import the instance"
  terraform apply -auto-approve
  echo "***********************************************************************"

  # you can now configure the unmanaged instance using terraform
  # by editing the imports.tf file and running terraform apply again

  # The new EC2 instance that was "unmanaged"  will be listed as a  terrafrom managed resource
  # after you terraform apply the imports.tf file
  echo "***********************************************************************"
  echo "Terraform Resources for Project(post import): ${PROJECT}"
  terraform state list
  echo "***********************************************************************"
}
# Uncomment the conditional statement below if you source the functions outside of the debugger
#if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Run the demo - you can uncomment the conditional statement if running outside of the debugger.
  demo
#fi
