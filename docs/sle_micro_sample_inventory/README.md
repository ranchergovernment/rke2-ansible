# SLE Micro 6+ Support

This directory demonstrates a simplified inventory for launching RKE2 instances on SLE Micro 6+. Support for this feature is **experimental**.

## Requirements

* SLE Micro 6 &mdash; Older versions of SLE Micro do not play nicely with this playbook.
* Ansible 2.16+ &mdash; Older versions of Ansible may or may not work. For example, we were unable to use the playbook on Ansible 2.14 provided by Alma 9. We attempted to make this addition to the playbook compatible with older versions of Ansible, but YMMV.

## Filing Issues

Support for SLE Micro 6 is in an experimental phase. If you encounter issues not covered in this document, we encourage you to open a GitHub issue using the following link:

* [RKE2 Ansible Playbook Issues](https://github.com/ranchergovernment/rke2-ansible/issues)

## The Default Behavior

By default, the RKE2 installer uses the *tarball method* when installing on SLE Micro and SLES. For that reason, this playbook follows the same logic.

If you wish to use the *RPM method* to install RKE2, you need to set the `rke2_use_slem_rpms` to `true` in your Ansible variables. You can find an example of this in `group_vars/all.yml'.

```yaml
rke2_user_slem_rpms: true
```
## The Playbook Run

The Ansible playbook remains unchanged, though there are a few items of note:

### Private Repositories

When selecting the *RPM method*, SLE Micro needs the RKE2 Zypper repositories. By default, the playbook configures them for you, but assumes you have access to the open Internet.

If you are running the playbook in an air-gapped environment, you need to configure those repositories. You can change the default values using Ansible variables, in your `group_vars/all.yml` file.

The following block is an example of what your `group_var/all.yaml` file may look like:

```yaml
rke2_user_slem_rpms: true
rke2_channel: "stable"

# Change the baseurl to reflect your private repos
rke2_common_zypper_repo:
  name: rancher-rke2-common
  description: "Rancher RKE2 Common {{ rke2_channel }}"
  baseurl: "https://my.private-repo.io/rke2/{{ rke2_channel }}/common/slemicro/noarch"
  gpgcheck: true
  gpgkey: "https://my.private-repo.io/public.key"
  enabled: true

rke2_versioned_zypper_repo:
  name: "rancher-rke2-v{{ rke2_version_majmin }}"
  description: "Rancher RKE2 v{{ rke2_version_majmin }}"
  baseurl: "https://my.private-repo.io/rke2/{{ rke2_channel }}/{{ rke2_version_majmin }}/slemicro/x86_64"
  gpgcheck: true
  gpgkey: "https://my.private-repo.io/public.key"
  enabled: true
```

### The Transactional Update

When installing via the *RPM method*, the `transactional-update` requires an immediate reboot of the system. This blind reboot has not been a problem in our testing, but YMMV. If you encounter issues with this approach, please feel free to open an issue.


### Installation Locations

The installation location of the *tarball* and *RPM methods* are different. The *tarball method* installs RKE2 in the `/opt` directory. This allows RKE2 to persist between reboots because `/opt` exists outside of what SLE Micro considers immutable.

The *RPM installation method* installs RKE2 in `/var/lib/rancher/rke2`.

