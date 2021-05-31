# Copy zabbix agent file
New-Item -ItemType Directory -Path 'c:\program files\zabbix'
Copy-Item -Path \\nas-pub01\Userhome\mainad\administrator\zabbix-agent -Filter zabbix_* -Destination c:\program files\zabbix
Set-Location -Path c:\program files\zabbix

# change config file
$hostname = hostname
get-content zabbix_agentd.conf | %{_ -replace 'Hostname=devsrv-01', "Hostname=$hostname"}

# add zabbix agent to service
zabbix_agentd.exe --config .\zabbix_agentd.conf --install

# open inbound zabbix port (tcp/10050)
netsh advfirewall firewall add rule name='Zabbix-Agent' dir=in action=allow protocol=TCP localport=10050

start-service -name 'Zabbix Agent'