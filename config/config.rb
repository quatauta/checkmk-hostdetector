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
# name ip: '*.*.*.1', name: '%<site>sR01_%<ip_a>03d_%<ip_b>03d_%<ip_c>03d_%<ip_d>03d', ip_a: -3, ip_b: +4, ip_c: -100, ip_d: -30

# Device vendor/products
tag 'vendor',  'dell',      /poweredge|equallogic|eqlappliance/i
tag 'product', 'dell-r520', /poweredge.*r520/i
tag 'product', 'dell-r710', /poweredge.*r710/i
tag 'product', 'dell-t300', /poweredge.*t300/i
tag 'product', 'dell-t420', /poweredge.*t420/i
tag 'vendor',  'fsc',       /primergy/i
tag 'product', 'fsc-tx300', /primergy.*tx.*300/i

# Device vendor/product for VMware virtual machine with VMware MAC
tag 'vendor',  'vmware',    /vmware|esx|vsphere/i
tag 'product', 'vmware-vm', /mac.*00:50:56.*vmware/i

tag 'operatingsystem', 'linux',        /linux/i
tag 'operatingsystem', 'sco-openunix', /sco.*(open|unix)/i
tag 'operatingsystem', 'vmware-esx',   /vmware.*esx/i
tag 'operatingsystem', 'windows',      /windows/i

# Services of hosts based on nmap/snmpstatus output
tag 'backupexec-agent',  /10000.*(ndmp|backup.*exec|snet-sensor)/i
tag 'dhcp',              /dhcp/i
tag 'dns',               /53.*(dns|domain)/i
tag 'fileserver',        /13[789].*netbios/i
tag 'http',              /80.*http\b/i
tag 'https',             /443.*(https|ssl.*http)/i
tag 'iperf',             /5001.*iperf/i
tag 'iscsi',             /(860|3260).*iscsi/i
tag 'ldap',              /389.*ldap\b/i
tag 'ldaps',             /636.*(ldaps|ssl.*ldap)/i
tag 'mssql',             /1433.*ms-sql-s/i
tag 'mssql2005',         /sql.*server.*2005/i
tag 'mssql2008',         /sql.*server.*2008/i
tag 'mysql',             /3306.*mysql/i
tag 'officescan-client', /12345.*(netbus|officescan)/i
tag 'rdp',               /3389.*ms-wbt-server/i
tag 'rsync',             /873.*rsync/i
tag 'smtp',              /25.*smtp\b/i
tag 'smtps',             /465.*(smtps|ssl.*smtp)/i
tag 'ssh',               /22.*ssh/i

# Device classes/types
tag 'printer', /brother.*nc/i # u.a. Brother MFC-6490CW
tag 'printer', /canon.*mx/i
tag 'printer', /dlink.*print/i
tag 'printer', /hp.*ethernet/i # u.a. HP OfficeJet Pro 8600 N911a
tag 'printer', /jetdirect/i
tag 'printer', /konica.*minolta/i
tag 'printer', /kyocera/i
tag 'printer', /lexmark/i
tag 'switch' , /switch|superstack/i
