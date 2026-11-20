
# AI-Assisted Network Lab - Client-01

## Purpose
Normal user workstation for VLAN 10.

Generates predictable user traffic for:
- network monitoring
- telemetry
- troubleshooting
- fault simulation
- AI-assisted diagnostics

## Network

Hostname: ubuntu-01
VLAN: 10
IP: 10.0.10.50
Gateway: 10.0.10.1

## Installed network tools

- curl
- wget
- dnsutils
- iputils-ping
- traceroute
- mtr-tiny
- net-tools
- nmap
- tcpdump
- iperf3
- openssh-client
- git
- jq

## Lab traffic generator

Location:

/opt/lab-client/traffic-generator.sh

Log:

/opt/lab-client/logs/traffic.log

Traffic generator service:

lab-client-traffic.service

Current traffic generated every 30 seconds:

1. ICMP to VLAN 10 gateway
2. DNS lookup for google.com
3. HTTPS request to Internet
4. HTTP request to VLAN 20 Nginx server
5. FastAPI health check to VLAN 20 server

VLAN 20 server:

10.0.20.50

## Useful commands

Start traffic generator:

/opt/lab-client/traffic-generator.sh

Watch traffic log:

tail -f /opt/lab-client/logs/traffic.log

Capture generated traffic:

sudo tcpdump -ni any 'icmp or port 53 or port 80 or port 443'

## Status

- [x] VLAN 10 connectivity
- [x] Default gateway
- [x] DNS
- [x] Internet connectivity
- [x] Basic troubleshooting tools
- [x] Traffic generator
- [x] VLAN 20 Nginx HTTP traffic
- [x] VLAN 20 FastAPI health check 
- [x] systemd service
- [x] Client-specific traffic profile
- [ ] Fault simulation





