## 功能介绍
每天自动拉取tomcat服务器前一天访问日志到本地，使用goaccess进行分析生成html文件报告，并把html文件报告，发送给指定邮箱

## 依赖环境
1、脚本执行服务器需要和tomcat服务器配置ssh免密钥环境。<br />
2、需要安装goaccess环境，使用yum安装goaccess即可。<br />
3、需要配置mutt邮件发送环境。<br />

## tomcat日志切割
1、tomcat每天凌晨0点切割昨天访问日志为如下格式：
```
tomcat-01_access_log.2016-11-08.txt
```
2、tomcat日志格式如下所示，如果为其他格式，修改goaccess，--log-format选项
```
%h %^[%d:%t %^] \"%r\" %s %b
```
## 脚本使用 
tomcat日志每天0点切割，脚本执行只需要设置0点之后的时间即可，我设置为2点执行，设置方式如下：
```
[root@ansible ~]# crontab -l
# 分析tomcat访问日志
00 2 * * * /bin/sh /shell/goaccess_tomcat.sh
```