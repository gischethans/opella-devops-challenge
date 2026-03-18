#!/bin/bash

# This script bootstraps the Azure Storage components 
# required for tracking remote Terraform state across the team & pipelines.

RESOURCE_GROUP_NAME="rg-opella-tfstate"
STORAGE_ACCOUNT_NAME="stopellatfstate0941"  # Needs to be globally unique
CONTAINER_NAME="tfstate"
LOCATION="eastus"

echo "Creating Resource Group: $RESOURCE_GROUP_NAME..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION -o none

echo "Creating Storage Account: $STORAGE_ACCOUNT_NAME..."
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob \
  -o none

echo "Creating Blob Container: $CONTAINER_NAME..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode login \
  -o none

echo "=========================================================="
echo "✅ Terraform Remote State Storage Successfully Created!"
echo "Resource Group:       $RESOURCE_GROUP_NAME"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "Container Name:       $CONTAINER_NAME"
echo "=========================================================="
