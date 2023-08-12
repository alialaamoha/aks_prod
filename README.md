# Azure Kubernetes using terraform for production 
Azure Kubernetes (Iac)  for production  


the components for the baseline archeticture 
- Network topology
    A hub-spoke network  deployed in separate virtual networks connected through peering.
    
   - #### A hub-spoke network   
     hub virtual network hosts shared Azure services. Workloads hosted in the spoke virtual networks can use these services. The hub virtual network is the central point of connectivity for cross-premises networks.

     The hub virtual network is the central point of connectivity and observability. A hub always contains an Azure Firewall with global firewall policies defined by your central IT teams to enforce organization wide firewall policy, Azure Bastion, a gateway subnet for VPN connectivity, and Azure Monitor for network observability

   - #### Spoke virtual networks. 
    Spoke virtual networks isolate and manage workloads separately in each spoke. Each workload can include multiple tiers, with multiple subnets connected through Azure load balancers. Spokes can exist in different subscriptions and represent different environments, such as Production and Non-production.

   - #### Virtual network connectivity (Peering).

   - #### Azure Bastion host.
   - #### Azure Firewall
   - #### Azure VPN Gateway





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



AKS Baseline Automation

- ### The Infrastructure team 
  Automating the deployment of AKS and the Azure resources that it depends on, such as ACR, KeyVault, Managed Identities, Log Analytics, etc.


- ### The Networking team
  Networking components of the solution such as Vnets, DNS, App Gateways, etc

- ## The Application team
  Automating the deployment of their application services into AKS and managing their release to production using a Blue/Green or Canary approach.

  these teams can accomplish their goals by packaging their service using helm and deploying them either through a CI/CD pipeline such as GitHub Actions or a GitOp tools such as Flux or ArgoCD.


- ### The Shared-Services team

  Responsible for maintaining the overall health of the AKS clusters and the common components that run on them, such as monitoring,networking, security and other utility services.


  AKS add-ons such 
   - Azure Active Directory pod-managed identities in Azure Kubernetes
   - Secret Store CSI Driver Provider, 
   - 3rd party such as Prisma defender or Splunk daemonset
   - open source such as KEDA, 
   - External-dns 
   - Cert-manager. 
   
   This team is also responsible for the lifecycle management of the clusters, such as making sure that updates/upgrades are periodically performed on the cluster, its nodes, the Shared-Services running in it and that cluster configuration changes are seamlessly conducted as needed without impacting the applications.

- ### The Security team
   making sure that security is built into the pipeline and all components deployed are secured by default.

   maintaining the 
   - Azure Policies, 
   - NSGs, 
   - firewalls rules outside the cluster as well as all security related configuration within the AKS cluster, such as Kubernetes Network Policies, RBAC or authentication and authorization rules within a Service Mesh



Each team will be responsible for maintaining their own automation pipeline. These pipelines access to Azure should only be granted through a Service Principal, a Managed Identity or preferably a Federated Identity with the minimum set of permissions required to automatically perform the tasks that the team is responsible for.



Reference 

hub spoke pattern for network 
https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli