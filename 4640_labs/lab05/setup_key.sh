#!/bin/bash
aws ec2 create-key-pair \
--key-name "acit_4640_lab05_key" \
--key-type ed25519 \
--key-format pem \
--tag-specifications 'ResourceType=key-pair,Tags=[{Key=project,Value=acit_4640_lab05_key}]' \
--output text \
--query "KeyMaterial" > acit_4640_lab05_key.pem

