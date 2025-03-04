#!/bin/bash

echo "=============================="
echo "       Turbo-Network 🚀       "
echo "=============================="
echo "۱) نصب تنظیمات"
echo "۲) حذف تنظیمات"
read -p "گزینه مورد نظر را وارد کنید: " choice

if [[ $EUID -ne 0 ]]; then
   echo "❌ این اسکریپت باید با دسترسی root اجرا شود!" 
   exit 1
fi

if [ "$choice" == "1" ]; then
    echo "✅ نصب تنظیمات در حال انجام است..."

    grep -q "net.ipv4.tcp_fin_timeout" /etc/sysctl.conf || echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_time" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_time = 120" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_intvl" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_intvl = 30" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_keepalive_probes" /etc/sysctl.conf || echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.conf
    grep -q "net.core.somaxconn" /etc/sysctl.conf || echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
    grep -q "net.netfilter.nf_conntrack_max" /etc/sysctl.conf || echo "net.netfilter.nf_conntrack_max = 262144" >> /etc/sysctl.conf
    grep -q "fs.file-max" /etc/sysctl.conf || echo "fs.file-max = 1048576" >> /etc/sysctl.conf

    sysctl -p || { echo "❌ اعمال تنظیمات sysctl با خطا مواجه شد!"; exit 1; }

    grep -q "\* soft nofile 200000" /etc/security/limits.conf || echo "* soft nofile 200000" >> /etc/security/limits.conf
    grep -q "\* hard nofile 200000" /etc/security/limits.conf || echo "* hard nofile 200000" >> /etc/security/limits.conf

    ulimit -n 1048576
    ulimit -Hn 1048576

    echo "✅ تنظیمات با موفقیت اعمال شد!"

elif [ "$choice" == "2" ]; then
    echo "🚀 در حال حذف تنظیمات..."

    sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_intvl/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.conf
    sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
    sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf
    sed -i '/fs.file-max/d' /etc/sysctl.conf

    sysctl -p || { echo "❌ بازگردانی تنظیمات sysctl با خطا مواجه شد!"; exit 1; }

    sed -i '/\* soft nofile 200000/d' /etc/security/limits.conf
    sed -i '/\* hard nofile 200000/d' /etc/security/limits.conf

    echo "✅ تنظیمات با موفقیت حذف شد و به حالت پیش‌فرض برگشت!"

else
    echo "❌ گزینه نامعتبر است!"
fi
