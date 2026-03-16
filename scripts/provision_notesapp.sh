#!/bin/bash

set -e

echo "Starting NotesApp infrastructure provisioning..."

# -------------------------
# CONFIGURATION
# -------------------------

REGION="us-east-1"
KEY_NAME="notesapp-key"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"

export AWS_REGION=$REGION

# -------------------------
# CREATE VPC
# -------------------------

echo "Creating VPC..."

VPC_ID=$(aws ec2 create-vpc \
--cidr-block $VPC_CIDR \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=notesapp-vpc}]' \
--query 'Vpc.VpcId' \
--output text)

echo "VPC: $VPC_ID"

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

# -------------------------
# CREATE SUBNET
# -------------------------

echo "Creating subnet..."

SUBNET_ID=$(aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block $SUBNET_CIDR \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=notesapp-subnet}]' \
--query 'Subnet.SubnetId' \
--output text)

echo "Subnet: $SUBNET_ID"

aws ec2 modify-subnet-attribute \
--subnet-id $SUBNET_ID \
--map-public-ip-on-launch

# -------------------------
# INTERNET GATEWAY
# -------------------------

echo "Creating internet gateway..."

IGW_ID=$(aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=notesapp-igw}]' \
--query 'InternetGateway.InternetGatewayId' \
--output text)

echo "IGW: $IGW_ID"

aws ec2 attach-internet-gateway \
--internet-gateway-id $IGW_ID \
--vpc-id $VPC_ID

# -------------------------
# ROUTE TABLE
# -------------------------

echo "Creating route table..."

RT_ID=$(aws ec2 create-route-table \
--vpc-id $VPC_ID \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=notesapp-rt}]' \
--query 'RouteTable.RouteTableId' \
--output text)

echo "Route Table: $RT_ID"

aws ec2 create-route \
--route-table-id $RT_ID \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $IGW_ID

aws ec2 associate-route-table \
--subnet-id $SUBNET_ID \
--route-table-id $RT_ID

# -------------------------
# KEY PAIR
# -------------------------

echo "Creating key pair..."

aws ec2 create-key-pair \
--key-name $KEY_NAME \
--query 'KeyMaterial' \
--output text > $KEY_NAME.pem

chmod 400 $KEY_NAME.pem

# -------------------------
# SECURITY GROUP
# -------------------------

echo "Creating security group..."

SG_ID=$(aws ec2 create-security-group \
--group-name notesapp-sg \
--description "NotesApp security group" \
--vpc-id $VPC_ID \
--query 'GroupId' \
--output text)

echo "Security Group: $SG_ID"

# SSH
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

# HTTP
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0

# NotesApp
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 3000 \
--cidr 0.0.0.0/0

# -------------------------
# GET AMI
# -------------------------

echo "Fetching latest Amazon Linux AMI..."

AMI_ID=$(aws ec2 describe-images \
--owners amazon \
--filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
--query 'Images | sort_by(@,&CreationDate)[-1].ImageId' \
--output text)

echo "AMI: $AMI_ID"

# -------------------------
# LAUNCH INSTANCE
# -------------------------

echo "Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
--image-id $AMI_ID \
--instance-type t2.micro \
--key-name $KEY_NAME \
--subnet-id $SUBNET_ID \
--security-group-ids $SG_ID \
--associate-public-ip-address \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=notesapp-server}]' \
--query 'Instances[0].InstanceId' \
--output text)

echo "Instance: $INSTANCE_ID"

# -------------------------
# WAIT FOR INSTANCE
# -------------------------

echo "Waiting for instance to start..."

aws ec2 wait instance-running \
--instance-ids $INSTANCE_ID

# -------------------------
# GET PUBLIC IP
# -------------------------

PUBLIC_IP=$(aws ec2 describe-instances \
--instance-ids $INSTANCE_ID \
--query 'Reservations[0].Instances[0].PublicIpAddress' \
--output text)

echo "Instance Public IP: $PUBLIC_IP"

# -------------------------
# DONE
# -------------------------

echo ""
echo "Infrastructure ready."
echo ""
echo "SSH Access:"
echo "ssh -i $KEY_NAME.pem ec2-user@$PUBLIC_IP"
echo ""
echo "NotesApp endpoint:"
echo "http://$PUBLIC_IP:3000"
