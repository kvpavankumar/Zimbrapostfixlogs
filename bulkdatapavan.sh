#!/bin/bash
set -x
HN="$(hostname  | cut -f 2 -d .)"
DDD=`date --date "1 days ago" +%Y-%m-%d`
DDD1=`date --date "1 days ago" +%Y-%m`
path="/root/bouncedata/New/"$DDD1"/"$DDD"/"
RB=""$path""$DDD"_"$HN"_RawData.csv"
AS=""$path""$DDD"_"$HN"_Subject.csv"
QN=""$path""$DDD"_"$HN"_queue.csv"
logpath="/var/log/mail.log*"
errorlog="/var/log/bulklog"
if [ ! -f $errorlog ]
then
   touch $errorlog
fi

if [ ! -d $path ]
then
    mkdir -p $path
    echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Folder created - Status :" $?>>$errorlog
else
    echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Folder exists - Status :" $?>>$errorlog
fi
grep -ih $DDD $logpath | grep "postfix/smtp" | grep "status=" |  sed "s/\(.\+\) mail.*: \(.\+\):.* to=<\(.\+\)>.* status=\([^ ]\+\)/\1,\2,\3,\4,/"| sed 's/./&,/10' | sed 's/,/:/6g' |sort | uniq >$RB
 echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Raw Log $RB- Status :" $?>>$errorlog
grep -h Subject $logpath | grep 'helo=<localhost>'| sed "s/\(.\+\) mail.*]: \(.\+\): w.*Subject: \(.\+\);.*from=<\(.\+\)>.* to=<\(.\+\)> .*/\1,\3,\4,\5,\2/"|sed 's/./&,/10'| sed -e 's/from localhost\[127.0.0.1\]//' |sort | uniq >$AS
 echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Subject Log $AS - Status :" $?>>$errorlog

grep -h 'queued as' $logpath |grep -v FWD| sed "s/\(.\+\) .*mail.*: \(.\+\):.* to=<\(.\+\)>.* as \(.\+\))/\4,\2/" | sort | uniq >$QN
echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Queue Logs - Status $QN :" $?>>$errorlog

filename=("$RB" "$AS" "$QN")
ssh root@10.100.112.68 mkdir -p /mail/$HN/"$DDD1"/"$DDD"/
echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Remote Folder Creationi - Status :" $?>>$errorlog
echo "`date '+%Y_%m_%d__%H_%M_%S'`:  Started Sycing" >>$errorlog
for (( i=0; i<3; i++ ));
do
if [  -f ${filename[$i]} ]
   then
        rsync -avz ${filename[$i]} root@10.100.112.68:/mail/$HN/"$DDD1"/"$DDD"/
        if [ $? -eq 0 ]; then
        echo "`date '+%Y_%m_%d__%H_%M_%S'` ${table[$i]}: File Copied - Status :" $?>>$errorlog
         table[$i]="copied"
         else
         table[$i]="failedC"
        echo "`date '+%Y_%m_%d__%H_%M_%S'` ${table[$i]}: File not Copied - Error :" $?>>$errorlog
        fi
else
table[$i]=failedG
echo "`date '+%Y_%m_%d__%H_%M_%S'` ${table[$i]}: File not exits - Error :" $?>>$errorlog
fi
done

mysql --host=10.100.112.68 --user=pavan --password=Lez1an@123 zimbra   -e  "INSERT INTO Status(inserted_date,Subject,RawData,Queue,Server)VALUES (NOW(),'${table[0]}','${table[1]}','${table[2]}','$HN')"

echo "`date '+%Y_%m_%d__%H_%M_%S'` ${table[$i]}: MySql Query Status" $?>>$errorlog

