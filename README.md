# Puppet Agent-Server Infrastructure with Terraform

This project automatically provisions and configures Puppet infrastructure on AWS using Terraform.

## 🚀 Quick Start

### Prerequisites
- Terraform installed
- AWS CLI configured
- Key pair `puppet.pem` in project directory

### Deploy Infrastructure

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Plan deployment:**
```bash
terraform plan
```

3. **Deploy infrastructure:**
```bash
terraform apply
```

4. **Access your Apache server:**
```bash
# Get the agent's public IP from outputs
terraform output apache_url
```

### Cleanup
```bash
terraform destroy
```

## 🏗️ What Gets Deployed

- **2 Ubuntu EC2 instances** (t3.medium)
- **Security Group** with ports 22, 80, 8140
- **Puppet Server** with Apache manifest
- **Puppet Agent** with automated Apache installation
- **Automated certificate signing**

## 📋 Configuration

Modify `variables.tf` to customize:
- AWS region
- Instance type
- Key pair name
- Private key path

## 🔍 Outputs

After deployment, Terraform provides:
- Server and agent IP addresses
- SSH commands
- Apache URL

## ⚡ Automation Features

- Fully automated Puppet installation
- Certificate management
- Apache deployment
- No manual intervention required
       │                                │
       │ 4. Compiled Catalog           │
       ◄────────────────────────────────┤
       │                                │
       │ 5. Report Submission          │
       ├──────────────────────────────► │
       │                                │
```

### **Deployment Workflow**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   1. Server     │───►│   2. Agent      │───►│ 3. Certificate  │
│     Setup       │    │     Setup       │    │   Management    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Install Puppet │    │  Install Puppet │    │ Sign Agent Cert │
│     Server      │    │     Agent       │    │   on Server     │
│  Configure SSL  │    │ Configure hosts │    │                 │
│  Create Manifest│    │ Set server URL  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  6. Validation  │◄───│ 5. Idempotency  │◄───│ 4. Apply Config │
│     & Testing   │    │     Testing     │    │   Run Puppet    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **File System Layout**
```
Puppet Server (/etc/puppetlabs/)
├── puppet/
│   ├── puppet.conf
│   └── ssl/
│       ├── ca/
│       │   ├── ca_crt.pem
│       │   └── ca_key.pem
│       └── certs/
└── code/
    └── environments/
        └── production/
            ├── manifests/
            │   └── site.pp          ← Apache deployment manifest
            └── modules/

Puppet Agent (/etc/puppetlabs/)
├── puppet/
│   ├── puppet.conf                  ← Server configuration
│   └── ssl/
│       ├── certs/
│       │   └── puppetagent.pem      ← Agent certificate
│       └── certificate_requests/
└── facter/                          ← System facts
```

### **Network Security**
```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Group Rules                         │
├─────────────────┬─────────────┬─────────────────────────────────┤
│      Port       │   Protocol  │           Purpose               │
├─────────────────┼─────────────┼─────────────────────────────────┤
│       22        │     TCP     │  SSH Access (Management)       │
│       80        │     TCP     │  HTTP (Apache Web Server)      │
│      8140       │     TCP     │  Puppet Communication          │
└─────────────────┴─────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Certificate Chain                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐         ┌─────────────────┐               │
│  │  Puppet CA      │ signs   │ Agent Certificate│               │
│  │ (puppetserver)  │ ──────► │  (puppetagent)  │               │
│  └─────────────────┘         └─────────────────┘               │
│           │                           │                         │
│           └─── Mutual TLS Authentication ───┘                   │
└─────────────────────────────────────────────────────────────────┘
```

### **Key Architecture Components**

* **Puppet Server**: Centralized configuration management server
* **Puppet Agent**: Client service that applies configurations
* **Certificate Authority**: Manages SSL certificates for secure communication
* **Manifests**: Declarative configuration files (site.pp)
* **Catalog**: Compiled configuration sent to agents
* **Reports**: Status updates sent back to server
* **Idempotent Execution**: Same configuration produces same result

---

## 🎯 Project Objectives

* Install and configure **Puppet Server**
* Install and configure **Puppet Agent**
* Establish secure agent–server communication
* Deploy Apache on agent node
* Manage services and files centrally
* Validate idempotency and state enforcement

---

## 🧰 Prerequisites

### **AWS Requirements**

* 2 EC2 instances
* Ubuntu 20.04 / 22.04 LTS
* Same VPC (recommended)
* Same Availability Zone (optional, for lower latency)

### **Recommended Instance Types**

#### **💰 Budget-Friendly (Development/Learning)**
```
┌─────────────────┬─────────────────┬─────────────────────────────────┐
│   Instance      │   Instance Type │         Specifications          │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Puppet Server   │    t3.small     │ 2 vCPU, 2 GB RAM, $15/month    │
│ Puppet Agent    │    t3.micro     │ 2 vCPU, 1 GB RAM, $8/month     │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Total Cost      │      ~$23/month │ Good for learning/testing       │
└─────────────────┴─────────────────┴─────────────────────────────────┘
```

#### **🚀 Production-Ready (Small Scale)**
```
┌─────────────────┬─────────────────┬─────────────────────────────────┐
│   Instance      │   Instance Type │         Specifications          │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Puppet Server   │    t3.medium    │ 2 vCPU, 4 GB RAM, $30/month    │
│ Puppet Agent    │    t3.small     │ 2 vCPU, 2 GB RAM, $15/month    │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Total Cost      │      ~$45/month │ Handles multiple agents         │
└─────────────────┴─────────────────┴─────────────────────────────────┘
```

#### **⚡ High Performance (Enterprise)**
```
┌─────────────────┬─────────────────┬─────────────────────────────────┐
│   Instance      │   Instance Type │         Specifications          │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Puppet Server   │    m5.large     │ 2 vCPU, 8 GB RAM, $70/month    │
│ Puppet Agent    │    t3.medium    │ 2 vCPU, 4 GB RAM, $30/month    │
├─────────────────┼─────────────────┼─────────────────────────────────┤
│ Total Cost      │     ~$100/month │ Supports 50+ agents             │
└─────────────────┴─────────────────┴─────────────────────────────────┘
```

### **Resource Requirements**

#### **Puppet Server Minimum Specs:**
- **CPU**: 2 cores (4 recommended for production)
- **RAM**: 2 GB minimum (4-8 GB recommended)
- **Disk**: 20 GB (SSD preferred for better I/O)
- **Network**: Stable connection for port 8140

#### **Puppet Agent Minimum Specs:**
- **CPU**: 1 core (2 recommended)
- **RAM**: 1 GB minimum (2 GB recommended)
- **Disk**: 10 GB (for logs and temporary files)
- **Network**: Reliable connection to Puppet Server

### **Instance Selection Guide**

| **Use Case**           | **Server Type** | **Agent Type** | **Best For**                    |
|------------------------|-----------------|----------------|---------------------------------|
| **Learning/Tutorial**  | t3.micro        | t3.nano        | Cost-effective learning         |
| **Development**        | t3.small        | t3.micro       | Single developer testing        |
| **Small Production**   | t3.medium       | t3.small       | 5-10 managed nodes             |
| **Medium Production**  | m5.large        | t3.medium      | 10-50 managed nodes            |
| **Large Production**   | m5.xlarge       | m5.large       | 50+ managed nodes              |

### **💡 Cost Optimization Tips**

- **Spot Instances**: Use for development (up to 90% savings)
- **Reserved Instances**: 1-year term saves ~40% for production
- **Free Tier**: t2.micro available for first 12 months (AWS Free Tier)
- **Stop Instances**: When not in use to avoid charges
- **Monitoring**: Use CloudWatch to track resource utilization

### **Security Group Rules**

| Port | Purpose       | Source          | Notes                    |
| ---- | ------------- | --------------- | ------------------------ |
| 22   | SSH           | Your IP/CIDR    | Administrative access    |
| 80   | HTTP (Apache) | 0.0.0.0/0       | Web server access        |
| 8140 | Puppet        | Agent Security  | Puppet communication     |
|      |               | Group           |                          |

---

## 🖥️ EC2 Instance Configuration

### **Recommended Setup for This Project**

| Instance | Role          | Instance Type | vCPU | RAM  | Storage | Est. Cost/Month |
| -------- | ------------- | ------------- | ---- | ---- | ------- | --------------- |
| EC2-1    | Puppet Server | t3.small      | 2    | 2 GB | 20 GB   | ~$15            |
| EC2-2    | Puppet Agent  | t3.micro      | 2    | 1 GB | 10 GB   | ~$8             |

**Total Estimated Cost: ~$23/month**

### **Launch Configuration**

#### **Both Instances:**
- **AMI**: Ubuntu Server 22.04 LTS
- **Key Pair**: Create/Select your SSH key
- **VPC**: Use default or create custom
- **Subnet**: Public subnet for internet access
- **Auto-assign Public IP**: Enable
- **Storage**: General Purpose SSD (gp3)

#### **Security Groups Setup:**
```bash
# Create Puppet Server Security Group
aws ec2 create-security-group \
  --group-name puppet-server-sg \
  --description "Puppet Server Security Group"

# Add rules for Puppet Server
aws ec2 authorize-security-group-ingress \
  --group-name puppet-server-sg \
  --protocol tcp --port 22 --cidr 0.0.0.0/0    # SSH
  
aws ec2 authorize-security-group-ingress \
  --group-name puppet-server-sg \
  --protocol tcp --port 8140 --cidr 10.0.0.0/16  # Puppet (VPC CIDR)

# Create Puppet Agent Security Group  
aws ec2 create-security-group \
  --group-name puppet-agent-sg \
  --description "Puppet Agent Security Group"

# Add rules for Puppet Agent
aws ec2 authorize-security-group-ingress \
  --group-name puppet-agent-sg \
  --protocol tcp --port 22 --cidr 0.0.0.0/0    # SSH
  
aws ec2 authorize-security-group-ingress \
  --group-name puppet-agent-sg \
  --protocol tcp --port 80 --cidr 0.0.0.0/0    # HTTP
```

### **Alternative Instance Types by Use Case**

#### **🧪 Free Tier (Learning)**
- **Server**: t2.micro (1 vCPU, 1 GB) - Limited performance
- **Agent**: t2.micro (1 vCPU, 1 GB) - Free for 12 months
- **Note**: May be slow but functional for learning

#### **💼 Production (Small Team)**
- **Server**: t3.medium (2 vCPU, 4 GB) - Handles 10-20 agents
- **Agent**: t3.small (2 vCPU, 2 GB) - Better performance

#### **🏢 Enterprise (Large Scale)**
- **Server**: m5.large+ (2+ vCPU, 8+ GB) - Supports 50+ agents
- **Agent**: t3.medium (2 vCPU, 4 GB) - Production workloads

---

## 📂 Directory Structure (Server)

```
/etc/puppetlabs/code/environments/production/
├── manifests/
│   └── site.pp
```

---

## 🔴 Puppet Server Setup

### Install Puppet Server

```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppetserver
```

### Configure Memory

```bash
sudo nano /etc/default/puppetserver
```

```ini
JAVA_ARGS="-Xms512m -Xmx512m"
```

### Start Puppet Server

```bash
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
```

---

## 🟢 Puppet Agent Setup

### Install Puppet Agent

```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppet-agent
```

### Configure Agent

```bash
sudo nano /etc/puppetlabs/puppet/puppet.conf
```

```ini
[main]
server = puppetserver
environment = production
```

### Hostname Configuration

```bash
hostnamectl set-hostname puppetagent
```

---

## 🔑 Certificate Management

### Trigger Certificate Request (Agent)

```bash
sudo puppet agent -t
```

### Sign Certificate (Server)

```bash
sudo /opt/puppetlabs/bin/puppetserver ca list
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
```

Re-run on agent:

```bash
sudo puppet agent -t
```

---

## 📝 Puppet Manifest

### `site.pp`

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

---

## ▶️ Apply Configuration

On Puppet Agent:

```bash
sudo puppet agent -t
```

Expected output:

```
Notice: Applied catalog in XX seconds
```

---

## 🌐 Verification

Open browser:

```
http://<AGENT_PUBLIC_IP>
```

You should see:

```
Apache managed by Puppet Server
```

---

## 🧪 Validation Commands

```bash
puppet agent --test
puppet resource service apache2
puppet resource package apache2
systemctl status apache2
```

---

## 📚 Key Concepts Demonstrated

* Puppet Agent–Server architecture
* Certificate-based trust model
* Declarative manifests
* Idempotency
* Centralized configuration
* Production environment structure

---

## 🚀 How to Run This Project

### **Option 1: Automated Setup (Recommended)**

1. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh run-project.sh
   ```

2. **View execution guide:**
   ```bash
   ./run-project.sh
   ```

3. **Follow the step-by-step instructions displayed**

### **Option 2: Complete Manual Setup**

#### **Step 1: Puppet Server Setup (EC2 Instance 1)**

**1.1 Update system and install Puppet Server:**
```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppetserver
```

**1.2 Configure memory settings:**
```bash
sudo nano /etc/default/puppetserver
# Change: JAVA_ARGS="-Xms512m -Xmx512m"
```

**1.3 Set hostname:**
```bash
sudo hostnamectl set-hostname puppetserver
```

**1.4 Create directory structure:**
```bash
sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests
```

**1.5 Create site.pp manifest:**
```bash
sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp
```
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
    content => "Apache managed by Puppet Server - Manual Setup\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['apache2'],
  }
}
```

**1.6 Start Puppet Server:**
```bash
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
```

#### **Step 2: Puppet Agent Setup (EC2 Instance 2)**

**2.1 Update system and install Puppet Agent:**
```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppet-agent
```

**2.2 Set hostname:**
```bash
sudo hostnamectl set-hostname puppetagent
```

**2.3 Configure hosts file (replace with actual server IP):**
```bash
echo "<PUPPET_SERVER_PRIVATE_IP> puppetserver" | sudo tee -a /etc/hosts
```

**2.4 Configure Puppet Agent:**
```bash
sudo nano /etc/puppetlabs/puppet/puppet.conf
```
```ini
[main]
server = puppetserver
environment = production

[agent]
report = true
pluginsync = true
```

**2.5 Enable Puppet service:**
```bash
sudo systemctl enable puppet
export PATH=$PATH:/opt/puppetlabs/bin
```

#### **Step 3: Certificate Management**

**3.1 Request certificate (on Agent):**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

**3.2 Sign certificate (on Server):**
```bash
sudo /opt/puppetlabs/bin/puppetserver ca list
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
```

**3.3 Apply configuration (on Agent):**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

#### **Step 4: Manual Validation**

**4.1 Verify Apache installation (on Agent):**
```bash
systemctl status apache2
dpkg -l | grep apache2
ls -la /var/www/html/index.html
```

**4.2 Test web server:**
```bash
curl http://localhost
# Should return: "Apache managed by Puppet Server - Manual Setup"
```

**4.3 Check Puppet resource status:**
```bash
sudo /opt/puppetlabs/bin/puppet resource package apache2
sudo /opt/puppetlabs/bin/puppet resource service apache2
sudo /opt/puppetlabs/bin/puppet resource file /var/www/html/index.html
```

**4.4 Test idempotency:**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
# Should show no changes on second run
```

### **Step 6: Verify Deployment**

1. **Check Apache status:**
   ```bash
   systemctl status apache2
   curl http://localhost
   ```

2. **Access via web browser:**
   ```
   http://<AGENT_PUBLIC_IP>
   ```
   You should see: "Apache managed by Puppet Server"

---

## 🧪 Testing & Validation

### **Automated Test Suite**
```bash
# Comprehensive testing (detects server vs agent automatically)
./scripts/test-puppet-setup.sh
```

### **End-to-End Validation**
```bash
# Complete deployment validation (run on agent)
./scripts/validate-deployment.sh
```

### **Manual Validation Commands**
```bash
# Test Puppet configuration
sudo /opt/puppetlabs/bin/puppet agent -t

# Check resource status
sudo /opt/puppetlabs/bin/puppet resource package apache2
sudo /opt/puppetlabs/bin/puppet resource service apache2

# View logs
journalctl -u puppet -f          # Agent logs
journalctl -u puppetserver -f    # Server logs
```

---

## 📋 Prerequisites Checklist

- ✅ **2 Ubuntu EC2 instances** (20.04/22.04 LTS)
- ✅ **Security Groups** configured:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 8140 (Puppet)
- ✅ **Same VPC** (recommended)
- ✅ **SSH access** to both instances

---

## 🔧 Troubleshooting

### **Common Issues**
- **Certificate errors**: Check `/etc/hosts` hostname resolution
- **Connection refused**: Verify Security Group rules for port 8140
- **Agent not updating**: Check Puppet Server logs
- **Apache issues**: Validate manifest syntax in `site.pp`

### **Debug Commands**
```bash
# Verbose Puppet run
sudo /opt/puppetlabs/bin/puppet agent -t --verbose

# Certificate status
sudo /opt/puppetlabs/bin/puppetserver ca list --all

# Test connectivity
telnet <server_ip> 8140
```

---

## 🎯 Expected Results

✅ **Puppet Server** running and accessible on port 8140  
✅ **Agent registered** with signed certificate  
✅ **Apache installed** via Puppet manifest  
✅ **Apache service** running and enabled  
✅ **Custom web page** deployed with Puppet-managed content  
✅ **HTTP access** working on port 80  
✅ **Idempotent** configuration management

---

## 📁 Project Structure

```
puppet-agent-server-project/
├── scripts/
│   ├── puppet-server-setup.sh    # Automated server setup
│   ├── puppet-agent-setup.sh     # Automated agent setup  
│   ├── test-puppet-setup.sh      # Comprehensive test suite
│   ├── validate-deployment.sh    # End-to-end validation
│   └── README.md                 # Scripts documentation
├── run-project.sh                # Execution guide
├── README.md                     # This file
└── LICENSE                       # Project license
```

---

