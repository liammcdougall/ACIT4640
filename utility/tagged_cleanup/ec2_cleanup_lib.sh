#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error

ec2_instance_delete() {
    declare instance_id="$1"
    echo -e "\n** EC2 Instance ID ${instance_id} **"

    if aws ec2 describe-instances --instance-ids "${instance_id}" --no-cli-pager --output table; then # check if instance exists
        if aws ec2 terminate-instances --instance-ids "${instance_id}"; then
            # Wait for instance to terminate
            aws ec2 wait instance-terminated --instance-ids "${instance_id}"
            echo -e "\n** EC2 Instance ${instance_id} terminated **"
        else
            echo -e "\n** EC2 Instance ${instance_id} not terminated **"
        fi
    fi

}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "${BASH_SOURCE[0]} is a library, meant to be sourced, not run"
fi
