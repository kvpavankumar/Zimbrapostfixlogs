#!/bin/bash

set -x
HN="$(hostname  | cut -f 2 -d .)"
pass=(`/opt/zimbra/bin/zimbra_pflogsumm.pl -d today /var/log/zimbra.log`)
psql -U postgres -d   zimbra -h 10.100.112.139  -c "INSERT INTO  totalstatus (Servername,received,delivered,forwarded,deferred,bounced,rejected,rejectwarnings,held,discarded,bytesreceived,bytesdelivered,senders,sendinghostsdomains,recipients,recipienthostsdomains,time) VALUES ('"$HN"',"$pass",current_timestamp)";

p='su - zimbra -c'
g2=$(echo  $($p  "qshape deferred | grep gmail.com ") | awk '{print $2}')

if [  -z "$g2" ]; then
g2=0
fi

y2=$(echo  $($p  "qshape deferred | grep yahoo.com ") | awk '{print $2}')
if [ -z "$y2" ];then
y2=0
fi

psql -U postgres -d   zimbra -h 10.100.112.139  -c "INSERT INTO  deferredstatus (servername,gmail,yahoo,time) VALUES ('"$HN"',"$g2","$y2",current_timestamp)";

rsync -avz  /var/log/mail.log* root@10.100.112.68:/root/bulkmail/$(hostname)/
/opt/zimbra/common/sbin/postqueue -p | awk 'BEGIN { RS = "" } { if ($7 == "MAILER-DAEMON" ) print $1 }' | tr -d '!*' | /opt/zimbra/common/sbin/postsuper -d -
