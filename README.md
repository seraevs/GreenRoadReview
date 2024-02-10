## Azure Web Application and Monitoring Solution Deployment Pipeline

    This README document provides a comprehensive guide on setting up and using a CI/CD pipeline for deploying a web application alongside a monitoring solution on Azure. 
    The pipeline uses Terraform for infrastructure provisioning and Kubernetes for application deployment.

# Overview
    The pipeline is structured into two primary stages:

        1) Terraform Provisioning: Automates the creation of Azure infrastructure required for the application and monitoring solution.
        2) Kubernetes Deployment: Manages the deployment of the web application and Grafana (used for monitoring) on a Kubernetes cluster in Azure.

# Prerequisites
    Before you begin, ensure you have the following prerequisites in place:

        An Azure subscription with sufficient permissions to create and manage resources.
        Azure CLI installed and configured for access to your Azure subscription.
        A Kubernetes cluster running on Azure (AKS can be used for simplicity).
        Terraform installed locally or in your CI/CD environment.
        Access to a container registry (such as Azure Container Registry) if using custom container images for your web application or monitoring solution.

# Pipeline Stages and Scripts
    Terraform Provisioning Stage
    This stage sets up the necessary Azure infrastructure components using Terraform.

    Key Scripts and Files:
        terraform/main.tf: Contains Terraform configurations for provisioning Azure resources such as virtual networks, subnets, and Kubernetes service principals.
        Resources Provisioned:
        Azure Resource Group: A container that holds related resources for an Azure solution.
        Azure Virtual Network and Subnet: Networking infrastructure to provide isolation and routing for the AKS cluster.
        Azure Kubernetes Service (AKS) Cluster: Managed Kubernetes service for deploying containerized applications.
        Azure Role Assignments: Necessary permissions for the Kubernetes service principal to manage resources.
     
# Kubernetes Deployment Stage
    This stage deploys the web application and the Grafana monitoring solution onto the 
    Kubernetes cluster using Kubernetes manifests.

    Key Scripts and Files:
        kubernetes/web-site-deployment.yaml: Kubernetes manifest for deploying the web application, typically using Nginx as a web server.
        kubernetes/web-site-service.yaml: Kubernetes service to expose the web application externally.
        kubernetes/monitoring-solution-deployment.yaml: Kubernetes manifest for deploying Grafana for monitoring purposes.
        kubernetes/monitoring-solution-service.yaml: Kubernetes service to expose the Grafana dashboard externally.

    Components Deployed:
        Web Application: A scalable deployment managed by Kubernetes, accessible through a LoadBalancer service.
        Grafana Dashboard: A deployment for the Grafana monitoring tool, also exposed through a LoadBalancer service for easy access.

# Getting Started
    1. Setup Azure Environment
        Login to the Azure CLI and select your subscription.
        Ensure your service principal has the necessary permissions for creating and managing resources.
    2. Configure Terraform
        Update the terraform/main.tf file with your specific Azure settings, such as the subscription ID, tenant ID, and service principal details.
    3. Configure Kubernetes Manifests
        Modify the Kubernetes deployment and service YAML files under the kubernetes/ directory to match your application and monitoring requirements.
    4. Run the Pipeline
        Commit your changes to trigger the pipeline automatically, or manually initiate the pipeline run through your CI/CD platform's dashboard.
    5. Access the Deployed Services
        Once the deployment is successful, use the Azure portal or kubectl to find the external IP addresses of the web application and Grafana dashboard services.

# Monitoring and Logging
        Leverage Azure Monitor and Log Analytics to keep track of your deployments and to set up alerts for any potential issues.
        Use Grafana to visualize metrics from your application and Kubernetes cluster for performance monitoring and troubleshooting.
# Troubleshooting
        Terraform Errors: Verify Azure service principal permissions and ensure all required fields in the Terraform configuration are correctly filled out.
        Kubernetes Deployment Issues: Check the logs of Kubernetes pods and services. Use kubectl describe and kubectl logs commands for detailed diagnostics.
        Service Access: If encounter issues accessing the web application or Grafana dashboard, 
        verify the LoadBalancer services in Kubernetes and ensure your network security rules in Azure allow traffic to the designated ports.

        For more detailed guidance and troubleshooting, refer to Azure and Kubernetes documentation, 
        or reach out to the community forums for specific issues encountered during the deployment process.
