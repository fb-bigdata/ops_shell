#!/bin/bash
# 获取监控服务器主机名
hostname=`hostname`
# 监控的日志文件，多个文件用空格分隔
LOG_FILE="/data/log/java_api/error.log"
# 历史error数量记录目录
LOG_HIS_COUNT_DIR="/data/log_jk/log_his_count/"
# 当前error数量记录目录
LOG_CUR_COUNT_DIR="/data/log_jk/log_cur_count/"
# 错误日志结尾文件存放目录
LOG_MAIL_DIR="/data/log_jk/log_mail/"
# 锁文件目录
LOG_LOCK_DIR="/data/log_jk/log_lock/"
# 发送日志文件的后多少行
line=300
# 监控的时间间隔
mon_time=60
# 报警邮箱
OPS="will.wang@gevek.com"
# 监控阀值
num=5
# 关键字
Keyword=ERROR

# 判断日志文件是否存在
for log in $LOG_FILE;do
    if [ ! -f $log ];then
	echo "$log文件不存在请检查"
	exit 1
    fi
done
# 判断相关目录是否存在并创建
if [ ! -d $LOG_HIS_COUNT_DIR ];then
   	mkdir -p $LOG_HIS_COUNT_DIR
fi
if [ ! -d $LOG_CUR_COUNT_DIR ];then
   	mkdir -p $LOG_CUR_COUNT_DIR
fi
if [ ! -d $LOG_MAIL_DIR ];then
   	mkdir -p $LOG_MAIL_DIR
fi
if [ ! -d $LOG_LOCK_DIR ];then
   	mkdir -p $LOG_LOCK_DIR
fi
# 获取日志error数量并记录
get_his_error (){
    for log in $LOG_FILE;do
       his_count=`grep "$Keyword" $log | wc -l`
       echo $his_count > "$LOG_HIS_COUNT_DIR""$(basename $log)"
    done
}
# 获取当前error数量
get_cur_error (){
    for log in $LOG_FILE;do
       cur_count=`grep "$Keyword" $log | wc -l`
       echo $cur_count > "$LOG_CUR_COUNT_DIR""$(basename $log)"
    done
}
# 判断是否报警
all_the_police (){
    for log in $LOG_FILE;do
	if [ ! -f $LOG_LOCK_DIR$(basename $log) ];then
			# 获取日志监控间隔产生的error数量
        	his_count=`/bin/cat $LOG_HIS_COUNT_DIR$(basename $log)`
			cur_count=`/bin/cat $LOG_CUR_COUNT_DIR$(basename $log)`
    		error=`expr $cur_count - $his_count`
			# 判断error数量是否超过监控阀值，如果超过发送报警邮件
    		if [ $error -ge $num ];then
				CTIME=$(date "+%Y-%m-%d-%H-%M")
    			tail -n $line $log > "$LOG_MAIL_DIR""$(basename $log)" > $LOG_MAIL_DIR$CTIME-$(basename $log)
				echo -e "hi:\n主机:$hostname 日志:$log 在$mon_time秒之内出现"ERROR"字符 $error 次,日志文件后$line行，已经发送到了你的附件，请查看.\nps:为了防止报警邮件频繁发送，在本邮件发送之后已 经对$log文件监控上锁，请在解决故障后删除$LOG_LOCK_DIR$(basename $log)文件开锁。" | mutt -s "日志报警：主机:"$hostname" 日志:$log " $OPS -a $LOG_MAIL_DIR$CTIME-$(basename $log) 
			#发送报警邮件之后，对监控日志上锁
			if [ $? = 0 ];then
				touch $LOG_LOCK_DIR$(basename $log)
			fi
		fi
	fi
    done 
}
while true;do
	get_his_error
	sleep $mon_time
	get_cur_error
	all_the_police
done
