#!/bin/bash

echo "Running example post shell script ..."

#CHROOT=/mnt/sysimage
mkdir -p $CHROOT/root/.ssh
cat >> $CHROOT/root/.ssh/authorized_keys << EOF
from="work.salstar.sk,158.197.240.41,work6.salstar.sk,2001:4118:400:1::/64" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAou3n+SuHVsuM5QXAKnIKilPHnJdKm/KP31Ho2VahJIC7mK0+snbXZYXeQmnwYvqQaDVCl8p0ANMonbs189t+RdBZ86Yq6/boc7zhyrj3gqzflsjyGWp5Gfo2AGQ9pgW3JMHefHMMXqF2uB9pT7PRL873gGfMG1WE3W+loFpDYPgg5TQvDifDP+cnlEdT/30JROFBbJ6sJro5la+7vZT/Yd9JOyNSvjizSsqLyva/t1zhQ2Bb37xGJOgVoRc1Hj+fYe1+jaD2ebtGWWIykvfIb33tpoBg3KkN01rrniTiVD8t1yNPGxc9VecqJoK5QJOCZ6zpjeFtvmiZwdd9bgfznQ== ondrejj@work
EOF
