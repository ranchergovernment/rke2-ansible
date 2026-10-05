# SLE Micro 6+ Support

This directory demonstrates a simplified inventory for launching RKE2 instances on SLE Micro 6+. Support for this feature is **experimental**.

## Requirements

* SLE Micro 6 - Older versions of SLE Micro do not play nicely with this playbook. 
* Ansible 2+

## The Default Behavior

By default, the RKE2 installer uses the *tarball method* when installing on SLE Micro and SLES. For that reason, this playbook follows the same logic.

If you wish to use the *RPM method* to install RKE2, you need to set the `rke2_use_slem_rpms` to `true` in your Ansible variables. You can find an example of this in `group_vars/all.yml'.

```yaml
rke2_user_slem_rpms: true
```
## The Playbook Run

The Ansible playbook remains unchanged, though there are a few items of note.

### Private Repositories

When selecting the *RPM method*, SLE Micro needs the RKE2 Zypper repositories to be configured. By default, the playbook configures them for you, assuming you have access to the open Internet.

If you are in an air-gapped environment, you will need to configure those repositories. You can change the default values via the Ansible variables.

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

When installing via the *RPM method*, the `transactional-update` command requires an immediate reboot of the system. This blind reboot has not been a problem in our testing. YMMV.

### Installation Locations

The installation location of the *tarball* and *RPM methods* are different. The *tarball method* installs RKE2 in the `/opt` directory. This allows RKE2 to persist between reboots because `/opt` exists outside of what SLE Micro considers immutable.

The *RPM installation method* installs RKE2 in `/var/lib/rancher/rke2`.

## The CIS Configured Example

The example in here contains the necessary components to fully enable RKE2's CIS profile. This is intended to be an example, not a one-size fits most CIS-enabled RKE2 example you can plug and play anywhere.
