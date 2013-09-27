# -*- coding: UTF-8; -*-
# vim:set fileencoding=UTF-8:

config.jobs = 8

config.snmp_oids = %w[
  sysDescr
  sysObjectID
  MIB-Dell-CM::dell.10892.1.300.10.1.9
  SNMPv2-SMI::enterprises.231.2.10.2.2.5.10.3.1.4
]

config.names = [
  { ip: '10.9.*.1',    name: '%<location>sR01' },
  { ip: '10.190.*.1',  name: '%<location>sR11' },
  { ip: '10.190.*.16', name: '%<location>sR21' },

  { ip: '10.9.*.3[1-9]', ip_d: -30, location: '!tr11', name: '%<location>sS%<ip_d>02d' },

  { ip: '10.9.(112|113|114|115).3[1-9]', ip_d: -30, name: '%<location>sS%<ip_c>03d%<ip_d>02d' },

  { ip: '10.9.145.6',  location: 'tr11', name: '%<location>sS0K1' },
  { ip: '10.9.145.10', location: 'tr11', name: '%<location>sS101' },
  { ip: '10.9.145.11', location: 'tr11', name: '%<location>sS102' },
  { ip: '10.9.145.12', location: 'tr11', name: '%<location>sS111' },
  { ip: '10.9.145.13', location: 'tr11', name: '%<location>sS112' },
  { ip: '10.9.145.14', location: 'tr11', name: '%<location>sS121' },
  { ip: '10.9.145.15', location: 'tr11', name: '%<location>sS122' },
  { ip: '10.9.145.16', location: 'tr11', name: '%<location>sS131' },
  { ip: '10.9.145.17', location: 'tr11', name: '%<location>sS132' },
  { ip: '10.9.145.18', location: 'tr11', name: '%<location>sS141' },
  { ip: '10.9.145.19', location: 'tr11', name: '%<location>sS142' },
  { ip: '10.9.145.20', location: 'tr11', name: '%<location>sS151' },
  { ip: '10.9.145.21', location: 'tr11', name: '%<location>sS152' },
  { ip: '10.9.145.22', location: 'tr11', name: '%<location>sS161' },
  { ip: '10.9.145.23', location: 'tr11', name: '%<location>sS162' },
  { ip: '10.9.145.24', location: 'tr11', name: '%<location>sS311' },
  { ip: '10.9.145.25', location: 'tr11', name: '%<location>sS312' },

  { ip: '10.9.*.(23[0-9]|240)', ip_d: -229, name: '%<location>sTK%<ip_d>02d' },
]

config.models = [
  { value: 'vmware-vm',             regex: /mac.*00:50:56.*vmware/i },
  { value: '3com-3824',             regex: /3com.*switch.*3824/i },
  { value: '3com-4400',             regex: /3com.*switch.*4400/i },
  { value: '3com-4500',             regex: /3com.*switch.*4500/i },
  { value: '3com-5500g',            regex: /3com.*switch.*5500g/i },
  { value: 'canon-mx-850',          regex: /canon.*mx.*850/i },
  { value: 'dell-2900',             regex: /poweredge.*2900/i },
  { value: 'dell-r520',             regex: /poweredge.*r520/i },
  { value: 'dell-r710',             regex: /poweredge.*r710/i },
  { value: 'dell-t300',             regex: /poweredge.*t300/i },
  { value: 'dell-t420',             regex: /poweredge.*t420/i },
  { value: 'fsc-h250',              regex: /primergy.*h.*250/i },
  { value: 'fsc-tx300',             regex: /primergy.*tx.*300/i },
  { value: 'hipath-4000',           regex: /sco.*(open|unix)/i },
  { value: 'hp-a5120',              regex: /hp.*a5120.*switch/i },
  { value: 'hp-clj-3550',           regex: /hp.*color.*laserjet.*3550/i },
  { value: 'hp-clj-3600',           regex: /hp.*color.*laserjet.*3600/i },
  { value: 'hp-clj-4650',           regex: /hp.*color.*laserjet.*4650/i },
  { value: 'hp-clj-cp3525',         regex: /hp.*color.*laserjet.*cp3525/i },
  { value: 'koncia-magicolor-5450', regex: /konica.*5450/i },
  { value: 'konica-bizhub-222',     regex: /konica.*222/i },
  { value: 'lexmark-c734',          regex: /lexmark.*c734/i },
  { value: 'lexmark-c746',          regex: /lexmark.*c746/i },
  { value: 'lexmark-e460',          regex: /lexmark.*e460/i },
  { value: 'lexmark-t640',          regex: /lexmark.*t640/i },
  { value: 'lexmark-x463',          regex: /lexmark.*x463/i },
  { value: 'lexmark-x464',          regex: /lexmark.*x464/i },
]

config.operatingsystems = [
  { value: 'drac',       regex: /dell.*remote.*access|linux.*rb[cm]/i },
  { value: 'equallogic', regex: /equallogic|eqlappliance/i },
  { value: 'linux',      regex: /linux/i },
  { value: 'vmware-esx', regex: /vmware.*esx/i },
  { value: 'windows',    regex: /windows/i },
]

config.services = [
  { value: 'backupexecagent',  regex: /10000.*(ndmp|backup.*exec|snet-sensor)/i },
  { value: 'backupexecserver', regex: /[^t][^r][^1][^0]sdm00|tr10sdm12/i },
  { value: 'dhcp',             regex: /dhcp/i },
  { value: 'dns',              regex: /53.*(dns|domain)/i },
  { value: 'empirumdepot',     regex: /sdm00\b/i },
  { value: 'fileserver',       regex: /13[789].*netbios/i },
  { value: 'http',             regex: /80.*http\b/i },
  { value: 'https',            regex: /443.*(https|ssl.*http)/i },
  { value: 'iperf',            regex: /5001.*iperf/i },
  { value: 'iscsi',            regex: /(860|3260).*iscsi/i },
  { value: 'ldap',             regex: /389.*ldap\b/i },
  { value: 'ldaps',            regex: /636.*(ldaps|ssl.*ldap)/i },
  { value: 'mssql',            regex: /1433.*ms-sql-s/i },
  { value: 'mysql',            regex: /3306.*mysql/i },
  { value: 'mssql2005',        regex: /sql.*server.*2005/i },
  { value: 'mssql2008',        regex: /sql.*server.*2008/i },
  { value: 'netlogon',         regex: /sdm00\b/i },
  { value: 'officescanclient', regex: /12345.*(netbus|officescan)/i },
  { value: 'printserver',      regex: /sdm00\b/i },
  { value: 'profiles',         regex: /sdm00\b/i },
  { value: 'rdp',              regex: /3389.*ms-wbt-server/i },
  { value: 'rsync',            regex: /873.*rsync/i },
  { value: 'smtp',             regex: /25.*smtp\b/i },
  { value: 'smtps',            regex: /465.*(smtps|ssl.*smtp)/i },
  { value: 'ssh',              regex: /22.*ssh/i },
  { value: 'user-p',           regex: /sdm00\b/i },
  { value: 'wsus',             regex: /sdm00\b/i },
]

config.types = [
  { value: 'brickbox',     regex: /10.9\..*.1/i },
  { value: 'brickbox',     regex: /[a-z]{2}[0-9]{2}r[0-9]{2}/i },
  { value: 'drac',         regex: /[a-z]{2}[0-9]{2}rb[cmv][0-9]{2}/i },
  { value: 'printer',      regex: /brother.*nc/i }, # u.a. Brother MFC-6490CW
  { value: 'printer',      regex: /canon.*mx/i },
  { value: 'printer',      regex: /dlink.*print/i },
  { value: 'printer',      regex: /hp.*ethernet/i }, # u.a. HP OfficeJet Pro 8600 N911a
  { value: 'printer',      regex: /jetdirect/i },
  { value: 'printer',      regex: /konica.*minolta/i },
  { value: 'printer',      regex: /kyocera/i },
  { value: 'printer',      regex: /lexmark/i },
  { value: 'richtfunk',    regex: /airlaser|city.*link/i },
  { value: 'server-tr',    regex: /[a-z]{2}[0-9]{2}sdm/i },
  { value: 'server-tr',    regex: /[a-z]{2}[0-9]{2}srv/i },
  { value: 'server-tr',    regex: /[a-z]{2}[0-9]{2}sto/i },
  { value: 'server-tr',    regex: /[a-z]{2}[0-9]{2}svh/i },
  { value: 'server-zpt',   regex: /[a-z]{2}[0-9]{2}sdc/i },
  { value: 'switch',       regex: /switch|superstack/i },
  { value: 'tkanlage',     regex: /10.9\..*.(23[0-9]|240)/i },
  { value: 'tkanlage',     regex: /[a-z]{2}[0-9]{2}tk[0-9]{2}/i },
]
