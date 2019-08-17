#!/bin/bash
if [ ! -d "/root/bouncedata/" ]
then
    echo "File doesn't exist. Creating now"
    mkdir /root/bouncedata/
    echo "File created"
else
    echo "File exists"
fi
HN="$(hostname  | cut -f 2 -d .)"
DDD=`date --date "1 days ago" +%Y-%m-%d`
DDD1=`date --date "1 days ago" +%Y-%m`
RB="/root/bouncedata/"$DDD"_RAW_"$HN"_bounced.csv"
TS="/tmp/"$DDD1"Temp_"$HN"_Subject.csv"
AS="/root/bouncedata/"$DDD1"_"$HN"_Subject.csv"
TQ="/tmp/"$DDD1"Temp_"$HN"_queue.csv"
TM="/tmp/"$DDD1"_"$HN"_mix.txt"
TM1="/tmp/"$DDD1"_"$HN"_mix1.txt"
QN="/root/bouncedata/"$DDD1"_"$HN"_queue.csv"
DDD2=`date --date "1 days ago"  "+%h %d"`
Col=","
empty="$DDD2,00:00:00,,,"
TT="/tmp/"$DDD1"_"$HN"_total.txt"
cat /var/log/maillog*  |grep -i "$(date --date="1 days ago" +%b" "%_d)" | grep "postfix/smtp" |grep -P 'status=(?!sent)' |  sed "s/\(.\+\) mail.*: \(.\+\):.* to=<\(.\+\)>.* status=\([^ ]\+\)/\1,\2,\3,\4,/" | sort | uniq >$RB
if [ -s $RB ]
then
echo "file is not empty "
cat /var/log/maillog* | grep Subject | grep 'helo=<localhost>'| sed "s/\(.\+\) mail.*]: \(.\+\): w.*Subject: \(.\+\);.*from=<\(.\+\)>.* to=<\(.\+\)> .*/\1,\3,\4,\5,\2/"| sort | uniq >$TS
echo "fetching subject from logs"
if [ -f ${AS} ]
then
cat $AS>> $TS
echo "loding date from Bounce data to Temp"
cat $TS |sort |uniq >$AS
else
cat $TS |sort |uniq >$AS
fi
cat /var/log/maillog* | grep 'queued as' |grep -v FWD| sed "s/\(.\+\) .*mail.*: \(.\+\):.* to=<\(.\+\)>.* as \(.\+\))/\4,\2/" | sort | uniq >$TQ
if [ -f ${QN} ]
then
cat $QN >>$TQ
cat $TQ | sort | uniq > $QN
else
cat $TQ | sort | uniq > $QN
fi
DELIMITER="," ;
for i in $(cut -f 2 -d "${DELIMITER}" $RB );
do
  g=($(grep "${i}" /root/bouncedata/*_"$HN"_queue.csv | cut -f 2 -d "${DELIMITER}"))
  if [ ${#g} -ge 10 ]; then
     for j in ${g};
     do
       #echo ${g} >>/root/bouncedata/arrayg.txt
       L2=$(cat /root/bouncedata/*_Subject.csv | grep ${g} | tail -n "1" )
       if [ ${#L2} -ge 1 ]; then
          L1=$(grep "${i}" $RB | tail -n "1" | sed 's/./&,/6')
          z=$L2$Col$L1
          echo $z>>$TM
       else
          Tempv=$(cat $RB | grep ${i} | tail -n "1")
          Tempv1=$(echo $Tempv | tail -n "1" | cut -d ',' -f2,3 --complement |sed 's/./&,/6')
          Tempv2=$(echo $Tempv | tail -n "1" | cut -d ',' -f3 |sed 's/$/,/' )
          echo $empty$Tempv2$Tempv1>>$TM1
       fi
     done
  else
    Tempv=$(cat $RB | grep ${i} | tail -n "1")
    Tempv1=$(echo $Tempv | tail -n "1" | cut -d ',' -f2,3 --complement |sed 's/./&,/6')
    Tempv2=$(echo $Tempv | tail -n "1" | cut -d ',' -f3 |sed 's/$/,/' )
   echo $empty$Tempv2$Tempv1>>$TM1
  fi
done
sed -i "s|$AS||g"  $TM
cat $TM | cut -d, -f5,8-9 --complement | sed 's/./&,/6' | sed -e 's/from localhost\[127.0.0.1\]//'|sed 's/,/:/9g' |sort | uniq > $TT
#cat $TM |sort | uniq > $TT

sed -i '1s/^/Initiated Date,Time,Subject,From,To,Response Date,Time,Status,reason,server\n/' $TT
cat $TM1 |sort| uniq>> $TT
sed "s/$/,$HN/" $TT >/root/bouncedata/"$DDD"_"$HN"_bounced.csv

rm $TM $TS $TQ $TM1 $TT
