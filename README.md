Build a Kubernetes cluster using RKE2 via Ansible
=========  
<p align="center">
  <img src="./docs/assets/RGS_Logo.png" />
</p>


> [!CAUTION]  
> The RKE2-Ansible repository has been significantly refactored. Note that configurations/inventories written for the v1.0.0 release and earlier are not compatible with v2.0.0 and on. Please see the documentation and make any adjustments necessary. 

Unofficial Rancher Government Repository
---------

Support: Please note that the code provided in this repository is not supported under any official support subscriptions. While we strive to ensure the quality and functionality of our code, we provide it on an "as-is" basis and make no guarantees regarding its performance.

Issues: We understand that issues may arise, and while we do not offer formal support, we will address reported issues on a "best effort" basis. We encourage users to report any problems or bugs they encounter, and we will do our best to address them in a timely manner.

Contributions: Contributions to this repository are welcome! If you have improvements or fixes, please feel free to submit a pull request. We appreciate your efforts to improve the quality and effectiveness of this code.

Thank you for your understanding and cooperation.

Ansible RKE2 (RKE Government) Playbook
---------

RKE2, also known as RKE Government, is Rancher's next-generation Kubernetes distribution. This Ansible playbook installs RKE2 for both the control plane and workers.

See the [docs](https://docs.rke2.io/) more information about [RKE Government](https://docs.rke2.io/).


Platforms
---------  

[![Lint](https://github.com/rancherfederal/rke2-ansible/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/rancherfederal/rke2-ansible/actions/workflows/lint.yml) [![Rocky](https://github.com/rancherfederal/rke2-ansible/actions/workflows/rocky.yml/badge.svg?branch=main)](https://github.com/rancherfederal/rke2-ansible/actions/workflows/rocky.yml) [![Ubuntu](https://github.com/rancherfederal/rke2-ansible/actions/workflows/ubuntu.yml/badge.svg?branch=main)](https://github.com/rancherfederal/rke2-ansible/actions/workflows/ubuntu.yml) [![Ansible Galaxy](https://img.shields.io/badge/Ansible%20Galaxy-rancherfederal.rke2_ansible-blue?logo=ansible&style=flat-square)](https://galaxy.ansible.com/rancherfederal/rke2_ansible)

The RKE2 Ansible playbook supports:
- Rocky 8, and 9
- RedHat: 8, and 9
- Ubuntu: 22, and 24


System requirements
-------------------
Deployment environment must have Ansible 2.9.0+

Usage
-----
Create an Ansible inventory file (or folder), you can check the docs folder for examples (`basic_sample_inventory` or `advanced_sample_inventory`).

> [!NOTE]  
> More detailed information can be found [here](./docs/README.md)

Start provisioning the cluster using the following command:
```bash
ansible-playbook ./playbooks/site.yml -i inventory/hosts.yml -b
```  


Tarball Install/Air-Gap Install  
-------------------------------  
Air-Gap/Tarball install information can be found [here](./docs/tarball_install.md)


Kubeconfig
----------
The root user will have the `kubeconfig` and `kubectl` made available, to access your cluster login into any server node and `kubectl` will be available for use immediately. 


Uninstall RKE2  
---------------  
    Note: Uninstalling RKE2 deletes the cluster data and all of the scripts.
The official documentation for fully uninstalling the RKE2 cluster can be found in the [RKE2 Documentation](https://docs.rke2.io/install/uninstall/).

If you used this module to created the cluster and RKE2 was installed via yum, then you can attempt to run this command to remove all cluster data and all RKE2 scripts.

Replace `ec2-user` with your ansible user.
```bash
ansible -i 18.217.113.10, all -u ec2-user -a "/usr/bin/rke2-uninstall.sh"
```

If the tarball method was used then you can attempt to use the following command:
```bash
ansible -i 18.217.113.10, all -u ec2-user -a "/usr/local/bin/rke2-uninstall.sh"
```
On rare occasions you may have to run the uninstall commands a second time.

Known Issues
------------------

- For RHEL8+ Operating Systems that have FapolicyD daemon running, rpm installation of RKE2 will fail due to a permission error while starting containerd. Users have to add the following rules file before installing RKE2. This is not an issue if the install.sh script is used to install RKE2. The RPM issue is expected to be fixed in later versions of RKE2.

As of RKE2 1.30.5, FapolicyD rules are now deployed via the rke2-common RPM. The RPM does not attempt to restart FapolicyD, therefore this playbook still assumes ownership of the FapolicyD rules.

The rke2-common RPM creates the 80-rke2.rules file with root:root ownership. This playbook will modify that to be root:fapolicy, which may result in a change being shown on a second playbook run.

```bash
cat <<-EOF >>"/etc/fapolicyd/rules.d/80-rke2.rules"
allow perm=any all : dir=/var/lib/rancher/
allow perm=any all : dir=/opt/cni/
allow perm=any all : dir=/run/k3s/
allow perm=any all : dir=/var/lib/kubelet/
EOF

systemctl restart fapolicyd

```

- The rke2-selinux RPM will set proper SELinux context for RKE2 on systems with SELinux enabled. If modifying `data-dir`, the rke2-selinux RPM is not aware of this change and will not be setting the proper context on the new `data-dir` directories. Setting the proper SELinux context for a modified `data-dir` is not supported by this playbook and should be handled externally before this playbook runs.

Author Information
------------------

[Rancher Government Solutions](https://ranchergovernment.com/)
