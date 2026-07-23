#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
Instance_Type="t3.micro"
SG_ID="sg-020b6d9853c171a73"
SUB_ID="subnet-0a76f340dca5f78a5" 
Domain_Name="daws88s.shop"
ZONE_ID=Z01154241BNSMMPVQO32W


if [ $# -eq 0 ]; then
   echo "please provide the instance name to create the instance"
   exit 1
fi

VALIDATE() 
    if [ $? -eq 0 ]; then
    echo "$2 record name is $instance.$Domain_Name created"
    else 
    echo "$2 record is not created..."
    fi

for instance in $@; do

ec2_instance=$(aws ec2 run-instances --image-id $AMI_ID \
    --instance-type $Instance_Type \
    --security-group-ids $SG_ID \
    --subnet-id $SUB_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --count 1)

if [ $instance == frontend ]; then
   
   public_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance" \
    --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

   echo "$instance instance public is $public_ip"



aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID \
--change-batch '{
        "Comment": "Upserting a record",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$instance.$Domain_Name'",
                    "Type": "A",
                    "TTL": 2,
                    "ResourceRecords": [
                        {
                            "Value": "'$public_ip'"
                        }
                    ]
                }
            }
        ]
    }'


VALIDATE $? $instance 

else

   private_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance" \
               --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)

   echo "$instance instance private is $private_ip"

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID \
--change-batch '{
        "Comment": "Upserting a record",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$instance.$Domain_Name'",
                    "Type": "A",
                    "TTL": 2,
                    "ResourceRecords": [
                        {
                            "Value": "'$private_ip'"
                        }
                    ]
                }
            }
        ]
    }'

 VALIDATE $? $instance 

 fi

done




   