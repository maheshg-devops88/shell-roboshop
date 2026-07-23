#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
Instance_Type="t3.micro"
SG_ID="sg-020b6d9853c171a73"
SUB_ID="subnet-0123456789abcdef0" 


aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $Instance_Type \
    --security-group-ids s$SG_ID \
    --subnet-id $SUB_ID \
    --count 1
