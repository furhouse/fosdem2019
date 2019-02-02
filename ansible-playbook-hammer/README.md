### Set up SSHD on target

LXD example:

https://gitlab.10.132.8.93.nip.io/root/ansible-playbook-hammer/merge_requests/7

    lxc config set k2 environment.LANG en_US.UTF-8
    lxc exec k2 -- yum -y localinstall https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.7.1-1.el7.ans.noarch.rpm
    lxc exec k2 -- sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
    lxc exec k2 -- systemctl restart sshd
    lxc file push ~/.ssh/id_rsa.pub k2/root/.ssh/authorized_keys
    lxc exec k2 -- chown root.root /root/.ssh/authorized_keys
    lxc exec k2 -- chmod 0600 /root/.ssh/authorized_keys

    hammer host create --name "henk.lxd" --hostgroup "el7_group" --interface "type=interface,managed=true,primary=true,provision=true,compute_bridge=br0" --volume="capacity=32G" --compute-attributes "start=1" --location "wim-ws2" --organization lxd

https://access.redhat.com/documentation/en-us/red_hat_satellite/6.2/html/provisioning_guide/provisioning_virtual_machines_in_kvm#Provisioning_Virtual_Machines_in_KVM-Creating_Image_Based_Hosts_on_a_KVM_Server

https://github.com/theforeman/hammer-cli-foreman/blob/master/doc/host_create.md#libvirt

Via cloud-init, note _user_, also requires `ansible become`:

```yaml
#cloud-config
users:
  - name: centos
    groups: sudo
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBKVxMClR2MgAdsk8B2/HSZPPiScLdQpmLf0j1t8/v2mQtLennsYuY6NAWXLF5Ju7QaCPtjp3ucklC9hHCFGVv7zURb5iZQClkc2C98nPcrGKCjgm3LH3nNYrfbZvGweRba2FPkbpm/ShazN64yYvn8Zccqrxz1/PoFpe/YqYZS0ycjcAgqxPIODhV7nXk/FgSReNh1OViB3mL86okxhLX8GlxDKmZrclD4q+F6OfVkTd8eNhdgV3txgp+PZmJHkQmItRep1dz/tCxXm9nudtqMRetYDwSgB8BwbEThkHQSyMrBGHcs9DEoaESSEY1TIX14QxvlpX+k2JmU0xCm0tw1+Su5SfmJLkXiPSZSIK7W8C+kAsDPrcV1baGwIGBd+tZ9hgg3MWux/md4Dx2W9eWRatnqTV/nAD5CMNRUA57lj61aeYjxHhGI0rR31D/lx89YndwOFA/ErkRgigjEPehJyTbke4o/uuySrjfr9gcW/vbl+IaLOUg2PzCdX3xlCpoXlB95t8czxoW4LZl7cp4zaue4p6mJJQsGWbjnXwj+BlFnOgkBuqiEfj8Dsb3DNaX9twdWGFnYcA2wkDIl9JUq9nq/IqW4b6o4oCvpPM86uIwVMvuuFIA8MORq068KesnjHfPSJ4se6ONG8Azf5CKDYYjidpczYAcxQbh6+PNtw== wim@chief
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjSWYXdGFBoPI2VZvHqqbQv6a+Mpmhy2lJFM+N9qL3giv7MFG7+qgMUeS7iDEOS2x6LA1rmOVQRLwdeNL9/7PO3TaCpYCGXidGSSRkQdrNA4Yv1xjjX2+71EvWVHim/LEs6n1nPLI9nRdvPa9VHvRrllaocxH0BIodz2vozO7t1dEGpnuUJs1ls5k0fd+dAZHvvsi4bHN/Tg7G8lDiCgMm+ohAgpS9VhD+sBYFwGFra6LoNZzuiJ+CRm/rXA3M83vj6QKOE112RJa23JVrXx3Qh9X0k3V8x5CuVMEqMuJgbd1vDbYfXgr6njtd1UITBNB5oHQAxw+YNAOQEf22VaS3sVrw32JuDcb+zHr5zF9HvRzHOsS5kfTlBXmWMZhGP1cnCxkvgvDQDvr8bQSywdeTyMofZTmTHo4nFETLeleYjTh/PuHh1zR0kFeVrrPeWoh/dph/l73ol4TJXsRpOcZjSDDPNjMDGJZdRbXOnBm7xFdOgC2ZN+thGyHESalP6B96WFysmGH1olEmNWrJgWTW5JpZnE38lSGJnh15JyHGGYWr0nhM4Ae6TPexyrh9ykLpQn8f+1YXrJWOIBMp+A6FbIiW3u39tsUo0Rtq94eLKpKBOKMIwA/DRBrYAqxOSIFNBhflwz6/oi3yTgCWMpY3/2PB9vvwIQQqQpn43EVLWQ== wim@wim-ws2
runcmd:
  - yum -y localinstall https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.7.1-1.el7.ans.noarch.rpm
  - yum install -y openssh-server
```

### Known issues

* if cloning via ssh, add private key to git before `r10k.yml` playbook starts
* first apply sync creation fails
* second apply content view creation fails -> comment versions
* 3rd apply fails -> uncomment versions
* `centos_version` seems to change from `CentOS 7.5.1804` to `CentOS Linux 7.5.1804`
* ~~Asignment of OS mirror based on hardcoded OS id, see os.yml~~
* fam repo sync is broken, A value must be provided for the \"organization\" field.
* centos-errata.yml playbook uses `yum` module for installing `katello-agent`
    with `gpgcheck=0`

## Hardcoded Values

**subnet.yml**

*network type: IPv4*

*boot-mode DHCP*

*ipam None*

domain-ids 2

tftp-id 1

**hostgroup.yml**

*description Host group for CentOS 7 servers*

*architecture x86_64*

*pxe-loader PXELINUX BIOS*

**repos.yml**

*names, upstream urls, content credential names*

*sync plan name/interval/sync_date/product*

*content view repositories*

**keys.yml**

*key names*

*upstream md5sums*


**global param**

*enable-puppetlabs-puppet5-repo=true*

**base_katello.yml**

*idle_timeout: 10080*

lifecycle envs:
 - Devel
 - Test
 - Production
