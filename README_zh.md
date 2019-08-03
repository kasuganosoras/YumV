# YumV
YumV 是一个 FiveM 服务器的插件管理器，它允许你像使用 CentOS 的 yum 一样快速安装各种插件、载具、地图等，并且有一个完整的社区。

## 功能
- 全自动安装插件、载具、地图、人物以及更多资源
- 搜索你想要的任何东西
- 删除一个已经存在的插件
- 将本地的插件更新到新版本
- 显示所有已安装的插件

## 安装方法
在开始安装之前，请先确认你的服务器已经安装了 wget 和 unzip，如果没有的话可以用以下命令安装
```bash
# 这是 Linux Shell，不是在游戏服务器里输入
yum install wget unzip -y
# 如果你的服务器是 Ubuntu 或者 Debian
apt-get install wget unzip -y
```
一切准备就绪后，我们开始安装 YumV！

首先，打开你的 FiveM 服务器的资源文件夹，例如 `/home/akkariin/fivem/resources/`。
```
cd /home/akkariin/fivem/resources/
```
然后将本项目 clone 到你的资源文件夹
```
git clone https://github.com/kasuganosoras/YumV yum/
```
编辑你的 `server.cfg` 并在结尾增加以下内容：
```
start yum
add_ace resource.yum command.refresh allow
```
最后，重启你的 FiveM 服务器，开始玩耍吧！

## 使用介绍
安装一辆新车，名字叫 "gtr":
```
yum install gtr
```
搜索所有关于 "bmw" 的内容:
```
yum search bmw
```
升级本地的插件 "vMenu":
```
yum update vMenu
```
删除一辆载具，名字叫 "subwrx":
```
yum remove subwrx
```
列出所有已经安装的插件:
```
yum list
```
你可以使用 `yum help` 随时查看帮助信息。

## 上传资源
资源全部存放在 YumV 官方镜像站：https://yumv.net/

目前资源收集主要靠作者我自己在网上找，并且保持每周更新 10~30 个插件，大家也可以注册自己的账号，自行上传各种插件。

## 开源协议
这个项目使用 GPL v3 协议开放源代码。
