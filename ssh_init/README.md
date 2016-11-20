## 功能介绍：
新安装服务器，自动添加ansible服务器公钥到本机的authorized_keys文件

## 注意事项：
新安装服务器的密码应该为expect.exp文件中设置的服务器密码，不然无法添加密钥

## 使用文档：

1、设置ssh_init.ssh文件host变量为新安装服务器IP地址，多个IP空格分开<br />
2、设置好host变量之后，无须其他修改，直接执行脚本即可，执行成功之后如下所示
```
[root@ansible ~]# sh /shell/ssh_init.ssh
192.168.10.5                                               [  OK  ]
```