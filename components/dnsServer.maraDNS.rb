#!/usr/bin/env jruby

require 'fileutils'

remoteRequire 'installerLogger'
remoteRequire 'networkHelper'
remoteRequire 'components/gnuBuild'
remoteRequire 'ioHelpers'
remoteRequire 'osHelpers'

class DnsServer < GnuBuild

  def initialize
    super
    @settings = COMPONENT_OPTIONS.dnsServer
  end
  
  def canBeInstalled?
    if @settings.osSpecific.nil?
      return true
    else
      desiredOS = @settings.osSpecific
      if desiredOS.downcase == OSHelpers.getSystemType
        return true
      else
        logger.warn("#{@settings.name} can only be installed on #{desiredOS}")
        return false
      end
    end
  end
  
  def alreadyInstalled?
    logger.debug("Component: #{@settings.name} : Checking for presence of file '/etc/mararc' . File #{File.exists?('/etc/mararc') ? 'is' : 'is not'} present so component #{File.exists?('/etc/mararc') ? 'is' : 'is not'} already installed.")
    return File.exists?('/etc/mararc')
  end
  
  def configureBuild
    # puts "Entering DnsServer.configureBuild"
    # caller[0,5].each do |callEntry|
    #   puts "DnsServer.configureBuild #{callEntry}"
    # end
    FileUtils.mkdir_p("#{@settings.buildInstallationDirectory}/sbin")
    executeWithErrorCheck do
      options = getOptions.dup
      options[:customConfigureBuildCommand] = "export PREFIX=#{@settings.buildInstallationDirectory}   ; ./configure"
      results = BuildHelper.configureBuild(@settings,options)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def make
    executeWithErrorCheck do
      options = getOptions.dup
      options[:customMakeCommand] = "export PREFIX=#{@settings.buildInstallationDirectory}   ; make"
      results = BuildHelper.make(@baseFileName,@settings,options)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def install
    executeWithErrorCheck do
      options = getOptions.dup
      options[:customMakeInstallCommand] = "export PREFIX=#{@settings.buildInstallationDirectory}   ; make install"
      results = BuildHelper.install(@baseFileName,@settings,options)
      @status = results[:retVal]
      { :status => @status, :errorMsg => results[:errorMsg] }
    end
  end
  
  def configure

    buildInstallationDir = @settings.buildInstallationDirectory
    ipAddress = nil
    primaryDomain = nil
    status = nil
    errorMsg = nil
    executeWithErrorCheck({:installCheck => false }) do
      begin
        if alreadyInstalled?
          if defined?(::DNS_PRIMARY_IP)
            ipAddress = ::DNS_PRIMARY_IP
          else
            ipAddress = NetworkHelper.getPrimaryIPAddress unless ipAddress
            # if ipAddress
            #   puts "DnsServer.configure ipAddress #{ipAddress}"
            # else
            #   puts "DnsServer.configure no IP address found"
            # end
            userIpAddress = IOHelpers.readKeyboardWithPrompt("#{@settings.name} : Enter Primary IP address (#{ipAddress})")
            if userIpAddress != ''
              ipAddress = userIpAddress
            end
          end
          if defined?(::DNS_PRIMARY_DOMAIN)
            primaryDomain = ::DNS_PRIMARY_DOMAIN
          else
            while primaryDomain.nil?
              primaryDomain = IOHelpers.readKeyboardWithPrompt("#{@settings.name} : Enter Primary domain")
              if primaryDomain == ''
                primaryDomain = nil
              end
            end
          end
          mararc = <<MARARC
#Automatically generated by CommonInstaller
ipv4_bind_addresses = "#{ipAddress}"
chroot_dir = "/etc/maradns"
csv2 = {}
csv2["#{primaryDomain}."] = "db.#{primaryDomain}"
MARARC

          domainZone = <<DOMAIN_ZONE
#Automatically generated by CommonInstaller
*.#{primaryDomain}. #{ipAddress} ~
DOMAIN_ZONE
          
          maradnsScript = <<MARADNS_SCRIPT
#!/bin/bash
# MaraDNS       This shell script takes care of starting and stopping MaraDNS
# chkconfig: - 55 45
# description: MaraDNS is secure Domain Name Server (DNS)
# probe: true

# Copyright 2005-2006 Sam Trenholme

# TERMS

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

# This software is provided 'as is' with no guarantees of correctness or
# fitness for purpose.

# This is a script which stops and starts the MaraDNS process
# The first line points to bash because I don't have a true Solaris /bin/sh
# to test this against.

# The following is a pointer to the MaraDNS program
if [ -x "#{buildInstallationDir}/sbin/maradns" ] ; then
        MARADNS="#{buildInstallationDir}/sbin/maradns"
elif [ -x "#{buildInstallationDir}/sbin/maradns.authonly" ] ; then
        MARADNS="#{buildInstallationDir}/sbin/maradns.authonly"
else
        echo unable to find maradns
        exit 1
fi

# The following is a pointer to the duende daemonizer
if [ -x "#{buildInstallationDir}/sbin/duende" ] ; then
        DUENDE="#{buildInstallationDir}/sbin/duende"
elif [ -x "#{buildInstallationDir}/bin/duende" ] ; then
        DUENDE="#{buildInstallationDir}/bin/duende"
else
        echo unable to find duende
        exit 1
fi

# The following is the directory we place MaraDNS log entries in
LOGDIR="/var/log"

# The following is a list of all mararc files which we will load or
# unload;
# Simple case: Only one MaraDNS process, using the /etc/mararc file
MARARCS="/etc/mararc"
# Case two: Three MaraDNS processes, one using /etc/mararc.1, the second one
# using /etc/mararc.2, and the third one using /etc/mararc.3
# (this is not as essential as it was in the 1.0 days; MaraDNS can now bind
#  to multiple IPs)
#MARARCS="/etc/mararc.1 /etc/mararc.2 /etc/mararc.3"

# Show usage information if this script is invoked with no arguments
if [ $# -lt 1 ] ; then
    echo Usage: $0  "(start\|stop\|restart)"
    exit 1
fi

# If invoked as stop or restart, kill *all* MaraDNS processes
if [ $1 = "stop" -o $1 = "restart" ] ; then
    echo Sending all MaraDNS processes the TERM signal
    ps -ef | awk '{print $2":"$8}' | grep maradns | grep -v $$ | \
      cut -f1 -d: | xargs kill > /dev/null 2>&1
    echo waiting 1 second
    sleep 1
    echo Sending all MaraDNS processes the KILL signal
    ps -e | awk '{print $1":"$NF}' | grep maradns | grep -v $$ | \
      cut -f1 -d: | xargs kill -9 > /dev/null 2>&1
    echo MaraDNS should have been stopped
    if [ $1 = "stop" ] ; then
        exit 0
    fi
fi

# If invoked as start or restart, start the MaraDNS processes
if [ $1 = "start" -o $1 = "restart" ] ; then
    echo Starting all maradns processes
    for a in $MARARCS ; do
        echo Starting maradns process which uses Mararc file $a
        # Duende syslogs MaraDNS' output messages and daemonizes MaraDNS
        $DUENDE $MARADNS -f $a
    done
    exit 0
fi
MARADNS_SCRIPT
      
      maradns_zonesserver = <<MARADNS_ZONESERVER
#!/bin/bash

# Copyright 2005-2006 Sam Trenholme

# TERMS

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

# This software is provided 'as is' with no guarantees of correctness or
# fitness for purpose.

# This is a script which stops and starts the MaraDNS zoneserver process
# The first line points to bash because I don't have a true Solaris /bin/sh
# to test this against.

# The following is a pointer to the MaraDNS program
if [ -x "#{buildInstallationDir}/sbin/zoneserver" ] ; then
        ZONESERVER="#{buildInstallationDir}/sbin/zoneserver"
else
        echo unable to find zoneserver
        exit 1
fi

# The following is a pointer to the duende daemonizer
if [ -x "#{buildInstallationDir}/sbin/duende" ] ; then
        DUENDE="#{buildInstallationDir}/sbin/duende"
elif [ -x "#{buildInstallationDir}/bin/duende" ] ; then
        DUENDE="#{buildInstallationDir}/bin/duende"
else
        echo unable to find duende
        exit 1
fi

# The following is the directory we place MaraDNS log entries in
LOGDIR="/var/log"

# The following is a list of all mararc files which we will load or
# unload;
# Simple case: Only one MaraDNS zoneserver process, using the /etc/mararc file
MARARCS="/etc/mararc"
# Case two: Three MaraDNS processes, one using /etc/mararc.1, the second one
# using /etc/mararc.2, and the third one using /etc/mararc.3
#MARARCS="/etc/mararc.1 /etc/mararc.2 /etc/mararc.3"

# Show usage information if this script is invoked with no arguments
if [ $# -lt 1 ] ; then
    echo Usage: $0 "(start\|stop\|restart)"
    exit 1
fi

# If invoked as stop or restart, kill *all* MaraDNS processes
if [ $1 = "stop" -o $1 = "restart" ] ; then
    echo Sending all MaraDNS processes the TERM signal
    ps -ef | awk '{print $2":"$8}' | grep zoneserver | grep -v $$ | \
      cut -f1 -d: | xargs kill > /dev/null 2>&1
    echo waiting 1 second
    sleep 1
    echo Sending all MaraDNS processes the KILL signal
    ps -e | awk '{print $1":"$NF}' | grep zoneserver | grep -v $$ | \
      cut -f1 -d: | xargs kill -9 > /dev/null 2>&1
    echo MaraDNS should have been stopped
fi

# If invoked as start or restart, start the MaraDNS processes
if [ $1 = "start" -o $1 = "restart" ] ; then
    echo Starting all zoneserver processes
    for a in $MARARCS ; do
        echo Starting zoneserver process which uses Mararc file $a
        # Duende syslogs MaraDNS' output messages and daemonizes MaraDNS
        $DUENDE $ZONESERVER -f $a
    done
fi
MARADNS_ZONESERVER
      
          IOHelpers.overwriteFile('/etc/mararc',mararc)
          IOHelpers.overwriteFile("/etc/maradns/db.#{primaryDomain}",domainZone)
          IOHelpers.overwriteFile('/etc/init.d/maradns',maradnsScript)
          FileUtils.chmod(0755,'/etc/init.d/maradns')
          IOHelpers.overwriteFile('/etc/init.d/maradns.zoneserver',maradns_zonesserver)
          FileUtils.chmod(0755,'/etc/init.d/maradns.zoneserver')
          
          logger.info(%{#{@settings.name} : Server has been configured successfully })
          status = SUCCESS
        end
      rescue Exception => ex
        status = FAILURE
        errorMsg = %{Unexpected error encountered while configuring #{@settings.name} \n #{ex.to_s} \n #{ex.backtrace.join("\n")}}
      end
      
      {:status => status , :errorMsg => errorMsg}
    end
  
  end

  def run
    status = nil
    errorMsg = nil
    executeWithErrorCheck({:installCheck => false }) do
      autoStart = false
      if defined?(::DNS_SERVER_AUTO_START)
        autostart = ::DNS_SERVER_AUTO_START
      end
      begin
        if autostart
          if OSHelpers.isCommmandPresent?('service')
            results = OSHelpers.executeCommand("service maradns restart")
            status = results[:status]
            if status == SUCCESS
              results = OSHelpers.executeCommand("service maradns.zoneserver restart")
              status = results[:status]
              if status == SUCCESS
                logger.info("#{@settings.name} : Successfully started services")
              else
                errorMsg = %{#{@settings.name} : Service 'maradns.zoneserver' failed to start}
              end
            else
              errorMsg = %{#{@settings.name} : Service 'maradns' failed to start}
            end
          else
            status = FAILURE
            errorMsg = %{#{@settings.name} : Failed to find command 'service'}
          end
        end
      rescue Exception => ex
        status = FAILURE
        errorMsg = %{Unexpected error encountered while running #{@settings.name} \n #{ex.to_s} \n #{ex.join.backtrace("\n")}}
      end
      if status == SUCCESS
        logger.info("Component #{@settings.name} successfully started")
      end
      {:status => status , :errorMsg => errorMsg}  
    end
  end
  
end
