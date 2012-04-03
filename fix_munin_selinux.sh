#!/bin/bash
# Creates a module to stop Munin breaking with SELinux

if [[ $UID != 0 ]]; then
    echo "You must be root."
    exit 1
fi

echo "Ensure Munin is installed and running."
echo "About to enable verbose SELinux audit logs and sleep for 10 minutes..."
semodule -DB &

if [[ ! -x `which audit2allow` ]]; then
    echo "audit2allow not found, installing..."
    yum -q -y install policycoreutils-python
fi

echo "Sleeping..."
sleep 600 # Wait for logs to be generated.

echo "Generating SELinux module..."
grep "denied" /var/log/audit/audit.log | grep "munin" | audit2allow -M /root/muninpol

echo "Installing SELinux module..."
semodule -i /root/muninpol.pp

echo "Disabling verbose audit logs..."
semodule -B

echo "Done."
