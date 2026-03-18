# Opella DevOps Technical Challenge: Provision Azure Infrastructure with Terraform

⚠️ **It's perfectly fine to use AI to assist with this coding challenge. However, ensure you can explain and justify your decisions during the live interview. Let's make the most of our time together.** ⚠️

## Objective

Showcase your skills in provisioning Azure infrastructure using Terraform, emphasizing reusable, secure, and maintainable Infrastructure as Code (IaC). This challenge will assess your ability to structure code effectively, manage resources across environments, and apply industry-standard practices using Azure, Terraform, and GitHub.

## Deliverables

1. Build a reusable Terraform module to deploy an Azure Virtual Network (VNET).
2. Use this module to create multiple environments in Azure (eg, Develoment and Production), adding a few additional resources of your choice (eg, Blob).
3. Submit your work via one or many GitHub repositories, make them plublic and share the URL with us.
   - Please share the terraform plan output. You can use the [Azure Free-tier](https://azure.microsoft.com/en-in/pricing/free-services/).
4. Make sure your code is clean. Propose tools and processes to help you in this aspect.

Expect to spend about 2-4 hours on this.

---

## Requirements

### 1. Reusable Module Creation

**Task**: Create a Terraform module for provisioning an Azure VNET that can be reused across different setups.

- **Purpose**: This should deploy a VNET and related networking resources, designed with flexibility and security in mind.
- **Hints**:
  - Think about what configurations might need to change depending on where or how this is used.
  - Consider optional features that could enhance network security.
  - What outputs you would add and why?
  - What information would someone need in order to use this module? Bonus points if you automate documentation! (indicate how)
  - Super extra points if your module is tested

### 2. Infrastructure Setup

**Task**: Create a repository and a GitHub pipeline to deploy multiple environments in Azure using your VNET module, plus a couple of additional resources.

- **Folder Structure**: Set up your code to handle a `dev` environment in one Azure region (e.g., `eastus`), with an eye toward scaling to other environments and regions later.

- **Hints**:
  - Argument why would you use Resource Groups or Subscriptions for multiple environments.
  - Include a virtual machine and one other resources (your choice—think about what’s useful in a dev setup).
  - Name and label resources to make the environment and region clear.
  - Avoid repeating values—how can you make this flexible?
  - How might you label resources for better tracking? How would you enforce this?
  - What outputs might be useful and why?
  - Bonus points if you build a GitHub pipeline and explain the release lifecycle.

---

Good luck—we’re excited to see your work!