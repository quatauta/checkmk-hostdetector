# -*- coding: utf-8; -*-
# vim:set fileencoding=utf-8:

module CheckMK
  module HostDetector
    class WatoOutput

      basedir  = '/etc/checkmk/conf.d/wato'
      basedir  = '/opt/omd/%<omd_site>s/checkmk/conf.d/wato'
      sitefile = '%<site>s/detected/hosts.mk'

      # .wato:
      # {'attributes': {}, 'num_hosts': 0, 'title': u'HK01'}
      def mkdir(dirname, title)
        File.mkdir(dirname) unless File.exist? dirname

        wato_dir_filename = File.join(dirname, '.wato')
        unless File.exist? wato_dir_filename
          File.write(wato_dir_filename) do |file|
            file << "{ 'title': u'%<title>s' }" % { title: title }
          end
        end
      end

      def hosts_mk(hosts = [])
        text = '# encoding: utf-8' << "\n\n"

        hosts.each do |host|
          text << hosts_mk_host(host)
          text << "\n"
        end

        text
      end

      def hosts_mk_host(host)
        text = ''
        text << host_tags(host) << "\n"
        text << host_ipaddress(host) << "\n" if host.hostname.to_s.empty?
        text << host_attributes(host) << "\n"
        text
      end

      # all_hosts += [ "HK01R01|lan|prod|ping|hk01|brickbox|wato|/" + FOLDER_PATH + "/", ]
      # all_hosts += [ "HK01SDM00|profile|lan|windows|dell-t420|snmp|wsus|hk01|snmp-only|dns|dhcp|iperf|server-tr|netlogon|prod|snare|user-p|printserver|wato|/" + FOLDER_PATH + "/", ]
      def host_tags(host)
        'all_hosts += [ u"%<name>s|%<site>s|%<tags>s|wato|/" + FOLDER_PATH + "/" ]' % {
          name: host.name,
          site: host.site.name,
          tags: host.tags.to_h.values.join('|'),
        }
      end

      # ipaddresses.update( { 'HK01R01': u'10.9.136.1' } )
      def host_ipaddress(host)
        if host.hostname.to_s.empty?
          'ipaddresses.update({ "%<name>s": u"%<ip>s" })' % {
            name: host.name,
            ip:   host.ipaddress
          }
        end
      end

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
      def host_attributes(host)
        tags = host.tags.to_h
        tags[:site] = host.site.name

        attributes = {}
        attributes[:ipaddress] = host.ipaddress if host.hostname.to_s.empty?

        tags.each_pair do |tag, value|
          attributes['tag_%<tag>s' % { tag: tag }] = value
        end

        attributes = attributes.to_a.map { |ary|
          '"%<attribute>s:": u"%<value>s"' % { attribute: ary[0], value: ary[1], }
        }.sort.join(", ")

        'host_attributes.update({ "%<name>s": { %<attributes>s } })' % {
          name:       host.name,
          attributes: attributes,
        }
      end
    end
  end
end
