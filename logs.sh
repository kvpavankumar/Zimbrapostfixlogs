#!/bin/bash
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/50-default.conf > /etc/rsyslog.d/50-default.conf
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/rsyslog> /etc/logrotate.d/rsyslog 
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/rsyslog.conf>/etc/rsyslog.conf
sudo systemctl restart syslog.service
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/zimbra_pflogsumm.pl >/opt/zimbra/bin/zimbra_pflogsumm.pl
curl https://raw.githubusercontent.com/kvpavankumar/Zimbraprerequest/main/zimbrainfosec.sh > clear.sh
sudo chmod 777 clear.sh
sudo ./clear.sh
