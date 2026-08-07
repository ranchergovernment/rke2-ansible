# Table of Contents
- [Table of Contents](#table-of-contents)
- [Basic Usage](#basic-usage)
  - [Cloning](#cloning)
  - [Importing](#importing)
  - [Playbooks](#playbooks)
    - [`site.yml`](#siteyml)
    - [`install.yml`](#installyml)
    - [`rotate-certs.yml`](#rotate-certsyml)
    - [`testing.yml`](#testingyml)
    - [`upgrade.yml`](#upgradeyml)
  - [Tags](#tags)
- [Defining Your Cluster](#defining-your-cluster)
  - [Minimal Cluster Inventory](#minimal-cluster-inventory)
  - [Structuring Your Variable Files](#structuring-your-variable-files)
  - [Enabling SELinux](#enabling-selinux)
  - [Enabling CIS Modes](#enabling-cis-modes)
  - [Special Variables](#special-variables)
    - [RKE2 Config Variables](#rke2-config-variables)
    - [Defining the RKE2 Version](#defining-the-rke2-version)
      - [Example](#example)
    - [Defining a PSA Config](#defining-a-psa-config)
      - [Example](#example-1)
    - [Defining an Audit Policy](#defining-an-audit-policy)
      - [Example](#example-2)
    - [Defining a registries.yaml Config](#defining-a-registriesyaml-config)
      - [Example](#example-3)
    - [Adding Additional Cluster Manifests](#adding-additional-cluster-manifests)
      - [Pre-Deploy Example](#pre-deploy-example)
      - [Post-Deploy Example](#post-deploy-example)
- [Examples](#examples)

# Basic Usage  
There are two methods for consuming this repository, one is to simply clone the repository and edit it as necessary, the other is to import it as a collection, both options are detailed below. 

> [!NOTE]  
> If you are looking for airgap or tarball installation instructions, please go [here](./tarball_install.md)

## Cloning  
The simplest method for using this repository (as detailed in the main README.md) is to simply clone the repository and copy the sample inventory. 


## Importing  
The second method for using this project is to import it as a collection in your own `requirements.yml` as this repository does contain a `galaxy.yml`. To import it add the following to your `galaxy.yml`:  
```yaml
collections:
  - name: rancherfederal.rke2-ansible
    source: git@github.com:rancherfederal/rke2-ansible.git
    type: git
    version: main
```  
Then you can call the RKE2 role in a play like so:  
```yaml
---
- name: RKE2 play
  hosts: all
  any_errors_fatal: True
  roles:
    - role: rancherfederal.rke2_ansible.rke2
```

## Playbooks  
Most of the playbooks provided by this repository are not intended to be used in production environments without testing and should therefore be considered experimental with two exceptions `site.yml` and `install.yml`.  All playbooks are provided as is and are not guaranteed to be stable or safe.   
### `site.yml`  
`site.yml` has been kept for backwards compatibility, `site.yml` only calls `install.yml`.

### `install.yml`  
This playbook is the full install playbook intended to build your RKE2 cluster.

### `rotate-certs.yml`  
When building out a cluster RKE2 needs to generate certificates, all certificates are valid for 365 days be default. This play stops the RKE2 service of each node (by default one at a time), rotates the certificates by calling `rke2 certificate rotate` then starts the service again.  
> RKE2 client and server certificates are valid for 365 days from their date of issuance. Any certificates that are expired or within 120 days to expire are automatically renewed every time RKE2 starts. This renewal extends the lifetime of the existing certs.

> [!NOTE]  
> Certificates will not be rotated if they are not within at least 120 days old of expiring. 

### `testing.yml`  
This is used for the repositories testing, do not use.

### `upgrade.yml`  
> [!CAUTION]  
> This is a very basic playbook and running it against a production cluster is not advised. This playbook will not drain a node before upgrading. Please consider using the [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) instead. Use this playbook at your own risk.   

This playbook collects the needed details from all nodes before running the installation on each server, then each agent. By default this playbook will only update one server at a time, then one agent at a time. 

## Tags  
The RKE2 role currently contains seven tags ("cis", "setup-os", "configure", "addons", "setup-root", "stig", "never"). Some must be run after the cluster is installed and some may happen before. When using these tags caution is advised.   

- "cis" only runs the needed tasks to run the "cis_hardening.yml" task set. This task sets up the etcd user, configures systemctl, and reboots.
- "setup-os" is used to run the "pre-reqs.yml" task set. This configures FirewallD, iptables, NetworkManager, and FapolicyD.
- "configure" will update just the RKE2 configuration files. This does not include the add on manifests. 
- "addons" is used to deploy the addon files, including post and pre-deployment manifests.
- "setup-root" sets the root user up for access to `kubectl` and other useful binaries. 
- "stig" resolves a few stig findings needed for compliance.
- "never" Runs a couple debug tasks to display information in case of failures or debugging needs.

# Defining Your Cluster  
This repository is not intended to be opinionated and as a result it is important you to have read and understand the [RKE2 docs](https://docs.rke2.io/) before moving forward, this documentation is not intended to be an exhaustive explanation of all possible RKE2 configuration options, it is up to the end user to ensure their options are valid. 


## Minimal Cluster Inventory  
The most basic inventory file contains nothing more than your hosts, see below:
```yaml
---
rke2_cluster:
  children:
    rke2_servers:
      hosts:
        server0.example.com:
    rke2_agents:
      hosts:
        agent0.example.com:
```  
This is the simplest possible inventory file and will deploy the latest available version of RKE2 with only default settings.


## Structuring Your Variable Files  
Configurations and variables can become lengthy and unwieldy, as a general note of advice it is best to move variables into a `group_vars` folder.
```
./inventory
├── Cluser_A
│   ├── group_vars
│   │   ├── all.yml
│   │   ├── rke2_agents.yml
│   │   └── rke2_servers.yml
│   └── hosts.yml
└── Cluser_B
    ├── group_vars
    │   ├── all.yml
    │   ├── rke2_agents.yml
    │   └── rke2_servers.yml
    └── hosts.yml

5 directories, 8 files
```


## Enabling SELinux  
Enabling SELinux in the playbook requires `selinux: true` be set in either the cluster, group, or host level config profiles (Please see [Special Variables](#special-variables) for more info). Though generally this should be set at the cluster and can be done like so:  
__hosts.yml:__  
```yaml
---
all:
  vars:
    cluster_rke2_config:
      selinux: true
```
For more information please see the RKE2 documentation, [here](https://docs.rke2.io/security/selinux).


## Enabling CIS Modes  
Enabling the CIS tasks in the playbook requires a CIS profile be added to the ansible variables file. This can be placed in either the cluster, or group level config profiles (Please see [Special Variables](#special-variables) for more info). Below is an example, in the example the CIS profile is set at the group level, this ensures all server nodes run the CIS hardening profile tasks.  
__hosts.yml:__  
```yaml
rke2_cluster:
  children:
    rke2_servers:
      vars:
        group_rke2_config:
          profile: cis 
```
For more information please see the RKE2 documentation, [here](https://docs.rke2.io/security/hardening_guide).


## Special Variables  
In general this repository has attempted to move away from special or "magic" variables, however some are unavoidable, the (non-exhaustive) list of variables is below:    
  - `all.vars.rke2_install_version`: This defines what version of RKE2 to install 
  - `rke2_cluster.children.rke2_servers.vars.hosts.<host>.node_labels`: Defines a list of node labels for a specific server node     
  - `rke2_cluster.children.rke2_agents.vars.hosts.<host>.node_labels`: Defines a list of node labels for a specific agent node  


### RKE2 Config Variables  
There are three levels an RKE2 config variables can be placed in, that is `cluster_rke2_config`, `group_rke2_config`, and `host_rke2_config`. 
  - `all.vars.cluster_rke2_config`: Defines common RKE2 config options for the whole cluster
  - `rke2_cluster.children.rke2_servers.vars.group_rke2_config`: Defines common RKE2 config options for the `rke2_servers` group  
  - `rke2_cluster.children.rke2_agents.vars.group_rke2_config`: Defines common RKE2 config options for the `rke2_agents` group   
  - `rke2_cluster.children.rke2_servers.vars.hosts.<host>.host_rke2_config`: Defines RKE2 config options for a specific server node 
  - `rke2_cluster.children.rke2_agents.vars.hosts.<host>.host_rke2_config`: Defines RKE2 config options for a specific agent node

> [!NOTE]
> Through the rest of these docs you may see references to `rke2_servers.yml`, this is the group vars file for rke2_servers. This is functionally equivalent to `rke2_cluster.children.rke2_servers.vars`. References to `rke2_agents.yml` is functionally equivalent to `rke2_cluster.children.rke2_agents.vars`

It is important to understand these variables here are not special in the sense that they enable or disable certain functions in the RKE2 role, with one notable exception being the `profile` key. These variables are special in the sense that they will be condensed into a single config file on each node. Each node will end up with a merged config file comprised of `cluster_rke2_config`, `group_rke2_config`, and `host_rke2_config`. 


### Defining the RKE2 Version  
A version of RKE2 can be selected to be installed via the `all.vars.rke2_install_version` variable, please see the RKE2 repository for available [releases](releases).  

#### Example 
__group_vars/all.yml:__   
```yaml
---
all:
  vars:
    rke2_install_version: v1.29.12+rke2r1
```  

### Defining a PSA Config  
In order to define a PSA (Pod Security Admission) config, server nodes will need to have the `rke2_pod_security_admission_config_file_path` variable defined, then the `pod-security-admission-config-file` will need to be defined in the rke2_config variable at the relevant level (please see [RKE Config Variables](#rke2-config-variables)). 

Alternatively, the inline variable `rke2_pod_security_admission_config_file_content` can be used to pass the YAML content directly (useful when the policy is generated dynamically or stored in inventory). When set, it takes precedence over `rke2_pod_security_admission_config_file_path`.

#### Example 
Below is an example of how this can be defined at the server group level (`rke2_cluster.children.rke2_servers.vars`):  

__group_vars/rke2_servers.yml:__
```yaml
---
rke2_pod_security_admission_config_file_path: "{{ playbook_dir }}/docs/advanced_sample_inventory/files/pod-security-admission-config.yaml"
group_rke2_config:
  pod-security-admission-config-file: /etc/rancher/rke2/pod-security-admission-config.yaml   
```


### Defining an Audit Policy  
In order to define a audit policy config, server nodes will need to have the `rke2_audit_policy_config_file_path` variable defined, then the `audit-policy-file` will need to be defined in the rke2_config variable at the relevant level (please see [RKE Config Variables](#rke2-config-variables)). 

Alternatively, the inline variable `rke2_audit_policy_config_file_content` can be used to pass the YAML content directly. When set, it takes precedence over `rke2_audit_policy_config_file_path`.

#### Example 
Below is an example of how this can be defined at the server group level (`rke2_cluster.children.rke2_servers.vars`):  

__group_vars/rke2_servers.yml:__
```yaml
rke2_audit_policy_config_file_path: "{{ playbook_dir }}/docs/advanced_sample_inventory/files/audit-policy.yaml"
group_rke2_config:
  audit-policy-file: /etc/rancher/rke2/audit-policy.yaml
  kube-apiserver-arg:
    - audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
    - audit-log-path=/var/lib/rancher/rke2/server/logs/audit.log
```


### Defining a registries.yaml Config
As seen [here](https://docs.rke2.io/install/private_registry), RKE2 allows for manipulation of how containerd pulls containers. In order to define a registries.yaml config, nodes will need to have the `rke2_registry_config_file_path` variable defined. Assuming all nodes are to use the same registry configuration, this variable can be set at the top-level so that it applies to all nodes.

Alternatively, the inline variable `rke2_registry_config_file_content` can be used to pass the YAML content directly. When set, it takes precedence over `rke2_registry_config_file_path`.

#### Example 
Below is an example of how this can be defined at the top-level:  

__group_vars/all.yml:__
```yaml
rke2_registry_config_file_path: "{{ playbook_dir }}/docs/advanced_sample_inventory/files/registries.yaml"
```


### Adding Additional Cluster Manifests  
If you have a cluster that needs extra manifests to be deployed or the cluster needs a critical component to be configured, RKE2's "Helm Chart" and "HelmChartConfig" are an available option (among others). The Ansible repository supports the use of these configuration files. Simply place the file (or files) containing these manifests in a folder, give Ansible the path to the folder, and Ansible will enumerate the files and place them on the first server node. 

There are two variables that control the deployment of manifests to the server nodes:  
  - `rke2_manifest_config_directory`
  - `rke2_manifest_config_post_run_directory`  

The first variable is used to deploy manifest to the server nodes before starting the RKE2 server process, this ensures critical components (like the CNI) can be configured when the RKE2 server process starts. The second, ensures applications are deployed after the RKE2 server process starts. There are examples of both below.

#### Pre-Deploy Example 
The example used is configuring Cilium with the kube-proxy replacement enabled (a fairly common use case):  

> [!WARNING]  
> If this option is used you must provide a `become` password and this must be the password for the local host running the Ansible playbook. The playbook is looking for this directory on the localhost, and will run as root. This imposes some limitations, if you are using an SSH password to login to remote systems (typical for STIG'd clusters) the `become` password must be the same for the cluster nodes AND localhost.

__group_vars/rke2_servers.yml:__  
For this example to work kube-proxy needs to be disabled, and the Cilium CNI needs to be enabled.
```yaml
rke2_manifest_config_directory: "{{ playbook_dir }}/docs/advanced_sample_inventory/pre-deploy-manifests/"
group_rke2_config:
  # Use Cilium as the CNI
  cni:
    - cilium
  # Cilium will replace this
  disable-kube-proxy: true
```

__cilium.yaml:__  
This file should be placed in the directory you intend to upload to the server node, in the example above that is `{{ playbook_dir }}/docs/advanced_sample_inventory/pre-deploy-manifests/`.
```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    kubeProxyReplacement: true
    k8sServiceHost: 127.0.0.1
    k8sServicePort: 6443
    bpf:
      masquerade: true
      preallocateMaps: true
      tproxy: true
    bpfClockProbe: true
```

#### Post-Deploy Example  
In the example below cert-manager is auto deployed after the RKE2 server process is started. 
__group_vars/rke2_servers.yml:__  
```yaml
rke2_manifest_config_post_run_directory: "{{ playbook_dir }}/docs/advanced_sample_inventory/post-deploy-manifests/"
```

This file should be placed in the directory you intend to upload to the server node, in the example above that is `{{ playbook_dir }}/docs/advanced_sample_inventory/pre-deploy-manifests/`.
__cert-manager.yaml__  
```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: jetstack
  namespace: kube-system
spec:
  repo: https://charts.jetstack.io
  chart: cert-manager
  version: v1.16.2
  targetNamespace: cert-manager
  createNamespace: true
  valuesContent: |-
    crds:
      enabled: true
```

# Examples  
There are two examples provided in this folder, `basic_sample_inventory`, and `advanced_sample_inventory`. The basic example is the simplest possible example, the advanced example is all of the options explained above in one example.
