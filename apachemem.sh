#!/bin/sh

if [[ ! -e /usr/local/bin/pssgen.py ]]; then
cat <<EOF > /usr/local/bin/pssgen.py
#!/usr/bin/python
import glob
import re
import os

ispid = re.compile("/proc/([0-9]+)")
pssinfo = re.compile("Private.+:\s+([0-9]+)")
files = glob.glob('/proc/*')

for apid in files:
        m = ispid.match(apid)
        if not m:
                continue
        pid = m.group(1)

        try:
                data = open(os.path.join(apid,'smaps')).read(512000)
                stat = open(os.path.join(apid,'stat')).read(512000).split(" ")[1]
        except IOError:
                continue
        m = pssinfo.findall(data)
        m = map(int,m)
        a = 0
        for b in m:
                a += b
        print "%d %s %s" % (a, pid, stat)
EOF
fi

if [[ -e /usr/local/bin/pssgen.py ]]; then
    chmod +x /usr/local/bin/pssgen.py
else
    echo "Something went wrong, /usr/local/bin/pssgen.py should exist now but doesn't."
    exit 1
fi

APACHEBIN=""

if [[ -e /etc/debian-release ]]; then
    APACHEBIN="apache2"
elif [[ -e /etc/redhat-release ]]; then
    APACHEBIN="httpd"
else
    echo "Could not determine distro (although I didn't try very hard)."
    exit 2
fi

/usr/local/bin/pssgen.py | awk "/$APACHEBIN/{TOT+=\$1;SUM++}END{printf \"\nApache is using %.2fMb spread over %d servers, averaging %.2fMb per server.\n\",TOT/1024,SUM,(TOT/SUM)/1024}"

PERSERVER=$(/usr/local/bin/pssgen.py | awk "/$APACHEBIN/{TOT+=\$1;SUM++}END{printf \"%.2f\",(TOT/SUM)/1024}")
PATHTOMC=""
if [[ ! -d /usr/local/cpanel ]]; then
    if [[ -e /etc/debian-release ]]; then
        PATHTOMC="/etc/apache2/apache2.conf"
    elif [[ -e /etc/redhat-release ]]; then
        PATHTOMC="/etc/httpd/conf/httpd.conf"
    fi
elif [[ -d /usr/local/cpanel ]]; then
    PATHTOMC="/usr/local/apache/conf/extra/httpd-mpm.conf"
else
    echo "I'm not going to be able to find Apache's MaxClients setting, sorry."
    exit 1
fi

if [[ ! -e "$PATHTOMC" ]]; then
    echo "$PATHTOMC doesn't seem to exist, but it should (probably)."
    exit 1
fi

# I know these are horrible, deal with it.
MAXCLIENTS=$(cat $PATHTOMC | tr -s " " | sed 's/^ //' | egrep -m1 "^MaxClients" | sed 's/MaxClients//' | tr -d " ")
MAXMEM=$(echo "$PERSERVER * $MAXCLIENTS" | bc)
AVAILMEM=$(free -m | grep Mem | tr -s " " | cut -d" " -f2)
MAXMAXCLIENTS=$(echo "$AVAILMEM / $PERSERVER" | bc)
echo "MaxClients is currently set to ${MAXCLIENTS}."
echo "Current settings will allow maximum memory usage to be: ${MAXMEM}Mb"
echo "MaxClients should be no larger than: ${MAXMAXCLIENTS}"
echo 
