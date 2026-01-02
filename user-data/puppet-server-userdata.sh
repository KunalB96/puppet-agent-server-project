#!/bin/bash

# Puppet Server User Data Script for Ubuntu
set -e

echo "🔴 Starting Puppet Server Setup via Terraform..."

# Update system
apt update -y
apt install -y wget

# Download and install Puppet 7 repository
wget https://apt.puppet.com/puppet7-release-focal.deb
dpkg -i puppet7-release-focal.deb
apt update

# Install Puppet Server
apt install -y puppetserver

# Add Puppet to PATH
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /etc/environment
export PATH=/opt/puppetlabs/bin:$PATH

# Configure memory settings for t3.medium
sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g"/JAVA_ARGS="-Xms1g -Xmx1g"/' /etc/default/puppetserver

# Create production environment structure
mkdir -p /etc/puppetlabs/code/environments/production/manifests

# Create site.pp manifest
cat > /etc/puppetlabs/code/environments/production/manifests/site.pp << 'EOF'
node 'puppetagent' {

  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => "Apache managed by Puppet Server via Terraform\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['apache2'],
  }

}

node default {
  notify { 'Default node': 
    message => "No specific configuration for this node"
  }
}
EOF

# Set hostname
hostnamectl set-hostname ${puppet_server_hostname}

# Start and enable Puppet Server
systemctl start puppetserver
systemctl enable puppetserver

# Wait for service to be ready
sleep 30

echo "🎉 Puppet Server setup complete via Terraform!"