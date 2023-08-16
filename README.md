# Azure Kubernetes using terraform for production 

Azure platform
AKS  latest version 
System and User node pool separation
AKS-managed Azure AD
Azure AD-backed Kubernetes RBAC (local user accounts disabled)
Managed Identities
Azure CNI
Azure Monitor for containers
Azure Virtual Networks (hub-spoke)
Azure Firewall managed egress
Azure Application Gateway (WAF)
AKS-managed Internal Load Balancers
In-cluster OSS components
Azure Workload Identity [AKS-managed add-on]
Flux GitOps Operator [AKS-managed extension]
ImageCleaner (Eraser) [AKS-managed add-on]
Kubernetes Reboot Daemon
Secrets Store CSI Driver for Kubernetes [AKS-managed add-on]
Traefik Ingress Controller




Azure Kubernetes (Iac)  for production  

components in the code 

- Hub network with 2 subnets
  - Azure Firewall 
  - Azure Bastion
- Spoke network 
  - pod subnet
  - service subnet
  - additional 
  - workload subnet (user vms)
- private endpoint 
- private dns zone 
- private container regisry

kubernetes components
- external dns
- flux
- argo cd
- Azuredevops agents
- istio
- promethuos 
- grafana 
- loki
- jeager

Messaging 
- kafka
- postgress
- mongodb
- rabbitmq
- azure service bus

additional
- valut
- harbor 

connect to the virtual machine with bastion host 

```
az network bastion ssh --name "<BastionName>" --resource-group "<ResourceGroupName>" --target-ip-addres "<VMIPAddress>" --auth-type "ssh-key" --username "<Username>" --ssh-key "<Filepath>"
```

- create a storage account to store terraform state 
- create a resource group to categorize the resources for AKS project
- create an active directory users and groups
- create service account and permission to create users and appliances 
- create a network
- create subnet for the network 
- create aks 
- addons for aks
  - external dns
  - tls
  - api gateways
  - service mesh
  - network security group
- integration with aks
- workload inside aks
- logs/ tracing /etrics
- gitops

## Core architecture components
AKS Private Cluster
Azure Virtual Networks (hub-spoke)
Azure Firewall managed egress
Azure Application Gateway (WAF)
Application Gateway Ingress Controller
AKS-managed Internal Load Balancer
Azure CNI
Azure Keyvault
Azure Container registry
Azure Bastion
Azure Monitor for containers
Azure firewall
MongoDB
Helm
Secret store CSI driver
Azure RBAC for Kubernetes Authorization
Azure Active Directory pod-managed identities


## A future workload for this scenario will include the following

Horizontal Pod Autoscaling
Cluster Autoscaling
Readiness/Liveness Probes
Azure Service Bus
Azure CosmosDb
Azure MongoDb
Azure Redis Cache

