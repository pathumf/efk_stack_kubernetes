#EFK STACK ON KUBERNETES 
Deploying efk stack on kubernetes with kube operation and terraform 

inststalled 100% automated logging cluster with Terraform and Kube Operations on Kubernetes cluster. we installed EFK and started sending any logs events from kube nodes using fluentd agent.

#Architecture

![alt tag](https://s3-ap-northeast-1.amazonaws.com/ku8-yaml-conf-720d/arch.png)

#Prerequisite
AWS Cli

# Deployment infrastructure
1) Edit variable file with necessary parameters

2) ./terraform_wrapper.sh apply | plan 

#Destroying infrastructure

1) ./terraform_wrapper.sh destroy


