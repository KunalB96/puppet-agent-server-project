# Puppet Manual Setup Commands

## Infrastructure Requirements

1. launch 2 instances | t3.medium | puppet.pem 
2. puppet-server, puppet-agent 
3. SG - 8140, 22. 80

## Puppet Server Setup Commands

```bash
sudo apt update -y
sudo apt install -y wget
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppetserver
sudo apt remove --purge -y puppetserver puppet-agent puppet7-release puppet-module-puppetlabs-mailalias-core
sudo apt autoremove -y
sudo apt clean
sudo rm -f /etc/apt/sources.list.d/puppet*.list
sudo rm -f /etc/apt/trusted.gpg.d/puppet*.gpg
sudo apt update
sudo apt install -y puppetserver
puppetserver --version
puppet --version
  
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

puppet --version
sudo systemctl start puppet
sudo systemctl enable puppet
sudo systemctl status puppet

mkdir -p puppet-apache/{manifests,files}
cd puppet-apache
cd manifests

touch site.pp
```

### site.pp Content

```puppet
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
    content => "Apache managed by Puppet Server\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
  }

}
```

## Puppet Agent Setup Commands

```bash
// on agent 

sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppet-agent

echo 'export PATH=$PATH:/opt/puppetlabs/bin' >> ~/.bashrc
source ~/.bashrc

sudo hostnamectl set-hostname puppetagent
sudo /opt/puppetlabs/bin/puppet agent -t
```

## Instance Details

### Server Instance
```
i-0d58a7d3956e6d4f9 (server)
PublicIPs: 34.230.29.197    PrivateIPs: 172.31.24.198    
```

### Agent Instance
```
i-0d4b78d801167ee2f (agent)
PublicIPs: 98.94.87.179    PrivateIPs: 172.31.17.211    
```
