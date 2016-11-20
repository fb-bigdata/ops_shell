## 功能介绍
从gitlab获取安卓最新代码进行打包，并且推送到共享目录给员工下载

## 脚本执行依赖环境
使用此脚本打包依赖如下安卓sdk环境，gradle编译环境，环境的安装配置按照此连接部署：[http://www.fblinux.com/?p=578](http://www.fblinux.com/?p=578 "安装自动化打包")

## 设计文档
### 1、获取代码
在部署服务器使用先使用git checkout master切换到master分支，在使用git pull 命令拉取最新的代码到本地，然后checkout到需要部署到服务器的tag。<br />
ps：脚本中git_pro函数在最后一行定义了cd $CODE_DIR && git pull，就是说用户传入的不是tag而是一个分支名称，可以拉取这个分支最新的代码进行部署，比如部署dev分支最新代码到web服务器，或者部署master分支最新代码到web服务器。如果只允许传入tag则删除此脚本。
### 2、推送代码到编译目录
如果在gitlab目录进行编译，会导致无法直接pull下来gitlab代码。所以需要把源码放到另外一个目录进行编译。
### 3、设置代码配置文件
由于不同环境的配置文件存在差异，所以需要单独进行管理，这里使用sed命令来设置签名文件，以及设置对应环境的api接口地址。
### 4、编译代码
签名文件和接口地址设置好之后，就可以进行编译打包了，直接使用gradle clean && gradle build 命令就可以打出apk安装包。
### 5、推送apk安装包到共享目录
包打出来后就是推送到samba或者httpd download上面，让员工可以访问到。


## 脚本使用

### 打包
从master分支拉取最新的代码进行打包
```
sh project.sh build master
```

