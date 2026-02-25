#!/bin/bash
set -e

# Block cloud metadata service addresses.
iptables -A OUTPUT -d 169.254.169.254 -j DROP
iptables -A OUTPUT -d 169.254.170.2 -j DROP

# Allow all traffic on Docker bridge interfaces (for Docker-in-Docker).
iptables -A OUTPUT -o docker0 -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o docker+ -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o br-+ -j ACCEPT 2>/dev/null || true

# Allow local loopback and internal/private network ranges.
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT

# Allow established traffic.
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS/HTTP/HTTPS egress for package installs and normal dev traffic.
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow Docker forwarding when bridge is present.
iptables -A FORWARD -i docker0 -j ACCEPT 2>/dev/null || true
iptables -A FORWARD -o docker0 -j ACCEPT 2>/dev/null || true

# Keep default policy unchanged to avoid accidentally blocking local workflows.
