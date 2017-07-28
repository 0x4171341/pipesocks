#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Yellow_font="\033[33m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
reboot="${Yellow_font}reboot${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: pipesocks
# Version: 1.0
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"

#check root
check_root(){
    if [[ "`id -u`" = "0" ]]; then
    echo -e "${Info} user is root"
	else echo -e "${Error} must be root user" && exit 1
    fi
}

#determine workplace directory
directory(){
    [[ ! -d /home/pipesocks ]] && mkdir -p /home/pipesocks
	cd /home/pipesocks
}

get_port(){
    echo -e "${Info} input required server port:"
	stty erase '^H' && read -p "(defaultly use '2000'):" port
	[[ -z "${port}" ]] && port=2000
}

get_password(){
    echo -e "${Info} input required password:"
	stty erase '^H' && read -p "(defaultly use 'wallace'):" password
	[[ -z "${password}" ]] && password=wallace
}

install(){
    check_root
    directory
	ver=`wget -qO- https://github.com/pipesocks/pipesocks/releases/latest | grep "<title>" | sed -r 's/.*pipesocks (.+) · pipesocks.*/\1/'`
	wget "https://github.com/pipesocks/pipesocks/releases/download/${ver}/pipesocks-${ver}-linux.tar.xz" && tar -xJf pipesocks-${ver}-linux.tar.xz
	[[ ! -e pipesocks ]] && echo -e "${Error} file download error, please check!" && exit 1
	chmod -R 7777 /home/pipesocks
	get_port
	get_password
	nohup ./pipesocks pump -p ${port} -k ${password} >> /home/pipesocks.log 2>&1 &
	echo "/home/pipesocks/pipesocks pump -p ${port} -k ${password}" > /home/pipesocks/start.sh && chmod +x /home/pipesocks/start.sh && echo "/home/pipesocks/start.sh" >> /etc/rc.local
    exit 0
}

upgrade(){
    check_root
    directory
    killall pipesocks && rm pipesocks
	ver=`wget -qO- https://github.com/pipesocks/pipesocks/releases/latest | grep "<title>" | sed -r 's/.*pipesocks (.+) · pipesocks.*/\1/'`
	wget "https://github.com/pipesocks/pipesocks/releases/download/${ver}/pipesocks-${ver}-linux.tar.xz" && tar -xJf pipesocks-${ver}-linux.tar.xz
	[[ ! -e pipesocks ]] && echo -e "${Error} file download error, please check!" && exit 1
	chmod -R 7777 /home/pipesocks
	get_port
	get_password
	nohup ./pipesocks pump -p ${port} -k ${password} >> /home/pipesocks.log 2>&1 &
	exit 0
}

uninstall(){
    check_root
    killall pipesocks
	rm -rf /home/pipesocks
	sed -i '/home/pipesocks/start.sh' /etc/rc.local
	echo -e "${Info} uninstall pipesocks finished"
	exit 0
}

command=$1
if [[ "${command}" = "" ]]; then
    echo -e "${Info}command not found, usage: ${Green_font}{ install | upgrade | uninstall }${Font_suffix}" && exit 0
else
    command=$1
fi
case "${command}" in
	 install)
     install 2>&1 | tee -i /home/pipesocks-install.log
	 ;;
	 upgrade)
     upgrade 2>&1 | tee -i /home/pipesocks-upgrade.log
	 ;;
	 uninstall)
     uninstall 2>&1 | tee -i /home/pipesocks-uninstall.log
	 ;;
esac