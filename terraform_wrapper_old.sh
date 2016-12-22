#!/bin/bash
#create_vars
TARGET=terraform
OUTPUT_PATH=out/terraform
FILE=out/terraform/data/aws_launch_configuration_master*
BASE_DIR=`pwd`
export PATH=$PATH
echo $PATH
for i in $(/bin/cat $BASE_DIR/variables); do export $i; done

$BASE_DIR/src/kops create cluster \
	--name=$CLUSTER_NAME \
	--state=$STATE \
        --zones=$ZONES \
        --node-count=$NODE_COUNT \
        --node-size=$NODE_SIZE \
        --master-size=$MASTER_SIZE --dns-zone=$DNS_ZONE \
        --target=$TARGET 

/bin/sleep 60 

if [ -f $FILE && grep -Fi "logging_stack.sh" $FILE ];
then
  echo "wget https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/elk-yaml-conf.tar.gz" >> $FILE
  echo "wget https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/logging_stack.sh" >> $FILE
  echo "bash logging_stack.sh" >> $FILE
else 
  echo "Error in launch config"
fi

if [ -f $OUTPUT_PATH/kubernetes.tf ];
then
  if [ $1 == "destroy" ];
  then
   terraform $1
   if [ $? -ne 0 ];
   then
    kops delete cluster $CLUSTER_NAME --yes --state=$STATE
   fi
  else 
   terraform $1
  fi
else
  echo "Check the terraform.tf file path and run"
fi
