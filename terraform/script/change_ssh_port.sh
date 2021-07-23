ssh_port=$1
if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$ssh_port" != '22' ];then
    sed -i "s@^#Port.*@&\nPort $ssh_port@" /etc/ssh/sshd_config
elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
    sed -i "s@^Port.*@Port $ssh_port@" /etc/ssh/sshd_config
fi