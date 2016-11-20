#!/bin/bash
# 设置时间变量
CTIME=$(date "+%Y-%m-%d-%H-%M")
# 项目名称，建议和gitlab仓库名称一致
project=
# 本地代码目录（gitlab拉取代码后存放目录）
CODE_DIR=/data/gitlab/"$project"
# 临时代码目录，用来修改配置文件和编译打包代码
TMP_DIR=/data/tmp/"$project"
# 签名文件
jks_file=

# 脚本使用帮助
usage(){
   echo $"Usage: $0 [build tag ENV]"
}

# 拉取代码
git_pro() {
   echo "拉取代码"
   if [ $# -lt 1 ];then
        echo "请传入tag"
        exit 1
   fi
   tag=$1
   cd $CODE_DIR && git checkout master && git pull && git checkout $1
   if [ $? != 0 ];then
    echo "拉取代码失败"
    exit 10
   fi
   cd $CODE_DIR && git pull 2>/dev/null >/dev/null
}
# 推送代码到编译目录
sync_tmp() {
   echo "推送代码到编译目录"
   rsync -avz --delete $CODE_DIR/ $TMP_DIR/ 2>/dev/null >/dev/null
}
# 设置代码配置文件
set_conf() {
   echo "设置代码配置文件"
   # 设置代码的签名配置
   # 设置代码的接口名称服务器地址
}

# 编译代码
build(){
  echo "打包代码"
  cd $TMP_DIR/gevek && gradle clean && gradle build 
}
# 推送apk安装包到共享目录
scp_apk(){
  echo "推送代码到共享服务器"
  #使用scp或者rsyncd推送到公司的web download服务器，或者share服务器
}
# 代码执行选项设置
main() {
 case $1 in
  build)
   git_pro $2;
   sync_tmp;
   set_conf;
   build;
   scp_apk;
   ;;
  *)
   usage;
 esac
}

main $1 $2
