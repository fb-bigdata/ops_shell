#!/bin/bash

# 设置时间变量
LOG_DATE=`date +%F -d  "-1days"`
# 本地日志分析目录
LOCAL_LOG_DIR=/data/pro_tomcat_log/
# tomcat服务器日志目录
TOMCAT_LOG_DIR=/usr/local/tomcat/logs/
# 远程tomcat主机
TOMCAT_SERVER="tomcat-01 tomcat-02"
# 收件人邮箱
OPS="will.wang@gevek.com"
# 复制tomcat访问日志到本地
scp_access_log (){
  for host in $TOMCAT_SERVER;do
    scp "$host":"$TOMCAT_LOG_DIR""$host"_access_log."$LOG_DATE".txt $LOCAL_LOG_DIR
  done
}

# 合并访问日志
merge_access_log (){
  for host in $TOMCAT_SERVER;do
    cat "$LOCAL_LOG_DIR""$host"_access_log."$LOG_DATE".txt >> "$LOCAL_LOG_DIR"tomcat_access_"$LOG_DATE".log
  done
}

# goaccess分析访问日志，生成html文件
analysis_access_log (){
  goaccess -f "$LOCAL_LOG_DIR"tomcat_access_"$LOG_DATE".log --log-format="%h %^[%d:%t %^] \"%r\" %s %b" --date-format="%d/%b/%Y" --time-format=%H:%M:%S -a > "$LOCAL_LOG_DIR"tomcat_access_"$LOG_DATE".html
}

# 发送html文件到邮箱
sendmail_html (){
  echo "tomcat访问日志分析见附件" | mutt -s "\"$LOG_DATE\"TOMCAT访问日志分析" $ops -a "$LOCAL_LOG_DIR"tomcat_access_"$LOG_DATE".html 
}

# 脚本执行
scp_access_log
merge_access_log
analysis_access_log
sendmail_html
