#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
Instance_Type="t3.micro"
SG_ID="sg-020b6d9853c171a73"
SUB_ID="subnet-0a76f340dca5f78a5" 


aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $Instance_Type \
    --security-group-ids $SG_ID \
    --subnet-id $SUB_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$1}]' \
    --count 1
