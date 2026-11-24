## AI-Assisted Network Lab - Client-01

### Purpose

Normal office/user workstation for VLAN 10.

Generates predictable low-volume user traffic for:
- network monitoring
- telemetry
- troubleshooting
- application monitoring
- AI-assisted diagnostics

Client-01 represents the normal baseline user.
It generates regular Internet and internal application traffic that can
later be used to detect and correlate network or application failures.

### Network

Hostname: ubuntu-01
VLAN: 10
IP: 10.0.10.50
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

normal-office-user

Current traffic pattern:

- ICMP to VLAN 10 gateway every 30 seconds
- DNS lookup for google.com every 30 seconds
- HTTPS request to google.com every 30 seconds
- HTTP request to VLAN 20 Nginx every 30 seconds
- FastAPI health request every 30 seconds

VLAN 20 server:

10.0.20.50

Nginx endpoint:

http://10.0.20.50

FastAPI endpoint:

http://10.0.20.50:8000/api/health

### Useful commands

Start traffic generator manually:

/opt/lab-client/traffic-generator.sh

Check service:

systemctl status lab-client-traffic

Restart service:

sudo systemctl restart lab-client-traffic

Stop service:

sudo systemctl stop lab-client-traffic

Start service:

sudo systemctl start lab-client-traffic

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
- [x] systemd service
- [x] Client-specific traffic profile
- [x] Logrotate for traffic logs
- [ ] Log forwarding to the central log server
- [ ] Optional additional user traffic later

