# Ecom application deployment on AWS network with EKS
# November 18, 2023

## Purpose

The primary goal of this deployment is to leverage Kubernetes to deploy a robust e-commerce application within the AWS network. Automation is introduced by Terraform and Jenkins to streamline the provisioning of the application's architecture. To enhance security, the application’s containers are launched in private subnets. Workload distribution and accessibility are ensured through the deployment of a load balancer. Configuration details, such as accessible ports and desired states, are declared in YAML files.

This setup aims to establish a resilient and scalable infrastructure for the e-commerce application, optimizing performance and scalability during traffic spikes, and addressing disaster recovery scenarios.
