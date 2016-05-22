Install lamp on lxd container
=============================

on lxd host 192.168.0.105:
    
    lxc remote add images https://images.linuxcontainers.org/ --public true --protocol=lxd
    lxc launch images:opensuse/13.2/amd64 s2
    lxc file push install.sh s2/
    lxc exec s2 -- /install.sh

    CONTAINER_IP=`lxc info s2 | grep eth0 | head -1 | awk '{print $3}'`
    iptables -t nat -A POSTROUTING -j MASQUERADE
    sysctl net.ipv4.ip_forward=1
    iptables -t nat -A PREROUTING -p tcp -d 192.168.0.105 --dport 10080 -j DNAT --to-destination ${CONTAINER_IP}:80

http://192.168.0.105:10080/icinga (username/password: admin/admin)



