#!/usr/bin/env bash
function get_recent_ubuntu_release() {
  month=$(date +%m)
  year=$(date +%Y)

  # Determine the closest valid month/year
  if [[ "$month" -lt 4 ]]; then
      closest_year=$((year - 1))
      closest_month="10"
  elif [[ "$month" -lt 10 ]]; then
      closest_year=$year
      closest_month="04"
  else
      closest_year=$year
      closest_month="10"
  fi

  # Format the result as YY.MM
  result=$(printf "%02d.%02d" $((closest_year % 100)) $closest_month)

  echo $result
}

function get_ubuntu_ami() {
  # Usage: get_ubuntu_ami [release] [product] [serial] [arch] [virt_type] [vol_type]
  # References: https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/#images-for-ec2-and-eks
  current_release=$(get_recent_ubuntu_release)
  local release="${1:-${current_release}}"
  local product="${2:-server}"
  local serial="${3:-current}"
  local arch="${4:-amd64}"
  local virt_type="${5:-hvm}"
  local vol_type="${6:-ebs-gp3}"

  local ami_id=$(aws ssm get-parameters \
    --names "/aws/service/canonical/ubuntu/${product}/${release}/stable/${serial}/${arch}/${virt_type}/${vol_type}/ami-id"\
    --query Parameters[*].Value \
    --output text
  )

  echo "${ami_id}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  get_ubuntu_ami "$@"
fi