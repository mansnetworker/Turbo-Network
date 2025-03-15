#!/bin/bash

echo "=============================="
echo "       Turbo-Network 🚀       "
echo "=============================="
echo "1) Install Turbo Network"
echo "2) Uninstall Turbo Network"
read -p "Please select an option: " choice

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

if [ "$choice" == "1" ]; then
    echo "🚀 Installing Turbo Network settings..."

    grep -q "net.ipv4.tcp_fin_timeout" /etc/sysctl.conf || echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_time" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_time = 10" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_intvl" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_intvl = 10" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_probes" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf
    grep -q "net.core.somaxconn" /etc/sysctl.conf || echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
    grep -q "net.netfilter.nf_conntrack_max" /etc/sysctl.conf || echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.conf
    grep -q "fs.file-max" /etc/sysctl.conf || echo "fs.file-max = 1048576" >> /etc/sysctl.conf
    grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

    sysctl -p || { echo "❌ Failed to apply sysctl settings!"; exit 1; }

    grep -q "* soft nofile 200000" /etc/security/limits.conf || echo "* soft nofile 200000" >> /etc/security/limits.conf
    grep -q "* hard nofile 200000" /etc/security/limits.conf || echo "* hard nofile 200000" >> /etc/security/limits.conf

    ulimit -n 1048576
    ulimit -Hn 1048576

    modprobe tcp_bbr
    echo "tcp_bbr" >> /etc/modules-load.d/bbr.conf

    echo "✅ Turbo Network settings and BBR installed successfully!"
    echo "Successful!"

elif [ "$choice" == "2" ]; then
    echo "🚀 Removing Turbo Network settings..."

    sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_intvl/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.conf
    sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
    sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf
    sed -i '/fs.file-max/d' /etc/sysctl.conf
    sed -i '/net.core.default_qdisc=fq/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf

    sysctl -p || { echo "❌ Failed to revert sysctl settings!"; exit 1; }

    sed -i '/\* soft nofile 200000/d' /etc/security/limits.conf
    sed -i '/\* hard nofile 200000/d' /etc/security/limits.conf

    rm -f /etc/modules-load.d/bbr.conf
    modprobe -r tcp_bbr

    echo "✅ Turbo Network settings and BBR removed successfully!"
    echo "Successful!"

else
    echo "❌ Invalid option selected!"
fi
