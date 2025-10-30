#!/bin/bash
set -ex

# EKS Node bootstrap script
# This is a minimal bootstrap; AWS handles most EKS node setup

exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "EKS Node bootstrap started at $(date)"
echo "Cluster: ${cluster_name}"
echo "Endpoint: ${cluster_endpoint}"

# Update system
yum update -y

echo "EKS Node bootstrap completed at $(date)"
