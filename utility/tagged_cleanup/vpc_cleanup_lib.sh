#!/usr/bin/env bash
set -o nounset

ssh_key_pair_delete(){
  declare key_pair_id="$1"
  echo -e "\n** Key Pair ID ${key_pair_id} **"

  if aws ec2 describe-key-pairs --key-pair-ids "${key_pair_id}" --output table --no-cli-pager; then # check if key pair exists
    if aws ec2 delete-key-pair --key-pair-id "${key_pair_id}"; then
      echo -e "\n** Key Pair ${key_pair_id} deleted **"
    else
      echo -e "\n** Key Pair ${key_pair_id} not deleted **"
    fi
  fi
}

routing_table_delete() {
  declare route_table_id="$1"
  echo -e "\n** Route Table ID ${route_table_id} **"

  if aws ec2 describe-route-tables --route-table-ids "${route_table_id}" --output table --no-cli-pager; then # check if route table exists
    if aws ec2 delete-route-table --route-table-id "${route_table_id}"; then
      echo -e "\n** Route Table ${route_table_id} deleted **"
    else
      echo -e "\n** Route Table ${route_table_id} not deleted **"
    fi
  fi
}

gateway_delete() {
  declare gateway_id="$1"
  declare vpc_id="$(aws ec2 describe-internet-gateways --internet-gateway-ids ${gateway_id} --query InternetGateways[*].Attachments[*].VpcId --output text --no-cli-pager)"
  echo -e "\n** Internet Gateway ID ${gateway_id} **"

  if aws ec2 describe-internet-gateways --internet-gateway-ids "${gateway_id}" --output table --no-cli-pager; then # check if gateway exists
    if aws ec2 detach-internet-gateway --internet-gateway-id "${gateway_id}" --vpc-id "${vpc_id}"; then
      if aws ec2 delete-internet-gateway --internet-gateway-id "${gateway_id}"; then
        echo -e "\n** Internet Gateway ${gateway_id} deleted **"
      else
        echo -e "\n** Internet Gateway ${gateway_id} not deleted **"
      fi
    else
      echo -e "\n** Internet Gateway ${gateway_id} not detached from VPC ${vpc_id} **"
    fi
  fi
}

subnet_delete() {
  declare subnet_id="$1"
  echo -e "\n** Subnet ID ${subnet_id} **"

  if aws ec2 describe-subnets --subnet-ids "${subnet_id}" --output table --no-cli-pager; then # check if subnet exists
    if aws ec2 delete-subnet --subnet-id "${subnet_id}"; then
      echo -e "\n** Subnet ${subnet_id} deleted **"
    else
      echo -e "\n** Subnet ${subnet_id} not deleted **"
    fi
  else
    echo -e "\n** Subnet ${subnet_id} not found **"
  fi
}

security_group_delete() {
  declare security_group_id="$1"
  echo -e "\n** Security Group ID ${security_group_id} **"

  if aws ec2 describe-security-groups --group-ids "${security_group_id}" --output table --no-cli-pager; then # check if security group exists

    declare ingress_rules_json
    # All rules that refer to other security groups must be removed before the security group can be deleted
    # Get all rules and remove them
    ingress_rules_json=$(aws ec2 describe-security-groups --output json --group-ids "${security_group_id}" --query "SecurityGroups[0].IpPermissions")
    aws ec2 revoke-security-group-ingress --group-id "${security_group_id}" --ip-permissions "${ingress_rules_json}"

    if aws ec2 delete-security-group --group-id "${security_group_id}"; then
      echo -e "\n** Security Group ${security_group_id} deleted **"
    else
      echo -e "\n** Security Group ${security_group_id} not deleted **"
    fi
  fi
}

vpc_delete() {
  declare vpc_id="$1"
  echo -e "\n** VPC ${vpc_id} **"

  if aws ec2 describe-vpcs --vpc-id "${vpc_id}" --output table --no-cli-pager; then # check if VPC exists
    #Delete the VPC
    if aws ec2 delete-vpc --vpc-id "${vpc_id}"; then
      echo -e "\n** VPC ${vpc_id} deleted **"
    else
      echo -e "\n** VPC ${vpc_id} not deleted **"
    fi
  fi
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "${BASH_SOURCE[0]} is a library, meant to be sourced, not run"
fi
