# Урок 10. Управление пакетами. Дистрибьюция софта.
В репозитори находятся файлы: [Cкрипт, который выполняется после запуска ОС](lesson_10.sh), [Vagrantfile](Vagrantfile).
##1 Сборка rpm пакета

###1.1 Устанавливаем;
```yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils
```
###1.2 Скачиваю nginx;
```
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.18.0-2.el8.ngx.src.rpm 
```
###1.3 Распаковываем скаченный пакет. Далее командой rpm -i создается древо каталогов со spec и src файлами;
```rpm -i nginx-1.18.0-2.el8.ngx.src.rpm
```
###1.4 Скачиваем последний пакет openssl и распаковываем;
```
wget https://www.openssl.org/source/latest.tar.gz && tar -xvf latest.tar.gz
```
###1.5 Ставим все зависимости nginx;
```
yum-builddep rpmbuild/SPECS/nginx.spec -y
```
###1.6 Изменяем spec файл nginx, чтобы сборка rpm пакеты включала опцию ssl;
```
awk '{sub(/--with-debug/,"--with-openssl=/root/openssl-1.1.1i")}1' /root/rpmbuild/SPECS/nginx.spec > tmp && mv tmp /root/rpmbuild/SPECS/nginx.spec -f
```
###1.7 Процесс сборки пакета;
```
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
```
###1.8 Процесс установки собранного rpm пакет;
```
ll /root/rpmbuild/RPMS/x86_64/
yum localinstall /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm -y
systemctl start nginx && systemctl status nginx
```
##2. Создание своего репозитория;

###2.1 Создание каталога для собранного пакета nginx, чтобы был доступен из репозитория;
```
mkdir /usr/share/nginx/html/repo
```
####2.2 Копируем rpm пакет;
```
cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo
```
###2.3 Скачиваем и копируем в наш репозиторий, пакет percona-release-1.0-17.noarch.rpm. Noarch.rpm означает для любых архитектур;
```
wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-17/redhat/percona-release-1.0-17.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-17.noarch.rpm
```
###2.4 Инициализация пакета;
```
createrepo /usr/share/nginx/html/repo/
```
###2.5 Добавим директиву autoindex on в /etc/nginx/conf.d/default.conf. Проверяем синтаксис nginx и перезапуск nginx;
```
awk '{sub (/index  index.html index.htm;/,"index  index.html index.htm;\n \tautoindex on;")}1' /etc/nginx/conf.d/default.conf > tmp && mv -f tmp /etc/nginx/conf.d/default.conf
nginx -t
nginx -s reload
```
###2.6 Добавим настройки нашего репозитория в /etc/yum.repos.d.;
```
cat >> /etc/yum.repos.d/otus.repo << EOF

[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```
###2.7 Установим percona-release;
```
yum install percona-release -y
```
