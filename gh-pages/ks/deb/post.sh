#!/bin/sh

GW=`/sbin/ip route get to 1.1.1.1 | grep " via " | cut -d" " -f3`
echo Gateway: $GW

if echo $GW | grep -q '^\(10\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\)\.'; then
  GWS=",$GW"
fi

mkdir -p /target/root/.ssh
echo 'from="work.salstar.sk,158.197.240.41,work6.salstar.sk,2001:4118:400:1::/64'$GWS'" ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAORxvbaG3OX99nkgSkVCPbptyfeBUUdlOtz5wPkN/EZozVQ56ZsKMHLXpHiBb973/PCrVQz1B4+n+D7Ud/UMSZIgGBThb2+Mh46qqrgPu1QhbvzcK1W4qEOsDWu4KQgCpxfFEaaF6a7V7MOrtXdSZmauMmSpSHO7BWM7Aq3PTVXH0Hvg== ondrejj@work.salstar.sk' \
  > /target/root/.ssh/authorized_keys
