#!/bin/bash -x

# attach the ENI
aws ec2 attach-network-interface \
  --region "$(/opt/aws/bin/ec2-metadata -z  | sed 's/placement: \(.*\).$/\1/')" \
  --instance-id "$(/opt/aws/bin/ec2-metadata -i | cut -d' ' -f2)" \
  --device-index 1 \
  --network-interface-id "${eni_id}"

# Disable Source/Dest check (https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#EIP_Disable_SrcDestCheck)
REGION=$(ec2-metadata --availability-zone | sed 's/placement: \(.*\).$/\1/')
INSTANCE=$(ec2-metadata --instance-id | sed 's/instance-id: \(.*\)$/\1/')
aws ec2 modify-instance-attribute --no-source-dest-check --instance-id "$INSTANCE" --region "$REGION"

# start SNAT
systemctl enable snat
systemctl start snat
