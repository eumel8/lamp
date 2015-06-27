#!/bin/sh

BRANCH=`git rev-parse --abbrev-ref HEAD`
DATE=`date +%s`

# fpm -s dir -t deb -C /tmp/project --name project_name --version 1.0.0 --iteration 1 --depends debian_dependency1 --description "A sample package" .

fpm -s dir -t deb -d 'puppet' -v "01-$BRANCH-$DATE"  \
        -n lamp-conf  \
	--iteration 1 \
        -x .git -x .gitmdules  \
        -x scripts \
        --description "LAMP Configuration package" \
        --prefix /etc/puppet  .


fpm -s dir -t rpm -d 'puppet' -v "$BRANCH-$DATE"  \
        -n lamp-conf -a all \
        -x .git -x .gitmdules  \
        --rpm-auto-add-directories \
        --replaces lamp-conf \
        --description "LAMP Configuration package" \
        --prefix /etc/puppet  .

