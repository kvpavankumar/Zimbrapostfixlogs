# Zimbrapostfixlogs


It will export raw postfix log to CSV 

It will capture below filed from postfix log
- Initiated Date
- Time
- Subject
- From
- To
- Response Date
- Time
- Status,reason




step 1: su - zimbra  

step 2: vi /opt/zimbra/conf/custom_header_checks  
 Fill with the following line :  
   /^Subject:/ WARN  
   /^subject:/ WARN  
   /filename=\"?(.*)\"?$/ WARN  

setp 3: Modify zimbraMtaHeaderChecks for include custom_header_checks  
  zmprov ms `zmhostname` zimbraMtaHeaderChecks "pcre:/opt/zimbra/conf/postfix_header_checks, pcre:/opt/zimbra/conf/custom_header_checks"   zmprov mcf zimbraMtaBlockedExtensionWarnRecipient FALSE  

step 4: Reload Postfix Zimbra
   postfix reload

step 5: Run below shell script to dowload logs:  
  zimbrapostfix.sh


