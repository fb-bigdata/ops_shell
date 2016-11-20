#!/bin/bash
# 设置相关变量
# 设置easy-rsa/2.0目录全路径
work_dir=/usr/local/openvpn/easy-rsa/2.0
# 设置临时目录，存放新建用户的证书文件，配置文件
tmp_dir=/data/tmp/openvpn
# 设置用户客户端配置文件，存放在$tmp_dir目录下
client_config=client.ovpn
# 设置发送邮件内容
mail_content=/shell/mail.txt

# 使用帮助
help(){
  echo '添加vpn用户执行命令sh create_vpnuser.sh add'
  echo '删除vpn用户执行命令sh create_vpnuser.sh del'
}
# 判断用户是否存在
add_user(){
  # 交互输入用户名和邮箱
  read -p "please input a user name:" name
  read -p "please input a user email:" email
  if [ -f $work_dir/keys/$name.crt ];then
	echo "新建vpn用户存在,请检查!"
	exit 1
  else
   # 创建用户密钥
   cd $work_dir && source ./vars
   /usr/bin/expect /shell/vpn_expect.expect $name
   if [ $? != 0 ];then
	echo "创建密钥失败"
	exit 10
   fi
   # 密钥和配置文件打包
   cd $work_dir/keys/
   cp $name.* ca.crt $tmp_dir
   if [ $? != 0 ];then
	echo "复制密钥失败"
	exit 20
   fi
   sed -i s@vpnclient@$name@g $tmp_dir/$client_config
   cd $tmp_dir
   tar zcf $name.tar.gz $name.* ca.crt $client_config openvpn-2.2.2-install.exe
   # 发送邮件给员工
   sed -i s@vpnclient@$name@g $mail_content 
   cat $mail_content | mutt -s "VPN帐号开通" $email -a $tmp_dir/$name.tar.gz 
   sed -i s@$name@vpnclient@g $tmp_dir/$client_config
   sed -i s@$name@vpnclient@g $mail_content
  fi
}
del_user(){
  # 交互输入用户名
  read -p "please input a user name:" name
  if [ -f $work_dir/keys/$name.crt ];then
     cd $work_dir && source ./vars && ./revoke-full $name 
  else
     echo "删除vpn用户不存在，请检查"
  fi
}
main(){
  case $1 in
   add)
   add_user;
   ;;
   del)
   del_user;
   ;;
   *)
   help;
   esac
}
main $1
