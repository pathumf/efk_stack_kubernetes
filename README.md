#EFK STACK ON KUBERNETES 
Deploying efk stack on kubernetes with kube operation and terraform 

This is soulution we inststalled 100% automated logging cluster with Terraform and Kube Operations on Kubernetes cluster. we installed EFK and started sending any logs events from kube nodes using fluentd agent.

#Prerequisite
AWS Cli

# Deployment infrastructure
1) Edit variable file with necessary parameters

2) ./terraform_wrapper.sh apply | plan 

#Destroying infrastructure

1) ./terraform_wrapper.sh destroy


