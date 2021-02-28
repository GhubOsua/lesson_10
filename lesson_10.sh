#!/bin/bash
yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils

wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.18.0-2.el8.ngx.src.rpm

rpm -i nginx-1.18.0-2.el8.ngx.src.rpm

wget https://www.openssl.org/source/latest.tar.gz && tar -xvf latest.tar.gz

yum-builddep /root/rpmbuild/SPECS/nginx.spec -y

awk '{sub(/--with-debug/,"--with-openssl=/root/openssl-1.1.1j")}1' /root/rpmbuild/SPECS/nginx.spec > tmp && mv tmp /root/rpmbuild/SPECS/nginx.spec -f

rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec -y

yum localinstall /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm -y

systemctl start nginx && systemctl status nginx

mkdir /usr/share/nginx/html/repo

cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo

wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-17/redhat/percona-release-1.0-17.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-17.noarch.rpm

createrepo /usr/share/nginx/html/repo/

awk '{sub (/index  index.html index.htm;/,"index  index.html index.htm;\n \tautoindex on;")}1' /etc/nginx/conf.d/default.conf > tmp && mv -f tmp /etc/nginx/conf.d/default.conf
nginx -t
nginx -s reload

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

yum install percona-release -y

yum repolist enabled | grep otus

