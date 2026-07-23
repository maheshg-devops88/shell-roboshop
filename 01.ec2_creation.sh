#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
Instance_Type="t3.micro"
SG_ID="sg-020b6d9853c171a73"
SUB_ID="subnet-0a76f340dca5f78a5" 

for instance in $@; do

aws ec2 run-instances --image-id $AMI_ID \
    --instance-type $Instance_Type \
    --security-group-ids $SG_ID \
    --subnet-id $SUB_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --count 1

if [$instance==frontend]; then
   
   public_ip="aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance" \
             --query "Reservations[*].Instances[*].PublicIpAddress" --output text"

   echo "$instance instance public is $public_ip

else

   private_ip="aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance" \
               --query "Reservations[*].Instances[*].PrivateIpAddress" --output text"

   echo "$instance instance private is $private_ip
 fi

done



# aws ec2 describe-instances \
#     --instance-ids i-0123456789abcdef0 \
#     --query "Reservations[*].Instances[*].PublicIpAddress" \
#     --output text

# for Name in $@
   
#     if [ $Name==frontend ]; then
       
#     public_ip="aws ec2 describe-instances --instance-ids i-0123456789abcdef0 \
#             --query "Reservations[*].Instances[*].PublicIpAddress" --output text"
   
   