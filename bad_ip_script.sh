#!/bin/bash
#add failed login ip addresses to hosts.deny
#add as a cron job to run periodically

#create bad_ip.txt with header to hold ip addresses
echo '#bad_ip_script' > bad_ip.txt

#search auth.log for failed sshd login attempts and append unique ip addesses to bad_ip
grep sshd /var/log/auth.log | grep sshd | grep 'Failed password for root' | awk '{print "sshd : " $11}'| sort| uniq >> bad_ip.txt
grep sshd /var/log/auth.log | grep sshd | grep 'Failed password for invalid user' | awk '{print "sshd : " $13}'| sort| uniq >> bad_ip.txt
grep sshd /var/log/auth.log | grep sshd | grep ' Unable to negotiate with' | awk '{print "sshd : " $10}'| sort| uniq >> bad_ip.txt

#copy any existing bad sshd ip's to bad_ip
grep sshd /etc/hosts.deny >> bad_ip.txt

#copy all unique bad_ip's to unique_bad_ip
cat bad_ip.txt | sort | uniq > unique_bad_ip.txt

#remove existing bad_ip's from hosts.deny
sed -i '/#bad_ip_script/,$ d' /etc/hosts.deny

#add new bad_ip's to hosts.deny
cat unique_bad_ip.txt >> /etc/hosts.deny
cat unique_bad_ip.txt | grep -c 'sshd'
echo 'bad ip addresses'
