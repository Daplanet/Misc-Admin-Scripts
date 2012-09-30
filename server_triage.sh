#!/bin/bash



PUBLICIP=$(curl -s icanhazip.com)
IPS=$(ifconfig | grep "inet addr" | grep -v "127.0.0.1")










# show mysql processlist - use plesk password if available
if [ -f /etc/psa/.psa.shadow ]
then
	mysql -u admin -p`cat /etc/psa/.psa.shadow` -e "show processlist;"
	mysql -u admin -p`/usr/local/psa/bin/admin --show-password` -e "show processlist;"
else
	mysql -e "show processlist;"
fi




# Plesk version
if [ -f /usr/local/psa/version ]
then
	cat /usr/local/psa/version
	cat `locate "psa/version"`
	echo "https://$PUBLICIP:8443"
fi




# Plesk password
if [ -f /etc/psa/.psa.shadow ]
then
	cat /etc/psa/.psa.shadow
fi

if [ -f /usr/local/psa/bin/admin ]
then
	/usr/local/psa/bin/admin --show-password
fi







SMARTCTL=$(which smartctl)
if [ $? -lt 1 ]; then
	$SMARTCTL -a /dev/sda | grep "SMART" | grep "health"
fi



HOSTNAME=$(hostname)
echo "# Server: $HOSTNAME"

UPTIME=$(uptime | cut -d "," -f 1 | awk '{print $3,$4;}')
echo "# Uptime: $UPTIME"

echo "# Public IP: $PUBLICIP"
echo "# All IPS: $IPS"







# Check ram usage
MEM=$(free -t -m | grep "Mem:")
MEMFREE=$(echo $MEM | awk '{print $4}')
#echo "$MEMFREE MB free ram"
MEMTOTAL=$(echo $MEM | awk '{print $2}')
#echo "$MEMTOTAL total ram"

PERCENTMEMFREE=$(echo "scale=2; $MEMFREE / $MEMTOTAL * 100" | bc)
#echo "$PERCENTMEMFREE % free RAM"
PERCENTMEMUSE=$(echo "scale=2; 100-$PERCENTMEMFREE" | bc)
#echo "$PERCENTMEMUSE % used RAM"
if [ $(echo "$PERCENTMEMUSE" | cut -d "." -f 1) -gt 80 ]
then
	echo "$PROBLEMS\nHigh memory use - $PERCENTMEMUSE"
fi




# check swap usage
SWAP=$(free -t -m | grep "Swap:")
SWAPFREE=$(echo $SWAP | awk '{print $4}')
#echo "$SWAPFREE MB free swap"
SWAPTOTAL=$(echo $SWAP | awk '{print $2}')
#echo "$SWAPTOTAL total swap"
PERCENTSWAPFREE=$(echo "scale=2; $SWAPFREE / $SWAPTOTAL * 100" | bc)
PERCENTSWAPUSE=$(echo "scale=2; 100-$PERCENTSWAPFREE" | bc)
echo "$PERCENTSWAPUSE % swap used"
if [ $(echo "$PERCENTSWAPUSE" | cut -d "." -f 1) -gt 80 ]
then
        echo "$PROBLEMS\nHigh swap use - $PERCENTSWAPUSE"
fi




if [ -f /etc/redhat-release ]
then

	REDHATRELEASE=$(cat /etc/redhat-release)

	if [ $(echo $REDHATRELEASE | grep -i "CentOS" | wc -l) -gt 0 ]
	then
		echo "CentOS found"
		CENTOS=1
	fi

    if [ $(echo $REDHATRELEASE | grep -i "Fedora" | wc -l) -gt 0 ]
    then
            echo "Fedora found"
            FEDORA=1
    fi

    if [ $(echo $REDHATRELEASE | grep -i "Red Hat" | wc -l) -gt 0 ]
    then
            echo "Red Hat found"
            RHEL=1
    fi


	if [ $(echo $REDHATRELEASE | grep "6." | wc -l) -gt 0 ]
	then
		echo "Version 6. something"
		VERSION=6
	fi

	echo "Redhat release $REDHATRELEASE"

fi











































exit













# checks all services that should be running and check if they are
services=$(chkconfig --list --type sysv | grep "3:on" | cut -d " " -f 1)
for service in $services
do
	#echo $service
	service $service status > /dev/null 2>&1
	if [ $? != 0 ]
	then
		#echo "$service OK"
	#else
		PROBLEMS="$PROBLEMS\n$service not running or error:"
		PROBLEMS="$PROBLEMS $(service $service status)"
	fi
	# do /etc/init.d/ for debian etc
done







echo " Swap usage of each process"
swap_total=0

for i in /proc/[0-9]*; do

  pid=$(echo $i | sed -e 's/\/proc\///g')

  swap_pid=$(cat /proc/$pid/smaps |

    awk 'BEGIN{total=0}/^Swap:/{total+=$2}END{print total}')

  if [ "$swap_pid" -gt 0 ]; then

    name=$(cat /proc/$pid/status | grep ^Name: |

      awk '{print $2}')

    echo "${name} (${pid}) ${swap_pid} kB"

    let swap_total+=$swap_pid

  fi

done

echo

echo "Total: ${swap_total} kB" 
