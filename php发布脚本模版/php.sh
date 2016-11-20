#!/bin/bash
 
# 设置时间相关变量
CTIME=$(date "+%Y-%m-%d-%H-%M")
# 项目名称和gitlab仓库名称一致
project=
# 本地代码目录（gitlab拉取代码后存放目录）
CODE_DIR=/data/gitlab/pro/$project/
# 远程主机
REMOTE_HOST=""
# 远程主机代码目录
REMOTE_DIR=/data/www/$project/
# 远程主机用户
REMOTE_USER=root
# 远程主机代码执行用户
CODE_USER=php
# 上线日志
DEPKOY_LOG=/data/log/pro_log.log

#脚本使用帮助
usage(){
   echo $"Usage: $0 [deploy tag]"
}
 
#拉取代码
git_pro(){
   if [ $# -lt 1 ];then
        echo "请传入tag"
        exit 1
   fi
   echo "拉取代码"
   cd $CODE_DIR && git checkout master && git pull && git checkout $1
   if [ $? != 0 ];then
    echo "拉取代码失败"
    exit 10
   fi
   cd $CODE_DIR && git pull
}
 
#推送代码服务器
rsync_pro(){
for host in $REMOTE_HOST;do
   echo "推送代码到服务器$host"
   rsync -rPv -P --delete --exclude="config.php" --exclude=".git" $CODE_DIR  -e 'ssh -p 22' $REMOTE_USER@$host:$REMOTE_DIR
   if [ $? != 0 ];then
    echo "推送代码失败"
    exit 10
   fi
   echo "代码授权"
   ssh $REMOTE_USER@$host "chown -R $CODE_USER $REMOTE_DIR"
   if [ $? != 0 ];then
    echo "代码授权失败"
    exit 10
   fi
done
}
 
#记录日志
record_log(){
  echo "$CTIME 主机:$REMOTE_HOST 项目:$project tag:$1" >> $DEPKOY_LOG
}
 
main(){
  case $1 in
   deploy)
   git_pro $2;
   rsync_pro;
   record_log $2;
   ;;
   *)
   usage;
   esac
}
main $1 $2