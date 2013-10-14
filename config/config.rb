# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

# run four nmap/snmpstatus jobs in parallel
jobs 4

# SNMP community and OIDs
snmp_community 'public'
snmp_oid 'sysDescr'
snmp_oid 'sysObjectID'
snmp_oid 'MIB-Dell-CM::dell.10892.1.300.10.1.9'
snmp_oid 'SNMPv2-SMI::enterprises.231.2.10.2.2.5.10.3.1.4'

# Hostnames/IPs to exclude
# exclude_host /EXCLUDE_ME/i

# Names for Routes
# name ip: '*.*.*.1', name: '%<site>sR01'

# Device vendor/models
model value: 'dell-r520',             regex: /poweredge.*r520/i
model value: 'dell-r710',             regex: /poweredge.*r710/i
model value: 'dell-t300',             regex: /poweredge.*t300/i
model value: 'dell-t420',             regex: /poweredge.*t420/i
model value: 'fsc-tx300',             regex: /primergy.*tx.*300/i

# Device vendor/model for VMware virtual machine with VMware MAC
model value: 'vmware-vm',             regex: /mac.*00:50:56.*vmware/i

operatingsystem value: 'linux',        regex: /linux/i
operatingsystem value: 'sco-openunix', regex: /sco.*(open|unix)/i
operatingsystem value: 'vmware-esx',   regex: /vmware.*esx/i
operatingsystem value: 'windows',      regex: /windows/i

# Services of hosts based on nmap/snmpstatus output
service value: 'backupexecagent',  regex: /10000.*(ndmp|backup.*exec|snet-sensor)/i
service value: 'dhcp',             regex: /dhcp/i
service value: 'dns',              regex: /53.*(dns|domain)/i
service value: 'fileserver',       regex: /13[789].*netbios/i
service value: 'http',             regex: /80.*http\b/i
service value: 'https',            regex: /443.*(https|ssl.*http)/i
service value: 'iperf',            regex: /5001.*iperf/i
service value: 'iscsi',            regex: /(860|3260).*iscsi/i
service value: 'ldap',             regex: /389.*ldap\b/i
service value: 'ldaps',            regex: /636.*(ldaps|ssl.*ldap)/i
service value: 'mssql',            regex: /1433.*ms-sql-s/i
service value: 'mssql2005',        regex: /sql.*server.*2005/i
service value: 'mssql2008',        regex: /sql.*server.*2008/i
service value: 'mysql',            regex: /3306.*mysql/i
service value: 'officescanclient', regex: /12345.*(netbus|officescan)/i
service value: 'rdp',              regex: /3389.*ms-wbt-server/i
service value: 'rsync',            regex: /873.*rsync/i
service value: 'smtp',             regex: /25.*smtp\b/i
service value: 'smtps',            regex: /465.*(smtps|ssl.*smtp)/i
service value: 'ssh',              regex: /22.*ssh/i

# Device classes/types
type value: 'printer', regex: /brother.*nc/i # u.a. Brother MFC-6490CW
type value: 'printer', regex: /canon.*mx/i
type value: 'printer', regex: /dlink.*print/i
type value: 'printer', regex: /hp.*ethernet/i # u.a. HP OfficeJet Pro 8600 N911a
type value: 'printer', regex: /jetdirect/i
type value: 'printer', regex: /konica.*minolta/i
type value: 'printer', regex: /kyocera/i
type value: 'printer', regex: /lexmark/i
type value: 'switch',  regex: /switch|superstack/i
