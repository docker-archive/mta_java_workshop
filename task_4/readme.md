# Configure Docker hosts for ELK containers

Each Linux Docker host needs to be configured to allow ELK stack containers to run on it. Set the following configuration on each host:

```bash
sysctl -w vm.max_map_count=262144
```

For the configuraiton to persist host reboots:

```bash
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
```

>you can use `PDSH` to apply the change to multiple nodes at the same time

```bash
# example host list
hostlist='ucp1,dtr1,wrkr1,wrkr2'
pdsh -w $hostlist "echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf"
```
