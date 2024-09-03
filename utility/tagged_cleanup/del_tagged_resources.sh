#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error

function arn_decode_id() {
  declare arn=$1
  declare resource_id

  # split arn into parts using / as delimiter
  readarray -td $":" arn_parts <<<"${arn}"

  # split resource type/id parts using / as delimiter, the resource id is the last part
  readarray -td $'/' resource_type_id <<<${arn_parts[-1]}

  # output the resource id
  echo "${resource_type_id[-1]}"
}

function append_resources_list() {
  # TODO: add checking for state of EC2 instances to check they aren't
  # already terminated

  declare resource_id="${1}"
  declare resource_type

  # get resource type from resource id prefix (up to leading -)
  resource_type=$(cut -d '-' -f 1 <<<${resource_id})

  case "${resource_type}" in

  "vpc") # vpc
    vpc_ids+=("${resource_id}")
    ;;

  "subnet") # subnet
    subnet_ids+=("${resource_id}")
    ;;

  "sg") # security group
    sg_ids+=("${resource_id}")
    ;;

  "igw") # gateway
    gw_ids+=("${resource_id}")
    ;;

  "i") # ec2 instance
    ec2_ids+=("${resource_id}")
    ;;

  "rtb") # route table
    rt_ids+=("${resource_id}")
    ;;
  
  "key") # ssh key pair
    key_pair_ids+=("${resource_id}")
    ;;
  esac


}

function enumerate_resources() {
  declare key_name=$1
  declare key_value=$2

  # Make global lists to store all of the resource ids separated by type
  declare -ga ec2_ids
  declare -ga gw_ids
  declare -ga subnet_ids
  declare -ga rt_ids
  declare -ga sg_ids
  declare -ga vpc_ids
  declare -ga key_pair_ids

  if [[ -z "${key_name}" || -z "${key_value}" ]]; then
    echo "key_name or key_value is empty, not deleting everything"
    exit 1
  fi

  readarray -td$'\t' arns < <(
    aws resourcegroupstaggingapi get-resources \
      --tag-filters Key="${key_name}",Values="${key_value}" \
      --query ResourceTagMappingList[*].ResourceARN \
      --output text \
      --no-cli-pager
  )

  for arn in "${arns[@]}"; do
    # remove trailing whitespace characters
    # see: https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
    arn="${arn%"${arn##*[![:space:]]}"}"

    resource_id="$(arn_decode_id "${arn}")"

    append_resources_list "${resource_id}"
  done

}

function delete_resources() {
  # delete all ec2 instances
  for ec2_id in "${ec2_ids[@]}"; do
    ec2_instance_delete "${ec2_id}"
  done

  # delete all key pairs
  for key_pair_id in "${key_pair_ids[@]}"; do
    ssh_key_pair_delete "${key_pair_id}"
  done

  # delete all gateways
  for gw_id in "${gw_ids[@]}"; do
    gateway_delete "${gw_id}"
  done

  # delete all route tables
  for rt_id in "${rt_ids[@]}"; do
    routing_table_delete "${rt_id}"
  done

  # delete all subnets
  for subnet_id in "${subnet_ids[@]}"; do
    subnet_delete "${subnet_id}"
  done

  # delete all security groups
  for sg_id in "${sg_ids[@]}"; do
    security_group_delete "${sg_id}"
  done

  # delete all vpcs
  for vpc_id in "${vpc_ids[@]}"; do
    vpc_delete "${vpc_id}"
  done
}

function main() {
  # Assume that the script libraries are in the same directory as this script
  declare -r script_dir="$(dirname "${BASH_SOURCE[0]}")" #can't symlink this script
  source ${script_dir}/ec2_cleanup_lib.sh
  source ${script_dir}/vpc_cleanup_lib.sh

  enumerate_resources ${1:-"Project"} ${2:-"a1_project"}
  delete_resources

}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
