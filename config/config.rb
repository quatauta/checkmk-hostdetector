# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

# Acht NMAP/SNMP-Scanns gleichzeitig durchführen
jobs 8

# SNMP-OIDs, die für den SNMP-Status abgefragt werden sollen
snmp_oid 'sysDescr'
snmp_oid 'sysObjectID'
snmp_oid 'MIB-Dell-CM::dell.10892.1.300.10.1.9'
snmp_oid 'SNMPv2-SMI::enterprises.231.2.10.2.2.5.10.3.1.4'

# Hostnamen/IP-Adressen, die nicht betrachtet werden sollen
exclude_host /[a-z]{2}w[0-9]{4}/i
exclude_host /[a-z]{2}n[0-9]{4}/i
exclude_host /[a-z]{2}p[0-9]+/i

# Namen for Router, die nicht im DNS eingetragen sind
name ip: '10.9.*.1',    name: '%<site>sR01'
name ip: '10.190.*.1',  name: '%<site>sR11'
name ip: '10.190.*.16', name: '%<site>sR21'

# Name for Switche
name ip: '10.9.*.3[1-9]', ip_d: -30, name: '%<site>sS%<ip_d>02d'

# Name for Switche in TR01/TR10 mit /23-Subnetz
name ip: '10.9.(112|113|114|115).3[1-9]', ip_d: -30, name: '%<site>sS%<ip_c>03d%<ip_d>02d'

# Namen for Switche in TR11
name ip: '10.9.145.6',  site: 'tr11', name: '%<site>sS0K1'
name ip: '10.9.145.10', site: 'tr11', name: '%<site>sS101'
name ip: '10.9.145.11', site: 'tr11', name: '%<site>sS102'
name ip: '10.9.145.12', site: 'tr11', name: '%<site>sS111'
name ip: '10.9.145.13', site: 'tr11', name: '%<site>sS112'
name ip: '10.9.145.14', site: 'tr11', name: '%<site>sS121'
name ip: '10.9.145.15', site: 'tr11', name: '%<site>sS122'
name ip: '10.9.145.16', site: 'tr11', name: '%<site>sS131'
name ip: '10.9.145.17', site: 'tr11', name: '%<site>sS132'
name ip: '10.9.145.18', site: 'tr11', name: '%<site>sS141'
name ip: '10.9.145.19', site: 'tr11', name: '%<site>sS142'
name ip: '10.9.145.20', site: 'tr11', name: '%<site>sS151'
name ip: '10.9.145.21', site: 'tr11', name: '%<site>sS152'
name ip: '10.9.145.22', site: 'tr11', name: '%<site>sS161'
name ip: '10.9.145.23', site: 'tr11', name: '%<site>sS162'
name ip: '10.9.145.24', site: 'tr11', name: '%<site>sS311'
name ip: '10.9.145.25', site: 'tr11', name: '%<site>sS312'

# Namen für Geräte der TK-Anlagen
name ip: '10.9.*.(23[0-9]|240)', ip_d: -229, name: '%<site>sTK%<ip_d>02d'

# Gerätemodelle Switche
model value: '3com-3824',             regex: /3com.*switch.*3824/i
model value: '3com-4400',             regex: /3com.*switch.*4400/i
model value: '3com-4500',             regex: /3com.*switch.*4500/i
model value: '3com-5500g',            regex: /3com.*switch.*5500g/i
model value: 'hp-a5120',              regex: /hp.*a5120.*switch/i

# Gerätemodelle Server
model value: 'dell-2900',             regex: /poweredge.*2900/i
model value: 'dell-r520',             regex: /poweredge.*r520/i
model value: 'dell-r710',             regex: /poweredge.*r710/i
model value: 'dell-t300',             regex: /poweredge.*t300/i
model value: 'dell-t420',             regex: /poweredge.*t420/i
model value: 'fsc-h250',              regex: /primergy.*h.*250/i
model value: 'fsc-tx300',             regex: /primergy.*tx.*300/i

# Gerätemodell für virtuelle Maschine mit VMware MAC-Adresse
model value: 'vmware-vm',             regex: /mac.*00:50:56.*vmware/i

# Gerätemodell für Telefonanlagen
model value: 'hipath-4000',           regex: /sco.*(open|unix)/i

# Gerätemodelle für Drucker
model value: 'canon-mx-850',          regex: /canon.*mx.*850/i
model value: 'hp-clj-3550',           regex: /hp.*color.*laserjet.*3550/i
model value: 'hp-clj-3600',           regex: /hp.*color.*laserjet.*3600/i
model value: 'hp-clj-4650',           regex: /hp.*color.*laserjet.*4650/i
model value: 'hp-clj-cp3525',         regex: /hp.*color.*laserjet.*cp3525/i
model value: 'koncia-magicolor-5450', regex: /konica.*5450/i
model value: 'konica-bizhub-222',     regex: /konica.*222/i
model value: 'lexmark-c734',          regex: /lexmark.*c734/i
model value: 'lexmark-c746',          regex: /lexmark.*c746/i
model value: 'lexmark-e460',          regex: /lexmark.*e460/i
model value: 'lexmark-t640',          regex: /lexmark.*t640/i
model value: 'lexmark-x463',          regex: /lexmark.*x463/i
model value: 'lexmark-x464',          regex: /lexmark.*x464/i

# Betriebssysteme
operatingsystem value: 'drac',         regex: /dell.*remote.*access|linux.*rb[cm]/i
operatingsystem value: 'equallogic',   regex: /equallogic|eqlappliance/i
operatingsystem value: 'linux',        regex: /linux/i
operatingsystem value: 'sco-openunix', regex: /sco.*(open|unix)/i
operatingsystem value: 'vmware-esx',   regex: /vmware.*esx/i
operatingsystem value: 'windows',      regex: /windows/i

# Dienste von Hosts anhand NMAP/SNMP-Ausgabe
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

# Dienste von Hosts anhand des Namens
service value: 'backupexecserver', regex: /([^t][^r][^1][^0]sdm00|tr10sdm12)\b/i
service value: 'empirumdepot',     regex: /sdm00\b/i
service value: 'netlogon',         regex: /sdm00\b/i
service value: 'printserver',      regex: /sdm00\b/i
service value: 'profiles',         regex: /sdm00\b/i
service value: 'user-p',           regex: /sdm00\b/i
service value: 'wsus',             regex: /sdm00\b/i

# Geräteklassen/-typen
type value: 'brickbox',   regex: /10.9\..*.1/i
type value: 'brickbox',   regex: /[a-z]{2}[0-9]{2}r[0-9]{2}/i
type value: 'drac',       regex: /[a-z]{2}[0-9]{2}rb[cmv][0-9]{2}/i
type value: 'printer',    regex: /brother.*nc/i # u.a. Brother MFC-6490CW
type value: 'printer',    regex: /canon.*mx/i
type value: 'printer',    regex: /dlink.*print/i
type value: 'printer',    regex: /hp.*ethernet/i # u.a. HP OfficeJet Pro 8600 N911a
type value: 'printer',    regex: /jetdirect/i
type value: 'printer',    regex: /konica.*minolta/i
type value: 'printer',    regex: /kyocera/i
type value: 'printer',    regex: /lexmark/i
type value: 'richtfunk',  regex: /airlaser|city.*link/i
type value: 'server-tr',  regex: /[a-z]{2}[0-9]{2}sdm/i
type value: 'server-tr',  regex: /[a-z]{2}[0-9]{2}srv/i
type value: 'server-tr',  regex: /[a-z]{2}[0-9]{2}sto/i
type value: 'server-tr',  regex: /[a-z]{2}[0-9]{2}svh/i
type value: 'server-zpt', regex: /[a-z]{2}[0-9]{2}sdc/i
type value: 'switch',     regex: /switch|superstack/i
type value: 'tkanlage',   regex: /10.9\..*.(23[0-9]|240)/i
type value: 'tkanlage',   regex: /[a-z]{2}[0-9]{2}tk[0-9]{2}/i
