#!/bin/bash

# Puppet Agent User Data Script for Ubuntu
set -e

echo "🟢 Starting Puppet Agent Setup via Terraform..."

# Update system
apt update
apt install -y wget

# Download and install Puppet 7 repository
wget https://apt.puppet.com/puppet7-release-focal.deb
dpkg -i puppet7-release-focal.deb
apt update

# Install Puppet Agent
apt install -y puppet-agent

# Add Puppet to PATH
echo 'export PATH=$PATH:/opt/puppetlabs/bin' >> /etc/environment
export PATH=$PATH:/opt/puppetlabs/bin

# Set hostname
hostnamectl set-hostname puppetagent

# Add Puppet Server to hosts file
echo "${puppet_server_ip} ${puppet_server_hostname}" >> /etc/hosts

# Configure Puppet Agent
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
server = ${puppet_server_hostname}
environment = production
runinterval = 30m

[agent]
report = true
pluginsync = true
EOF

# Enable Puppet Agent service
systemctl enable puppet

# Wait for server to be ready, then request certificate
sleep 120
/opt/puppetlabs/bin/puppet agent -t --verbose || echo "⚠️ Certificate request sent to server"

echo "🎉 Puppet Agent setup complete via Terraform!"