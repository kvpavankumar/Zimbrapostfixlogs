sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/50-default.conf > /etc/rsyslog.d/50-default.conf
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/rsyslog> /etc/logrotate.d/rsyslog 
sudo curl https://raw.githubusercontent.com/kvpavankumar/Zimbrapostfixlogs/master/rsyslog.conf>/etc/rsyslog.conf
sudo systemctl restart syslog.service
