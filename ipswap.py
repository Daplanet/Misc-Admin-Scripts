import glob
import shutil
import os
import re

backupdir = '/root/ifcfg-backup/'
sysconfglob = '/etc/sysconfig/network-scripts/ifcfg-eth0*'
gateway = '172.29.34.1'
r_ipaddr = re.compile(r'^IPADDR=.*$', re.MULTILINE)
r_gateway = re.compile(r'^GATEWAY=.*$', re.MULTILINE)

iplist = []
with open('iplist.txt') as f:
    iplist = f.readlines()

ifcfglist = glob.glob(sysconfglob)
ifcfglist.sort()

try:
    os.mkdir(backupdir)
except OSError:
    pass

for cfg in ifcfglist:
    shutil.copy(cfg, backupdir+os.path.basename(cfg))

for cfg in ifcfglist:
    cur = ""
    with open(cfg, 'r') as f:
        cur = f.read()

    out = re.sub(r_ipaddr,'IPADDR='+iplist.pop(0).rstrip(), cur)
    out = re.sub(r_gateway,'GATEWAY='+gateway, out)

    with open(cfg, 'w') as f:
        f.write(out)
