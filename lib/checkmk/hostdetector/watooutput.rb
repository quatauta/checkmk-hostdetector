# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK::HostDetector
  class WatoOutput
    # .wato:
    # {'attributes': {}, 'num_hosts': 0, 'title': u'HK01'}
    #
    # hosts.mk:
    # # encoding: utf-8
    #
    # all_hosts += [ "HK01R01|lan|prod|ping|hk01|brickbox|wato|/" + FOLDER_PATH + "/", ]
    # ipaddresses.update( { 'HK01R01': u'10.9.136.1' } )
    # host_attributes.update( {
    #     'HK01R01': {
    #         'ipaddress': u'10.9.136.1',
    #         'tag_agent': 'ping',
    #         'tag_criticality': 'prod',
    #         'tag_devicetype': 'brickbox',
    #         'tag_site': 'hk01',
    #         'tag_networking': 'lan',
    #     },
    # } )
    #
    # all_hosts += [ "HK01SDM00|profile|lan|windows|dell-t420|snmp|wsus|hk01|snmp-only|dns|dhcp|iperf|server-tr|netlogon|prod|snare|user-p|printserver|wato|/" + FOLDER_PATH + "/", ]
    # host_attributes.update( {
    #     'HK01SDM01': {
    #         'tag_agent':           'snmp-only',
    #         'tag_criticality':     'prod',
    #         'tag_devicemodel':     'dell-t420',
    #         'tag_devicetype':      'server-tr',
    #         'tag_dhcp':            'dhcp',
    #         'tag_dns':             'dns',
    #         'tag_empirumdepot':    'empirumdepot',
    #         'tag_iperf':           'iperf',
    #         'tag_site':            'hk01',
    #         'tag_netlogon':        'netlogon',
    #         'tag_networking':      'lan',
    #         'tag_operatingsystem': 'windows',
    #         'tag_printserver':     'printserver',
    #         'tag_profile':         'profile',
    #         'tag_snare':           'snare',
    #         'tag_snmp':            'snmp',
    #         'tag_user-p':          'user-p',
    #         'tag_wsus':            'wsus',
    #     },
    # } )

    basedir  = '/etc/checkmk/conf.d/wato'
    basedir  = '/opt/omd/%<omd_site>s/checkmk/conf.d/wato'
    sitefile = '%<site>s/detected/hosts.mk'

    def wato_dir(dirname, title)
      File.mkdir(dirname) unless File.exist? dirname

      wato_dir_filename = File.join(dirname, '.wato')
      unless File.exist? wato_dir_filename
        File.write(wato_dir_filename) do |file|
          file << "{'title': u'%<title>s'}" % { title: title }
        end
      end
    end

    def wato_host(host)
      'all_hosts += [ "%<name>s|%<tags>s|wato|/" + FOLDER_PATH + "/", ]' % {
        name: host.name,
        tags: [].join('|'),
      }

      if host.hostname.to_s.empty?
        'ipaddresses.update({ "%<name>s": u"%<ip>s" })' % {
          name: host.name,
          ip: host.ipaddress
        }
      end

      'host_attributes.update({ "%<name>s": { %<attribs>s } })' % {
        name: host.name,
        attribs: (host.tags.to_a + ['site', host.site.name]).map { |a|
          '"tag_%<tag>:": "%<value>s",' % {
            tag:   a[0],
            value: a[1],
          }
        }.sort.join('\n')
      }
    end
  end
end
