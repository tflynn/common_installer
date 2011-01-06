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

  def alreadyInstalled?
    buildInstallationDirectory = @settings.buildInstallationDirectory
    componentInstalled = OSHelpers.isCommmandPresent?('named',{:dependencyPaths => ["#{buildInstallationDirectory}/bin", "#{buildInstallationDirectory}/sbin" ]})
    logger.debug("Component: #{@settings.name} : Checking for presence of command 'named'. Command 'named' #{componentInstalled ? 'is' : 'is not'} present so component #{componentInstalled ? 'is' : 'is not'} already installed.")
    return componentInstalled
  end

  def configureBuild
    executeWithErrorCheck do
      buildInstallationDirectory = @settings.buildInstallationDirectory
      openSSLBuildInstallationDirectory = COMPONENT_OPTIONS.openssl.buildInstallationDirectory
      cmd = %{./configure --prefix=#{buildInstallationDirectory} --with-openssl=#{openSSLBuildInstallationDirectory}}
      options = getOptions.merge({:customConfigureBuildCommand => cmd })
      results = BuildHelper.configureBuild(@settings,options)
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
          
          namedConf = <<NAMED_CONF_CONTENTS
options {
        directory "/var/named";
        dump-file "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
};          
logging {
 channel named_log{
  file "/var/log/named/named.log" versions 3 size 2m;
  severity info;
  print-severity yes;
  print-time yes;
  print-category yes;
 };
 category default{
  named_log;
 };
};
zone "*.#{primaryDomain}" IN {
        type master;
        file "#{primaryDomain}.zone";
        allow-update { none; };
};        
NAMED_CONF_CONTENTS

          
          #IOHelpers.overwriteFile('/etc/named.conf',namedConf)
          
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

end

