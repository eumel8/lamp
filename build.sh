#!/bin/sh

BRANCH=`git rev-parse --abbrev-ref HEAD`
DATE=`date +%s`

# fpm -s dir -t deb -C /tmp/project --name project_name --version 1.0.0 --iteration 1 --depends debian_dependency1 --description "A sample package" .

if [ `which fpm` ] 
then
fpm -s dir -t deb -d 'puppet' -v "01-$BRANCH-$DATE"  \
        -n lamp-conf  \
	-a all \
	--iteration 1 \
        -x .git -x .gitmdules  \
        -x scripts \
        --description "LAMP Configuration package" \
        --prefix /etc/puppet  .

if [ -f "lamp-conf_01-${BRANCH}-${DATE}-1_all.deb" ] 
then
sudo mv "lamp-conf_01-${BRANCH}-${DATE}-1_all.deb" /build/www/
sudo rm -f "/build/www/lamp-conf_01-${BRANCH}_latest-1_all.deb" 
sudo ln -s "/build/www/lamp-conf_01-${BRANCH}-${DATE}-1_all.deb" "/build/www/lamp-conf_01-${BRANCH}_latest-1_all.deb" 
fi


fpm -s dir -t rpm -d 'puppet' -v "$BRANCH"_"$DATE"  \
        -n lamp-conf -a all \
        -x .git -x .gitmdules  \
        --rpm-auto-add-directories \
        --replaces lamp-conf \
        --description "LAMP Configuration package" \
        --prefix /etc/puppet  .
if [ -f "lamp-conf-${BRANCH}"_"${DATE}-1.noarch.rpm" ] 
then
sudo mv "lamp-conf-${BRANCH}"_"${DATE}-1.noarch.rpm" /build/www/
sudo rm -f "/build/www/lamp-conf-${BRANCH}_latest-1.noarch.rpm" 
sudo ln -s "/build/www/lamp-conf-${BRANCH}"_"${DATE}-1.noarch.rpm" "/build/www/lamp-conf-${BRANCH}_latest-1.noarch.rpm" 
fi

else 
echo "fpm is needed...."
fi


