## AI-Assisted Network Lab - Client-02

### Purpose

Application-heavy user workstation for VLAN 10.

Generates predictable application-oriented traffic for:
- network monitoring
- telemetry
- troubleshooting
- application monitoring
- AI-assisted diagnostics

Compared with Client-01, Client-02 generates more frequent internal
application and API traffic while generating less frequent Internet traffic.

### Network

Hostname: ubuntu-02
VLAN: 10
IP: 10.0.10.51
Gateway: 10.0.10.1

### Installed network tools

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

### Lab traffic generator

Location:

/opt/lab-client/traffic-generator.sh

Configuration:

/opt/lab-client/client.conf

Log:

/opt/lab-client/logs/traffic.log

Traffic generator service:

lab-client-traffic.service

Profile:

application-heavy-user

Current traffic pattern:

- ICMP to VLAN 10 gateway every 20 seconds
- DNS lookup for github.com every 20 seconds
- HTTP request to VLAN 20 Nginx every 20 seconds
- FastAPI health request every 20 seconds
- FastAPI status request every 40 seconds
- HTTPS request to github.com every 60 seconds

VLAN 20 server:

10.0.20.50

FastAPI endpoints:

http://10.0.20.50:8000/api/health
http://10.0.20.50:8000/api/status

### Useful commands

Start traffic generator manually:

/opt/lab-client/traffic-generator.sh

Check service:

systemctl status lab-client-traffic

Restart service:

sudo systemctl restart lab-client-traffic

Watch traffic log:

tail -f /opt/lab-client/logs/traffic.log

Watch systemd log:

journalctl -fu lab-client-traffic

Capture generated traffic:

sudo tcpdump -ni any 'icmp or port 53 or port 80 or port 443 or port 8000'

### Status

- [x] VLAN 10 connectivity
- [x] Default gateway
- [x] DNS
- [x] Internet connectivity
- [x] Basic troubleshooting tools
- [x] Traffic generator
- [x] VLAN 20 Nginx HTTP traffic
- [x] VLAN 20 FastAPI health check
- [x] VLAN 20 FastAPI status check
- [x] systemd service
- [x] Client-specific traffic profile
- [ ] Optional file-transfer traffic
- [ ] Optional SSH traffic
- [ ] Optional controlled traffic bursts
