## 功能介绍
灰度发布gitlab中java代码自动部署到web服务器。

## 脚本执行依赖环境
1、java项目使用maven管理，所以部署maven编译环境。<br />
2、前端使用haproxy实现负载均衡，使用haproxy socat实现RS的平滑上下线。
## 设计文档
### 1、获取代码
在部署服务器使用先使用git checkout master切换到master分支，在使用git pull 命令拉取最新的代码到本地，然后checkout到需要部署到服务器的tag。<br />
ps：脚本中git_pro函数在最后一行定义了cd $CODE_DIR && git pull，就是说用户传入的不是tag而是一个分支名称，可以拉取这个分支最新的代码进行部署，比如部署dev分支最新代码到web服务器，或者部署master分支最新代码到web服务器。如果只允许传入tag则删除此脚本。
### 2、推送代码到编译目录
如果在gitlab目录进行编译，会导致无法直接pull下来gitlab代码。所以需要把源码放到另外一个目录进行编译。

### 3、匹配差异文件
由于不同环境的配置文件存在差异，所以需要单独进行管理，我这里使用目录来区分是生产还是测试，如果需要部署，只需要删除代码仓库的配置文件，将对应环境的配置文件copy到代码目录即可。
### 4、打包（编译）代码
由于java是编译型语言语言，所以需要编译。直接进入代码目录使用mvn clean compile war:war命令打一个包即可。
### 5、推送war包到web服务器
使用scp命令，将代码包部署到目标服务器的/data/war/目录
### 6、解压代码包
在目标服务器上解压这个软件包。
### 7、部署服务器拿出集群
在部署之前将部署的后端节点拿出集群
### 8、创建软连接
我们的Web根路径是/data/webapps/project/，我们把所有的代码都存放在/data/code_tmp/目录下，那么webroot实际上是一个软连接，它链接到当前的版本。webroot如下所示：
```
[root@tomcat-01 ~]# ll /data/webapps/
total 4
lrwxrwxrwx 1 tomcat root 61 Oct 31 11:32 project -> /data/code_tmp/project_project_1.3.0.0_2016-10-31-11-29/
```
### 9、重启web服务器
重启tomcat服务器把class文件加载到jvm中
### 10、加入集群
接待你部署完成就把他加入集群，然后部署下一个节点。


## 脚本使用

### 发布代码
使用sh命令执行脚本，传入deploy tag参数，比如我要部署的tag版本为vrwroldapi1.3.0.0，那么脚本执行如下
```
sh project.sh deploy vrwroldapi1.3.0.0
```

### 列出可回滚代码
回滚代码执行执行脚本，传入rollback_list参数，查询可以回滚的版本
```
[root@jenkins pro]# sh project.sh rollback_list
------------可回滚版本-------------
project_project_1.3.0.0_2016-10-31-11-29
project_project_1.2.0.6_2016-10-21-16-10

```
### 回滚代码
如果刚才发布的project1.3.0.0 版本存在bug 需要回滚代码，理论应该回滚到上一个tag也就是vrworldapi1.2.0.6 版本，那么执行方式如下：
```
sh project.sh rollback_pro project_project_i1.2.0.6_2016-10-21-16-10
```