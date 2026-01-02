Puppet Server & Agent Setup on AWS EC2 (Ubuntu 22.04)

This project demonstrates how to set up a Puppet Server and Puppet Agent on AWS EC2 instances and manage configuration using Puppet manifests.

Architecture Overview

Instances: 2 EC2 instances

Instance Type: t3.medium

Key Pair: puppet.pem

OS: Ubuntu 22.04 (Jammy)

Security Group Ports:

22 – SSH

80 – Apache HTTP

8140 – Puppet Server

Nodes
Role	Hostname
Puppet Server	puppet.ec2.internal
Puppet Agent	puppetagent
Step 1: Launch EC2 Instances

Launch 2 EC2 instances

Assign the same Security Group

Allow inbound traffic on:

SSH (22)

HTTP (80)

Puppet (8140)

Puppet Server Setup
1. Set Hostname
sudo hostnamectl set-hostname puppet.ec2.internal


Edit hosts file:

sudo nano /etc/hosts


Add:

127.0.0.1   puppet.ec2.internal
172.31.35.34 puppet.ec2.internal

2. Install Puppet Server
wget https://apt.puppet.com/puppet7-release-jammy.deb
sudo dpkg -i puppet7-release-jammy.deb
sudo apt update
sudo apt install -y puppetserver

3. Configure Puppet Server
sudo nano /etc/puppetlabs/puppet/puppet.conf

[main]
certname = puppet.ec2.internal
server = puppet.ec2.internal
environment = production

[server]
dns_alt_names = puppet,puppet.ec2.internal

4. Start Puppet Server
sudo systemctl enable puppetserver
sudo systemctl start puppetserver


Verify status:

sudo systemctl status puppetserver

5. Create Puppet Manifest
sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp

node 'puppet.ec2.internal' {
  file { '/tmp/puppet_test.txt':
    ensure  => file,
    content => "Puppet Server is working\n",
  }
}

node 'puppetagent' {
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure => running,
    enable => true,
    require => Package['apache2'],
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => "Apache managed by Puppet\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
  }
}

node default {
  notify { "Unknown node: ${trusted.certname}": }
}

6. Verify Puppet Server Certname
sudo puppet config print certname


Expected output:

puppet.ec2.internal

Puppet Agent Setup
1. Set Hostname
sudo hostnamectl set-hostname puppetagent

2. Fix Name Resolution
sudo nano /etc/hosts


Add:

172.31.35.34 puppet.ec2.internal

3. Install Puppet Agent
wget https://apt.puppet.com/puppet7-release-jammy.deb
sudo dpkg -i puppet7-release-jammy.deb
sudo apt update
sudo apt install -y puppet-agent

4. Configure Puppet Agent
sudo nano /etc/puppetlabs/puppet/puppet.conf

[main]
certname = puppetagent
server = puppet.ec2.internal
environment = production

5. Remove Old SSL (If Retried)
sudo rm -rf /etc/puppetlabs/puppet/ssl

6. Run Puppet Agent (Generate CSR)
sudo /opt/puppetlabs/bin/puppet agent -t


Expected output:

Certificate for puppetagent has not been signed yet

Certificate Signing (On Puppet Server)
1. List Pending Certificates
sudo /opt/puppetlabs/bin/puppetserver ca list

2. Sign Agent Certificate
sudo /opt/puppetlabs/bin/puppetserver ca sign --certname puppetagent

Final Agent Run & Verification
1. Run Puppet Agent Again
sudo /opt/puppetlabs/bin/puppet agent -t


Expected output:

Notice: /Package[apache2]/ensure: created
Notice: /Service[apache2]/ensure: ensure changed 'stopped' to 'running'
Notice: /File[/var/www/html/index.html]/content: content changed

2. Test Apache
curl http://localhost


Expected output:

Apache managed by Puppet

Result

✅ Puppet Server successfully manages the Puppet Agent
✅ Apache installed, running, and configured via Puppet
✅ Configuration management verified
