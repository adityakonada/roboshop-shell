#!/bin/bash

AMI=ami-0b4f379183e5706b9 #this keeps on changing
SG_ID=sg-060cc4f8d742c5a9e #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z06052533ER7D19715K92 # replace your zone ID
DOMAIN_NAME="adityakonada.site"

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t3.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    #--tag-specifications -->is for giving name to the created instance; #value is nothing but $i in line 9
    #--query 'Instances[0].PrivateIpAddress' --> fetches the private Ip adderess 
    #In instance 0 List; . = search privateIpaddress ;  --output text = prints the output (see notes)  
    #we are storing the Private Ip address in IP_ADDRESS variable   #doing this for Route53 purpose. 
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing A-record (Dont delete NS & SOA records. )
    #below command found from google 
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done

#name = mongodb.adityakonada.site
#type = A-record 
#Value = private Ip address. 