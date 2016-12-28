#!/bin/bash
#create_vars
TARGET=terraform
OUTPUT_PATH=out/terraform
FILE=out/terraform/data/aws_launch_configuration_master*
FILE2=out/terraform/data/aws_launch_configuration_nodes*
BASE_DIR=`pwd`
export PATH=$PATH
KOPS=`ls $BASE_DIR/src/`
if [ -z "$KOPS" ];
then
  wget https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/kops -P $BASE_DIR/src/ 
else
  echo "KOPS Already in src folder"
fi
#check for aws cli
#command -v aws >/dev/null 2>&1 || { echo >&2 "I require awscli but it's not installed. Please install aws cli Aborting."; exit 1; }


for i in $(/bin/cat $BASE_DIR/variables); do export $i; done

if [ -z "$AWS_ACCESS_KEY_ID" ];
then 
  echo "Setup AWS access key and the secret key, Aborting.."
  /bin/sleep 6
  exit 1
fi

if [ -z "`command -v aws`" ];
then
  echo "Please install aws cli and re run the script, Aborting"
  /bin/sleep 6
  exit 1 
else
    aws s3api create-bucket --bucket $S3_BUCKET_NAME --region $REGION >> /dev/null
fi
chmod 777 $BASE_DIR/src/kops

$BASE_DIR/src/kops create cluster \
	--name=$CLUSTER_NAME \
	--state=$STATE \
        --zones=$ZONES \
        --node-count=$NODE_COUNT \
        --node-size=$NODE_SIZE \ 
        --dns-zone=$DNS_ZONE \ 
        --master-size=$MASTER_SIZE \
        --target=$TARGET 

/bin/sleep 6 
OUTPUT=`grep -Fi "logging_stack.sh" $FILE`

if ([ -f $FILE ] && [ -z "$OUTPUT" ]);
then
  echo "wget https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/elk-yaml-conf.tar.gz" >> $FILE
  echo "wget https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/logging_stack.sh" >> $FILE
  echo "bash logging_stack.sh" >> $FILE
  echo "sudo su -c  \"echo 262144 > /proc/sys/vm/max_map_count\"" >> $FILE
  echo "sudo su -c  \"echo 262144 > /proc/sys/vm/max_map_count\"" >> $FILE2
else 
  echo "configuration files already added to launch config"
fi

if [ -f $OUTPUT_PATH/kubernetes.tf ];
then
  if [ $1 == "destroy" ];
  then
   cd $BASE_DIR/out/terraform
   terraform $1
   if [ $? -ne 0 ];
   then
    echo "running kops"
    kops delete cluster $CLUSTER_NAME --yes --state=$STATE
   fi
  else 
   echo "applying terraform"
   cd $BASE_DIR/out/terraform
   terraform $1
  fi
else
  echo "Check the terraform.tf file path and run"
fi
