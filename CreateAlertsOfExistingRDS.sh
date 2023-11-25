#!/bin/bash

REGION="us-east-1"
THRESHOLD_FOR_CPU=80
THRESHOLD_FOR_RAM=500000000   # In bytes
SNS="your-sns-topic-arn"
RDS_LIST=$(aws rds describe-db-instances --region $REGION --query 'DBInstances[*].DBInstanceIdentifier' --output text)

for INSTANCE_ID in $RDS_LIST; do
    aws cloudwatch put-metric-alarm \
        --region $REGION \
        --alarm-name "CPU-Alert-For-$INSTANCE_ID" \
        --alarm-description "CPU is high for $INSTANCE_ID RDS instance" \
        --actions-enabled \
        --alarm-actions $SNS \
        --metric-name CPUUtilization \
        --namespace AWS/RDS \
        --statistic Average \
        --dimensions "Name=DBInstanceIdentifier,Value=$INSTANCE_ID" \
        --period 120 \
        --threshold $THRESHOLD_FOR_CPU \
        --comparison-operator GreaterThanThreshold \
        --evaluation-periods 2

    aws cloudwatch put-metric-alarm \
        --region $REGION \
        --alarm-name "Freeable-Memory-Alert-For-$INSTANCE_ID" \
        --alarm-description "Freeable Memory is low for $INSTANCE_ID RDS instance" \
        --actions-enabled \
        --alarm-actions $SNS \
        --metric-name FreeableMemory \
        --namespace AWS/RDS \
        --statistic Average \
        --dimensions "Name=DBInstanceIdentifier,Value=$INSTANCE_ID" \
        --period 120 \
        --threshold $THRESHOLD_FOR_RAM \
        --comparison-operator LessThanThreshold \
        --evaluation-periods 2

done
