#!/usr/bin/env bash
set -ex

# Traffic forwarding
iptables -D FORWARD -i wg0 -j ACCEPT
iptables -D FORWARD -o wg0 -j ACCEPT

# SNAT
#iptables -t nat -D POSTROUTING -o eth1 -j MASQUERADE

