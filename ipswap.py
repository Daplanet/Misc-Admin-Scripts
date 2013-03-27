import glob
import shutil
import os
import re

backupdir = '/root/ifcfg-backup/'
sysconfglob = '/etc/sysconfig/network-scripts/ifcfg-eth0*'
gateway = '10.0.0.0'

iplist = []
with open('iplist.txt') as f:
    iplist = f.readlines()

ifcfglist = glob.glob(sysconfglob)
ifcfglist.sort()

os.mkdir(backupdir)

for cfg in ifcfglist:
    shutil.copy(cfg, backupdir+os.path.basename(cfg))

for cfg in ifcfglist:
    cur = ""
    with open(cfg, 'r') as f:
        cur = f.read()

    out = re.sub(r'^IPADDR=.*$','IPADDR='+iplist.pop(0).rstrip(), cur, flags=re.MULTILINE)
    out = re.sub(r'^GATEWAY=.*$','GATEWAY='+gateway, out, flags=re.MULTILINE)

    with open(cfg, 'w') as f:
        f.write(out)
