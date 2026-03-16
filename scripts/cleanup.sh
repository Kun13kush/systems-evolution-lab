#!/bin/bash

set -e

echo "Starting NotesApp infrastructure cleanup..."

# -------------------------
# CONFIGURATION
# -------------------------

REGION="us-east-1"
KEY_NAME="notesapp-key"

export AWS_REGION=$REGION

# -------------------------
# FIND RESOURCES BY TAG
# -------------------------

echo "Looking up resources..."

INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=notesapp-server" \
             "Name=instance-state-name,Values=running,stopped,pending,stopping" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=notesapp-vpc" \
  --query 'Vpcs[0].VpcId' \
  --output text)

SUBNET_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=notesapp-subnet" \
  --query 'Subnets[0].SubnetId' \
  --output text)

IGW_ID=$(aws ec2 describe-internet-gateways \
  --filters "Name=tag:Name,Values=notesapp-igw" \
  --query 'InternetGateways[0].InternetGatewayId' \
  --output text)

RT_ID=$(aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=notesapp-rt" \
  --query 'RouteTables[0].RouteTableId' \
  --output text)

SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=notesapp-sg" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

echo "Instance:       $INSTANCE_ID"
echo "VPC:            $VPC_ID"
echo "Subnet:         $SUBNET_ID"
echo "Internet GW:    $IGW_ID"
echo "Route Table:    $RT_ID"
echo "Security Group: $SG_ID"

# -------------------------
# CONFIRM
# -------------------------

echo ""
read -p "Are you sure you want to delete all the above resources? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

echo ""

# -------------------------
# TERMINATE INSTANCE
# -------------------------

if [[ "$INSTANCE_ID" != "None" && -n "$INSTANCE_ID" ]]; then
  echo "Terminating instance $INSTANCE_ID..."
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  echo "Waiting for instance to terminate..."
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
  echo "Instance terminated."
else
  echo "No instance found, skipping."
fi

# -------------------------
# DELETE KEY PAIR
# -------------------------

echo "Deleting key pair..."
aws ec2 delete-key-pair --key-name $KEY_NAME && echo "Key pair deleted." || echo "Key pair not found, skipping."

if [[ -f "$KEY_NAME.pem" ]]; then
  rm -f $KEY_NAME.pem
  echo "Local .pem file removed."
fi

# -------------------------
# DELETE SECURITY GROUP
# -------------------------

if [[ "$SG_ID" != "None" && -n "$SG_ID" ]]; then
  echo "Deleting security group $SG_ID..."
  aws ec2 delete-security-group --group-id $SG_ID && echo "Security group deleted." || echo "Security group not found, skipping."
else
  echo "No security group found, skipping."
fi

# -------------------------
# DISASSOCIATE & DELETE ROUTE TABLE
# -------------------------

if [[ "$RT_ID" != "None" && -n "$RT_ID" ]]; then
  echo "Disassociating route table $RT_ID..."
  ASSOC_ID=$(aws ec2 describe-route-tables \
    --route-table-ids $RT_ID \
    --query 'RouteTables[0].Associations[?Main==`false`].RouteTableAssociationId' \
    --output text)

  if [[ -n "$ASSOC_ID" && "$ASSOC_ID" != "None" ]]; then
    aws ec2 disassociate-route-table --association-id $ASSOC_ID
    echo "Route table disassociated."
  fi

  echo "Deleting route table $RT_ID..."
  aws ec2 delete-route-table --route-table-id $RT_ID && echo "Route table deleted." || echo "Route table not found, skipping."
else
  echo "No route table found, skipping."
fi

# -------------------------
# DETACH & DELETE INTERNET GATEWAY
# -------------------------

if [[ "$IGW_ID" != "None" && -n "$IGW_ID" && "$VPC_ID" != "None" && -n "$VPC_ID" ]]; then
  echo "Detaching internet gateway $IGW_ID..."
  aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
  echo "Deleting internet gateway $IGW_ID..."
  aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID && echo "Internet gateway deleted." || echo "Internet gateway not found, skipping."
else
  echo "No internet gateway found, skipping."
fi

# -------------------------
# DELETE SUBNET
# -------------------------

if [[ "$SUBNET_ID" != "None" && -n "$SUBNET_ID" ]]; then
  echo "Deleting subnet $SUBNET_ID..."
  aws ec2 delete-subnet --subnet-id $SUBNET_ID && echo "Subnet deleted." || echo "Subnet not found, skipping."
else
  echo "No subnet found, skipping."
fi

# -------------------------
# DELETE VPC
# -------------------------

if [[ "$VPC_ID" != "None" && -n "$VPC_ID" ]]; then
  echo "Deleting VPC $VPC_ID..."
  aws ec2 delete-vpc --vpc-id $VPC_ID && echo "VPC deleted." || echo "VPC not found, skipping."
else
  echo "No VPC found, skipping."
fi

# -------------------------
# DONE
# -------------------------

echo ""
echo "Cleanup complete. All NotesApp resources have been removed."
