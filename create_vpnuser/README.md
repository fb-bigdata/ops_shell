## 功能介绍 ##
自动开通或删除openvpn帐号，并打包证书文件，安装文件，客户端配置文件，以及安装教程发送到员工邮箱。

## 文件介绍 ##

create_vpnuser.sh：主文件用来创建和删除openvpn帐号<br />
vpn_expect.expect：expect脚本，用来处理openvpn创建证书文件的交互<br />
mail.txt：发送给用户的邮件正文，里面包含openvpn客户端环境的使用教程链接<br />
client.ovpn：发送给用户的客户端配置文件<br />

## 使用文档 ##
### 使用前注意
1、设置$client_config变量无须全路径，会自动到$tmp_dir目录下查找。<br />
2、mail.txt和client.ovpn文件中用户名默认为vpnclient这个无须修改，发送邮件之前会替换为交互输入的用户名，邮件发送完毕，会替换为vpnclient。<br />
3、openvpn发送邮件使用mutt，如果没有配置mutt环境，无法发送邮件。<br />
ps：配置邮件发送环境参考：[http://www.fblinux.com/?p=469](http://www.fblinux.com/?p=469 "mutt+smtpd发送邮件")
### 创建用户: ###
执行create_vpnuser.sh脚本，传入add参数，然后根据提示输入创建用户的用户名和邮箱即可。
```
[root@openvpn ~]# sh /shell/create_vpnuser.sh add
please input a user name:zhangsan
please input a user email:zhangsan@gevek.com
```
### 删除用户: ###
执行create_vpnuser.sh脚本，传入del参数，然后根据提示输入删除的用户名即可
```
[root@openvpn ~]# sh /shell/create_vpnuser.sh del
please input a user name:zhangsan
```



