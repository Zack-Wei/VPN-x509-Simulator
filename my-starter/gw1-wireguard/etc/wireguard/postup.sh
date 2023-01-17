#!/usr/bin/env bash
set -ex

# Traffic forwarding
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# SNAT
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
