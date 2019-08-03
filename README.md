# YumV
YumV is a FiveM server script, you can use it to install plugin, vehicle and maps quickly, like use the yum in CentOS.

[点我阅读中文介绍](README_zh.md)

## Feature
- Auto install plugin, vehicle, maps, peds or other.
- Search the anything you want.
- Remove the exist plugin.
- Update the exist plugin to new version.
- Show the installed plugin list.

## Installation
Before install YumV, you need to install __wget__ and __unzip__ in your system.
```bash
# Is the Linux shell, not in game!
yum install wget unzip -y
# If your server is Ubuntu or Debian
apt-get install wget unzip -y
```
Now, let's start install YumV!

First, goto your FXServer resources directory, such as `/home/akkariin/fivem/resources/`.
```
cd /home/akkariin/fivem/resources/
```
Then, clone this project to your resources directory.
```
git clone https://github.com/kasuganosoras/YumV yum/
```
Edit your `server.cfg` and append the following text:
```
start yum
add_ace resource.yum command.refresh allow
```
Final, restart your FXServer, enjoy!

## Example use
Install the vehicle "gtr":
```
yum install gtr
```
Search the vehicle "bmw":
```
yum search bmw
```
Update local plugin "vMenu":
```
yum update vMenu
```
Remove an exist plugin "subwrx":
```
yum remove subwrx
```
List all the plugins you installed:
```
yum list
```
You can use command `yum help` for help.

## Upload
If you want to upload a new resource to YumV mirror, you can visit: https://yumv.net/ (Chinese website)

You need to register an account to upload files.

## License
This project is open-source, use GPL-v3 license.
